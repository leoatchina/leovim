if  [ -f "$HOME/.local/bin/vim.appimage" ] && [ -x "$HOME/.local/bin/vim.appimage" ];  then
  VIMCMD="$HOME/.local/bin/vim.appimage"
elif [ -f "$HOME/.local/vim9/bin/vim" ] && [ -x "$HOME/.local/vim9/bin/vim" ]; then
  VIMCMD="$HOME/.local/vim9/bin/vim"
else
  ret='0'
  command -v vim >/dev/null 2>&1 || { local ret='1'; }
  if [ "$ret" -ne 0 ]; then
    echo "vim not executable"
    exit 1
  else
    VIMCMD="vim"
  fi
fi
$VIMCMD -u ~/.leovim/conf.d/init.vim --cmd "let g:packs=['mcm']" "$@"
