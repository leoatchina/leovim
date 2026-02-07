" Skip in VSCode environment
if utils#is_vscode()
    finish
endif
if pack#installed('vista.vim')
    let g:vista#renderer#ctags = 'kind'
    let g:vista_update_on_text_changed = 1
    let g:vista_sidebar_position = 'vertical topleft'
    let g:vista_sidebar_width = 35
    let g:vista_echo_cursor   = 0
    let g:vista_stay_on_open  = 0
    let g:vista_icon_indent   =  ["╰─▸ ", "├─▸ "]
    let g:vista_executive_for = {
                \ 'vimwiki': 'markdown',
                \ 'pandoc': 'markdown',
                \ 'markdown': 'toc',
                \ }
    if g:ctags_type != ''
        let g:vista_executive_for.go = 'ctags'
    endif
endif
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
" matchup
" --------------------------
nnoremap <silent>sm :MatchupWhereAmI??<Cr>
" --------------------------
" fuzzy_finder intergrated
" --------------------------
if get(g:, 'ctags_type', '') != ''
    let lst = g:root_patterns + ['lib', '.cache', 'package-lock.json']
    if utils#is_win()
        let s:fzf_tags_command = utils#expand("~/.leovim.windows/tools/ctags.exe")
    else
        let s:fzf_tags_command = 'ctags'
    endif
    let g:fzf_tags_command = s:fzf_tags_command . ' -R --exclude=' . join(lst, " --exclude=")
    if g:symbol_tool =~ 'leaderftags'
        let g:Lf_Ctags = g:fzf_tags_command
        nnoremap <silent><leader>T :LeaderfTag<Cr>
        nnoremap <silent>T<Cr> :LeaderfBufTagAll<Cr>
    elseif g:symbol_tool =~ 'fzftags' && executable('perl')
        nnoremap <silent><leader>T :FzfTags<Cr>
    elseif g:symbol_tool =~ 'ctrlptags'
        nnoremap <silent><leader>T :CtrlPTags<Cr>
    endif
    if g:complete_engine == 'coc' && utils#is_unix() && g:ctags_type != ''
        nnoremap <silent>t<Cr> :CocFzfList outline<Cr>
    elseif pack#installed('vista.vim') && g:ctags_type =~ 'Universal'
        nnoremap <silent>t<Cr> :Vista finder ctags<Cr>
    elseif g:symbol_tool =~ 'leaderftags'
        nnoremap <silent>t<Cr> :LeaderfBufTag<Cr>
    elseif g:symbol_tool =~ 'fzftags'
        nnoremap <silent>t<Cr> :FzfBTags<Cr>
    elseif g:symbol_tool =~ 'ctrlptags'
        nnoremap <silent>t<Cr> :CtrlPBufTag<Cr>
    endif
endif
" f<Cr> to useing native functions show
if pack#planned('vim-funky')
    command! QfFunky call funky#qf#show()
    if pack#installed('fzf', 'fzf.vim')
        command! FzfFunky call funky#fzf#show()
        nnoremap <silent>f<Cr> :w!<Cr>:FzfFunky<Cr>
    else
        nnoremap <silent>f<Cr> :w!<Cr>:QfFunky<Cr>
    endif
endif
" lsp tag show
if pack#installed_coc()
    nnoremap <silent><leader>t :Vista finder coc<Cr>
elseif pack#installed_lsp()
    nnoremap <silent><leader>t :Vista finder nvim_lsp<Cr>
endif
" -------------------------------
" vim-gutentags
" -------------------------------
set tags=./tags;,tags,./.tags;,.tags
let g:Lf_CacheDirectory = utils#expand("~/.vim", 1)
let g:gutentags_cache_dir = g:Lf_CacheDirectory . '/LeaderF/gtags'
if !isdirectory(g:gutentags_cache_dir)
    silent! call mkdir(g:gutentags_cache_dir, 'p')
endif
let g:gutentags_modules = []
if pack#planned('vim-gutentags')
    " exclude files
    let g:gutentags_ctags_exclude = ["*.min.js", "*.min.css", "build", "vendor", "node_modules", "*.vim/bundle/*", ".ccls_cache", "__pycache__"] + g:root_patterns
    " gutentags search project directory markers, stop recursion when encountering these files/directories
    let g:gutentags_project_root = g:root_patterns
    let g:gutentags_add_default_project_roots = 0
    let g:gutentags_define_advanced_commands = 1
    " name of generated data files
    let g:gutentags_ctags_tagfile = '.tags'
    " modules
    if g:ctags_type != ''
        let g:gutentags_modules += ['ctags']
        " configure ctags
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
                    if utils#is_win()
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
    nnoremap <leader>g<Space> :GutentagsDelTagsAndUpdate<Cr>
    command! GutentagsCommands call FzfCallCommands('GutentagsCommands', 'Gutentags')
    nnoremap <leader>g: :GutentagsCommands<Cr>
endif
" --------------------------
" gtags
" --------------------------
if pack#planned('gutentags_plus')
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
    if pack#installed_adv()
        nnoremap <silent><leader>gl :GscopeFind d <C-R><C-W><Cr>
        nnoremap <silent><leader>gh :GscopeFind c <C-R><C-W><Cr>
    else
        nnoremap <silent>gl :GscopeFind d <C-R><C-W><Cr>
        nnoremap <silent>gh :GscopeFind c <C-R><C-W><Cr>
    endif
    " file
    nnoremap <silent><leader>gf :GscopeFind f <C-R>=utils#expand("<cfile>")<Cr><Cr>
    nnoremap <silent><leader>gi :GscopeFind i <C-R>=utils#expand("<cfile>")<Cr><Cr>
    " kill
    nnoremap <silent><leader>gk :GscopeKill<Cr>
    " leaderfgtags
    if pack#planned_leaderf() && utils#is_unix()
        let g:Lf_Gtags = utils#expand(exepath('gtags'))
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
function! s:find_with_ctags(...)
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
function! s:lsp_tag_search(method, ...) abort
    let tagname = utils#expand('<cword>')
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
                if utils#planned('vim-quickui')
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
    elseif index(['definition', 'declaration', 'type_definition', 'implementation', 'references', 'tags'], method) < 0
        let method = 'definition'
    endif
    " --------------------------
    " open_position
    " --------------------------
    if a:0 == 1
        let open_action = a:1
        if index(['edit', 'tabe', 'split', 'vsplit', 'list'], open_action) < 0
            let open_action = 'edit'
        endif
    else
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
    elseif method == "tags"
        let lsp = 0
    else
        let lsp = 1
    endif
    " --------------------------
    " coc
    " --------------------------
    if pack#installed('coc.nvim') && lsp
        let commands_dict = {
                    \ 'definition' : 'jumpDefinition',
                    \ 'declaration' : 'jumpDeclaration',
                    \ 'type_definition' : 'jumpTypeDefinition',
                    \ 'implementation' : 'jumpImplementation',
                    \ 'references' : 'jumpReferences',
                    \ }
        let jump_command = commands_dict[method]
        try
            if open_action == 'list'
                let symbol_found = CocAction(jump_command, v:false)
            else
                if open_action == 'edit'
                    let symbol_found = CocAction(jump_command)
                else
                    let symbol_found = CocAction(jump_command, open_action)
                endif
                if symbol_found
                    call s:settagstack(winnr, tagname, pos)
                    call feedkeys("zz", "n")
                    echo "Found by coc " . jump_command
                endif
            endif
        catch /.*/
            let symbol_found = 0
        endtry
    " --------------------------
    " lsp
    " --------------------------
    elseif pack#installed_lsp() && lsp
        let cmd = printf('lua require("lsp").LspAction("%s", "%s")', method, open_action)
        call utils#execute(cmd)
        let symbol_found = get(g:, 'lsp_found', 0)
        if symbol_found
            call s:settagstack(winnr, tagname, pos)
            call feedkeys("zz", "n")
            echo "found by vim.lsp " . method
        endif
    else
        let symbol_found = 0
    endif
    " view_tags
    if !symbol_found && g:ctags_type != '' && method != 'references' && method != 'implementation'
        let symbol_found = s:find_with_ctags(tagname, open_action)
    endif
    " search_all_cmd
    if !symbol_found
        if get(g:, 'search_all_cmd', '') != ''
            if open_action == 'list'
                execute g:search_all_cmd . ' ' . tagname
            else
                call preview#errmsg('Not found by neither lsp nor tags, you should press <M-d> to do grep search.')
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
nnoremap <silent>g<Cr> :call <SID>lsp_tag_search("tags", "list")<Cr>
" preview
nnoremap <silent><C-h> :call <SID>lsp_tag_search("preview")<Cr>
" definition
au FileType help,vimdoc nnoremap <C-]> <C-]>
nnoremap <silent><C-g> :call <SID>lsp_tag_search("definition")<Cr>
nnoremap <silent><C-]> :call <SID>lsp_tag_search("definition", "vsplit")<Cr>
nnoremap <silent><M-d> :call <SID>lsp_tag_search("definition", "list")<Cr>
nnoremap <silent><C-w>g :call <SID>lsp_tag_search("definition", "tabe")<Cr>
nnoremap <silent><C-w>] :call <SID>lsp_tag_search("definition", "split")<Cr>
nnoremap <silent><C-w><C-g> :call <SID>lsp_tag_search("definition", "tabe")<Cr>
nnoremap <silent><C-w><C-]> :call <SID>lsp_tag_search("definition", "split")<Cr>
" references
nnoremap <silent><M-/> :call <SID>lsp_tag_search("references", "list")<Cr>
if pack#installed_adv()
    " declaration
    nnoremap <silent><M-D> :call <SID>lsp_tag_search("declaration", "list")<Cr>
    " implementation
    nnoremap <silent><M-.> :call <SID>lsp_tag_search("implementation", "list")<Cr>
    " typeDefinition
    nnoremap <silent><M-?> :call <SID>lsp_tag_search("type_definition", "list")<Cr>
endif

