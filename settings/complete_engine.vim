" --------------------------
" complete
" --------------------------
syntax on
syntax enable
filetype on
filetype plugin on
filetype plugin indent on
set cpt=w,b,.,k
" --------------------------
" complete_snippet
" --------------------------
if Installed('ultisnips')
    " remap Ultisnips for compatibility
    let g:UltiSnipsNoPythonWarning          = 1
    let g:UltiSnipsRemoveSelectModeMappings = 0
    let g:UltiSnipsListSnippets             = "<C-l>"
    let g:UltiSnipsExpandTrigger            = "<C-g>"
    let g:UltiSnipsJumpForwardTrigger       = "<C-f>"
    let g:UltiSnipsJumpBackwardTrigger      = "<C-b>"
    if get(g:, 'fuzzy_finder', '') == 'leaderf'
        inoremap <c-x><c-l> <c-\><c-o>:Leaderf snippet<cr>
    endif
    " Ulti 的代码片段的文件夹
    let g:UltiSnipsSnippetsDir        = $HOME.'/.leovim.plug/ultisnips'
    let g:UltiSnipsSnippetDirectories = ["UltiSnips"]
    " Ulti python version
    let g:UltiSnipsUsePythonVersion = 3
elseif Installed('neosnippet')
    let g:neosnippet#enable_conceal_markers = 1
    let g:neosnippet#enable_completed_snippet = 1
    let g:neosnippet#snippets_directory=$VIM_PLUG.'/vim-snippets/snippets'
    smap <C-f> <Plug>(neosnippet_jump_or_expand)
else
    let g:complete_sinippet = ''
endif
if Installed('fzf') && Installed('fzf.vim')
    if executable('rg') && !WINDOWS()
        imap <expr> <c-x><c-j> fzf#vim#complete(fzf#wrap({
                    \ 'prefix': '^.*$',
                    \ 'source': 'rg -n ^ --color always',
                    \ 'options': '--ansi --delimiter : --nth 3..',
                    \ 'reducer': { lines -> join(split(lines[0], ':\zs')[2:], '') }}
                    \ ))
    else
        imap <c-x><c-j> <plug>(fzf-complete-line)
    endif
    imap <c-x><c-f> <plug>(fzf-complete-path)
endif
" --------------------------
" Snippet Tab
" --------------------------
function! s:check_back_space() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~ '\s'
endfunction
function! Snippet_Tab() abort
    if pumvisible()
        if get(g:, "complete_snippet", '') == 'ultisnips'
            call UltiSnips#ExpandSnippet()
        elseif get(g:, "complete_snippet", '') == 'neosnippet' && neosnippet#expandable()
            return neosnippet#mappings#expand_impl()
        endif
        if get(g:,'ulti_expand_res', 0) > 0
            return "\<Right>"
        elseif empty(get(v:, 'completed_item', {}))
            return "\<C-n>"
        else
            return "\<C-y>"
        endif
    else
        if s:check_back_space()
            return "\<Tab>"
        elseif get(g:, 'complete_engine', '') == 'coc'
            return coc#refresh()
        elseif get(g:, 'complete_engine', '') == 'vim-lsp'
            return asyncomplete#force_refresh()
        else
            return "\<C-n>"
        endif
    endif
endfunction
au BufEnter * exec "inoremap <silent> <Tab> <C-R>=Snippet_Tab()<cr>"
" --------------------------
" GoToDefinitionOrTagOrSearch
" --------------------------
function! GoToDefinitionOrTagOrSearch(type)
    if a:type == 'v'
        vsplit
    elseif a:type == 's'
        split
    elseif a:type == 't'
        split
        execute("silent! normal \<C-w>T")
    endif
    let res = 0
    if get(g:, 'complete_engine', '') =~ 'YCM'
        let ret = execute("silent! YcmCompleter GoToDefinition")
        if ret !~ 'error'
            let res = 1
        endif
    elseif get(g:, 'complete_engine', '') == 'coc' && CocAction('jumpDefinition')
        let res = 1
    endif
    if res == 0
        if executable('ctags')
            let ret = execute("silent! tag ".expand("<cword>"))
            if ret =~ "E433" || ret =~ "E426"
                call searchdecl(expand('<cword>'))
            endif
        else
            call searchdecl(expand('<cword>'))
        endif
    endif
endfunction
nnoremap <silent> gl       :call GoToDefinitionOrTagOrSearch("v")<Cr>
nnoremap <silent> g<cr>    :call GoToDefinitionOrTagOrSearch("n")<Cr>
nnoremap <silent> g<tab>   :call GoToDefinitionOrTagOrSearch("t")<Cr>
nnoremap <silent> g<space> :call GoToDefinitionOrTagOrSearch("s")<Cr>
" --------------------------
" complete_engine
" --------------------------
let g:ycm_filetype_blacklist = {
    \ 'coc-explorer': 1,
    \ 'tagbar':       1,
    \ 'vista':        1,
    \ 'leaderf':      1,
    \ 'fzf':          1,
    \ 'gitcommit':    1,
    \ 'php':          1,
    \ 'markdown':     1,
    \ 'text':         1,
    \ 'nginx':        1,
    \ 'yml':          1,
    \ 'json':         1,
    \ 'log':          1,
    \ }
if Installed('YouCompleteMe')
    let g:ycm_python_binary_path = g:python3_host_prog
    if WINDOWS()
        let g:ycm_global_ycm_extra_conf = $YCM_WINDIR . "\\.ycm_extra_conf.py"
    else
        let g:ycm_global_ycm_extra_conf = $INATLL_PATH . "/YouCompleteMe/.ycm_extra_conf.py"
    endif
    let g:ycm_add_preview_to_completeopt                = 0
    let g:ycm_autoclose_preview_window_after_completion = 1
    let g:ycm_autoclose_preview_window_after_insertion  = 1
    let g:ycm_key_list_select_completion                = ['<C-n>', '<Down>']
    let g:ycm_key_list_previous_completion              = ['<C-p>', '<Up>']
    let g:ycm_confirm_extra_conf                        = 1 " 加载.ycm_extra_conf.py 提示
    let g:ycm_min_num_of_chars_for_completion           = 2 " 从第 2 个键入字符就开始罗列匹配项
    let g:ycm_seed_identifiers_with_syntax              = 1 " 语法关键字补全
    let g:ycm_complete_in_comments                      = 1
    let g:ycm_complete_in_strings                       = 1
    let g:ycm_show_diagnostics_ui                       = 1
    let g:ycm_disable_signature_help                    = 0
    let g:ycm_collect_identifiers_from_tags_files           = 1
    let g:ycm_collect_identifiers_from_comments_and_strings = 1
    if exists('+completepopup') != 0
        set completeopt+=popup
        set completepopup=align:menu,border:off,highlight:WildMenu
    endif
    " hover
    let g:ycm_auto_hover = ''
    nmap     <M-,>  <Plug>(YCMHover)
    nnoremap <M-.>  :YcmCompleter GoToDefinition<Cr>
    nnoremap <M-l>; :YcmCompleter<Space>
    nnoremap <M-l>. :YcmCompleter Get<Tab>
    nnoremap <M-l>k :YcmCompleter GetDoc<CR>
    nnoremap <M-l>y :YcmCompleter GetType<Cr>
    nnoremap <M-l>p :YcmCompleter GetParent<CR>
    " with vsplit
    nnoremap <M-l>g :vs<Cr>:YcmCompleter GoTo<CR>
    nnoremap <M-l>d :vs<Cr>:YcmCompleter GoToDeclaration<CR>
    nnoremap <M-l>t :vs<Cr>:YcmCompleter GoToType<CR>
    nnoremap <M-l>r :vs<Cr>:YcmCompleter GoToReferences<CR>
    nnoremap <M-l>e :vs<Cr>:YcmCompleter GoToImplementation<CR>
    nnoremap <M-l>n :vs<Cr>:YcmCompleter GotoInclude<Space>
    " Goto
    nnoremap <M-j>g :YcmCompleter GoTo<CR>
    nnoremap <M-j>d :YcmCompleter GoToDeclaration<CR>
    nnoremap <M-j>t :YcmCompleter GoToType<CR>
    nnoremap <M-j>r :YcmCompleter GoToReferences<CR>
    nnoremap <M-j>e :YcmCompleter GoToImplementation<CR>
    nnoremap <M-j>I :YcmCompleter GotoInclude<Space>
    nnoremap <M-j>f :YcmCompleter GoToSymbol <C-r><C-w>
    xnoremap <M-j>f :YcmCompleter GoToSymbol <C-R>=GetVisualSelection()<CR>
    nnoremap ,cf :YcmCompleter Format<CR>
    nnoremap ,cx :YcmCompleter FixIt<Cr>
    " lsp config
    let g:ycm_language_server = []
    if executable('node')
        let g:ycm_language_server += [
                    \ {
                    \   'name': 'vim',
                    \   'filetypes': ['vim'],
                    \   'cmdline': ['node', expand('$INATLL_PATH/lsp-examples/viml/node_modules/.bin/vim-language-server'), '--stdio']
                    \ },
                    \ {
                    \   'name': 'yaml',
                    \   'filetypes': ['yaml'],
                    \   'cmdline': ['node', expand('$INATLL_PATH/lsp-examples/yaml/node_modules/.bin/yaml-language-server'), '--stdio' ]
                    \ },
                    \ {
                    \   'name': 'json',
                    \   'filetypes': ['json'],
                    \   'cmdline': ['node', expand('$INATLL_PATH/lsp-examples/json/node_modules/.bin/vscode-json-languageserver'), '--stdio']
                    \ },
                    \ {
                    \   'name': 'vue',
                    \   'filetypes': ['vue'],
                    \   'cmdline': [expand('$INATLL_PATH/lsp-examples/vue/node_modules/.bin/vls')]
                    \ }]
    endif
    if executable('julia')
        let g:ycm_julia_cmdline = ['julia', '--startup-file=no', '--history-file=no', '-e', '
                    \ using LanguageServer;
                    \ using Pkg;
                    \ import StaticLint;
                    \ import SymbolServer;
                    \ env_path = dirname(Pkg.Types.Context().env.project_file);
                    \ debug = false;
                    \ server = LanguageServer.LanguageServerInstance(stdin, stdout, debug, env_path, "", Dict());
                    \ server.runlinter = true;
                    \ run(server);
                    \ ']
        let g:ycm_language_server +=
                    \ [{ 'name': 'julia',
                    \     'filetypes': [ 'julia' ],
                    \     'project_root_files': [ 'Project.toml' ],
                    \     'cmdline': g:ycm_julia_cmdline
                    \ }]
    endif
elseif Installed('coc.nvim')
    " config as complete_engine
    call coc#config('suggest.floatEnable', v:true)
    call coc#config('signature.target', "float")
    call coc#config('coc.preferences.hoverTarget', "float")
    call coc#config('coc.preferences.enableFloatHighlight', v:true)
    call coc#config('rust-analyzer.inlayHints.enable', v:false)
    " as lsp engine
    nmap <M-,> :call <SID>show_documentation()<CR>
    nmap <M-.>  <Plug><coc-definition>
    " basic plug
    nmap <M-j>w :CocFzfList symbols<CR>
    nmap <M-j>s :CocAction('documentSymbols')<Cr>
    nmap <M-j>f :CocAction('getCurrentFunctionSymbol')<Cr>
    nmap <M-j>d <Plug>(coc-declaration)
    nmap <M-j>t <Plug>(coc-type-definition)
    nmap <M-j>r <Plug>(coc-references)
    nmap <M-j>e <Plug>(coc-implementation)
    nmap <M-j>R <Plug>(coc-refactor)
    " with vsplit
    nmap <M-l>d :vs<Cr>:execute "normal \<Plug>(coc-declaration)"<Cr>
    nmap <M-l>t :vs<Cr>:execute "normal \<Plug>(coc-type-definition)"<Cr>
    nmap <M-l>r :vs<Cr>:execute "normal \<Plug>(coc-references)"<Cr>
    nmap <M-l>e :vs<Cr>:execute "normal \<Plug>(coc-implementation)"<Cr>
    nmap <M-l>m :CocList marketplace<Cr>
    let g:coc_snippet_next = "<C-n>"
    let g:coc_snippet_prev = "<C-p>"
    augroup cocgroup
        autocmd!
        " Setup formatexpr specified filetype(s).
        autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
        " Update signature help on jump placeholder.
        autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
    augroup end
    function! s:show_documentation()
        if (index(['vim','help'], &filetype) >= 0)
            try
                execute 'h '.expand('<cword>')
            catch /.*/
                call CocAction('doHover')
            endtry
        else
            call CocAction('doHover')
        endif
    endfunction
    if has('nvim-0.4.0') || has('patch-8.2.0750')
        inoremap <silent><nowait><expr> <C-j> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<C-j>"
        inoremap <silent><nowait><expr> <C-k> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<C-j>"
        xnoremap <silent><nowait><expr> <C-j> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-j>"
        xnoremap <silent><nowait><expr> <C-k> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-k>"
        nnoremap <silent><nowait><expr> <C-j> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-j>"
        nnoremap <silent><nowait><expr> <C-k> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-k>"
    endif
    " codeaction and others
    nmap ,ca :CocFzfList actions<Cr>
    xmap ,c; <Plug>(coc-codeaction-selected)
    nmap ,c; <Plug>(coc-codeaction)
    nmap ,c, <Plug>(coc-codelens)
    nmap ,cl <Plug>(coc-codeaction-line)
    xmap ,cf <Plug>(coc-format-selected)
    nmap ,cf <Plug>(coc-format)
    nmap ,cr <Plug>(coc-rename)
    nmap ,cs <Plug>(coc-range-select)
    " multi cursors
    nmap ,cc <Plug>(coc-cursors-position)
    nmap ,co <Plug>(coc-cursors-operator)
    " Fix autofix problem of current line
    nmap ,cx <Plug>(coc-fix-current)
    " more
    nmap ,ch <Plug>(coc-float-hide)
    nmap ,cj <Plug>(coc-float-jump)
    " Do default action for next item.
    nmap <silent> ,cn :CocNext<CR>
    " Do default action for previous item.
    nmap <silent> ,cp :CocPrev<CR>
elseif Installed('vim-lsp')
    function! s:my_asyncomplete_preprocessor(options, matches) abort
        let l:visited = {}
        let l:items = []
        for [l:source_name, l:matches] in items(a:matches)
            for l:item in l:matches['items']
                if stridx(l:item['word'], a:options['base']) == 0
                    if !has_key(l:visited, l:item['word'])
                        call add(l:items, l:item)
                        let l:visited[l:item['word']] = 1
                    endif
                endif
            endfor
        endfor
        call asyncomplete#preprocess_complete(a:options, l:items)
    endfunction
    let g:asyncomplete_preprocessor = [function('s:my_asyncomplete_preprocessor')]
    let g:asyncomplete_auto_popup = 1
    au User asyncomplete_setup call asyncomplete#register_source(asyncomplete#sources#buffer#get_source_options({
                \ 'name': 'buffer',
                \ 'whitelist': ['*'],
                \ 'priority': 16,
                \ 'completor': function('asyncomplete#sources#buffer#completor'),
                \ }))
    au User asyncomplete_setup call asyncomplete#register_source(asyncomplete#sources#file#get_source_options({
                \ 'name': 'file',
                \ 'whitelist': ['*'],
                \ 'priority': 8,
                \ 'completor': function('asyncomplete#sources#file#completor')
                \ }))
    if Installed('asyncomplete-tags.vim') && executable('ctags')
        au User asyncomplete_setup call asyncomplete#register_source(asyncomplete#sources#tags#get_source_options({
                    \ 'name': 'tags',
                    \ 'whitelist': ['*'],
                    \ 'priority': 4,
                    \ 'completor': function('asyncomplete#sources#tags#completor'),
                    \ 'config': {'max_file_size': 50000000},
                    \ }))
    endif
    if Installed("asyncomplete-ultisnips.vim") && get(g:, 'complete_engine', '') == 'ultisnips'
        au User asyncomplete_setup call asyncomplete#register_source(asyncomplete#sources#ultisnips#get_source_options({
                    \ 'name': 'ultisnips',
                    \ 'whitelist': ['*'],
                    \ 'priority': 32,
                    \ 'completor': function('asyncomplete#sources#ultisnips#completor'),
                    \ }))
    elseif Installed("asyncomplete-neosnippet.vim") && get(g:, 'complete_engine', '') == 'neosnippet'
        au User asyncomplete_setup call asyncomplete#register_source(asyncomplete#sources#neosnippet#get_source_options({
                    \ 'name': 'neosnippet',
                    \ 'whitelist': ['*'],
                    \ 'priority': 32,
                    \ 'completor': function('asyncomplete#sources#neosnippet#completor')
                    \ }))
    endif
    if get(g:, 'ai_engine', '') == 'tabnine'
        call asyncomplete#register_source(asyncomplete#sources#tabnine#get_source_options({
            \ 'name': 'tabnine',
            \ 'allowlist': ['*'],
            \ 'completor': function('asyncomplete#sources#tabnine#completor'),
            \ 'config': {
            \   'line_limit': 1000,
            \   'max_num_result': 20,
            \  },
            \ }))
    endif
    " --------------------------
    " vim-lsp
    " --------------------------
    nnoremap <M-l>; :Lsp
    nnoremap <M-l>, :LspInstallServer<Space>
    let g:lsp_diagnostics_enabled    = 0
    let g:lsp_insert_text_enabled    = 1
    let g:lsp_text_edit_enabled      = 0
    let g:lsp_signature_help_enabled = 0
    let g:lsp_preview_doubletap      = [function('lsp#ui#vim#output#closepreview')]
    " with vsplit
    nnoremap <M-l>d :vs<Cr>:LspDeclaration<CR>
    nnoremap <M-l>t :vs<Cr>:LspTypeDefinition<CR>
    nnoremap <M-l>r :vs<Cr>:LspReferences<CR>
    nnoremap <M-l>e :vs<Cr>:LspImplementation<CR>
    nnoremap <M-l>i :LspCallHierarchyIncoming<Cr>
    nnoremap <M-l>o :LspCallHierarchyOutgoing<Cr>
    nnoremap <M-l>h :LspTypeHierarchy<Cr>
    nnoremap <M-l>s :LspSignatureHelp<Cr>
    nnoremap <M-l>c :LspDocument<Tab>
    " jump to
    nnoremap <M-.>  :LspDefinition<Cr>
    nnoremap <M-j>d :LspDeclaration<CR>
    nnoremap <M-j>t :LspTypeDefinition<CR>
    nnoremap <M-j>e :LspImplementation<CR>
    nnoremap <M-j>r :LspReferences<CR>
    nnoremap <M-j>w :LspWorkspaceSymbol<Cr>
    nnoremap <M-j>f :LspDocumentSymbol<Cr>
    " codeaction
    nnoremap ,cr :LspRename<CR>
    nnoremap ,c; :LspCodeAction<CR>
    nnoremap ,c, :LspCodeLens<CR>
    if has('patch-8.1.1517') || has('nvim')
        autocmd User lsp_float_opened nmap <buffer> <silent> <C-c> <Plug>(lsp-preview-close)
        nnoremap <M-,>  :LspHover<CR>
        nnoremap <M-j>h :LspPeekDefinition<Cr>
        nnoremap <M-j>e :LspPeekDeclaration<CR>
        nnoremap <M-j>y :LspPeekTypeDefinition<CR>
        nnoremap <M-j>m :LspPeekImplementation<CR>
        let g:lsp_preview_float      = 1
        let g:lsp_preview_keep_focus = 0
    else
        let g:lsp_preview_float      = 0
        let g:lsp_preview_keep_focus = 1
    endif
    if executable('ccls') && HasPlug('c')
        au User lsp_setup call lsp#register_server({
                    \ 'name': 'ccls',
                    \ 'cmd': {server_info->['ccls --init={"cache": {"directory": '. $HOME . '/.cache/ccls-cache}}']},
                    \ 'root_uri': {server_info->lsp#utils#path_to_uri(lsp#utils#find_nearest_parent_file_directory(lsp#utils#get_buffer_path(), 'compile_commands.json'))},
                    \ 'initialization_options': {},
                    \ 'whitelist': ['c', 'cpp', 'objc', 'objcpp', 'cc'],
                    \ })
    endif
    if has('nvim-0.4.0') || has('patch-8.1.1615')
        inoremap <buffer> <expr><C-j> lsp#scroll(+3)
        inoremap <buffer> <expr><C-k> lsp#scroll(-3)
    endif
    " --------------------------
    " vim-lsp-settings
    " --------------------------
    if Installed('vim-lsp-settings')
        let g:lsp_settings_servers_dir         = $INSTALL_PATH . '/vim-lsp-settings/servers'
        let g:lsp_settings_global_settings_dir = $INSTALL_PATH . '/vim-lsp-settings/global_config'
        let g:lsp_settings_enable_suggestions  = 1
        let g:lsp_log_file                     = $INSTALL_PATH . '/lsp.log'
    endif
elseif !HasPlug('no-complete')
    let g:complete_engine = 'apc'
else
    let g:complete_engine = ''
endif
""""""""""""""""""""
" APC settings
""""""""""""""""""""
if get(g:, 'complete_engine', '') != ''
    if get(g:, 'complete_engine', '') == 'apc'
        let g:apc_enable_ft = get(g:, 'apc_enable_ft', {'*':1})
    else
        let g:apc_enable_ft = g:ycm_filetype_blacklist
    endif
    let g:apc_enable_tab = get(g:, 'apc_enable_tab', 1) && get(g:, 'complete_snippet', '') == '' " remap tab
    let g:apc_min_length = get(g:, 'apc_min_length', 2)  " minimal length to open popup
    let g:apc_key_ignore = get(g:, 'apc_key_ignore', []) " ignore keywords
    " get word before cursor
    function! s:get_context()
        return strpart(getline('.'), 0, col('.') - 1)
    endfunc
    function! s:meets_keyword(context)
        if g:apc_min_length <= 0
            return 0
        endif
        let matches = matchlist(a:context, '\(\k\{' . g:apc_min_length . ',}\)$')
        if empty(matches)
            return 0
        endif
        for ignore in g:apc_key_ignore
            if stridx(ignore, matches[1]) == 0
                return 0
            endif
        endfor
        return 1
    endfunc
    function! s:on_backspace()
        if pumvisible() == 0
            return "\<BS>"
        endif
        let text = matchstr(s:get_context(), '.*\ze.')
        return s:meets_keyword(text)? "\<BS>" : "\<c-e>\<bs>"
    endfunc
    " autocmd for CursorMovedI
    function! s:feed_popup()
        let enable = get(b:, 'apc_enable', 0)
        let lastx = get(b:, 'apc_lastx', -1)
        let lasty = get(b:, 'apc_lasty', -1)
        let tick = get(b:, 'apc_tick', -1)
        if &bt != '' || enable == 0 || &paste
            return -1
        endif
        let x = col('.') - 1
        let y = line('.') - 1
        if pumvisible()
            let context = s:get_context()
            if s:meets_keyword(context) == 0
                call feedkeys("\<c-e>", 'n')
            endif
            let b:apc_lastx = x
            let b:apc_lasty = y
            let b:apc_tick = b:changedtick
            return 0
        elseif lastx == x && lasty == y
            return -2
        elseif b:changedtick == tick
            let lastx = x
            let lasty = y
            return -3
        endif
        let context = s:get_context()
        if s:meets_keyword(context)
            silent! call feedkeys("\<c-n>", 'n')
            let b:apc_lastx = x
            let b:apc_lasty = y
            let b:apc_tick = b:changedtick
        endif
        return 0
    endfunc
    " autocmd for CompleteDone
    function! s:complete_done()
        let b:apc_lastx = col('.') - 1
        let b:apc_lasty = line('.') - 1
        let b:apc_tick = b:changedtick
    endfunc
    " enable apc
    function! s:apc_enable()
        call s:apc_disable()
        augroup ApcEventGroup
            au!
            au CursorMovedI <buffer> nested call s:feed_popup()
            au CompleteDone <buffer> call s:complete_done()
        augroup END
        let b:apc_init_autocmd = 1
        if g:apc_enable_tab
            inoremap <silent><buffer><expr> <tab>
                        \ pumvisible()? "\<c-n>" :
                        \ <SID>check_back_space() ? "\<tab>" : "\<c-n>"
            inoremap <silent><buffer><expr> <s-tab>
                        \ pumvisible()? "\<c-p>" : "\<s-tab>"
            let b:apc_init_tab = 1
        endif
        inoremap <silent><buffer><expr> <cr> pumvisible()? "\<c-y>\<cr>" : "\<cr>"
        inoremap <silent><buffer><expr> <bs> <SID>on_backspace()
        let b:apc_init_bs = 1
        let b:apc_init_cr = 1
        let b:apc_save_infer = &infercase
        setlocal infercase
        let b:apc_enable = 1
    endfunc
    " disable apc
    function! s:apc_disable()
        if get(b:, 'apc_init_autocmd', 0)
            augroup ApcEventGroup
                au!
            augroup END
        endif
        if get(b:, 'apt_init_tab', 0)
            silent! iunmap <buffer><expr> <tab>
            silent! iunmap <buffer><expr> <s-tab>
        endif
        if get(b:, 'apc_init_bs', 0)
            silent! iunmap <buffer><expr> <bs>
        endif
        if get(b:, 'apc_init_cr', 0)
            silent! iunmap <buffer><expr> <cr>
        endif
        if get(b:, 'apc_save_infer', '') != ''
            let &l:infercase = b:apc_save_infer
        endif
        let b:apc_init_autocmd = 0
        let b:apt_init_tab = 0
        let b:apc_init_bs = 0
        let b:apc_init_cr = 0
        let b:apc_save_infer = ''
        let b:apc_enable = 0
    endfunc
    " check if need to be enabled
    function! s:apc_check_init()
        if &bt == '' && get(g:apc_enable_ft, &ft, 0) != 0
            ApcEnable
        elseif &bt == '' && get(g:apc_enable_ft, '*', 0) != 0
            ApcEnable
        endif
    endfunc
    " commands & autocmd
    command! -nargs=0 ApcEnable call s:apc_enable()
    command! -nargs=0 ApcDisable call s:apc_disable()
    augroup ApcInitGroup
        au!
        au FileType * call s:apc_check_init()
        au BufEnter * call s:apc_check_init()
        au TabEnter * call s:apc_check_init()
    augroup END
endif
if !exists("g:leovim_loaded") && get(g:, 'complete_engine', '') != ''
    set rtp+=$ADDINS_PATH/vim-dict
endif
if get(g:, 'complete_engine', '') != ''
    inoremap <silent><expr> <Up>       pumvisible()? "\<C-p>":                  "\<Up>"
    inoremap <silent><expr> <Down>     pumvisible()? "\<C-n>":                  "\<Down>"
    inoremap <silent><expr> <PageUp>   pumvisible()? "\<PageUp>\<C-p>\<C-n>":   "\<PageUp>"
    inoremap <silent><expr> <PageDown> pumvisible()? "\<PageDown>\<C-n>\<C-p>": "\<PageDown>"
    if get(g:, 'complete_engine', '') =~ "YCM" || get(g:, 'complete_engine', '') == "vim-lsp"
        imap <expr><Cr> pumvisible()? "\<C-[>a":"\<CR>"
    else
        imap <expr><Cr> pumvisible()? "\<C-e>" :"\<CR>"
    endif
endif
