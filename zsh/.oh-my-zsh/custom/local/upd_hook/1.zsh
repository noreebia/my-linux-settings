if (( $+commands[yt-dlp] )); then
  "$HOME/.local/share/yt-dlp-venv/bin/python" \
    -m pip install --upgrade "yt-dlp[default]" || return
fi

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
