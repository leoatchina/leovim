if  [ -f "$HOME/.local/bin/vim.appimage" ] && [ -x "$HOME/.local/bin/vim.appimage" ];  then
  VIMCMD="$HOME/.local/bin/vim.appimage"
elif [ -f "$HOME/.local/vim9/bin/vim" ] && [ -x "$HOME/.local/vim9/bin/vim" ]; then
  VIMCMD="$HOME/.local/vim9/bin/vim"
elif [ -x "vim" ]; then
  VIMCMD="vim"
else
  echo "vim not executable"
  exit 1
fi
$VIMCMD -u ~/.leovim/conf.d/init.vim --cmd "let g:preset_group=['coc']" "$@"
