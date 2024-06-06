set noai
set nosi
set noimdisable
set nojoinspaces
set nospell
set noeb
set nocursorcolumn
set nowrap
set nofoldenable
set nolist
set nobackup
set nowritebackup
set swapfile
set splitright
set splitbelow
set cursorline
set incsearch
set ruler
set hlsearch
set showmode
set vb
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
" wildmenu signcolumn wildignore
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
if has('nvim')
    set signcolumn=yes:1
elseif has('patch-7.4.2201')
    set signcolumn=yes
endif
if has('wildignore')
    set wildignore+=*\\tmp\\*,*/tmp/*,*.swp,*.exe,*.dll,*.so,*.zip,*.tar*,*.7z,*.rar,*.gz,*.pyd,*.pyc,*.ipynb
    set wildignore+=.ccls-cache/*,.idea/*,.vscode/*,__pycache__/*,.git/*,.svn/*,.hg/*,root/*
endif
