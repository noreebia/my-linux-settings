#!/bin/bash
# Claude Code Status Line (Bash) — v3
# Based on default-v2.sh, augmented with ideas ported from the wider ecosystem:
#   - ccstatusline (sirmalloc):     configurable "widget" registry + context bar
#   - claude-powerline (Owloops):   context auto-compact threshold + cost segment
#   - official Claude Code docs:     native context_window/cost JSON fields, git caching keyed by session_id
#
# What's new over v2:
#   - CONTEXT WINDOW segment (the headline gap in v2): colored bar + % from the
#     native context_window.used_percentage field — accurate and free, no JSONL math.
#   - COST segment from native cost.total_cost_usd.
#   - LINES segment from native cost.total_lines_added/removed.
#   - DURATION segment from native cost.total_duration_ms.
#   - STYLE segment showing the active output style when it isn't "default".
#   - Configurable segment registry: CLAUDE_STATUS_SEGMENTS picks which segments
#     show and in what order; a literal "|" splits them onto multiple lines.
#   - Git state cached per session_id (TTL configurable) — git is the slow part of
#     every refresh tick; the docs explicitly warn against pid-based cache keys.
#   - All native JSON fields parsed in a single jq pass (v2 called jq twice up front).
#
# v3 keeps every v2 strength: the 5-hour rate-limit window (tokens/messages/reset),
# parsed from project JSONL files, is conversation-independent and not in the JSON
# payload, so it stays. Context % (this conversation) and the 5h window (your plan's
# rolling quota) answer different questions; v3 shows both.
#
# Displays (default): dir · git · model · context · tokens · msgs · reset
# (the "cost" segment exists but is OFF by default — see CLAUDE_STATUS_SEGMENTS
#  to re-enable it; intentionally hidden so a subscription user isn't nudged by a
#  per-session dollar figure that doesn't reflect their actual billing.)
#
# Environment Variables:
#   CLAUDE_STATUS_DISPLAY_MODE - colors (default), minimal, or background
#   CLAUDE_STATUS_PLAN         - pro, max5 (default), max20
#   CLAUDE_STATUS_INFO_MODE    - none (default), emoji, or text
#   CLAUDE_STATUS_TOKEN_MODE   - output (default), standard, all, or minimal
#   CLAUDE_STATUS_SEGMENTS     - comma-separated, ordered segment list. Use "|" to
#                                split across lines. Available segments:
#                                  dir git model context cost lines duration
#                                  tokens msgs reset style version
#                                Default: "dir,git,model,context,tokens,msgs,reset"
#                                (add "cost" to this list to show $/session)
#   CLAUDE_STATUS_GIT_CACHE_TTL- seconds to cache git state per session (default 2)

command -v jq &>/dev/null || { echo "Please install jq dependency for correct statusline display"; exit 0; }

input=$(cat)

# --- Configuration ---
DISPLAY_MODE="${CLAUDE_STATUS_DISPLAY_MODE:-colors}"
INFO_MODE="${CLAUDE_STATUS_INFO_MODE:-none}"
PLAN="${CLAUDE_STATUS_PLAN:-${CLAUDE_PLAN:-${CLAUDE_CODE_PLAN:-max5}}}"
TOKEN_MODE="${CLAUDE_STATUS_TOKEN_MODE:-output}"
SEGMENTS="${CLAUDE_STATUS_SEGMENTS:-dir,git,model,context,tokens,msgs,reset}"
GIT_CACHE_TTL="${CLAUDE_STATUS_GIT_CACHE_TTL:-2}"
SESSION_HOURS=5

# --- Parse native JSON input (single jq pass) ---
# Fields are joined with the ASCII Unit Separator (<US>, $'\037') rather than a
# tab. read treats tab/space/newline as whitespace-class IFS, which COLLAPSES
# consecutive empty fields (e.g. a missing output_style + version) and shifts every
# later value — so session_id would silently land in the wrong variable. A
# non-whitespace separator preserves empty fields positionally, and <US> can't
# appear in any real path/model/style value.
IFS=$'\037' read -r CURRENT_DIR MODEL_NAME COST_USD LINES_ADDED LINES_REMOVED \
  DURATION_MS CTX_PCT CTX_SIZE CTX_IN CTX_OUT EXCEEDS_200K OUTPUT_STYLE \
  CC_VERSION SESSION_ID < <(echo "$input" | jq -r '
    [ (.workspace.current_dir // .cwd // "")
    , (.model.display_name // "")
    , (.cost.total_cost_usd // 0)
    , (.cost.total_lines_added // 0)
    , (.cost.total_lines_removed // 0)
    , (.cost.total_duration_ms // 0)
    , (.context_window.used_percentage // 0 | floor)
    , (.context_window.context_window_size // 0)
    , (.context_window.total_input_tokens // 0)
    , (.context_window.total_output_tokens // 0)
    , (.exceeds_200k_tokens // false)
    , (.output_style.name // "")
    , (.version // "")
    , (.session_id // "")
    ] | map(tostring) | join("\u001f")')

DIR_NAME=""
[[ -n "$CURRENT_DIR" ]] && DIR_NAME=$(basename "$CURRENT_DIR")

# --- Plan limits (for the 5-hour rate-limit window) ---
# Token limits vary by TOKEN_MODE. "output" limits are calibrated against /usage.
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
    C_MSGS='\033[38;5;248m'; C_TIME='\033[38;5;248m'; C_CONTEXT='\033[38;5;248m'
    C_COST='\033[38;5;248m'; C_LINES='\033[38;5;248m'; C_DURATION='\033[38;5;248m'
    C_STYLE='\033[38;5;248m'; C_VERSION='\033[38;5;248m'
    C_GIT_OK='\033[38;5;248m'; C_GIT_DIRTY='\033[38;5;248m'
    C_WARN='\033[38;5;248m'; C_OK='\033[38;5;248m'
    C_GRAY='\033[90m'; C_RESET='\033[0m'
    ;;
  background)
    C_DIR='\033[44m\033[37m'; C_MODEL='\033[45m\033[37m'; C_TOKENS='\033[46m\033[30m'
    C_MSGS='\033[42m\033[30m'; C_TIME='\033[43m\033[30m'; C_CONTEXT='\033[48;5;55m\033[37m'
    C_COST='\033[48;5;22m\033[37m'; C_LINES='\033[48;5;238m\033[37m'; C_DURATION='\033[43m\033[30m'
    C_STYLE='\033[48;5;53m\033[37m'; C_VERSION='\033[100m\033[37m'
    C_GIT_OK='\033[42m\033[37m'; C_GIT_DIRTY='\033[43m\033[37m'
    C_WARN='\033[41m\033[37m'; C_OK='\033[42m\033[37m'
    C_GRAY='\033[90m'; C_RESET='\033[0m'
    ;;
  *) # colors (default)
    C_DIR='\033[38;5;51m'; C_MODEL='\033[38;5;105m'; C_TOKENS='\033[38;5;141m'
    C_MSGS='\033[38;5;147m'; C_TIME='\033[38;5;220m'; C_CONTEXT='\033[38;5;75m'
    C_COST='\033[38;5;114m'; C_LINES='\033[38;5;245m'; C_DURATION='\033[38;5;180m'
    C_STYLE='\033[38;5;177m'; C_VERSION='\033[38;5;240m'
    C_GIT_OK='\033[38;5;154m'; C_GIT_DIRTY='\033[38;5;222m'
    C_WARN='\033[38;5;203m'; C_OK='\033[38;5;114m'
    C_GRAY='\033[90m'; C_RESET='\033[0m'
    ;;
esac

# --- Helpers ---
colorize() { printf '%b%s%b' "$1" "$2" "$C_RESET"; }

# Pick a color by percentage: <50 ok, 50-79 caution, >=80 warn.
pct_color() {
  local pct=$1
  if   (( pct >= 80 )); then printf '%s' "$C_WARN"
  elif (( pct >= 50 )); then printf '%s' "$C_TIME"
  else                       printf '%s' "$C_OK"
  fi
}

# Render a fixed-width progress bar for a 0-100 percentage.
make_bar() {
  local pct=$1 width=${2:-10}
  (( pct < 0 )) && pct=0
  (( pct > 100 )) && pct=100
  local filled=$(( (pct * width + 50) / 100 ))
  local empty=$(( width - filled ))
  local bar=""
  local i
  for ((i = 0; i < filled; i++)); do bar+="▓"; done
  for ((i = 0; i < empty; i++)); do bar+="░"; done
  printf '%s' "$bar"
}

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
        context) emoji="🧠" ;; cost) emoji="💰" ;; lines) emoji="📝" ;;
        duration) emoji="⌛" ;; style) emoji="🎨" ;; version) emoji="🏷️" ;;
      esac
      colorize "$color" "${pad}${emoji} ${text}${pad}"
      ;;
    *)
      colorize "$color" "${pad}${text}${pad}"
      ;;
  esac
}

# Human-readable token count: 12345 -> 12.3k, 1000000 -> 1.0M
format_k() {
  local n=$1
  if (( n >= 1000000 )); then
    awk "BEGIN { printf \"%.1fM\", $n / 1000000.0 }"
  elif (( n >= 100000 )); then
    awk "BEGIN { printf \"%dk\", $n / 1000.0 }"
  elif (( n >= 1000 )); then
    awk "BEGIN { printf \"%.1fk\", $n / 1000.0 }"
  else
    printf '%s' "$n"
  fi
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

# --- Git info (cached per session to avoid 3-4 git calls every refresh tick) ---
compute_git_info() {
  [[ -z "$CURRENT_DIR" ]] && return 1

  # Let git be the source of truth, not a `-d .git` filesystem check: `.git` is
  # only a directory at the repo ROOT with a standard layout. It's absent in
  # subdirectories (the common case), and a FILE (not a dir) in worktrees and
  # submodules — so the old check silently hid the branch in all of those.
  local branch indicators=""
  branch=$(git -C "$CURRENT_DIR" rev-parse --abbrev-ref HEAD 2>/dev/null) || return 1
  [[ -z "$branch" ]] && return 1
  # Detached HEAD reports the literal "HEAD"; show a short SHA instead.
  [[ "$branch" == "HEAD" ]] && branch="@$(git -C "$CURRENT_DIR" rev-parse --short HEAD 2>/dev/null)"

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

get_git_info() {
  # No session id or no caching requested -> compute directly.
  if [[ -z "$SESSION_ID" || "$GIT_CACHE_TTL" -le 0 ]] 2>/dev/null; then
    compute_git_info
    return
  fi

  # Cache keyed by session_id (stable per session, unique across concurrent
  # sessions) — the docs warn pid/$$ keys defeat the cache.
  local cache="${TMPDIR:-/tmp}/claude-statusline-git-${SESSION_ID}.cache"
  if [[ -f "$cache" ]]; then
    local now mtime age
    now=$(date +%s)
    mtime=$(stat -c %Y "$cache" 2>/dev/null || stat -f %m "$cache" 2>/dev/null || echo 0)
    age=$(( now - mtime ))
    if (( age < GIT_CACHE_TTL )); then
      cat "$cache"
      return
    fi
  fi

  local fresh
  fresh=$(compute_git_info) || { : > "$cache" 2>/dev/null; return 1; }
  printf '%s' "$fresh" > "$cache" 2>/dev/null
  printf '%s' "$fresh"
}

# --- Usage calculation from JSONL files (the 5-hour rate-limit window) ---
calculate_usage() {
  local default_reset=$((SESSION_HOURS * 3600))

  # The 5-hour quota is ACCOUNT-WIDE, not per-project: it pools usage across every
  # session in every working directory. So scan ALL project folders, not just the
  # one matching $CURRENT_DIR. This also makes the number independent of where
  # Claude was launched from — a home-dir launch previously keyed to an empty/
  # different project slug and showed 0/0. Records are deduped by message-id below,
  # which is globally unique, so cross-project merging is safe.
  local projects_root="$HOME/.claude/projects"
  if [[ ! -d "$projects_root" ]]; then
    echo "0 0 $default_reset"
    return
  fi

  local result
  result=$(find "$projects_root" -mindepth 2 -maxdepth 2 -name "*.jsonl" -type f -mtime -4 2>/dev/null \
    | while IFS= read -r f; do cat "$f"; done 2>/dev/null \
    | jq -R -c 'try (fromjson | select(.type == "assistant" and .message.usage != null))' 2>/dev/null \
    | jq -s --argjson sh "$SESSION_HOURS" --arg token_mode "$TOKEN_MODE" '
      now as $now |
      ($now - ($sh * 3600)) as $window_start |

      [.[] |
        (try (.timestamp | sub("\\.[0-9]+"; "") | fromdateiso8601) catch null) as $epoch |
        select($epoch != null and $epoch >= $window_start) |

        .message.usage as $u |

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

        ((.message.id // "") | tostring) as $mid |
        ((.requestId // .request_id // "") | tostring) as $rid |

        {
          e: $epoch,
          t: $tok,
          d: ($mid + ":" + $rid)
        }
      ] |

      group_by(.d) |
      [.[] |
        if .[0].d == ":"
        then .[]
        else sort_by(.t) | last
        end
      ] |
      sort_by(.e) |

      length as $msg_count |
      (map(.t) | add // 0) as $total_tokens |

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

# --- Lazily computed shared state (only if a segment needs it) ---
USAGE_DONE=0
TOTAL_TOKENS=0; MSG_COUNT=0; RESET_SECS=0
ensure_usage() {
  (( USAGE_DONE )) && return
  local usage_raw
  usage_raw=$(calculate_usage)
  read -r TOTAL_TOKENS MSG_COUNT RESET_SECS <<< "$usage_raw"
  USAGE_DONE=1
}

# --- Segment renderers: each prints a formatted, colored chunk (or nothing) ---
render_segment() {
  case "$1" in
    dir)
      [[ -z "$DIR_NAME" ]] && return
      if [[ "$DISPLAY_MODE" == "background" ]]; then
        format_with_info " ${DIR_NAME} " "$C_DIR" "dir"
      else
        format_with_info "${DIR_NAME}/" "$C_DIR" "dir"
      fi
      ;;

    git)
      local git_str
      git_str=$(get_git_info 2>/dev/null) || true
      [[ -z "$git_str" ]] && return
      local git_color="$C_GIT_OK"
      [[ "$git_str" =~ [?+!↑↓] ]] && git_color="$C_GIT_DIRTY"
      local pad=""
      [[ "$DISPLAY_MODE" == "background" ]] && pad=" "
      if [[ "$INFO_MODE" == "emoji" ]]; then
        colorize "$git_color" "${pad}🔀 ${git_str}${pad}"
      else
        colorize "$git_color" "${pad}${git_str}${pad}"
      fi
      ;;

    model)
      [[ -z "$MODEL_NAME" ]] && return
      format_with_info "$MODEL_NAME" "$C_MODEL" "model"
      ;;

    context)
      # Native context-window usage for THIS conversation. Bar colored by fill,
      # with a warning glyph once we cross the 200k auto-compact danger zone.
      local pct="${CTX_PCT:-0}"
      [[ "$pct" =~ ^[0-9]+$ ]] || pct=0
      local bar color
      bar=$(make_bar "$pct" 10)
      color=$(pct_color "$pct")
      local detail=""
      if (( CTX_SIZE > 0 )); then
        local used=$(( CTX_IN + CTX_OUT ))
        detail=" ($(format_k "$used")/$(format_k "$CTX_SIZE"))"
      fi
      format_with_info "${bar} ${pct}% ctx${detail}" "$color" "context"
      ;;

    cost)
      local cost_disp
      cost_disp=$(awk "BEGIN { printf \"\$%.2f\", ${COST_USD:-0} }")
      format_with_info "$cost_disp" "$C_COST" "cost"
      ;;

    lines)
      (( LINES_ADDED == 0 && LINES_REMOVED == 0 )) && return
      format_with_info "+${LINES_ADDED}/-${LINES_REMOVED}" "$C_LINES" "lines"
      ;;

    duration)
      local ms="${DURATION_MS:-0}"
      [[ "$ms" =~ ^[0-9]+$ ]] || ms=0
      local secs=$(( ms / 1000 ))
      local h=$(( secs / 3600 )) m=$(( (secs % 3600) / 60 ))
      local disp
      if (( h > 0 )); then disp="${h}h${m}m"; else disp="${m}m"; fi
      format_with_info "$disp" "$C_DURATION" "duration"
      ;;

    tokens)
      ensure_usage
      local pct=$(( TOTAL_TOKENS * 100 / TOKEN_LIMIT ))
      format_with_info "${pct}% token usage ($(format_count "$TOTAL_TOKENS" "$TOKEN_LIMIT"))" "$C_TOKENS" "tokens"
      ;;

    msgs)
      ensure_usage
      local pct=$(( MSG_COUNT * 100 / MSG_LIMIT ))
      format_with_info "${pct}% message usage (${MSG_COUNT}/${MSG_LIMIT})" "$C_MSGS" "msgs"
      ;;

    reset)
      ensure_usage
      local h=$(( RESET_SECS / 3600 )) m=$(( (RESET_SECS % 3600) / 60 ))
      format_with_info "${h}h${m}m before reset" "$C_TIME" "time"
      ;;

    style)
      # Only surface when in a non-default output style (e.g. explanatory).
      [[ -z "$OUTPUT_STYLE" || "$OUTPUT_STYLE" == "default" || "$OUTPUT_STYLE" == "null" ]] && return
      format_with_info "$OUTPUT_STYLE" "$C_STYLE" "style"
      ;;

    version)
      [[ -z "$CC_VERSION" || "$CC_VERSION" == "null" ]] && return
      format_with_info "v${CC_VERSION}" "$C_VERSION" "version"
      ;;
  esac
}

# --- Build output ---
join_line() {
  # Joins already-rendered, non-empty parts with the separator.
  local sep parts=("$@")
  if [[ "$DISPLAY_MODE" == "background" ]]; then
    sep=" "
  else
    sep=" $(printf '%b' "$C_GRAY")·$(printf '%b' "$C_RESET") "
  fi
  local out="" first=1 p
  for p in "${parts[@]}"; do
    [[ -z "$p" ]] && continue
    if (( first )); then out="$p"; first=0; else out+="${sep}${p}"; fi
  done
  printf '%s' "$out"
}

build_output() {
  # "|" in SEGMENTS splits into multiple lines (ccstatusline-style multi-line).
  local IFS_LINES='|'
  local line_specs=()
  IFS='|' read -r -a line_specs <<< "$SEGMENTS"

  local line_out=()
  local spec
  for spec in "${line_specs[@]}"; do
    local seg_keys=()
    IFS=',' read -r -a seg_keys <<< "$spec"
    local rendered=()
    local key
    for key in "${seg_keys[@]}"; do
      key="${key// /}"
      [[ -z "$key" ]] && continue
      rendered+=("$(render_segment "$key")")
    done
    line_out+=("$(join_line "${rendered[@]}")")
  done

  local i
  for i in "${!line_out[@]}"; do
    (( i > 0 )) && printf '\n'
    printf '%s' "${line_out[$i]}"
  done
  printf '\n'
}

build_output
