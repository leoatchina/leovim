" --------------------------
" preview
" --------------------------
let g:plugs_symbol = []
if !exists('g:leovim_loaded')
    set rtp+=$ADDINS_PATH/vim-preview
endif
au FileType qf nnoremap <silent><buffer> q     :PreviewClose<cr>
au FileType qf nnoremap <silent><buffer> Q     :PreviewClose<cr>
au FileType qf nnoremap <silent><buffer> <C-m> :PreviewQuickfix<cr>
au FileType qf nnoremap <silent><buffer> <Tab> :PreviewQuickfix<cr>
" preview file and openit
nnoremap ,<Cr>       :PreviewFile<Space>
nnoremap <silent> ,E :PreviewGoto edit<Cr><C-w>z
nnoremap <silent> ,V :PreviewGoto vsplit<Cr><C-w>z
nnoremap <silent> ,X :PreviewGoto split<Cr><C-w>z
nnoremap <silent> ,T :PreviewGoto tabe<Cr>gT<C-w>zgt
" --------------------------
" plugs_symbol
" --------------------------
if Installed('tagbar')
    call AddPlugSymbol('tagbar')
    let g:tagbar_sort  = 0
    let g:tagbar_width = 35
    let g:tagbar_type_css = {
                \ 'ctagstype' : 'css',
                \ 'kinds' : [
                \ 'c:classes',
                \ 's:selectors',
                \ 'i:identities'
                \ ]}
    if get(g:, 'has_lambda', 0) > 0
        let g:tagbar_position = 'leftabove vertical'
    else
        let g:tagbar_position = 'rightbelow vertical'
    endif
    if executable('tstags')
        if get(g:, "ctags_version", '') =~ "Universal"
            let g:tagbar_type_typescript = {
                        \ 'ctagstype': 'typescript',
                        \ 'ctagsbin':  'tstags',
                        \ 'ctagsargs': '-f-',
                        \ 'sort' : 0,
                        \ 'kinds': [
                        \ 'e:enums:0:1',
                        \ 'f:function:0:1',
                        \ 't:typealias:0:1',
                        \ 'M:Module:0:1',
                        \ 'I:import:0:1',
                        \ 'i:interface:0:1',
                        \ 'C:class:0:1',
                        \ 'm:method:0:1',
                        \ 'p:property:0:1',
                        \ 'v:variable:0:1',
                        \ 'c:const:0:1'
                        \ ]
                        \ }
        elseif get(g:, "ctags_version", '') =~ "Exuberant"
            let g:tagbar_type_typescript = {
                        \ 'ctagstype': 'typescript',
                        \ 'kinds': [
                        \ 'c:classes',
                        \ 'n:modules',
                        \ 'f:functions',
                        \ 'v:variables',
                        \ 'v:varlambdas',
                        \ 'm:members',
                        \ 'i:interfaces',
                        \ 'e:enums',
                        \ ]
                        \}
        endif
    endif
endif
if Installed('vista.vim')
    call AddPlugSymbol('vista')
    if get(g:, 'has_lambda', 0) > 0
        let g:vista_sidebar_position = 'vertical topleft'
    else
        let g:vista_sidebar_position = 'vertical topright'
    endif
    nnoremap <M-k>v :Vista<Space>
    let g:vista_sidebar_width        = 35
    let g:vista_echo_cursor          = 0
    let g:vista_stay_on_open         = 0
    let g:vista#renderer#enable_icon = 0
    let g:vista_icon_indent          = ["╰─▸ ", "├─▸ "]
    if WINDOWS()
        let g:vista_fzf_preview = ['up:30%:hidden']
    else
        let g:vista_fzf_preview = ['up:30%']
    endif
    if get(g:, 'ctags_version', '') =~ 'json'
        let g:vista_default_executive = 'ctags'
        nnoremap <M-?> :Vista finder!<Cr>
    endif
    if get(g:, 'vista_lsp_command', '') != ''
        execute("nnoremap <M-/> :Vista finder " . g:vista_lsp_command . "<Cr>")
        if get(g:, 'vista_default_executive', '') != 'ctags'
            let g:vista_default_executive = g:vista_lsp_command
            execute("nnoremap <M-?> :Vista finder " . g:vista_lsp_command . "<Cr>")
        endif
    elseif get(g:, 'vista_default_executive', '') == 'ctags'
        nnoremap <M-/> :Vista finder!<Cr>
    endif
endif
" --------------------------
" ctags
" --------------------------
if executable('ctags')
    " Make tags placed in .git/tags file available in all levels of a repository
    let &tags = './.tags;,.tags'
    " vim-preview
    let g:preview#preview_position = "rightbottom"
    let g:preview#preview_size     = get(g:, 'preview_rows', 8)
    nnoremap <silent> <M-:> <C-w>}
    nnoremap <silent> <M-;> :PreviewTag<Cr>
    nnoremap <silent> <C-l> :ToggleQuickfix<Cr>:PreviewList<Cr>
    if Installed('vim-quickui')
        call AddPlugSymbol('quickui')
        au FileType qf noremap <silent><buffer> <C-k> :call quickui#tools#preview_quickfix()<cr>
        au FileType qf noremap <silent><buffer> <Tab> :call quickui#tools#preview_quickfix()<cr>
        nnoremap <C-k> :<C-u>call quickui#tools#preview_tag('')<Cr>
    else
        nnoremap <silent> <C-k> :PreviewSignature!<Cr>
    endif
    if Installed('vim-gutentags')
        call AddPlugSymbol('gutentags')
        " 将自动生成的 tags 文件全部放入 leaderf gtags目录中，避免污染工程目录
        let g:gutentags_cache_dir = expand(g:Lf_CacheDirectory.'/.LfCache/gtags')
        if isdirectory(g:gutentags_cache_dir)
            silent! call mkdir(g:gutentags_cache_dir, 'p')
        endif
        " workmode
        if get(g:, 'pygments_import', 0) > 0 && get(g:, 'native_pygments', 1) > 0
            let $GTAGSLABEL = 'native-pygments'
        else
            let $GTAGSLABEL = 'native'
        endif
        " exclude files
        let g:gutentags_ctags_exclude = ["*.min.js", "*.min.css", "build", "vendor", "node_modules", "*.vim/bundle/*"]
        " gutentags 搜索工程目录的标志，碰到这些文件/目录名就停止向上一级目录递归
        let g:gutentags_project_root = ['.root', '.svn', '.git', '.hg', '.project']
        " 所生成的数据文件的名称
        let g:gutentags_ctags_tagfile = '.tags'
        " modules
        let g:gutentags_modules = ['ctags']
        " 配置 ctags 的参数
        let g:gutentags_ctags_extra_args = ['--fields=+niazS', '--c-kinds=+px', '--c++-kinds=+px']
        if g:ctags_version =~ "Universal"
            let g:gutentags_ctags_extra_args += ['--extras=+q', '--output-format=e-ctags']
        endif
        nnoremap <leader>gu :GutentagsUpdate<CR>
    endif
endif
" --------------------------
" gtags
" --------------------------
if Installed('gutentags_plus')
    call AddPlugSymbol('gtags')
    let g:gutentags_modules += ['gtags_cscope']
    " setting
    let g:gutentags_define_advanced_commands = 1
    let g:gutentags_plus_switch              = 1
    let g:gutentags_plus_nomap               = 1
    let g:gutentags_auto_add_gtags_cscope    = 1
    " s: Find this symbol
    " g: Find this definition
    " d: Find functions called by this function
    " c: Find functions calling this function
    " t: Find this text string
    " e: Find this egrep pattern
    " f: Find this file
    " i: Find files #including this file
    " a: Find places where this symbol is assigned a value
    nnoremap <silent> <leader>gs :GscopeFind s <C-R><C-W><cr>
    nnoremap <silent> <leader>gg :GscopeFind g <C-R><C-W><cr>
    nnoremap <silent> <leader>gd :GscopeFind d <C-R><C-W><cr>
    nnoremap <silent> <leader>gc :GscopeFind c <C-R><C-W><cr>
    nnoremap <silent> <leader>gt :GscopeFind t <C-R><C-W><cr>
    nnoremap <silent> <leader>ge :GscopeFind e <C-R><C-W><cr>
    nnoremap <silent> <leader>gf :GscopeFind f <C-R>=expand("<cfile>")<cr><cr>
    nnoremap <silent> <leader>gi :GscopeFind i <C-R>=expand("<cfile>")<cr><cr>
    nnoremap <silent> <leader>ga :GscopeFind a <C-R><C-W><cr>
    nnoremap <silent> <leader>gz :GscopeFind z <C-R><C-W><cr>
    nnoremap <leader>g, :GutentagsToggleTrace<CR>
    nnoremap <leader>g; :GutentagsToggleEnable<CR>
    if get(g:, 'fuzzy_finder', '') == 'leaderf'
        call AddPlugSymbol('leaderf')
        let g:Lf_Gtagsconf           = $GTAGSCONF
        let g:Lf_GtagsGutentags      = 1
        let g:Lf_GtagsAutoGenerate   = 0
        let g:Lf_GtagsSkipUnreadable = 1
        let g:Lf_GtagsAcceptDotfiles = 1
        let g:Lf_GtagsSkipSymlink    = 'a'
        nnoremap ,g; :<C-u>Leaderf gtags --all<Cr>
        nnoremap ,g, :<C-u>Leaderf gtags<Space>
        nnoremap ,gr :<C-u>Leaderf gtags --remove<Cr>
        nnoremap ,gl :<C-u>Leaderf gtags --all-buffers<Cr>
        nnoremap ,gb :<C-u>Leaderf gtags --current-buffer<Cr>
        nnoremap ,gu :<C-u>Leaderf gtags --update<Cr>
        nnoremap ,ga :<C-u>Leaderf gtags --append<CR>
        nnoremap ,gd :<C-U><C-R>=printf("Leaderf gtags -i -d %s ", expand("<cword>"))<CR><CR>
        nnoremap ,ge :<C-U><C-R>=printf("Leaderf gtags -i -r %s ", expand("<cword>"))<CR><CR>
        nnoremap ,gs :<C-U><C-R>=printf("Leaderf gtags -i -s %s ", expand("<cword>"))<CR><CR>
        nnoremap ,gg :<C-U><C-R>=printf("Leaderf gtags -i -g %s ", expand("<cword>"))<CR><CR>
        nnoremap ,gn :<C-U>Leaderf gtags --next<CR>
        nnoremap ,gp :<C-U>Leaderf gtags --previous<CR>
        nnoremap ,g. :<C-u>Leaderf gtags --recall<CR>
        " work with ctags
        if get(g:, 'pygments_import', 0) > 0 && get(g:, 'native_pygments', 1) > 0
            let g:Lf_Gtagslabel = 'native-pygments'
        else
            if g:ctags_version =~ "Universal"
                let g:Lf_Gtagslabel = 'new-ctags'
            elseif g:ctags_version =~ "Exuberant"
                let g:Lf_Gtagslabel = 'ctags'
            else
                let g:Lf_Gtagslabel = 'default'
            endif
        endif
    endif
endif
if len(g:plugs_symbol) > 0
    let g:symbol_tool = join(g:plugs_symbol, '-')
else
    let g:symbol_tool = ''
endif
if Installed("LeaderF")
    if executable('ctags')
        if WINDOWS()
            let g:Lf_Ctags = "ctags"
        else
            let g:Lf_Ctags = "ctags 2>/dev/null"
        endif
    endif
    nnoremap t<Cr>  :Leaderf tag<Cr>
    nnoremap f<Cr>  :Leaderf function<Cr>
    nnoremap q<Cr>  :Leaderf function --all<Cr>
    nnoremap <M-k>b :Leaderf bufTag<cr>
    nnoremap <M-k>t :Leaderf bufTag --all<cr>
elseif Installed('fzf.vim')
    let g:fzf_tags_command = 'ctags -R'
    nnoremap t<cr>  :FZFTags<CR>
    nnoremap <M-k>b :FzfBTags<CR>
    if Installed('fzf-funky')
        nnoremap f<Cr> :FzfFunky<Cr>
    endif
endif
