fzf-funky
============
A super simple function navigator for [fzf](https://github.com/junegunn/fzf), porting from [fzf-funky](https://github.com/leoatchina/fzf-funky).It is a very useful plugin when ctags is not exist or lsp is not support.

- Support neovim's floating window feature!
- Support vim's popup window feature!

SYNOPSIS
----------
This is a [fzf](https://github.com/junegunn/fzf) vim extension. It simply navigates and jumps to function definitions from the current file without ctags. It just searches for function definitions or equivalent lines using regular expressions, therefore some languages' abstractions aren't accurate because of them being hard to parse.

One of advantages of this plugin is that no configuration is required in most cases, so it starts working right after installation with no ctags required.
*If you want to have a more accurate list of function defs, you should use other ctags-based tools, etc.*

[![asciicast](https://asciinema.org/a/253055.svg)](https://asciinema.org/a/253055)

### Supported filetypes:
See [fzf-funky.txt](https://github.com/tracyone/fzf-funky/blob/master/doc/fzf-funky.txt#L22)


PREMISE
----------
First of all, I believe you're a user of a great Vim plugin called [fzf.vim](https://git::@github.com/junegunn/fzf.vim.git).
Otherwise, you need to install fzf.vim before you start using this plugin.


INSTALLATION
----------

### Plugin managers
It is recommended to install the plugin using plugin managers such as minpac, vim-plug, pathogen, Vundle, Dein.vim etc.
You can copy/paste a line below if you use vim-plug:

```vim
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'tracyone/fzf-funky',{'on': 'FzfFunky'}
```

### Manual installation
If you use neither of the plugin management systems, copy _autoload_ and _plugin_ directories to _.vim_ directory.
On Windows, basically, _vimfiles_ directory is used instead of _.vim_ directory.


CONFIGURATION
--------------
It should be useful to define key mappings like this:
```vim
nnoremap <Leader>fu :FzfFunky<Cr>
" narrow the list down with a word under cursor
nnoremap <Leader>fU :execute 'FzfFunky ' . expand('<cword>')<Cr>
```



LINK
-------

* [fzfvim/fzf.vim](https://github.com/fzfvim/fzf.vim)
* [vim.org/fzf-funky](http://www.vim.org/scripts/script.php?script_id=4592)
* [junegunn/fzf](https://github.com/junegunn/fzf)


LICENSE
-------

Copyright (C) 2012-2019 Takahiro Yoshihara. Distributed under the MIT License.

[1]: http://i.imgur.com/yO4PWAF.png
[2]: http://i.imgur.com/CnKui5H.png
[3]: http://i.imgur.com/B3hBycd.png
