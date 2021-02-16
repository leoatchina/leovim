" ------------------------------
" vim-header
" ------------------------------
let g:plugs_symbol = []
function! HasPlugSymbol(plug)
    return count(g:plugs_symbol, a:plug)
endfunction
function! AddPlugSymbol(plug)
    if !HasPlugSymbol(a:plug)
        let g:plugs_symbol += [a:plug]
    endif
endfunction
if exists("g:header_field_author")
    MyPlug 'alpertuna/vim-header'
    let g:header_auto_add_header = 0
    let g:header_field_timestamp_format = '%Y.%m.%d'
    nnoremap <leader>ea :AddHeader<Cr>
endif
" ------------------------------
" fuzzy_finder install
" ------------------------------
if (has('nvim') || has('patch-7.4.330')) && g:python_version > 0 && g:has_winnr && !HasPlug('fzf')
    call AddPlug('leaderf')
    MyPlug 'Yggdroot/LeaderF', {'do': ':LeaderfInstallCExtension' }
    if has('nvim') || v:version >= 800
        MyPlug 'tamago324/LeaderF-filer'
        MyPlug 'Yggdroot/LeaderF-marks'
        if get(g:, 'complete_snippet', '') == 'ultisnips'
            MyPlug 'skywind3000/leaderf-snippet'
        endif
    endif
    if get(g:, 'terminal_plus', '') =~ 'floaterm'
        MyPlug 'voldikss/LeaderF-floaterm'
    endif
endif
if v:version >= 704 || has('nvim')
    MyPlug 'junegunn/fzf.vim'
    MyPlug 'chengzeyi/fzf-preview.vim'
    if WINDOWS()
        MyPlug 'junegunn/fzf', {'do': 'Powershell ./install.ps1'}
    else
        if executable('fzf')
            MyPlug 'junegunn/fzf', {'do': './install --bin'}
        else
            MyPlug 'junegunn/fzf', {'do': './install --all'}
        endif
    endif
    if !HasPlug('leaderf')
        MyPlug 'pbogut/fzf-mru.vim'
        if get(g:, 'terminal_plus', '') =~ 'floaterm'
            MyPlug 'voldikss/fzf-floaterm'
        endif
        if has('nvim') || has('patch-8.1615')
            MyPlug 'tracyone/fzf-funky'
        endif
    endif
endif
" ------------------------------
" debug vimspector
" ------------------------------
if g:python_version > 3.6 && HasPlug('debug') && (has('nvim') || v:version >= 802)
    let vimspector_install = " ./install_gadget.py --all --disable-tcl --update-gadget-config"
    MyPlug 'puremourning/vimspector', {'do': g:python_exe_path . vimspector_install}
endif
" ------------------------------
" preview
" ------------------------------
if has('patch-7.3.1058') || has('nvim')
    MyPlug 'skywind3000/vim-preview'
endif
" ------------------------------
" ctags
" ------------------------------
if executable('ctags')
    if WINDOWS()
        let g:ctags_version = 'Universal-json'
    else
        let g:ctags_version = system('ctags --version')[0:8]
        " check if universal ctags with +json
        if g:ctags_version == 'Universal' && system('ctags --list-features | grep json') =~ 'json'
            let g:ctags_version = 'Universal-json'
        endif
    endif
    if v:version >= 800 || has('nvim')
        if g:ctags_version == 'Universal-json'
            call AddPlugSymbol('vista')
        else
            call AddPlugSymbol('tagbar')
        endif
    elseif has('patch-7.3.1058')
        call AddPlugSymbol('tagbar')
    endif
endif
if index(['coc', 'vim-lsp'], get(g:, 'complete_engine', '')) >= 0
    call AddPlugSymbol('vista')
endif
" ------------------------------
" gtags
" ------------------------------
if WINDOWS()
    let $GTAGSCONF = expand("$HOME/.vim-support/tools/gtags/share/gtags/gtags.conf")
endif
if v:version >= 800 || has('nvim')
    if executable('ctags')
        call AddPlugSymbol('gutentags')
    endif
    if executable('gtags-cscope') && executable('gtags') && exists("$GTAGSCONF") && filereadable($GTAGSCONF)
        call AddPlugSymbol('gutentags')
        call AddPlugSymbol('gtags')
        if HasPlug('leaderf')
            call AddPlugSymbol('leaderf')
        endif
    endif
endif
if HasPlugSymbol('tagbar')
    MyPlug 'majutsushi/tagbar'
endif
if HasPlugSymbol('vista')
    MyPlug 'liuchengxu/vista.vim'
endif
if HasPlugSymbol('gutentags')
    MyPlug 'ludovicchabant/vim-gutentags'
endif
if HasPlugSymbol('gtags')
    MyPlug 'skywind3000/gutentags_plus'
endif
" ------------------------------
" theme if has_trucolor
" ------------------------------
if get(g:, 'has_truecolor', 0) > 0
    " sainnhe's themes
    MyPlug 'sainnhe/edge'
    MyPlug 'sainnhe/sonokai'
    MyPlug 'sainnhe/gruvbox-material'
    " thems will be auto selected
    MyPlug 'wadackel/vim-dogrun'
    MyPlug 'ghifarit53/tokyonight-vim'
    MyPlug 'hardcoreplayers/oceanic-material'
    " others
    MyPlug 'ayu-theme/ayu-vim'
    MyPlug 'mhartington/oceanic-next'
    MyPlug 'tyrannicaltoucan/vim-quantum'
endif
" ------------------------------
" fullscreen
" ------------------------------
if WINDOWS()
    MyPlug 'pprovost/vim-ps1', {'for': 'ps1'}
elseif LINUX() && g:gui_running == 1
    MyPlug 'lambdalisue/vim-fullscreen'
    if has('nvim')
        let g:fullscreen#start_command = "call rpcnotify(0, 'Gui', 'WindowFullScreen', 1)"
        let g:fullscreen#stop_command  = "call rpcnotify(0, 'Gui', 'WindowFullScreen', 0)"
    endif
endif
" ------------------------------
" git
" ------------------------------
MyPlug 'tpope/vim-fugitive'
nnoremap <M-g>s :Gstatus<Cr>
nnoremap <M-g>. :Gblame<Cr>
nnoremap <M-g>, :Git<Space>
nnoremap <M-g>m :Gcommit -a -v<CR>
" ------------------------------
" signify
" ------------------------------
if has('nvim') || has('patch-8.0.902')
    MyPlug 'mhinz/vim-signify'
else
    MyPlug 'mhinz/vim-signify', {'tag': 'legacy', 'dir': '$INSTALL_PATH/vim-signify-legacy'}
endif
nnoremap <M-g>d    :SignifyDiff<Cr>
nnoremap <M-g>;    :Signify
nnoremap <leader>s :SignifyToggle<Cr>
let g:signify_disable_by_default = 1
" ------------------------------
" tmux
" ------------------------------
if executable('tmux') && g:gui_running == 0 && (has('nvim') || has('patch-8.0.1394'))
    MyPlug 'roxma/vim-tmux-clipboard'
    MyPlug 'tmux-plugins/vim-tmux-focus-events'
endif
" ------------------------------
" quickui
" ------------------------------
if has('nvim') && executable('nvr') || v:version >= 802 && !has('nvim')
    call AddPlugSymbol('quickui')
    MyPlug 'skywind3000/vim-quickui'
endif
" ------------------------------
" sidebar
" ------------------------------
if get(g:, 'has_lambda', 0) > 0
    MyPlug 'brglng/vim-sidebar-manager'
endif
" ------------------------------
" status
" ------------------------------
if has('signs')
    MyPlug 'kshenoy/vim-signature'
    MyPlug 'rhysd/conflict-marker.vim'
    let g:conflict_marker_enable_mappings = 0
    nnoremap <leader>ct :ConflictMarkerThemselves<Cr>
    nnoremap <leader>co :ConflictMarkerOurselves<Cr>
    nnoremap <leader>ce :ConflictMarkerNone<Cr>
    nnoremap <leader>cb :ConflictMarkerBoth<Cr>
    nnoremap <leader>cn :ConflictMarkerNextHunk<Cr>
    nnoremap <leader>cp :ConflictMarkerPrevHunk<Cr>
    if executable('go') && !WINDOWS()
        MyPlug 'RRethy/vim-hexokinase', {'for': ['css', 'html', 'less', 'scss', 'sass', 'stylus'], 'do': 'make hexokinase'}
        let g:Hexokinase_highlighters  = ['backgroundfull']
        nnoremap <M-m>o :HexokinaseToggle<Cr>
    else
        MyPlug 'gorodinskiy/vim-coloresque', {'for': ['css', 'html', 'less', 'scss', 'sass', 'stylus']}
    endif
endif
" ------------------------------
" textobj
" ------------------------------
if v:version >= 704 || has('nvim')
    " 函数文本对象：if/af
    MyPlug 'kana/vim-textobj-function', {'for':['c', 'cpp', 'vim', 'java']}
    " 提供 python 相关文本对象，if/af 表示函数，ic/ac 表示类
    MyPlug 'bps/vim-textobj-python', {'for': 'python'}
    " 提供 对 function 对象的选择
    MyPlug 'haya14busa/vim-textobj-function-syntax', {'for':['c', 'cpp', 'vim', 'java']}
    " 提供对各种 block 的匹配
    MyPlug 'rhysd/vim-textobj-anyblock'
    if HasPlug('javascript')
        MyPlug 'thinca/vim-textobj-function-javascript', {'for': ['javascript', 'typescript']}
    endif
    if HasPlug('web')
        MyPlug 'kentaro/vim-textobj-function-php', {'for': 'php'}
    endif
    if HasPlug('perl')
        MyPlug 'thinca/vim-textobj-function-perl', {'for': 'perl'}
    endif
    if HasPlug('latex')
        MyPlug 'rbonvall/vim-textobj-latex', {'for': 'latex'}
    endif
endif
" ------------------------------
" document && translate
" ------------------------------
if has('nvim') || v:version >= 800
    " translate
    MyPlug 'voldikss/vim-translate-me'
    nmap <silent> M <Plug>Translate
    xmap <silent> M <Plug>TranslateV
    if (has('nvim') || has('patch-8.1.1615'))
        "翻译光标下的文本，在窗口中显示
        nmap <silent> zw <Plug>TranslateW
        xmap <silent> zw <Plug>TranslateWV
    endif
    if HasPlug('document')
        if MACOS()
            MyPlug 'rizzatti/dash.vim'
            nmap z/ :Dash<Space>
            nmap z\ <Plug>DashGlobalSearch
            nmap zg <Plug>DashSearch
        else
            MyPlug 'KabbAmine/zeavim.vim'
            nmap z/ :Zeavim
            nmap z\ <Plug>ZVKeyDocset
            nmap gz <Plug>ZVOperator
            nmap zg <Plug>Zeavim
            xmap zg <Plug>ZVVisSelection
        endif
    endif
endif
" ------------------------------
" pairs
" ------------------------------
if v:version >= 800 || has('nvim')
    MyPlug 'tmsvg/pear-tree'
endif
" ------------------------------
" table-mode
" ------------------------------
MyPlug 'dhruvasagar/vim-table-mode'
let g:table_mode_map_prefix = '<leader>o'
nnoremap g= :Tableize<Space>
xnoremap g= :Tableize<Space>
function! s:isAtStartOfLine(mapping)
    let text_before_cursor = getline('.')[0 : col('.')-1]
    let mapping_pattern = '\V' . escape(a:mapping, '\')
    let comment_pattern = '\V' . escape(substitute(&l:commentstring, '%s.*$', '', ''), '\')
    return (text_before_cursor =~? '^' . ('\v(' . comment_pattern . '\v)?') . '\s*\v' . mapping_pattern . '\v$')
endfunction
inoreabbrev <expr> <bar><bar>
      \ <SID>isAtStartOfLine('\|\|') ?
      \ '<c-o>:TableModeEnable<cr><bar><space><bar><left><left>' : '<bar><bar>'
inoreabbrev <expr> __
      \ <SID>isAtStartOfLine('__') ?
      \ '<c-o>:silent! TableModeDisable<cr>' : '__'
let g:table_mode_corner='|'
let g:table_mode_corner_corner='+'
let g:table_mode_header_fillchar='='
" ------------------------------
" pangu
" ------------------------------
MyPlug 'hotoo/pangu.vim'
nnoremap qp :Pangu<Cr>
" ------------------------------
" fly_grep
" ------------------------------
MyPlug 'google/vim-searchindex'
let g:searchindex_line_limit = 2048
if (has('nvim') || has('patch-8.0.1039')) && (executable('rg') || executable('ack') || executable('ag') || executable('pt'))
    MyPlug 'dyng/ctrlsf.vim'
endif
" ------------------------------
" tree_browser
" ------------------------------
if v:version >= 801 || has('nvim')
    MyPlug 'lambdalisue/fern.vim'
    MyPlug 'lambdalisue/fern-hijack.vim'
    MyPlug 'lambdalisue/fern-git-status.vim'
    MyPlug 'lambdalisue/fern-mapping-git.vim'
    if !WINDOWS()
        MyPlug 'LumaKernel/fern-mapping-fzf.vim'
    endif
endif
" ------------------------------
" undotool
" ------------------------------
if has("persistent_undo") && g:has_lambda > 0
    if g:python_version >= 2.4
        let g:mundo_width = 60
        let g:mundo_preview_height = 20
        let g:mundo_right = 1
        MyPlug 'simnalamburt/vim-mundo'
    else
        let g:undotree_SetFocusWhenToggle = 1
        let g:undotree_CustomUndotreeCmd = 'vertical 60 new'
        let g:undotree_CustomDiffpanelCmd = 'belowright 15 new'
        MyPlug 'mbbill/undotree'
    endif
endif
" ------------------------------
" projectionist
" ------------------------------
if HasPlug('projectionist')
    MyPlug 'tpope/vim-projectionist'
    nnoremap <leader>ia :A<Space>
    nnoremap <leader>ie :A<Cr>
    nnoremap <leader>ix :AS<Space>
    nnoremap <leader>iv :AV<Space>
    nnoremap <leader>it :AT<Space>
    nnoremap <leader>id :AD<Space>
    nnoremap <leader>ic :Pcd<Space>
    nnoremap <leader>il :Plcd<Space>
    nnoremap <leader>ip :ProjectDo<Space>
endif
MyPlug 'tpope/vim-apathy'
" ------------------------------
" yoink
" ------------------------------
if has('nvim') || v:version >= 800
    MyPlug 'svermeulen/vim-yoink'
endif
