" -------------------------------
" vim-gutentags
" -------------------------------
if !exists('g:gutentags_modules')
    let g:gutentags_modules = []
endif
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
function! gutentags#delete_tags() abort
    if exists("b:gutentags_files")
        let del_cmds = []
        let col = col('.')
        let line = line('.')
        for [key, path] in items(b:gutentags_files)
            if filereadable(path)
                if utils#is_win()
                    let cmd = printf('!del %s /a /q', path)
                else
                    let cmd = printf('!rm -f %s', path)
                endif
                call add(del_cmds, cmd)
            endif
        endfor
        for del_cmd in del_cmds
            silent! exec del_cmd
        endfor
        call cursor(line, col)
    endif
    if exists('*lightline#update')
        call lightline#update()
    endif
endfunction
command! -bar GutentagsDelTags call gutentags#delete_tags()
command! GutentagsDelTagsAndUpdate GutentagsDelTags | GutentagsUpdate
nnoremap <leader>g<Cr> :GutentagsUpdate<Cr>
nnoremap <leader>g<Space> :GutentagsDelTagsAndUpdate<Cr>
command! GutentagsCommands call FzfCallCommands('GutentagsCommands', 'Gutentags')
nnoremap <leader>g: :GutentagsCommands<Cr>
" --------------------------
" gtags
" --------------------------
if pack#planned('gutentags_plus')
    if has('cscope')
        let g:gutentags_plus_native = 1
        set cscopeprg=gtags-cscope
    else
        let g:gutentags_plus_native = 0
    endif
    let g:gutentags_modules += ['gtags_cscope']
    let g:gutentags_define_advanced_commands = 1
    let g:gutentags_plus_switch = 1
    let g:gutentags_plus_nomap  = 1
    nnoremap <silent><leader>gs :GscopeFind s <C-R><C-W><Cr>
    nnoremap <silent><leader>gg :GscopeFind g <C-R><C-W><Cr>
    nnoremap <silent><leader>gt :GscopeFind t <C-R><C-W><Cr>
    nnoremap <silent><leader>ge :GscopeFind e <C-R><C-W><Cr>
    nnoremap <silent><leader>ga :GscopeFind a <C-R><C-W><Cr>
    nnoremap <silent><leader>gz :GscopeFind z <C-R><C-W><Cr>
    " file
    nnoremap <silent><leader>gf :GscopeFind f <C-R>=utils#expand("<cfile>")<Cr><Cr>
    nnoremap <silent><leader>gi :GscopeFind i <C-R>=utils#expand("<cfile>")<Cr><Cr>
    " Only the native backend maintains persistent cscope connections.
    if has('cscope')
        nnoremap <silent><leader>gk :GscopeKill<Cr>
    endif
    " hierarchy
    if pack#installed_adv()
        nnoremap <silent><leader>gl :GscopeFind d <C-R><C-W><Cr>
        nnoremap <silent><leader>gh :GscopeFind c <C-R><C-W><Cr>
    else
        nnoremap <silent>gl :GscopeFind d <C-R><C-W><Cr>
        nnoremap <silent>gh :GscopeFind c <C-R><C-W><Cr>
    endif
    " leaderfgtags
    if pack#planned_leaderf() && utils#is_unix()
        let g:Lf_Gtags = utils#expand(exepath('gtags'))
        let g:Lf_Gtagsconf = $GTAGSCONF
        let g:Lf_Gtagslabel = get(g:, 'Lf_Gtagslabel', $GTAGSLABEL)
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
endif
