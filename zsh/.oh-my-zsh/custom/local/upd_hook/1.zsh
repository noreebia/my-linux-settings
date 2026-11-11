if (( $+commands[yt-dlp] )); then
  "$HOME/.local/share/yt-dlp-venv/bin/python" \
    -m pip install --upgrade "yt-dlp[default]" || return
fi

npm install -g @openai/codex

if command -v flatpak >/dev/null; then
  sudo flatpak update -y || return
fi
