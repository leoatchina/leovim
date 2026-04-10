set noai
set nosi
set noimdisable
set nojoinspaces
set nospell
set noeb
set nocursorcolumn
set nowrap
set nolist
set nobackup
set nowritebackup
set vb
set cursorline
set incsearch
set ruler
set hlsearch
set showmode
set autochdir
set smartcase
set ignorecase
set showmatch
set backspace=indent,eol,start
set linespace=0
set enc=utf8
set fencs=utf-8,utf-16,ucs-bom,gbk,gb18030,big5,latin1
set winminheight=0
set scrolljump=5
set scrolloff=3
set mouse=a
set wildchar=<Tab>
" tab
set expandtab
set shiftwidth=4
set softtabstop=4
set tabstop=4
set textwidth=160
" switchbuf
set buftype=
set switchbuf=useopen,usetab,newtab
" --------------------------
" swapfile
" --------------------------
set swapfile
" --------------------------
" wildmenu
" --------------------------
set wildmenu
try
    set wildmode=longest,full
    try
        set wildoptions=pum,fuzzy
    catch
        set wildoptions=tagfile
    endtry
catch
    set wildmode=list
    set wildoptions=tagfile
endtry
" --------------------------
" wildignore
" --------------------------
if has('wildignore')
    set wildignore+=*\\tmp\\*,*/tmp/*,*.swp,*.exe,*.dll,*.so,*.zip,*.tar*,*.7z,*.rar,*.gz,*.pyd,*.pyc,*.ipynb
    set wildignore+=.ccls-cache/*,.idea/*,.vscode/*,__pycache__/*,.git/*,.svn/*,.hg/*,root/*
endif
" --------------------------
" signcolumn
" --------------------------
if has('nvim')
    set signcolumn=yes:1
elseif has('patch-7.4.2201')
    set signcolumn=yes
endif
" --------------------------
" jumpoption
" --------------------------
if has('nvim') || has('jumpoptions')
    set jumpoptions=stack
    if has('nvim')
        set jumpoptions+=view
    endif
endif
" --------------------------
" splitposition
" --------------------------
set splitright
set splitbelow
if has('nvim-0.9') || has('patch-9.0.0647')
    set splitkeep=cursor
endif
" ---------------------------------------
" autoread modified file outside (neo)vim
" ---------------------------------------
set autoread
if has('nvim')
    autocmd FocusGained,TermLeave,TermClose * if index(['terminal', 'nofile'], &bt) < 0 | silent! checktime | endif
elseif !utils#has_gui()
    " Vim terminal: do NOT hook WinEnter with :e! — it reloads on every split/window switch, discards
    " unsaved edits, and can leave buffers empty/broken with fzf/Leaderf. Use checktime + autoread instead.
    autocmd FocusGained * if index(['terminal', 'nofile'], &bt) < 0 | silent! checktime | endif
endif
" -----------------------------------
" swap exists ignore
" -----------------------------------
autocmd SwapExists * let v:swapchoice = 'o'
" --------------------------
" goto last visited line
" --------------------------
autocmd BufReadPost * silent! normal g`"
" --------------------------
" number
" --------------------------
set number
if !utils#is_vscode()
    set relativenumber
    nnoremap <leader>n :set relativenumber! relativenumber? \| set number<Cr>
    nnoremap <leader>N :set norelativenumber \| set nonu! nonu?<Cr>
    augroup numbertoggle
        autocmd!
        autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &nu && mode() != "i" | set rnu | endif
        autocmd BufLeave,FocusLost,InsertEnter,WinLeave   * if &nu | set nornu | endif
        if exists(':tnoremap')
            autocmd CmdlineLeave * if &nu && mode() != "i" | set rnu | endif
            autocmd CmdlineEnter * if &nu | set nornu | endif
        endif
        if has('nvim')
            autocmd TermLeave,TermClose * if &nu && mode() != "i" | set rnu | endif
            autocmd TermEnter,TermOpen  * if &nu | set nornu | endif
        endif
    augroup END
endif
" -----------------------------------
" hightlight todo note
" -----------------------------------
function! s:specialtodo_highlight() abort
    if exists('w:specialtodo_match_ids')
        return
    endif
    let w:specialtodo_match_ids = [
                \ matchadd('Todo', '\v\W\zs' . g:todo_patterns . '(\(.{-}\))?:?', -1),
                \ matchadd('Todo', '\v\W\zs' . g:note_patterns . '(\(.{-}\))?:?', -2)
                \ ]
endfunction
augroup SPECIALSTINGS
    autocmd!
    autocmd Syntax * call s:specialtodo_highlight()
augroup END
" -----------------------------------
" not automatical add comments when o/O
" -----------------------------------
augroup NoAddComment
    autocmd!
    autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o
augroup END
" trim
augroup TripSpaces
    autocmd FileType vim,c,cpp,java,go,php,javascript,typescript,python,rust,twig,xml,yml,perl,sql,r,conf,lua
                \ autocmd! BufWritePre <buffer> :call utils#trip_whitespace()
augroup END
" --------------------------
" file templates
" --------------------------
autocmd BufNewFile .lintr          0r $CONF_D_DIR/templates/lintr.spec
autocmd BufNewFile .Rprofile       0r $CONF_D_DIR/templates/Rprofile.spec
autocmd BufNewFile .gitconfig      0r $CONF_D_DIR/templates/gitconfig.spec
autocmd BufNewFile .gitignore      0r $CONF_D_DIR/templates/gitignore.spec
autocmd BufNewFile .wildignore     0r $CONF_D_DIR/templates/wildignore.spec
autocmd BufNewFile .radian_profile 0r $CONF_D_DIR/templates/radian_profile.spec
