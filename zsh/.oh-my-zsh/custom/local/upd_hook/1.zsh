# Update only the active yt-dlp installation, using its existing installer.
() {
  local yt_dlp_command
  yt_dlp_command=$(whence -p yt-dlp) || {
    print -r -- 'yt-dlp not found; skipping update.'
    return 0
  }

  local yt_dlp_binary="${yt_dlp_command:A}"
  local pipx_venvs uv_tools

  if (( $+commands[dpkg-query] )) &&
     dpkg-query -S "$yt_dlp_binary" >/dev/null 2>&1; then
    print -r -- 'yt-dlp is managed by apt; the system upgrade handles updates.'
    return 0
  fi

  if (( $+commands[pipx] )) &&
     pipx_venvs=$(pipx environment --value PIPX_LOCAL_VENVS 2>/dev/null) &&
     [[ -n "$pipx_venvs" && "$yt_dlp_binary" -ef "$pipx_venvs/yt-dlp/bin/yt-dlp" ]]; then
    print -r -- 'Updating yt-dlp with pipx...'
    pipx upgrade yt-dlp
    return $?
  fi

  if (( $+commands[uv] )) &&
     uv_tools=$(uv tool dir 2>/dev/null) &&
     [[ -n "$uv_tools" && "$yt_dlp_binary" -ef "$uv_tools/yt-dlp/bin/yt-dlp" ]]; then
    print -r -- 'Updating yt-dlp with uv...'
    uv tool upgrade yt-dlp
    return $?
  fi

  local yt_dlp_venv="${yt_dlp_binary:h:h}"
  # Managed environments must be updated by their installer, even if it is missing.
  if [[ -f "$yt_dlp_venv/pipx_metadata.json" || -f "$yt_dlp_venv/uv-receipt.toml" ]]; then
    print -r -- "yt-dlp belongs to a managed environment: $yt_dlp_venv; skipping update."
  elif [[ -f "$yt_dlp_venv/pyvenv.cfg" && -x "$yt_dlp_venv/bin/python" ]]; then
    if "$yt_dlp_venv/bin/python" -m pip --version >/dev/null 2>&1; then
      print -r -- "Updating yt-dlp in its virtual environment: $yt_dlp_venv"
      "$yt_dlp_venv/bin/python" -m pip install --upgrade "yt-dlp[default]"
      return $?
    fi
    print -r -- "pip is unavailable in $yt_dlp_venv; skipping yt-dlp update."
  else
    print -r -- "Unrecognized or incomplete yt-dlp installation: $yt_dlp_command; skipping update."
  fi
  return 0
} || return

# Update the active Codex installation with its existing installer.
() {
  local codex_command
  codex_command=$(whence -p codex) || {
    print -r -- 'Codex CLI not found; skipping update.'
    return 0
  }

  local codex_binary="${codex_command:A}"
  local codex_home="${CODEX_HOME:-$HOME/.codex}"
  local standalone_root="$codex_home/packages/standalone"
  standalone_root="${standalone_root:A}"

  if [[ "$codex_binary" == "$standalone_root"/releases/*/codex ||
        "$codex_binary" == "$standalone_root"/releases/*/bin/codex ]]; then
    print -r -- 'Updating Codex CLI with the standalone installer...'
    local codex_installer
    codex_installer=$(curl -fsSL https://chatgpt.com/codex/install.sh) || return
    CODEX_HOME="$codex_home" CODEX_INSTALL_DIR="${codex_command:h}" \
      CODEX_NON_INTERACTIVE=1 sh -c "$codex_installer" || return
  else
    local npm_root
    if (( $+commands[npm] )) && npm_root=$(npm root -g) &&
       [[ "$codex_binary" -ef "$npm_root/@openai/codex/bin/codex.js" ]]; then
      print -r -- 'Updating Codex CLI with npm...'
      npm install -g @openai/codex || return
    else
      print -r -- "Unrecognized Codex installation: $codex_command; skipping update."
    fi
  fi
} || return

if command -v flatpak >/dev/null; then
  sudo flatpak update -y || return
fi
