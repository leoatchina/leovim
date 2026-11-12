" Skip in VSCode environment
if utils#is_vscode()
    finish
endif
if pack#installed_snacks()
    nnoremap <silent><nowait><M-l><M-l> <Cmd>lua Snacks.picker.lines()<Cr>
elseif pack#installed_leaderf()
    nnoremap <nowait><M-l><M-l> :Leaderf line --fuzzy --no-sort<Cr>
elseif pack#installed_fzf() && executable('rg')
    nnoremap <nowait><M-l><M-l> :FzfBLines<Cr>
endif
if pack#installed_leaderf()
    nnoremap <silent><nowait><M-l><M-a> :Leaderf line --fuzzy --all --no-sort<Cr>
elseif pack#installed_fzf()
    nnoremap <silent><nowait><M-l><M-a> :FzfLines<Cr>
endif
" ------------------------
" y register for replace
" ------------------------
xnoremap / "yy/<C-r>=utils#escape(@y)<CR><Cr>
xnoremap ? "yy?<C-r>=utils#escape(@y)<CR><Cr>
xnoremap <Cr> "yy:%s/<C-r>=utils#escape(@y)<CR>/<C-r>=utils#escape(@y)<CR>/gc<Left><Left><Left>
" ----------------------------
" buffer search
" ----------------------------
function! s:search_cur(...)
    try
        if a:0 == 0
            let g:grep_word = utils#get_cword()
        else
            let g:grep_word = a:1
        endif
    catch /.*/
        call preview#errmsg("No search word offered")
        return
    endtry
    execute 'vimgrep /' . utils#escape(g:grep_word) . "/j %"
    if len(getqflist())
        execute "copen " . g:asyncrun_open
    endif
endfunction
command! -nargs=? GrepBuf call s:search_cur(<f-args>)
command! -nargs=0 GrepBufLast call s:search_cur(get(g:, 'grep_word', ''))
nnoremap z\ :GrepBuf <C-r>=utils#get_cword()<Cr><Cr>
xnoremap z\ :<C-u>GrepBuf <C-r>=utils#get_visual()<Cr><Cr>
nnoremap z. :GrepBufLast<CR>
nnoremap z/ :GrepBuf <C-r>=utils#get_cword()<Cr>
xnoremap z/ :<C-u>GrepBuf <C-r>=utils#get_visual()<Cr>
nnoremap z? :GrepBuf <C-r>=utils#escape(@")<Cr><Cr>
" ----------------------------
" using rg to search
" ----------------------------
if executable('rg')
    " NOTE: use --line-number --column instead of --vimgrep so that old rg versions work too
    set grepprg=rg\ --line-number\ --column\ --no-heading\ --smart-case\ --color=never
endif
function! s:grep(...)
    if a:0 == 0
        return
    endif
    let mode = a:000[-1]
    if mode == 1
        if a:0 == 1
            let g:grep_word = get(g:, 'grep_last', '')
        else
            let g:grep_word = a:1
            let g:grep_last = g:grep_word
        endif
    elseif mode == 2
        if a:0 == 1
            let g:grep_word = get(g:, 'grepall_last', '')
        else
            let g:grep_word = a:1
            let g:grepall_last = g:grep_word
        endif
    else
        return
    endif
    if executable('rg')
        if mode == 1
            let search_dir = '.'
        else
            let search_dir = utils#get_root_dir()
        endif
        let rg_cmd = &grepprg . ' ' . shellescape(g:grep_word) . ' ' . shellescape(search_dir)
        let lines = systemlist(rg_cmd)
        let qfl = []
        for l in lines
            if empty(l)
                continue
            endif
            " rg output: file:line:col:text, Windows: D:file:line:col:text
            " text itself may contain ':', so only match the prefix, take the rest as text
            if utils#is_win()
                let l = substitute(l, '\r', '', 'g')
            endif
            let m = matchlist(l, '^\v%([a-zA-Z]:)?(\f+):(\d+)(:(\d+))?:')
            if empty(m)
                continue
            endif
            let data = {'filename': m[1], 'lnum': m[2], 'col': m[4] != '' ? m[4] : 0, 'text': strpart(l, strlen(m[0]))}
            call add(qfl, data)
        endfor
        if !empty(qfl)
            call setqflist(qfl, 'r')
            execute "copen " . g:asyncrun_open
        endif
    else
        if mode == 1
            let cmd = printf('vimgrep /%s/j **/*', utils#escape(g:grep_word))
        else
            let cmd = printf('vimgrep /%s/j %s/**/*', utils#escape(g:grep_word), utils#get_root_dir())
        endif
        execute cmd
        if len(getqflist())
            execute "copen " . g:asyncrun_open
        endif
    endif
endfunction
command! GrepCurLast call s:grep(1)
command! -nargs=1 GrepCur call s:grep(<q-args>, 1)
command! GrepAllLast call s:grep(2)
command! -nargs=1 GrepAll call s:grep(<q-args>, 2)
" search
nnoremap s\ :GrepCur <C-r><C-w><Cr>
xnoremap s\ :<C-u>GrepCur <C-r>=utils#get_visual()<Cr><Cr>
nnoremap s[ :GrepCurLast<Cr>
nnoremap s] :GrepCur <C-r><C-w>
xnoremap s] :<C-u>GrepCur <C-r>=utils#get_visual()<Cr>
nnoremap s} :GrepCur <C-r>=@"<Cr><Cr>
" searchall
nnoremap s<Cr> :GrepAll <C-r><C-w><Cr>
xnoremap s<Cr> :<C-u>GrepAll <C-r>=utils#get_visual()<Cr><Cr>
nnoremap s. :GrepAllLast<Cr>
nnoremap s/ :GrepAll <C-r><C-w>
xnoremap s/ :<C-u>GrepAll <C-r>=utils#get_visual()<Cr>
nnoremap s? :GrepAll <C-r>=@"<Cr><Cr>
" --------------------------
" replace in filetype qf
" --------------------------
au Filetype qf nnoremap <buffer>r :cdo! s/<C-r>=get(g:, 'grep_word', '')<Cr>//ge<Left><Left><Left>
au Filetype qf nnoremap <buffer>R :cdo! s/<C-r>=get(g:, 'grep_word', '')<Cr>//gc<Left><Left><Left>
au Filetype qf nnoremap <buffer>W :cfdo! up
" --------------------------
" <leader>: search from get_root (utils#get_root_dir), \: from git root, <Tab>: from cwd
" --------------------------
if pack#installed_snacks()
    nnoremap <nowait><leader>/ <Cmd>lua Snacks.picker.grep({ dirs = { vim.fn['utils#get_root_dir']() } })<Cr>
    nnoremap <nowait><leader>. <Cmd>lua Snacks.picker.resume()<Cr>
    nnoremap <nowait><leader>\ <Cmd>lua Snacks.picker.grep({ search = vim.fn.expand('<cword>'), dirs = { vim.fn['utils#get_root_dir']() } })<Cr>
    xnoremap <nowait><leader>\ :<C-u>lua Snacks.picker.grep({ search = vim.fn['utils#get_visual'](), dirs = { vim.fn['utils#get_root_dir']() } })<Cr>
    nnoremap <nowait><leader>? <Cmd>lua Snacks.picker.grep({ search = vim.fn.getreg('"'), dirs = { vim.fn['utils#get_root_dir']() } })<Cr>
    nnoremap <nowait><leader>f/ <Cmd>lua Snacks.picker.grep({ search = vim.fn.expand('%:t:r'), dirs = { vim.fn['utils#get_root_dir']() } })<Cr>
    nnoremap <nowait><leader>f\ <Cmd>lua Snacks.picker.grep({ search = vim.fn.expand('%:p:h:t'), dirs = { vim.fn['utils#get_root_dir']() } })<Cr>
    nnoremap <nowait><Tab>/ <Cmd>lua Snacks.picker.grep({ dirs = { vim.fn.getcwd() } })<Cr>
    nnoremap <nowait><Tab>. <Cmd>lua Snacks.picker.resume()<Cr>
    nnoremap <nowait><Tab>\ <Cmd>lua Snacks.picker.grep({ search = vim.fn.expand('<cword>'), dirs = { vim.fn.getcwd() } })<Cr>
    xnoremap <nowait><Tab>\ :<C-u>lua Snacks.picker.grep({ search = vim.fn['utils#get_visual'](), dirs = { vim.fn.getcwd() } })<Cr>
    nnoremap <nowait><Tab>? <Cmd>lua Snacks.picker.grep({ search = vim.fn.getreg('"'), dirs = { vim.fn.getcwd() } })<Cr>
    nnoremap <nowait><Tab>f/ <Cmd>lua Snacks.picker.grep({ search = vim.fn.expand('%:t:r'), dirs = { vim.fn.getcwd() } })<Cr>
    nnoremap <nowait><Tab>f\ <Cmd>lua Snacks.picker.grep({ search = vim.fn.expand('%:p:h:t'), dirs = { vim.fn.getcwd() } })<Cr>
    nnoremap <nowait>\/ <Cmd>lua Snacks.picker.grep({ dirs = { vim.fn['utils#get_vcs_dir']() } })<Cr>
    nnoremap <nowait>\. <Cmd>lua Snacks.picker.resume()<Cr>
    nnoremap <nowait>\\ <Cmd>lua Snacks.picker.grep({ search = vim.fn.expand('<cword>'), dirs = { vim.fn['utils#get_vcs_dir']() } })<Cr>
    xnoremap <nowait>\\ :<C-u>lua Snacks.picker.grep({ search = vim.fn['utils#get_visual'](), dirs = { vim.fn['utils#get_vcs_dir']() } })<Cr>
    nnoremap <nowait>\? <Cmd>lua Snacks.picker.grep({ search = vim.fn.getreg('"'), dirs = { vim.fn['utils#get_vcs_dir']() } })<Cr>
    nnoremap <nowait>\f/ <Cmd>lua Snacks.picker.grep({ search = vim.fn.expand('%:t:r'), dirs = { vim.fn['utils#get_vcs_dir']() } })<Cr>
    nnoremap <nowait>\f\ <Cmd>lua Snacks.picker.grep({ search = vim.fn.expand('%:p:h:t'), dirs = { vim.fn['utils#get_vcs_dir']() } })<Cr>
elseif pack#installed_fzf()
    nnoremap <nowait><leader>/ :FzfSearchAll<Cr>
    nnoremap <nowait><leader>. :FzfSearchAllLast<Cr>
    nnoremap <nowait><leader>\ :FzfSearchAll <C-r><C-w>
    xnoremap <nowait><leader>\ :<C-u>FzfSearchAll <C-r>=utils#get_visual()<Cr>
    nnoremap <nowait><leader>? :FzfSearchAll <C-r>=@"<Cr><Cr>
    nnoremap <nowait><leader>f/ :FzfSearchAll <C-r>=utils#file_name_no_ext()<Cr><Cr>
    nnoremap <nowait><leader>f\ :FzfSearchAll <C-r>=utils#basename(utils#abs_dir())<Cr><Cr>
    nnoremap <nowait><Tab>/ :FzfSearch<Cr>
    nnoremap <nowait><Tab>. :FzfSearchLast<Cr>
    nnoremap <nowait><Tab>\ :FzfSearch <C-r><C-w>
    xnoremap <nowait><Tab>\ :<C-u>FzfSearch <C-r>=utils#get_visual()<Cr>
    nnoremap <nowait><Tab>? :FzfSearch <C-r>=@"<Cr><Cr>
    nnoremap <nowait><Tab>f/ :FzfSearch <C-r>=utils#file_name_no_ext()<Cr><Cr>
    nnoremap <nowait><Tab>f\ :FzfSearch <C-r>=utils#basename(utils#abs_dir())<Cr><Cr>
    nnoremap <nowait>\/ :FzfSearchGit<Cr>
    nnoremap <nowait>\. :FzfSearchGitLast<Cr>
    nnoremap <nowait>\\ :FzfSearchGit <C-r><C-w>
    xnoremap <nowait>\\ :<C-u>FzfSearchGit <C-r>=utils#get_visual()<Cr>
    nnoremap <nowait>\? :FzfSearchGit <C-r>=@"<Cr><Cr>
    nnoremap <nowait>\f/ :FzfSearchGit <C-r>=utils#file_name_no_ext()<Cr><Cr>
    nnoremap <nowait>\f\ :FzfSearchGit <C-r>=utils#basename(utils#abs_dir())<Cr><Cr>
endif
let s:search_tool = []
if pack#installed_leaderf() && executable('rg')
    call add(s:search_tool, 'leaderf')
endif
if pack#installed_snacks()
    call add(s:search_tool, 'snacks')
elseif pack#installed_fzf()
    call add(s:search_tool, 'fzf')
endif
call add(s:search_tool, 'grep')
let g:search_tool = join(s:search_tool, '-')
