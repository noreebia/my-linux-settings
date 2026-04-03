#!/bin/bash
# Claude Code Status Line (Bash) — Improved
# Based on default.sh with fixes for accurate token/message counting
#
# Displays: directory · git branch · model · tokens used · messages · time until reset
#
# Fixes over default.sh:
#   - Counts token types with configurable mode (standard/all/minimal)
#   - Scopes to current project directory only (no cross-project bleeding)
#   - Excludes subagent JSONL files (avoids double-counting)
#   - Takes last entry per message ID (gets cumulative totals, not streaming chunks)
#   - Filters to assistant entries only (other types don't carry usage data)
#
# Environment Variables:
#   CLAUDE_STATUS_DISPLAY_MODE - colors (default), minimal, or background
#   CLAUDE_STATUS_PLAN         - pro, max5 (default), max20
#   CLAUDE_STATUS_INFO_MODE    - none (default), emoji, or text
#   CLAUDE_STATUS_TOKEN_MODE   - output (default), standard, all, or minimal

command -v jq &>/dev/null || { echo "Please install jq dependency for correct statusline display"; exit 0; }

input=$(cat)

# --- Configuration ---
DISPLAY_MODE="${CLAUDE_STATUS_DISPLAY_MODE:-colors}"
INFO_MODE="${CLAUDE_STATUS_INFO_MODE:-none}"
PLAN="${CLAUDE_STATUS_PLAN:-${CLAUDE_PLAN:-${CLAUDE_CODE_PLAN:-max5}}}"
TOKEN_MODE="${CLAUDE_STATUS_TOKEN_MODE:-output}"
SESSION_HOURS=5

# --- Parse input JSON ---
CURRENT_DIR=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')
MODEL_NAME=$(echo "$input" | jq -r '.model.display_name // empty')
DIR_NAME=""
[[ -n "$CURRENT_DIR" ]] && DIR_NAME=$(basename "$CURRENT_DIR")

# --- Plan limits ---
# Token limits vary by TOKEN_MODE. "output" limits are calibrated against /usage.
# Other modes use legacy limits from the original script.
if [[ "$TOKEN_MODE" == "output" ]]; then
  case "$PLAN" in
    pro)   TOKEN_LIMIT=45000;   MSG_LIMIT=250 ;;
    max20) TOKEN_LIMIT=900000;  MSG_LIMIT=2000 ;;
    *)     TOKEN_LIMIT=200000;  MSG_LIMIT=1000 ;; # max5 / max
  esac
else
  case "$PLAN" in
    pro)   TOKEN_LIMIT=19000;  MSG_LIMIT=250 ;;
    max20) TOKEN_LIMIT=220000; MSG_LIMIT=2000 ;;
    *)     TOKEN_LIMIT=88000;  MSG_LIMIT=1000 ;; # max5 / max
  esac
fi

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
      colorize "$color" "${pad}${text}${pad}"
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
  local default_reset=$((SESSION_HOURS * 3600))

  # Scope to current project directory only
  # Claude Code converts workspace paths to dir names by replacing non-alphanumeric
  # chars (except -) with dashes: /home/user/code_linux -> -home-user-code-linux
  local project_subdir
  if [[ -n "$CURRENT_DIR" ]]; then
    project_subdir=$(echo "$CURRENT_DIR" | sed 's|[^a-zA-Z0-9-]|-|g')
  fi

  local project_path="$HOME/.claude/projects/${project_subdir}"
  if [[ -z "$project_subdir" || ! -d "$project_path" ]]; then
    echo "0 0 $default_reset"
    return
  fi

  # Find JSONL files in the current project only, excluding subagent files
  local result
  result=$(find "$project_path" -maxdepth 1 -name "*.jsonl" -type f -mtime -4 2>/dev/null \
    | while IFS= read -r f; do cat "$f"; done 2>/dev/null \
    | jq -c 'select(.type == "assistant" and .message.usage != null)' 2>/dev/null \
    | jq -s --argjson sh "$SESSION_HOURS" --arg token_mode "$TOKEN_MODE" '
      now as $now |
      ($now - ($sh * 3600)) as $window_start |

      # Parse entries: extract epoch and full token count
      [.[] |
        (try (.timestamp | sub("\\.[0-9]+"; "") | fromdateiso8601) catch null) as $epoch |
        select($epoch != null and $epoch >= $window_start) |

        .message.usage as $u |

        # Token counting mode (set via CLAUDE_STATUS_TOKEN_MODE):
        #   "output" (default): output tokens only -- closest match to /usage
        #   "standard":         input + cache_creation + output
        #   "all":              input + cache_creation + cache_read + output
        #   "minimal":          input + output only
        (if $token_mode == "output" then
          ($u.output_tokens // 0)
        elif $token_mode == "all" then
          ($u.input_tokens // 0) + ($u.cache_creation_input_tokens // 0) +
          ($u.cache_read_input_tokens // 0) + ($u.output_tokens // 0)
        elif $token_mode == "standard" then
          ($u.input_tokens // 0) + ($u.cache_creation_input_tokens // 0) +
          ($u.output_tokens // 0)
        else
          ($u.input_tokens // 0) + ($u.output_tokens // 0)
        end) as $tok |
        select($tok > 0) |

        # Dedup key: message id + request id
        ((.message.id // "") | tostring) as $mid |
        ((.requestId // .request_id // "") | tostring) as $rid |

        {
          e: $epoch,
          t: $tok,
          d: ($mid + ":" + $rid)
        }
      ] |

      # Deduplicate: take the LAST entry per key (has cumulative streaming totals)
      group_by(.d) |
      [.[] |
        if .[0].d == ":"
        then .[]  # no dedup key — keep all
        else sort_by(.t) | last  # take entry with highest token count
        end
      ] |
      sort_by(.e) |

      # Count unique messages (each group = 1 logical message turn)
      length as $msg_count |

      # Sum tokens
      (map(.t) | add // 0) as $total_tokens |

      # Reset timer: find the earliest entry in this window
      (if length > 0 then
        (.[0].e + ($sh * 3600) - $now) | if . < 0 then 0 else . end
      else
        $sh * 3600
      end) as $reset_secs |

      "\($total_tokens) \($msg_count) \($reset_secs | floor)"
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
