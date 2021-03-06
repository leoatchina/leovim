" --------------------------
" preview
" --------------------------
let g:plugs_symbol = []
if Installed('vim-preview')
    au FileType qf nnoremap <silent><buffer> qq    :PreviewClose<cr>
    au FileType qf nnoremap <silent><buffer> <C-m> :PreviewQuickfix<cr>
    " preview file and openit
    nnoremap ,<Tab> :PreviewFile<Space>
    nnoremap <silent> <leader>E :PreviewGoto edit<Cr><C-w>z
    nnoremap <silent> <leader>V :PreviewGoto vsplit<Cr><C-w>z
    nnoremap <silent> <leader>X :PreviewGoto split<Cr><C-w>z
    nnoremap <silent> <leader>T :PreviewGoto tabedit<Cr>gT<C-w>zgt
endif
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
    if get(g:, 'has_lambda', 0) == 0
        let g:tagbar_position = 'rightbelow vertical'
    else
        let g:tagbar_position = 'leftabove vertical'
    endif
    if get(g:, "ctags_version", '') =~ "Universal"
        if executable('tstags')
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
        endif
    elseif get(g:, "ctags_version", '') =~ "Exuberant"
        if executable('tstags')
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
    let g:vista_echo_cursor          = 0
    let g:vista_stay_on_open         = 0
    let g:vista_sidebar_width        = 35
    let g:vista#renderer#enable_icon = 0
    let g:vista_icon_indent          = ["╰─▸ ", "├─▸ "]
    if WINDOWS()
        let g:vista_fzf_preview = ['up:30%:hidden']
    else
        let g:vista_fzf_preview = ['up:30%']
    endif
    if get(g:, 'ctags_version', '') =~ 'json'
        let g:vista_default_executiveista = 'ctags'
        nnoremap <M-'> :Vista finder ctags<Cr>
        let s:vista_finder_shortcut = '<M-l>f'
    else
        let s:vista_finder_shortcut = "<M-'>"
    endif
    if get(g:, 'complete_engine', '') == 'coc'
        let g:vista_default_executive = 'coc'
        execute "nnoremap " . s:vista_finder_shortcut . " :Vista finder coc<Cr>"
    elseif get(g:, 'complete_engine', '') == 'vim-lsp'
        let g:vista_default_executive = 'vim_lsp'
        execute "nnoremap " . s:vista_finder_shortcut . " :Vista finder vim_lsp<Cr>"
    elseif get(g:, 'complete_engine', '') == 'nvim-lsp'
        let g:vista_default_executive = 'nvim_lsp'
        execute "nnoremap " . s:vista_finder_shortcut . " :Vista finder nvim_lsp<Cr>"
    endif
endif
" --------------------------
" ctags
" --------------------------
if executable('ctags')
    " Make tags placed in .git/tags file available in all levels of a repository
    let gitroot = substitute(system('git rev-parse --show-toplevel'), '[\n\r]', '', 'g')
    if gitroot != ''
        let &tags = gitroot . '/.git/tags;./.tags;,.tags'
    else
        let &tags = './.tags;,.tags'
    endif
    if Installed('vim-preview')
        let g:preview#preview_position = "rightbottom"
        let g:preview#preview_size = get(g:, 'preview_rows', 8)
        nnoremap <silent> <M-t> :ToggleQuickfix<Cr>:PreviewList<Cr>
        nnoremap <silent> <M-:> <C-w>}
        nnoremap <silent> <M-;> :PreviewTag<Cr>
        nnoremap <silent> <M-?> :PreviewSignature!<Cr>
    endif
    if Installed('vim-quickui')
        call AddPlugSymbol('quickui')
        au FileType qf noremap <silent><buffer> <C-k> :call quickui#tools#preview_quickfix()<cr>
        au FileType qf noremap <silent><buffer> <tab> :call quickui#tools#preview_quickfix()<cr>
        nnoremap <C-k> :<C-u>call quickui#tools#preview_tag('')<Cr>
    endif
    if Installed('vim-gutentags')
        call AddPlugSymbol('gutentags')
        " 将自动生成的 tags 文件全部放入 leaderf 目录中，避免污染工程目录
        let g:Lf_CacheDirectory   = expand("~/.cache/leaderf")
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
