#!/bin/bash
# Claude Code Status Line (Bash)
# Inspired by github.com/gabriel-dehan/claude_monitor_statusline
#
# Displays: directory · git branch · model · tokens used · messages · time until reset
#
# Environment Variables:
#   CLAUDE_STATUS_DISPLAY_MODE - colors (default), minimal, or background
#   CLAUDE_STATUS_PLAN         - pro, max5 (default), max20
#   CLAUDE_STATUS_INFO_MODE    - none (default), emoji, or text

command -v jq &>/dev/null || { echo "Please install jq dependency for correct statusline display"; exit 0; }

input=$(cat)

# --- Configuration ---
DISPLAY_MODE="${CLAUDE_STATUS_DISPLAY_MODE:-colors}"
INFO_MODE="${CLAUDE_STATUS_INFO_MODE:-none}"
PLAN="${CLAUDE_STATUS_PLAN:-${CLAUDE_PLAN:-${CLAUDE_CODE_PLAN:-max5}}}"
SESSION_HOURS=5

# --- Parse input JSON ---
CURRENT_DIR=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')
MODEL_NAME=$(echo "$input" | jq -r '.model.display_name // empty')
DIR_NAME=""
[[ -n "$CURRENT_DIR" ]] && DIR_NAME=$(basename "$CURRENT_DIR")

# --- Plan limits ---
case "$PLAN" in
  pro)   TOKEN_LIMIT=19000;  MSG_LIMIT=250 ;;
  max20) TOKEN_LIMIT=220000; MSG_LIMIT=2000 ;;
  *)     TOKEN_LIMIT=88000;  MSG_LIMIT=1000 ;; # max5 / max
esac

# --- Color schemes ---
case "$DISPLAY_MODE" in
  minimal)
    C_DIR='\033[38;5;250m'; C_MODEL='\033[38;5;248m'; C_TOKENS='\033[38;5;248m'
    C_MSGS='\033[38;5;248m'; C_TIME='\033[38;5;248m'
    C_GIT_OK='\033[38;5;248m'; C_GIT_DIRTY='\033[38;5;248m'
    C_GRAY='\033[90m'; C_RESET='\033[0m'
    ;;
  background)
    C_DIR='\033[44m\033[37m'; C_MODEL='\033[45m\033[37m'; C_TOKENS='\033[46m\033[30m'
    C_MSGS='\033[42m\033[30m'; C_TIME='\033[43m\033[30m'
    C_GIT_OK='\033[42m\033[37m'; C_GIT_DIRTY='\033[43m\033[37m'
    C_GRAY='\033[90m'; C_RESET='\033[0m'
    ;;
  *) # colors (default)
    C_DIR='\033[38;5;51m'; C_MODEL='\033[38;5;105m'; C_TOKENS='\033[38;5;141m'
    C_MSGS='\033[38;5;147m'; C_TIME='\033[38;5;220m'
    C_GIT_OK='\033[38;5;154m'; C_GIT_DIRTY='\033[38;5;222m'
    C_GRAY='\033[90m'; C_RESET='\033[0m'
    ;;
esac

# --- Helpers ---
colorize() { printf '%b%s%b' "$1" "$2" "$C_RESET"; }

format_with_info() {
  local text="$1" color="$2" type="$3"
  local pad=""
  [[ "$DISPLAY_MODE" == "background" ]] && pad=" "

  case "$INFO_MODE" in
    emoji)
      local emoji=""
      case "$type" in
        dir) emoji="📁" ;; git) emoji="🔀" ;; model) emoji="🦾" ;;
        tokens) emoji="📓" ;; msgs) emoji="✏️" ;; time) emoji="⏱️" ;;
      esac
      colorize "$color" "${pad}${emoji} ${text}${pad}"
      ;;
    text)
      local suffix=""
      case "$type" in
        *) ;;
      esac
      colorize "$color" "${pad}${text}${suffix}${pad}"
      ;;
    *)
      colorize "$color" "${pad}${text}${pad}"
      ;;
  esac
}

format_count() {
  local current=$1 limit=$2
  local cur_display lim_display
  if (( current >= 10000 )); then
    cur_display=$(awk "BEGIN { printf \"%.1fk\", $current / 1000.0 }")
  else
    cur_display="$current"
  fi
  if (( limit >= 1000 )); then
    lim_display="$((limit / 1000))k"
  else
    lim_display="$limit"
  fi
  echo "${cur_display}/${lim_display}"
}

# --- Git info ---
get_git_info() {
  [[ -z "$CURRENT_DIR" || ! -d "$CURRENT_DIR/.git" ]] && return 1

  local branch indicators=""
  branch=$(git -C "$CURRENT_DIR" rev-parse --abbrev-ref HEAD 2>/dev/null) || return 1
  [[ -z "$branch" ]] && return 1

  local status
  status=$(git -C "$CURRENT_DIR" status --porcelain 2>/dev/null) || true
  echo "$status" | grep -q '^??' 2>/dev/null && indicators+="?"
  echo "$status" | grep -qE '^[AM]' 2>/dev/null && indicators+="+"
  echo "$status" | grep -qE '^.[MD]' 2>/dev/null && indicators+="!"

  local ab
  ab=$(git -C "$CURRENT_DIR" rev-list --left-right --count "origin/${branch}...${branch}" 2>/dev/null) || true
  if [[ "$ab" =~ ^([0-9]+)[[:space:]]+([0-9]+)$ ]]; then
    (( BASH_REMATCH[2] > 0 )) && indicators+="↑${BASH_REMATCH[2]}"
    (( BASH_REMATCH[1] > 0 )) && indicators+="↓${BASH_REMATCH[1]}"
  fi

  echo " ${branch}${indicators}"
}

# --- Usage calculation from JSONL files ---
calculate_usage() {
  local project_dir="$HOME/.claude/projects"
  local default_reset=$((SESSION_HOURS * 3600))

  if [[ ! -d "$project_dir" ]]; then
    echo "0 0 $default_reset"
    return
  fi

  # Find JSONL files modified in the last 4 days, validate with first jq pass,
  # then process everything (filter, dedup, session blocks) in a single jq -s pass.
  local result
  result=$(find "$project_dir" -name "*.jsonl" -type f -mtime -4 -exec cat {} + 2>/dev/null \
    | jq -c '.' 2>/dev/null \
    | jq -s --argjson sh "$SESSION_HOURS" '
      now as $now |
      ($now - 96 * 3600) as $cutoff |

      # Parse entries: extract epoch, tokens, dedup key; filter by cutoff
      [.[] |
        select(.timestamp != null) |
        (try (.timestamp | sub("\\.[0-9]+"; "") | fromdateiso8601) catch null) as $epoch |
        select($epoch != null and $epoch >= $cutoff) |

        ((.message.usage // .usage // .) as $s |
          (($s.input_tokens // $s.inputTokens // $s.prompt_tokens // 0) +
           ($s.output_tokens // $s.outputTokens // $s.completion_tokens // 0))
        ) as $tok |
        select($tok > 0) |

        {
          e: $epoch,
          t: $tok,
          d: (((.message_id // .message.id // "") | tostring) + ":" +
              ((.requestId // .request_id // "") | tostring))
        }
      ] |

      # Deduplicate by message_id:request_id
      group_by(.d) | [.[] | if .[0].d == ":" then .[] else .[0] end] |
      sort_by(.e) |

      # Group into 5-hour session blocks (matching Ruby logic)
      reduce .[] as $x (
        {blocks: [], cur: null};
        if .cur == null or
           $x.e >= .cur.end or
           (.cur.last != null and ($x.e - .cur.last) >= ($sh * 3600))
        then
          ($x.e - ($x.e % 3600)) as $s |
          {
            blocks: (if .cur then .blocks + [.cur] else .blocks end),
            cur: {start: $s, end: ($s + $sh * 3600), tok: $x.t, msg: 1, first: $x.e, last: $x.e}
          }
        else
          if $x.e >= .cur.start and $x.e < .cur.end then
            .cur.tok += $x.t | .cur.msg += 1 | .cur.last = $x.e
          else . end
        end
      ) |

      # Collect all blocks
      (if .cur then .blocks + [.cur] else .blocks end) as $all |

      # Find active block (end_time > now), fallback to most recent
      $now as $n |
      ([$all[] | select(.end > $n)] | .[0]) as $active |
      (if $active then $active
       else ($all | sort_by(.last) | last)
       end) as $blk |

      if $blk then
        ([($blk.end - $n), 0] | max) as $secs |
        "\($blk.tok) \($blk.msg) \($secs | floor)"
      else
        "0 0 \($sh * 3600)"
      end
    ' 2>/dev/null)

  if [[ -z "$result" || "$result" == "null" ]]; then
    echo "0 0 $default_reset"
  else
    echo "$result" | tr -d '"'
  fi
}

# --- Build output ---
build_output() {
  local parts=()

  # Directory
  if [[ -n "$DIR_NAME" ]]; then
    if [[ "$DISPLAY_MODE" == "background" ]]; then
      parts+=("$(format_with_info " ${DIR_NAME} " "$C_DIR" "dir")")
    else
      parts+=("$(format_with_info "${DIR_NAME}/" "$C_DIR" "dir")")
    fi
  fi

  # Git branch + status
  local git_str
  git_str=$(get_git_info 2>/dev/null) || true
  if [[ -n "$git_str" ]]; then
    local git_color="$C_GIT_OK"
    [[ "$git_str" =~ [?+!↑↓] ]] && git_color="$C_GIT_DIRTY"
    if [[ "$INFO_MODE" == "emoji" ]]; then
      local pad=""
      [[ "$DISPLAY_MODE" == "background" ]] && pad=" "
      parts+=("$(colorize "$git_color" "${pad}🔀 ${git_str}${pad}")")
    else
      local pad=""
      [[ "$DISPLAY_MODE" == "background" ]] && pad=" "
      parts+=("$(colorize "$git_color" "${pad}${git_str}${pad}")")
    fi
  fi

  # Model
  if [[ -n "$MODEL_NAME" ]]; then
    parts+=("$(format_with_info "$MODEL_NAME" "$C_MODEL" "model")")
  fi

  # Usage (tokens, messages, reset timer)
  local usage_raw
  usage_raw=$(calculate_usage)
  local total_tokens msg_count reset_secs
  read -r total_tokens msg_count reset_secs <<< "$usage_raw"

  local token_str msg_str time_str
  local token_pct=$((total_tokens * 100 / TOKEN_LIMIT))
  local msg_pct=$((msg_count * 100 / MSG_LIMIT))
  token_str="${token_pct}% token usage ($(format_count "$total_tokens" "$TOKEN_LIMIT"))"
  msg_str="${msg_pct}% message usage (${msg_count}/${MSG_LIMIT})"
  local hours=$((reset_secs / 3600))
  local mins=$(( (reset_secs % 3600) / 60 ))
  time_str="${hours}h${mins}m before reset"

  parts+=("$(format_with_info "$token_str" "$C_TOKENS" "tokens")")
  parts+=("$(format_with_info "$msg_str" "$C_MSGS" "msgs")")
  parts+=("$(format_with_info "$time_str" "$C_TIME" "time")")

  # Join parts with separator
  local sep
  if [[ "$DISPLAY_MODE" == "background" ]]; then
    sep=" "
  else
    sep=" $(printf '%b' "$C_GRAY")·$(printf '%b' "$C_RESET") "
  fi

  local output=""
  for i in "${!parts[@]}"; do
    (( i > 0 )) && output+="$sep"
    output+="${parts[$i]}"
  done

  echo "$output"
}

build_output