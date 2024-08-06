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
    if WINDOWS()
        let s:fzf_tags_command = Expand("~/.leovim.windows/tools/ctags.exe")
    else
        let s:fzf_tags_command = 'ctags'
    endif
    let g:fzf_tags_command = s:fzf_tags_command . ' -R --exclude=' . join(lst, " --exclude=")
endif
" T<Cr>
if g:symbol_tool =~ 'leaderftags'
    let g:Lf_Ctags = g:fzf_tags_command
    nnoremap <silent><leader>T :LeaderfTag<Cr>
    nnoremap <silent>T<Cr> :LeaderfBufTagAll<Cr>
elseif g:symbol_tool =~ 'fzftags' && executable('perl')
    nnoremap <silent><leader>T :FzfTags<Cr>
elseif g:symbol_tool =~ 'ctrlptags'
    nnoremap <silent><leader>T :CtrlPTags<Cr>
endif
" f<Cr>
if Planned('fzf')
    PlugAddOpt 'vim-funky'
    command! FzfFunky call funky#fzf#show()
    nnoremap <silent>f<Cr> :FzfFunky<Cr>
elseif g:symbol_tool =~ 'leaderftags' && PlannedLeaderf()
    nnoremap <silent>f<Cr> :LeaderfFunction<Cr>
elseif Installed('vim-quickui') && g:symbol_tool =~ 'tags'
    nnoremap <silent>f<Cr> :call quickui#tools#list_function()<Cr>
endif
" F<Cr>
if g:symbol_tool =~ 'leaderftags'
    nnoremap <silent>F<Cr> :LeaderfFunctionAll<Cr>
elseif Planned('fzf')
    command! FzfFunkyAll call funky#fzf#show(1)
    nnoremap <silent>F<Cr> :FzfFunkyAll<Cr>
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
if Installed('vista.vim')
    let g:vista_update_on_text_changed = 1
    let g:vista_sidebar_position = 'vertical topleft'
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
elseif Installed('tagbar')
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
if Planned('vim-gutentags')
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
    nnoremap <leader>g<Cr> :GutentagsUpdate<Cr>
    nnoremap <leader>g<Tab> :GutentagsDelTags<Cr>
    nnoremap <leader>g<Space> :GutentagsDelTagsAndUpdate<Cr>
    command! GutentagsCommands call FzfCallCommands('GutentagsCommands', 'Gutentags')
    nnoremap <leader>gc :GutentagsCommands<Cr>
endif
" --------------------------
" gtags
" --------------------------
if Planned('gutentags_plus')
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
    if AdvCompEngine()
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
    if PlannedLeaderf() && UNIX()
        let g:Lf_Gtags = Expand(exepath('gtags'))
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
        let action_pos = 'list'
    else
        let tagname = a:1
        if a:0 >= 2
            let action_pos = a:2
        else
            let action_pos = 'edit'
        endif
    endif
    try
        let tag_found = preview#quickfix_list(tagname, 0, &filetype)
    catch /.*/
        let tag_found = 0
    endtry
    if tag_found
        silent! pclose
        if action_pos == 'list'
            execute "copen " . g:asyncrun_open
        else
            if action_pos != 'edit'
                if action_pos == 'tabe'
                    tabe %
                else
                    execute action_pos
                endif
            endif
            execute "tag " . tagname
            call feedkeys("zz", "n")
        endif
    endif
    return tag_found
endfunction
" --------------------------
" use lsp or tag to find
" --------------------------
function! SymbolOrTagOrSearchAll(method, ...) abort
    let tagname = expand('<cword>')
    if empty(tagname)
        call preview#errmsg("No symbol under cursor.")
        return
    endif
    let method = a:method
    if method == 'preview'
        if g:ctags_type == ''
            call preview#errmsg("Preview need ctags.")
        else
            try
                if &rtp =~ 'vim-quickui'
                    let symbol_found = quickui#tools#preview_tag(tagname, v:false) == 0
                else
                    let symbol_found = preview#preview_tag(tagname) == 0
                endif
                if symbol_found == 0
                    call preview#errmsg("Preview not found.")
                endif
            catch /.*/
                call preview#errmsg("Preview failed.")
            endtry
        endif
        return
    else
        let symbol_found = 0
        if index(['definition', 'references', 'type_defition', 'implementation', 'declaration', 'tags'], method) < 0
            let method = 'definition'
        endif
    endif
    " --------------------------
    " open_position
    " --------------------------
    if a:0 == 1
        let open_action = a:1
    else
        let open_action = 'edit'
    endif
    if index(['edit', 'tabe', 'split', 'vsplit', 'list'], open_action) < 0
        let open_action = 'edit'
    endif
    " --------------------------
    " variables for tagstack
    " --------------------------
    let winnr = winnr()
    let pos = getcurpos()
    let pos[0] = bufnr('')
    " --------------------------
    " check if cfile type
    " --------------------------
    if index(g:c_filetypes, &ft) >= 0 && index(['definition', 'tags'], method) >= 0 && g:ctags_type != ''
        let lsp = 0
    else
        if method == "tags"
            let lsp = 0
        else
            let lsp = 1
        endif
    endif
    " --------------------------
    " coc
    " --------------------------
    if Installed('coc.nvim') && lsp
        let commands_dict = {
                    \ 'definition' : 'jumpDefinition',
                    \ 'references' : 'jumpReferences',
                    \ 'type_defition' : 'jumpTypeDefinition',
                    \ 'implementation' : 'jumpImplementation',
                    \ 'declaration' : 'jumpDeclaration',
                    \ }
        let jump_command = commands_dict[method]
        if open_action == 'list'
            let symbol_found = CocAction(jump_command, v:false)
        else
            let symbol_found = CocAction(jump_command)
            sleep 200m
            if symbol_found
                call s:settagstack(winnr, tagname, pos)
                call feedkeys("zz", "n")
                echohl WarningMsg | echom "found by coc " . jump_command | echohl None
            endif
        endif
    " --------------------------
    " LspUI
    " --------------------------
    elseif Installed('lspui.nvim') && lsp
        if open_action == 'list'
            let cmd = printf('lua require("lsp").LspUIApi("%s")', method)
        else
            let cmd = printf('lua require("lsp").LspHandler("%s", "%s")', method, open_action)
        endif
        call execute(cmd)
        sleep 200m
        let symbol_found = get(g:, 'lsp_found', 0)
        if symbol_found
            call s:settagstack(winnr, tagname, pos)
            call feedkeys("zz", "n")
            echohl WarningMsg | echom "found by lsp " . method | echohl None
        endif
    endif
    " 利用errormsg判断是否找到,
    let messages = get(l:, 'messages', '')
    if messages =~ '^no ' || messages =~ 'not ' || messages =~ 'error'
        let symbol_found = 0
    endif
    " view_tags
    if !symbol_found && g:ctags_type != '' && method != 'references' && method != 'implementation'
        let symbol_found = s:view_tag(tagname, open_action)
    endif
    " searchall
    if !symbol_found
        if get(g:, 'searchall', '') != ''
            if open_action == 'list'
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
nnoremap <silent><C-w>g :call SymbolOrTagOrSearchAll("definition", "tabe")<Cr>
nnoremap <silent><C-w>] :call SymbolOrTagOrSearchAll("definition", "split")<Cr>
nnoremap <silent><C-w><C-g> :call SymbolOrTagOrSearchAll("definition", "tabe")<Cr>
nnoremap <silent><C-w><C-]> :call SymbolOrTagOrSearchAll("definition", "split")<Cr>
" references
nnoremap <silent><M-/> :call SymbolOrTagOrSearchAll("references", "list")<Cr>
if AdvCompEngine()
    " declaration
    nnoremap <silent><M-C> :call SymbolOrTagOrSearchAll("declaration", "list")<Cr>
    " implementation
    nnoremap <silent><M-.> :call SymbolOrTagOrSearchAll("implementation", "list")<Cr>
    " typeDefinition
    nnoremap <silent><M-?> :call SymbolOrTagOrSearchAll("type_definition", "list")<Cr>
endif
