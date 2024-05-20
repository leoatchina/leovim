" --------------------------
" symbol_tool
" --------------------------
if type(g:symbol_tool) == type([])
    let s:symbol_tool = join(g:symbol_tool, '-')
    unlet g:symbol_tool
    let g:symbol_tool = s:symbol_tool
    unlet s:symbol_tool
endif
" --------------------------
" set tags
" --------------------------
try
    set tags=./.tags;,.tags
catch /.*/
    let &tags = './.tags;,.tags'
endtry
if get(g:, 'ctags_type', '') != ''
    let lst = g:root_patterns + ['lib', '.cache', 'package-lock.json']
    let g:fzf_tags_command='ctags -R --exclude' . join(lst, " --exclude=")
endif
" T/F<Cr>
if g:symbol_tool =~ 'leaderftags'
    let g:Lf_Ctags = g:fzf_tags_command
    nnoremap <silent>T<Cr> :LeaderfBufTagAll<Cr>
    nnoremap <silent>F<Cr> :LeaderfFunctionAll<Cr>
    nnoremap <silent><leader>T :LeaderfTag<Cr>
elseif g:symbol_tool =~ 'fzftags' && executable('perl')
    nnoremap <silent><leader>T :FzfTags<Cr>
elseif g:symbol_tool =~ 'ctrlptags'
    nnoremap <silent><leader>T :CtrlPTags<Cr>
endif
if Installed('fzf')
    PlugAddOpt 'vim-funky'
    command! FzfFunky call funky#fzf#show()
    command! FzfFunkyAll call funky#fzf#show(1)
    nnoremap <silent>f<Cr> :FzfFunky<Cr>
    nnoremap <silent>F<Cr> :FzfFunkyAll<Cr>
elseif g:symbol_tool =~ 'leaderftags' && InstalledLeaderf()
    nnoremap <silent>f<Cr> :LeaderfFunction<Cr>
    nnoremap <silent>F<Cr> :LeaderfFunctionAll<Cr>
elseif Installed('vim-quickui') && g:symbol_tool =~ 'tags'
    nnoremap <silent>f<Cr> :call quickui#tools#list_function()<Cr>
endif
" t<Cr> for tags
if g:complete_engine == 'coc' && UNIX() && g:ctags_type != ''
    nnoremap <silent>t<Cr> :CocFzfList outline<Cr>
elseif Installed('vista.vim') && g:ctags_type =~ 'Universal'
    nnoremap <silent>t<Cr> :Vista finder ctags<Cr>
elseif g:symbol_tool =~ 'leaderftags'
    nnoremap <silent>t<Cr> :LeaderfBufTag<Cr>
elseif g:symbol_tool =~ 'fzftags'
    nnoremap <silent>t<Cr> :FzfBTags<Cr>
elseif g:symbol_tool =~ 'ctrlptags'
    nnoremap <silent>t<Cr> :CtrlPBufTag<Cr>
endif
" siderbar tag config
if Installed('tagbar')
    let g:tagbar_position = 'leftabove vertical'
    let g:tagbar_sort  = 0
    let g:tagbar_width = 35
    let g:tagbar_autoclose_netrw = 1
    let g:tagbar_type_css = {
                \ 'ctagstype' : 'css',
                \ 'kinds' : [
                    \ 'c:classes',
                    \ 's:selectors',
                    \ 'i:identities'
                    \ ]}
elseif Installed('vista.vim')
    let g:vista_sidebar_position = 'vertical topleft'
    let g:vista_update_on_text_changed = 1
    let g:vista_sidebar_width = 35
    let g:vista_echo_cursor   = 0
    let g:vista_stay_on_open  = 0
    let g:vista_icon_indent   = ["╰─▸ ", "├─▸ "]
    let g:vista_executive_for = {
                \ 'vimwiki': 'markdown',
                \ 'pandoc': 'markdown',
                \ 'markdown': 'toc',
                \ }
    if g:ctags_type != ''
        let g:vista_executive_for.go = 'ctags'
    endif
endif
" -------------------------------
" vim-gutentags
" -------------------------------
let g:Lf_CacheDirectory = Expand("~/.vim")
let g:gutentags_cache_dir = g:Lf_CacheDirectory . '/LeaderF/gtags'
if !isdirectory(g:gutentags_cache_dir)
    silent! call mkdir(g:gutentags_cache_dir, 'p')
endif
let g:gutentags_modules = []
if Installed('vim-gutentags')
    " exclude files
    let g:gutentags_ctags_exclude = ["*.min.js", "*.min.css", "build", "vendor", "node_modules", "*.vim/bundle/*", ".ccls_cache", "__pycache__"] + g:root_patterns
    " gutentags 搜索工程目录的标志，碰到这些文件/目录名就停止向上一级目录递归
    let g:gutentags_project_root = g:root_patterns
    let g:gutentags_add_default_project_roots = 0
    let g:gutentags_define_advanced_commands = 1
    " 所生成的数据文件的名称
    let g:gutentags_ctags_tagfile = '.tags'
    " modules
    if g:ctags_type != ''
        let g:gutentags_modules += ['ctags']
        " 配置 ctags 的参数
        let g:gutentags_ctags_extra_args = ['--fields=+niazS', '--extras=q', '--c-kinds=+px', '--c++-kinds=+pxl']
        if g:ctags_type =~ "Universal"
            let g:gutentags_ctags_extra_args += ['--output-format=e-ctags']
        endif
    endif
    function! s:delete_tags() abort
        if exists("b:gutentags_files")
            let del_cmds = []
            let col = col('.')
            let line = line('.')
            for [key, path] in items(b:gutentags_files)
                if filereadable(path)
                    if WINDOWS()
                        let cmd = printf('!del %s /a /q' % path)
                    else
                        let cmd = printf('!rm -f %s' % path)
                    endif
                    call add(del_cmds, cmd)
                    let gpath = substitute(path, '-.tags$', '', 'g')
                    if isdirectory(gpath)
                        if WINDOWS()
                            let cmd = printf('!del %s/* /a /q' % gpath)
                        else
                            let cmd = printf('!rm -f %s/*' % gpath)
                        endif
                        call add(del_cmds, cmd)
                    endif
                elseif isdirectory(path)
                    if WINDOWS()
                        let cmd = printf('!del %s/* /a /q' % path)
                    else
                        let cmd = printf('!rm -f %s/*' % path)
                    endif
                    call add(del_cmds, cmd)
                endif
            endfor
            for del_cmd in del_cmds
                silent! exec del_cmd
            endfor
            call cursor(line, col)
        endif
        call lightline#update()
    endfunction
    command! -bar GutentagsDelTags call s:delete_tags()
    command! GutentagsDelTagsAndUpdate GutentagsDelTags | GutentagsUpdate
    nnoremap <leader>g<Cr> :GutentagsDelTagsAndUpdate<Cr>
    nnoremap <leader>g<Tab> :GutentagsUpdate<Cr>
    nnoremap <leader>g<Space> :GutentagsDelTags<Cr>
    command! GutentagsCommands call FzfCallCommands('GutentagsCommands', 'Gutentags')
    nnoremap <leader>gc :GutentagsCommands<Cr>
endif
" --------------------------
" gtags
" --------------------------
if Installed('gutentags_plus')
    if has('+cscope') && executable('gtags-cscope')
        set cscopeprg=gtags-cscope
    elseif has('+cscope')
        set cscopeprg=
    endif
    let g:gutentags_modules += ['gtags_cscope']
    let g:gutentags_define_advanced_commands = 1
    let g:gutentags_auto_add_gtags_cscope = 1
    let g:gutentags_plus_switch = 1
    let g:gutentags_plus_nomap  = 1
    nnoremap <silent><leader>gs :GscopeFind s <C-R><C-W><Cr>
    nnoremap <silent><leader>gg :GscopeFind g <C-R><C-W><Cr>
    nnoremap <silent><leader>gt :GscopeFind t <C-R><C-W><Cr>
    nnoremap <silent><leader>ge :GscopeFind e <C-R><C-W><Cr>
    nnoremap <silent><leader>ga :GscopeFind a <C-R><C-W><Cr>
    nnoremap <silent><leader>gz :GscopeFind z <C-R><C-W><Cr>
    if InstalledAdvCompEng()
        nnoremap <silent><leader>gl :GscopeFind d <C-R><C-W><Cr>
        nnoremap <silent><leader>gh :GscopeFind c <C-R><C-W><Cr>
    else
        nnoremap <silent>gl :GscopeFind d <C-R><C-W><Cr>
        nnoremap <silent>gh :GscopeFind c <C-R><C-W><Cr>
    endif
    " file
    nnoremap <silent><leader>gf :GscopeFind f <C-R>=expand("<cfile>")<Cr><Cr>
    nnoremap <silent><leader>gi :GscopeFind i <C-R>=expand("<cfile>")<Cr><Cr>
    " kill
    nnoremap <silent><leader>gk :GscopeKill<Cr>
    " leaderfgtags
    if InstalledLeaderf() && UNIX()
        let g:Lf_Gtagsconf = $GTAGSCONF
        let g:Lf_Gtagslabel = get(g:, 'Lf_Gtagslabel', 'native-pygments')
        let g:Lf_GtagsGutentags = 1
        let g:Lf_GtagsSkipSymlink = 'a'
        let g:Lf_GtagsAutoGenerate = 0
        let g:Lf_GtagsAcceptDotfiles = 0
        let g:Lf_GtagsSkipUnreadable = 1
        nnoremap <silent><leader>G  :Leaderf gtags<Cr>
        nnoremap <silent><leader>gd :Leaderf gtags -d <C-r><C-w><Cr>
        nnoremap <silent><leader>gr :Leaderf gtags -r <C-r><C-w><Cr>
        nnoremap <silent><leader>g? :Leaderf gtags -g <C-r><C-w><Cr>
        nnoremap <silent><leader>g/ :Leaderf gtags --by-context<Cr>
    endif
elseif has('+cscope')
    set cscopeprg=
endif
" --------------------------
" matchup
" --------------------------
if g:has_popup_floating
    let g:matchup_matchparen_offscreen = {'methed': 'popup'}
else
    let g:matchup_matchparen_offscreen = {'methed': 'status_manual'}
endif
nnoremap <silent>M :MatchupWhereAmI??<Cr>
PlugAddOpt 'vim-matchup'
" --------------------------
" set tagstack and view tag
" --------------------------
function! s:settagstack(winnr, tagname, pos)
    if !exists('*settagstack') || !exists('*gettagstack')
        return
    endif
    silent! pclose
    if get(g:, 'check_settagstack', '') == ''
        try
            let g:check_settagstack = 't'
        catch /.*/
            let g:check_settagstack = 'a'
        endtry
    endif
    call settagstack(a:winnr, {
                \ 'curidx': gettagstack()['curidx'],
                \ 'items': [{'tagname': a:tagname, 'from': a:pos}]
                \ }, g:check_settagstack)
endfunction
function! s:view_tag(...)
    if a:0 == 0
        let tagname = expand('<cword>')
        let open_position = 'list'
    else
        let tagname = a:1
        if a:0 >= 2
            let open_position = a:2
        else
            let open_position = 'goto'
        endif
    endif
    try
        let found_symbol = preview#quickfix_list(tagname, 0, &filetype)
    catch /.*/
        let found_symbol = 0
    endtry
    if found_symbol
        silent! pclose
        if open_position == 'list'
            execute "copen " . g:asyncrun_open
        else
            if open_position != 'goto'
                if open_position == 'tabe'
                    tabe %
                else
                    execute open_position
                endif
            endif
            execute "tag " . tagname
            call feedkeys("zz", "n")
        endif
    endif
    return found_symbol
endfunction
" --------------------------
" use lsp or tag to find
" --------------------------
function! SymbolOrTagOrSearchAll(find_type, ...) abort
    let tagname = expand('<cword>')
    if empty(tagname)
        call preview#errmsg("No symbol under cursor.")
        return
    endif
    let find_type = a:find_type
    if find_type == 'preview'
        if g:ctags_type == ''
            call preview#errmsg("Preview need ctags.")
        else
            try
                if &rtp =~ 'vim-quickui'
                    let found_symbol = quickui#tools#preview_tag(tagname, v:false) == 0
                else
                    let found_symbol = preview#preview_tag(tagname) == 0
                endif
                if found_symbol == 0
                    call preview#errmsg("Preview not found.")
                endif
            catch /.*/
                call preview#errmsg("Preview failed.")
            endtry
        endif
        return
    else
        let found_symbol = 0
        if index(['definition', 'references', 'type_defition', 'implementation', 'declaration', 'tags'], find_type) < 0
            let find_type = 'definition'
        endif
    endif
    " --------------------------
    " open_position
    " --------------------------
    if a:0 == 1
        let open_position = a:1
    else
        let open_position = 'goto'
    endif
    if index(['tabe', 'split', 'vsplit', 'list', 'goto'], open_position) < 0
        let open_position = 'goto'
    endif
    " --------------------------
    " variables for tagstack
    " --------------------------
    let winnr = winnr()
    let pos = getcurpos()
    let pos[0] = bufnr('')
    " --------------------------
    " coc
    " --------------------------
    if InstalledCoc() && find_type != 'tags'
        let commands_dict = {
                    \ 'definition' : ['definitions', 'jumpDefinition'],
                    \ 'references' : ['references', 'jumpReferences'],
                    \ 'type_defition' : ['typeDefinitions', 'jumpTypeDefinition'],
                    \ 'implementation' : ['implementations', 'jumpImplementation'],
                    \ 'declaration' : ['declarations', 'jumpDeclaration'],
                    \ }
        let [handler, jump_command] = commands_dict[find_type]
        try
            let res = CocAction(handler)
        catch /.*/
            let res = []
        endtry
        if empty(res)
            let found_symbol = 0
        else
            let found_symbol = 1
            if open_position == 'list'
                call CocAction(jump_command, v:false)
            else
                call s:settagstack(winnr, tagname, pos)
                if open_position == 'goto'
                    let coc_command = printf('call CocAction("%s")', jump_command)
                else
                    let coc_command = printf('call CocAction("%s", "%s")', jump_command, open_position)
                endif
                call execute(coc_command)
                call feedkeys("zz", "n")
                echohl WarningMsg | echom "found by coc " . jump_command | echohl None
            endif
        endif
    " --------------------------
    " nvim-lsp
    " --------------------------
    elseif InstalledNvimLsp() && find_type != 'tags'
        let commands_dict = {
                    \ 'definition' : ['textDocument/definition', 'Glance definitions'],
                    \ 'references' : ['textDocument/references', 'Glance references'],
                    \ 'type_defition' : ['textDocument/typeDefinition', 'Glance type_definitions'],
                    \ 'implementation' : ['textDocument/implementation', 'Glance implementations'],
                    \ 'declaration' : ['textDocument/declaration', 'Declarations'],
                    \ }
        let [handler, float_command] = commands_dict[find_type]
        let found_symbol = luaeval(printf("CheckHandler('%s')", handler))
        if found_symbol
            redir => l:messages
            if open_position == 'list'
                call execute(float_command)
            else
                call s:settagstack(winnr, tagname, pos)
                let lua_command = printf('lua vim.lsp.buf.%s()', find_type)
                if open_position == 'goto'
                    call execute(lua_command)
                elseif open_position == 'tabe'
                    let lua_command = 'vsplit | ' . lua_command
                    call execute(lua_command)
                    call feedkeys("\<C-w>T", "n")
                else
                    let lua_command = open_position . ' | ' . lua_command
                    call execute(lua_command)
                endif
                call feedkeys("zz", "n")
                echohl WarningMsg | echom "found by vim.lsp.buf." . find_type  | echohl None
            endif
            redir END
            let l:messages = tolower(l:messages)
        endif
    endif
    " 利用errormsg判断是否找到
    let messages = get(l:, 'messages', '')
    if messages =~ '^no ' || messages =~ 'not ' || messages =~ 'error'
        let found_symbol = 0
    endif
    " references
    if find_type == "references" && get(g:, 'symbol_tool', '') =~ 'plus' && found_symbol == 0
        redir => messages
        call <SID>GscopeFind(0, 't')
        redir END
        if messages !~ 'Error'
            let found_symbol = 1
        endif
    endif
    " tags
    if found_symbol == 0 && g:ctags_type != ''
        let found_symbol = s:view_tag(tagname, open_position)
    endif
    " searchall
    if found_symbol == 0
        if get(g:, 'searchall', '') != ''
            if open_position == 'list'
                execute g:searchall . ' ' . tagname
            else
                call preview#errmsg('Not found by neither lsp nor tags, you should press <M-c> to do grep search.')
            endif
        else
            call preview#errmsg('Not found by neither lsp nor tags, and could not do grep search.')
        endif
    endif
endfunction
" ---------------
" lsp or tag
" ---------------
" tags
nnoremap <silent>g/ :call SymbolOrTagOrSearchAll("tags", "list")<Cr>
" preview
nnoremap <silent><C-h> :call SymbolOrTagOrSearchAll("preview")<Cr>
" definition
au FileType help,vimdoc nnoremap <C-]> <C-]>
nnoremap <silent><C-g> :call SymbolOrTagOrSearchAll("definition")<Cr>
nnoremap <silent><C-]> :call SymbolOrTagOrSearchAll("definition", "vsplit")<Cr>
nnoremap <silent><M-c> :call SymbolOrTagOrSearchAll("definition", "list")<Cr>
nnoremap <silent><C-w><C-g> :call SymbolOrTagOrSearchAll("definition", "tabe")<Cr>
nnoremap <silent><C-w><C-]> :call SymbolOrTagOrSearchAll("definition", "split")<Cr>
" references
nnoremap <silent><M-/> :call SymbolOrTagOrSearchAll("references", "list")<Cr>
if InstalledAdvCompEng()
    " declaration
    nnoremap <silent><M-C> :call SymbolOrTagOrSearchAll("declaration", "list")<Cr>
    " implementation
    nnoremap <silent><M-.> :call SymbolOrTagOrSearchAll("implementation", "list")<Cr>
    " typeDefinition
    nnoremap <silent><M-?> :call SymbolOrTagOrSearchAll("type_definition", "list")<Cr>
endif
