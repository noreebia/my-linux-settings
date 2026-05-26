alias rmzone="find . -name \"*:Zone.Identifier\" -type f -delete"

open() {
  if [ $# -eq 0 ]; then
    explorer.exe .
  else
    # Convert Linux path to Windows path and open
    explorer.exe $(wslpath -w "$1")
  fi
}