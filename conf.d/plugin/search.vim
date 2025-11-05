if PlannedFzf() && executable('rg')
    nnoremap <nowait><M-l><M-l> :FzfBLines<Cr>
elseif PlannedLeaderf()
    nnoremap <nowait><M-l><M-l> :Leaderf line --fuzzy --no-sort<Cr>
endif
if PlannedLeaderf()
    nnoremap <nowait><M-l><M-a> :Leaderf line --fuzzy --all --no-sort<Cr>
elseif PlannedFzf()
    nnoremap <nowait><M-l><M-a> :FzfLines<Cr>
else
    nnoremap <nowait><M-l><M-l> :CtrlPLine<Cr>
endif
" ----------------------------
" buffer search
" ----------------------------
function! s:search_cur(...)
    try
        if a:0 == 0
            let g:grepper_word = expand('<cword>')
        else
            let g:grepper_word = a:1
        endif
    catch /.*/
        let g:grepper_word = ""
    endtry
    if empty(g:grepper_word)
        call preview#errmsg("No search word offered")
    else
        try
            execute 'vimgrep /' . Escape(g:grepper_word) . "/j %"
            copen
        catch /.*/
            call preview#errmsg("vimgrep errors")
        endtry
    endif
endfunction
command! -nargs=? SearchCurrBuf call s:search_cur(<f-args>)
command! -nargs=0 SearchRepeat call s:search_cur(get(g:, 'grepper_word', ''))
nnoremap z/ :SearchCurrBuf <C-r><C-w><Cr>
xnoremap z/ :<C-u>SearchCurrBuf <C-r>=GetVisualSelection(1)<Cr><Cr>
nnoremap z. :SearchRepeat<CR>
nnoremap z\ :SearchCurrBuf <C-r><C-w>
xnoremap z\ :<C-u>SearchCurrBuf <C-r>=GetVisualSelection(1)<Cr>
nnoremap z? :SearchCurrBuf <C-r>=@"<Cr><Cr>
" ----------------------------
" grep search
" ----------------------------
if executable('rg')
    set grepprg=rg\ --line-number\ --no-heading\ --smart-case
    set grepformat=%f:%l:%m,%f:%l,%f:%m,%f
endif
function! s:grep(...)
    if a:0 == 0
        return
    elseif a:000[-1] == 1
        if a:0 == 1
            let g:grepper_word = get(g:, 'grep_last', '')
        else
            let g:grepper_word = Escape(a:1)
            let g:grep_last = g:grepper_word
        endif
        if executable('rg') && (!has('nvim') && WINDOWS() || UNIX())
            let cmd = printf('silent! grep %s', g:grepper_word)
        else
            let cmd = printf('vimgrep /%s/j **/*', g:grepper_word)
        endif
    elseif a:000[-1] == 2
        if a:0 == 1
            let g:grepper_word = get(g:, 'grepall_last', '')
        else
            let g:grepper_word = Escape(a:1)
            let g:grepall_last = g:grepper_word
        endif
        if executable('rg') && (!has('nvim') && WINDOWS() || UNIX())
            let cmd = printf('silent! grep %s %s', g:grepper_word, GetRootDir())
        else
            let cmd = printf('vimgrep /%s/j %s/**/*', g:grepper_word, GetRootDir())
        endif
    else
        return
    endif
    execute cmd
    if len(getqflist())
        copen
    endif
    if !has('nvim')
        redraw
    endif
endfunction
command! GrepLast call s:grep(1)
command! -nargs=1 Grep call s:grep(<q-args>, 1)
command! GrepAllLast call s:grep(2)
command! -nargs=1 GrepAll call s:grep(<q-args>, 2)
" search
nnoremap s<Cr> :Grep <C-r><C-w><Cr>
xnoremap s<Cr> :<C-u>Grep <C-r>=GetVisualSelection()<Cr><Cr>
nnoremap s[ :GrepLast<Cr>
nnoremap s] :Grep <C-r><C-w>
xnoremap s] :<C-u>Grep <C-r>=GetVisualSelection()<Cr>
" searchall
nnoremap s/ :GrepAll <C-r><C-w><Cr>
xnoremap s/ :<C-u>GrepAll <C-r>=GetVisualSelection()<Cr><Cr>
nnoremap s. :GrepAllLast<Cr>
nnoremap s\ :GrepAll <C-r><C-w>
xnoremap s\ :<C-u>GrepAll <C-r>=GetVisualSelection()<Cr>
nnoremap s? :GrepAll <C-r>=@"<Cr><Cr>
" --------------------------
" replace in filetype qf
" --------------------------
au Filetype qf nnoremap <buffer>r :cdo s/<C-r>=get(g:, 'grepper_word', '')<Cr>//gc<Left><Left><Left>
if Installed('quicker.nvim')
    au Filetype qf nnoremap <buffer>W :write
else
    au Filetype qf nnoremap <buffer>W :cfdo up
endif
" --------------------------
" FzfSearch
" --------------------------
if PlannedFzf()
    if executable('rg')
        command! -bang -nargs=* FzfBLines call fzf#vim#grep(
                    \ 'rg --with-filename --column --line-number --no-heading --smart-case . ' . fnameescape(expand('%:p')),
                    \ fzf#vim#with_preview({'options': ' --no-sort --layout reverse --query '.shellescape(<q-args>).' --with-nth=4.. --delimiter=":"'}),
                    \ 1)
        command! -bang -nargs=* FzfRg call fzf#vim#grep(
                    \ 'rg  --column --line-number --no-heading --color=always --smart-case ' . fzf#shellescape(<q-args>) . ' ./',
                    \ fzf#vim#with_preview({'options': ' --nth 4.. --delimiter=":"'}),
                    \ <bang>0)
        command! -bang -nargs=* FzfRoot call fzf#vim#grep(
                    \ 'rg  --column --line-number --no-heading --color=always --smart-case ' . fzf#shellescape(<q-args>) . ' ' . GetRootDir(),
                    \ fzf#vim#with_preview({'options': ' --nth 4.. --delimiter=":"'}),
                    \ <bang>0)
    endif
    if executable('git')
        command! -bang -nargs=* FzfGGrep call fzf#vim#grep(
                    \ 'git grep -I -n --color=always ' . fzf#shellescape(<q-args>) . ' -- ' . GitRootDir(),
                    \ fzf#vim#with_preview({'options': ' --nth 3..  --delimiter=":"'}),
                    \ <bang>0)
    endif
    if UNIX()
        command! -bang -nargs=* FzfGrep call fzf#vim#grep(
                    \ 'grep -I --line-number --color=always -r -- ' . fzf#shellescape(<q-args>) . ' . ',
                    \ fzf#vim#with_preview({'options': ' --nth 3..  --delimiter=":"'}),
                    \ <bang>0)
    elseif executable('findstr')
        command! -bang -nargs=* FzfGrep call fzf#vim#grep(
                    \ 'findstr /N /S /I ' . fzf#shellescape(<q-args>) . ' *.*',
                    \ fzf#vim#with_preview({'options': ' --nth 3..  --delimiter=":"'}),
                    \ <bang>0)
    endif
    function! s:fzf_search(...)
        if exists(':FzfRg')
            let fzf_cmd = 'FzfRg'
        else
            let fzf_cmd = 'FzfGrep'
        endif
        if a:0 == 0
            execute fzf_cmd
        elseif a:000[-1] == 1
            if a:0 == 1
                let search_str = get(g:, 'fzf_search_last', '')
            else
                let search_str = Escape(a:1)
                let g:fzf_search_last = search_str
            endif
        elseif a:000[-1] == 2
            if exists(':FzfRoot')
                let fzf_cmd = 'FzfRoot'
            endif
            if a:0 == 1
                let search_str = get(g:, 'fzf_searchall_last', '')
            else
                let search_str = Escape(a:1)
                let g:fzf_searchall_last = search_str
            endif
        elseif a:000[-1] == 3
            if GitRootDir() != ''
                let fzf_cmd = 'FzfGGrep'
            endif
            if a:0 == 1
                let search_str = get(g:, 'fzf_searchgit_last', '')
            else
                let search_str = Escape(a:1)
                let g:fzf_searchgit_last = search_str
            endif
        else
            return
        endif
        execute fzf_cmd . ' ' . search_str
    endfunction
    command! -nargs=0 FzfSearchLast call s:fzf_search(1)
    command! -nargs=? FzfSearch call s:fzf_search(<q-args>, 1)
    command! -nargs=0 FzfSearchAllLast call s:fzf_search(2)
    command! -nargs=? FzfSearchAll call s:fzf_search(<q-args>, 2)
    command! -nargs=0 FzfSearchGitLast call s:fzf_search(3)
    command! -nargs=? FzfSearchGit call s:fzf_search(<q-args>, 3)
    nnoremap <nowait><leader>/ :FzfSearch<Cr>
    nnoremap <nowait><leader>. :FzfSearchLast<Cr>
    nnoremap <nowait><leader>\ :FzfSearch <C-r><C-w>
    xnoremap <nowait><leader>\ :<C-u>FzfSearch <C-r>=GetVisualSelection()<Cr>
    nnoremap <nowait><leader>? :FzfSearch <C-r>=@"<Cr><Cr>
    nnoremap <nowait><Tab>/ :FzfSearchGit<Cr>
    nnoremap <nowait><Tab>. :FzfSearchGitLast<Cr>
    nnoremap <nowait><Tab>\ :FzfSearchGit <C-r><C-w>
    xnoremap <nowait><Tab>\ :<C-u>FzfSearchGit <C-r>=GetVisualSelection()<Cr>
    nnoremap <nowait><Tab>? :FzfSearchGit <C-r>=@"<Cr><Cr>
    nnoremap <nowait>\/ :FzfSearchAll<Cr>
    nnoremap <nowait>\. :FzfSearchAllLast<Cr>
    nnoremap <nowait>\\ :FzfSearchAll <C-r><C-w>
    xnoremap <nowait>\\ :<C-u>FzfSearchAll <C-r>=GetVisualSelection()<Cr>
    nnoremap <nowait>\? :FzfSearchAll <C-r>=@"<Cr><Cr>
endif
" ----------------------------
" leaderf search commands
" ----------------------------
if PlannedLeaderf() && executable('rg')
    let g:Lf_DefaultExternalTool = "rg"
    " LeaderfLast
    nnoremap <nowait><C-f>. :Leaderf rg --recal<Cr>
    " next/previous
    nnoremap <nowait><C-f>; :Leaderf rg --next<Cr>
    nnoremap <nowait><C-f>, :Leaderf rg --previous<Cr>
    " C-f map in bottom
    nnoremap <nowait><C-f>e :Leaderf rg --bottom --no-ignore -L -S -e --cword
    xnoremap <nowait><C-f>e :<C-u>Leaderf rg --bottom --no-ignore -L -S -e "<C-r>=GetVisualSelection()<Cr>"
    nnoremap <nowait><C-f>b :Leaderf rg --bottom --no-ignore -L -S --all-buffers --cword
    xnoremap <nowait><C-f>b :<C-u>Leaderf rg --bottom --no-ignore -L -S --all-buffers "<C-r>=GetVisualSelection()<Cr>"
    nnoremap <nowait><C-f>w :Leaderf rg --bottom --no-ignore -L -S -w --cword
    xnoremap <nowait><C-f>w :<C-u>Leaderf rg --bottom --no-ignore -L -S -w "<C-r>=GetVisualSelection()<Cr>"
    nnoremap <nowait><C-f>f :Leaderf rg --bottom --no-ignore -L -S -F --cword
    xnoremap <nowait><C-f>f :<C-u>Leaderf rg --bottom --no-ignore -L -S -F "<C-r>=GetVisualSelection()<Cr>"
    nnoremap <nowait><C-f>x :Leaderf rg --bottom --no-ignore -L -S -x --cword
    xnoremap <nowait><C-f>x :<C-u>Leaderf rg --bottom --no-ignore -L -S -x "<C-r>=GetVisualSelection()<Cr>"
    nnoremap <nowait><C-f>a :Leaderf rg --bottom --no-ignore --append --cword
    xnoremap <nowait><C-f>a :<C-u>Leaderf rg --bottom --no-ignore --append "<C-r>=GetVisualSelection()<Cr>"
    nnoremap <nowait><C-f>i :LeaderfRgInteractive<Cr>
    let g:Lf_RgConfig = [
                \ "--max-columns=10000",
                \ "--glob=!{.git,.svn,.hg,.project,.vscode,.idea,.vim}",
                \ "--hidden"
                \ ]
    let g:Lf_RgStorePattern = "e"
    nnoremap <C-f><Tab> :Leaderf rg --no-ignore<Space>
    function! s:todo_note(string, ...)
        let string = a:string[1:-2]
        let lst = split(string, "\|")
        call map(lst, 'v:val . ":"')
        call map(lst, '"\"" . v:val . "\""')
        let cmd = "Leaderf rg -e " . join(lst, " -e ")
        " NOTE:  --wd-mode=F means 'local only'
        if a:0 && a:1
            let cmd .= ' --wd-mode=F'
        endif
        execute cmd
    endfunction
    command! LeaderfTODO call s:todo_note(g:todo_patterns, 0)
    command! LeaderfNOTE call s:todo_note(g:note_patterns, 0)
    command! LeaderfTodo call s:todo_note(g:todo_patterns, 1)
    command! LeaderfNote call s:todo_note(g:note_patterns, 1)
    nnoremap <nowait><C-f>t :LeaderfTODO<Cr>
    nnoremap <nowait><C-f>n :LeaderfNOTE<Cr>
    nnoremap <nowait><C-f>T :LeaderfTodo<Cr>
    nnoremap <nowait><C-f>N :LeaderfNote<Cr>
    " leaderf_search
    function! s:leaderf_search(...) abort
        let cmd = 'Leaderf rg --no-ignore --bottom -L -S '
        " NOTE: a:1 == 'local only'
        if a:0 >= 2 && a:000[-1] == 1
            let cmd = cmd . ' --wd-mode=f'
            let cmd = cmd . ' ' . join(a:000[:-2])
        elseif a:0
            let cmd = cmd . ' ' . join(a:000)
        endif
        exec cmd
    endfunction
    command! -nargs=* -complete=dir LeaderfSearch call s:leaderf_search(<f-args>, 1)
    command! -nargs=* LeaderfSearchAll call s:leaderf_search(<f-args>)
    " map LeaderfSearch
    let g:search_all_cmd = 'LeaderfSearchAll'
    nnoremap <nowait><C-f>/ :LeaderfSearchAll <C-r><C-w><Cr>
    xnoremap <nowait><C-f>/ :<C-u>LeaderfSearchAll <C-r>=GetVisualSelection()<Cr><Cr>
    nnoremap <nowait><C-f>\ :LeaderfSearchAll <C-r><C-w>
    xnoremap <nowait><C-f>\ :<C-u>LeaderfSearchAll <C-r>=GetVisualSelection()<Cr>
    nnoremap <nowait><C-f>? :Leaderf rg --no-ignore --auto-preview -L -S <C-r>=@"<Cr>
    nnoremap <nowait><C-f><Cr> :LeaderfSearch <C-r><C-w><Cr>
    xnoremap <nowait><C-f><Cr> :<C-u>LeaderfSearch <C-r>=GetVisualSelection()<Cr><Cr>
    nnoremap <nowait><C-f><C-f> :LeaderfSearch <C-r><C-w>
    xnoremap <nowait><C-f><C-f> :<C-u>LeaderfSearch <C-r>=GetVisualSelection()<Cr>
    " flygrep
    nnoremap <nowait><C-f>] :Leaderf rg --no-ignore --auto-preview -L -S --cword<Cr>
    xnoremap <nowait><C-f>] :<C-u>Leaderf rg --no-ignore --auto-preview -L -S "<C-r>=GetVisualSelection()<Cr>"<Cr>
    nnoremap <nowait><C-f><C-]> :Leaderf rg --no-ignore --auto-preview -L -S --wd-mode=f --cword<Cr>
    xnoremap <nowait><C-f><C-]> :<C-u>Leaderf rg --no-ignore --auto-preview -L -S --wd-mode=f "<C-r>=GetVisualSelection()<Cr>"<Cr>
elseif exists(":FzfSearchAll")
    let g:search_all_cmd = 'FzfSearchAll'
    nnoremap <nowait><C-f><Cr> :FzfSearchAll <C-r><C-w><Cr>
    xnoremap <nowait><C-f><Cr> :<C-u>FzfSearchAll <C-r>=GetVisualSelection()<Cr>
else
    let g:search_all_cmd = 'GrepAll'
endif
" --------------------------------------
" search path && dir, ans set search-tool
" --------------------------------------
if PlannedLeaderf()
    if PlannedFzf()
        let g:search_tool = "leaderf-fzf-grep"
    else
        let g:search_tool = "leaderf-grep"
    endif
    nnoremap <nowait>\f/ :LeaderfSearchAll <C-r>=FileNameNoEXT()<Cr><Cr>
    nnoremap <nowait>\f\ :LeaderfSearchAll <C-r>=split(AbsDir(), "/")[-1]<Cr><Cr>
elseif PlannedFzf()
    let g:search_tool = "fzf-grep"
    nnoremap <nowait>\f/ :FzfSearchAll <C-r>=FileNameNoEXT()<Cr><Cr>
    nnoremap <nowait>\f\ :FzfSearchAll <C-r>=split(AbsDir(), "/")[-1]<Cr><Cr>
else
    let g:search_tool = "grep"
    nnoremap <nowait>\f/ :GrepAll <C-r>=FileNameNoEXT()<Cr><Cr>
    nnoremap <nowait>\f\ :GrepAll <C-r>=split(AbsDir(), "/")[-1]<Cr><Cr>
endif
if PlannedFzf()
    nnoremap <nowait><leader>f/ :FzfSearch <C-r>=FileNameNoEXT()<Cr><Cr>
    nnoremap <nowait><leader>f\ :FzfSearch <C-r>=split(AbsDir(), "/")[-1]<Cr><Cr>
    nnoremap <nowait><Tab>f/ :FzfSearchGit <C-r>=FileNameNoEXT()<Cr><Cr>
    nnoremap <nowait><Tab>f\ :FzfSearchGit <C-r>=split(AbsDir(), "/")[-1]<Cr><Cr>
    nnoremap <nowait>\g :FzfGitFiles <C-r>=@"<Cr>
    xnoremap <nowait>\g y:<C-u>FzfGitFiles <C-r>=GetVisualSelection()<Cr>
endif
