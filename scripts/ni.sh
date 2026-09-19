if  [ -f "$HOME/.local/bin/nvim.appimage" ] && [ -x "$HOME/.local/bin/nvim.appimage" ];  then
  NVIMCMD="$HOME/.local/bin/nvim.appimage"
elif [ -f "$HOME/.local/nvim-macos-arm64/bin/nvim" ] && [ -x "$HOME/.local/nvim-macos-arm64/bin/nvim" ]; then
  NVIMCMD="$HOME/.local/nvim-macos-arm64/bin/nvim"
elif [ -f "$HOME/.local/nvim-macos-x86_64/bin/nvim" ] && [ -x "$HOME/.local/nvim-macos-x86_64/bin/nvim" ]; then
  NVIMCMD="$HOME/.local/nvim-macos-x86_64/bin/nvim"
elif [ -f "$HOME/.local/nvim-linux-x86_64/bin/nvim" ] && [ -x "$HOME/.local/nvim-linux-x86_64/bin/nvim" ]; then
  NVIMCMD="$HOME/.local/nvim-linux-x86_64/bin/nvim"
elif [ -f "$HOME/.local/bin/nvim" ] && [ -x "$HOME/.local/bin/nvim" ]; then
  NVIMCMD="$HOME/.local/bin/nvim"
elif command -v nvim >/dev/null 2>&1; then
  NVIMCMD="nvim"
else
  echo "nvim not executable"
  exit 1
fi
$NVIMCMD --cmd "let g:packs=['cmp']" "$@"
