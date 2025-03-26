if ! command -v cargo &> /dev/null; then
    echo "Please install rust toolchain including cargo."
    exit 1
fi
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
elif [ -x "nvim" ]; then
  NVIMCMD="nvim"
else
  echo "nvim not executable"
  exit 1
fi
$NVIMCMD --cmd "let g:preset_group=['blk']" "$@"
