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
" ----------------------------------
" ufo
" ----------------------------------
if Installed('nvim-ufo', 'promise-async')
    lua require('ufo').setup()
else
    PlugAddOpt 'vim-searchindex'
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
nnoremap \| :SearchCurrBuf <C-r><C-w><Cr>
xnoremap \| :<C-u>SearchCurrBuf <C-r>=GetVisualSelection(1)<Cr><Cr>
nnoremap s\ :SearchCurrBuf <C-r><C-w>
xnoremap s\ :<C-u>SearchCurrBuf <C-r>=GetVisualSelection(1)<Cr>
" ----------------------------
" grepsearch search
" ----------------------------
if executable('rg')
    set grepprg=rg\ --line-number\ --no-heading\ --smart-case
    set grepformat=%f:%l:%m,%f:%l,%f:%m,%f
endif
function! s:grep(...)
    if a:0 == 0
        return
    endif
    if a:0 == 1
        if a:1 < 1
            return
        endif
        if a:1 == 1
            let g:grepper_word = get(g:, 'grepper_last', '')
        else
            let g:grepper_word = get(g:, 'grepper_all_last', '')
        endif
    elseif a:0 == 2
        if a:1 < 1
            return
        endif
        let g:grepper_word = a:2
        if a:1 == 1
            let g:grepper_last = g:grepper_word
        else
            let g:grepper_all_last = g:grepper_word
        endif
    endif
    " do the search
    if g:grepper_word == ''
        if a:0 == 1
            echo 'grep search last is empty'
        else
            echo 'grep search str is empty'
        endif
    else
        if a:1 == 1
            if executable('rg')
                let cmd = printf('silent! grep! %s', g:grepper_word)
            else
                let cmd = printf('vimgrep /%s/j **/*', Escape(g:grepper_word))
            endif
        else
            if executable('rg')
                let cmd = printf('silent! grep! %s %s', g:grepper_word, GetRootDir())
            else
                let cmd = printf('vimgrep /%s/j %s/**/*', Escape(g:grepper_word), GetRootDir())
            endif
        endif
        execute cmd
        if len(getqflist())
            copen
        endif
    endif
endfunction
command! GrepLast call s:grep(1)
command! -nargs=1 Grep call s:grep(1, <q-args>)
command! GrepAllLast call s:grep(2)
command! -nargs=1 GrepAll call s:grep(2, <q-args>)
" searchall
nnoremap s<Cr> :GrepAll <C-r><C-w><Cr>
xnoremap s<Cr> :<C-u>GrepAll <C-r>=GetVisualSelection()<Cr>
nnoremap s. :GrepAllLast<Cr>
nnoremap s/ :GrepAll<Space>
" search
nnoremap s] :Grep <C-r><C-w><Cr>
xnoremap s] :<C-u>Grep <C-r>=GetVisualSelection()<Cr>
nnoremap s[ :GrepLast<Cr>
nnoremap s? :Grep<Space>
au FileType qf nnoremap <buffer>r :cdo s/<C-r>=get(g:, 'grepper_word', '')<Cr>//gc<Left><Left><Left>
au FileType qf nnoremap <buffer><M-r> :cdo s/<C-r>=get(g:, 'grepper_word', '')<Cr>//gc<Left><Left><Left>
au FileType qf nnoremap <buffer><M-S> :cfdo up
cnoremap <M-S> cfdo up
" --------------------------
" FzfSearch
" --------------------------
if PlannedFzf()
    if executable('rg')
        command! -bang -nargs=* FzfBLines
                    \ call fzf#vim#grep(
                    \ 'rg --with-filename --column --line-number --no-heading --smart-case . '.fnameescape(expand('%:p')), 1,
                    \ fzf#vim#with_preview({'options': ' --no-sort --layout reverse --query '.shellescape(<q-args>).' --with-nth=4.. --delimiter=":"'}))
        command! -bang -nargs=* FzfRg call fzf#vim#grep(
                    \ 'rg  --column --line-number --no-heading --color=always --smart-case ' . fzf#shellescape(<q-args>),
                    \ fzf#vim#with_preview({'options': ' --no-sort --nth 4.. --delimiter=":"'}),
                    \ <bang>0)
        command! -bang -nargs=* FzfRoot call fzf#vim#grep(
                    \ 'rg  --column --line-number --no-heading --color=always --smart-case ' . fzf#shellescape(<q-args>) . ' ' . GetRootDir(),
                    \ fzf#vim#with_preview({'options': ' --no-sort --nth 4.. --delimiter=":"'}),
                    \ <bang>0)
        nnoremap <nowait><C-f>/ :FzfRoot<Space>
        xnoremap <nowait><C-f>/ :<C-u>FzfRoot <C-r>=GetVisualSelection()<Cr>
    endif
    if executable('git')
        command! -bang -nargs=* FzfGGrep call fzf#vim#grep(
                    \ 'git grep -I -n --color=always ' . fzf#shellescape(<q-args>) . ' -- ' . GitRootDir(),
                    \ fzf#vim#with_preview({'options': ' --no-sort --nth 3..  --delimiter=":"'}),
                    \ <bang>0)
    endif
    if UNIX()
        command! -bang -nargs=* FzfGrep call fzf#vim#grep(
                    \ 'grep -I --line-number --color=always -r -- ' . fzf#shellescape(<q-args>) . ' . ',
                    \ fzf#vim#with_preview({'options': ' --no-sort --nth 3..  --delimiter=":"'}),
                    \ <bang>0)
    elseif executable('findstr')
        command! -bang -nargs=* FzfGrep call fzf#vim#grep(
                    \ 'findstr /N /S /I ' . fzf#shellescape(<q-args>) . ' *.*',
                    \ fzf#vim#with_preview({'options': ' --no-sort --nth 3..  --delimiter=":"'}),
                    \ <bang>0)
    endif
    function! s:fzf_search(...)
        " a:0 代表参数数量, a1 代表 第一个参数
        if a:0 == 0
            return
        endif
        if a:1 == 2 && GitBranch() != ''
            let fzf_cmd = 'FzfGGrep'
        elseif a:1 == 2 && executable('rg')
            let fzf_cmd = 'FzfRoot'
        elseif executable('rg')
            let fzf_cmd = 'FzfRg'
        elseif exists(":FzfGrep")
            let fzf_cmd = 'FzfGrep'
        else
            return
        endif
        if a:1 == 0
            " FzfFlyGrep
            execute fzf_cmd
        else
            if a:0 == 1
                if a:1 == 1
                    let search_str = get(g:, 'fzf_search_last', '')
                else
                    let search_str = get(g:, 'fzf_searchall_last', '')
                endif
            elseif a:0 == 2
                let search_str = Escape(a:2)
                if a:1 == 1
                    let g:fzf_search_last = search_str
                else
                    let g:fzf_searchall_last = search_str
                endif
            endif
            " do the search
            if search_str == ''
                if a:0 == 1
                    echo 'fzf search last is empty'
                else
                    echo 'fzf search str is empty'
                endif
            else
                execute fzf_cmd . ' ' . search_str
            endif
        endif
    endfunction
    command! FzfFlyGrep call s:fzf_search(0)
    command! FzfSearchLast call s:fzf_search(1)
    command! -nargs=1 FzfSearch call s:fzf_search(1, <q-args>)
    command! FzfSearchAllLast call s:fzf_search(2)
    command! -nargs=1 FzfSearchAll call s:fzf_search(2, <q-args>)
endif
" ----------------------------
" leaderf search commands
" ----------------------------
if LINUX()
    let g:Lf_Rg = expand('~/.leovim.unix/linux/rg')
elseif MACOS()
    let g:Lf_Rg = expand('~/.leovim.unix/macox/rg')
elseif WINDOWS()
    let g:Lf_Rg = expand('~/.leovim.windows/tools/rg')
endif
if PlannedLeaderf() && filereadable(g:Lf_Rg)
    let g:Lf_RgConfig = [
                \ "--max-columns=10000",
                \ "--glob=!{.git,.svn,.hg,.project}",
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
        " NOTE: a:1 == 'local only'
        if a:0 && a:1 > 0
            let cmd .= ' --wd-mode=F'
        endif
        execute cmd
    endfunction
    command! TODO call s:todo_note(g:todo_patterns, 0)
    command! NOTE call s:todo_note(g:note_patterns, 0)
    command! Todo call s:todo_note(g:todo_patterns, 1)
    command! Note call s:todo_note(g:note_patterns, 1)
    nnoremap <nowait><C-f>t :TODO<Cr>
    nnoremap <nowait><C-f>n :NOTE<Cr>
    nnoremap <nowait><C-f>T :Todo<Cr>
    nnoremap <nowait><C-f>N :Note<Cr>
    " leaderf_search
    function! s:leaderf_search(...) abort
        let cmd = 'Leaderf rg --no-ignore --bottom -L -S '
        " NOTE: a:1 == 'local only'
        if a:0 >= 2 && a:000[-1] == 1
            let cmd = cmd . ' --wd-mode=F'
            let cmd = cmd . ' ' . join(a:000[:-2])
        elseif a:0
            let cmd = cmd . ' ' . join(a:000)
        endif
        exec cmd
    endfunction
    command! -nargs=* -complete=dir LeaderfSearch call s:leaderf_search(<f-args>, 1)
    command! -nargs=* LeaderfSearchAll call s:leaderf_search(<f-args>)
    nnoremap <nowait><C-f>; :Leaderf rg --next<Cr>
    nnoremap <nowait><C-f>, :Leaderf rg --previous<Cr>
    nnoremap <nowait><C-f>. :Leaderf rg --recal<Cr>
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
    " flygrep fuzzy mode
    nnoremap <nowait>,/  :Leaderf rg --no-ignore --fuzzy -L -S --wd-mode=f<Cr>
    nnoremap <nowait>,?  :Leaderf rg --no-ignore --fuzzy -L -S<Cr>
    nnoremap <nowait>,\  :Leaderf rg --no-ignore --fuzzy -L -S --wd-mode=f --cword<Cr>
    nnoremap <nowait>,\| :Leaderf rg --no-ignore --fuzzy -L -S --cword<Cr>
endif
" ---------------------------------
" maps make full use of fzf leaderf
" ---------------------------------
if PlannedFzf()
    " search
    nnoremap <nowait><C-f>] :FzfSearch <C-r><C-w><Cr>
    xnoremap <nowait><C-f>] :<C-u>FzfSearch <C-r>=GetVisualSelection()<Cr>
    nnoremap <nowait><C-f>[ :FzfSearchLast<Cr>
    if exists(":LeaderfSearchAll")
        let g:searchall = 'LeaderfSearchAll'
        nnoremap <nowait><C-f><Cr> :LeaderfSearchAll <C-r><C-w><Cr>
        xnoremap <nowait><C-f><Cr> :<C-u>LeaderfSearchAll <C-r>=GetVisualSelection()<Cr>
        nnoremap <nowait><C-f><C-f> :LeaderfSearch <C-r><C-w><Space>
        xnoremap <nowait><C-f><C-f> :<C-u>LeaderfSearch <C-r>=GetVisualSelection()<Cr>
        nnoremap <nowait><C-f>? :LeaderfSearchAll<Space>
    else
        let g:searchall = 'FzfSearchAll'
        " searchall
        nnoremap <nowait><C-f><Cr> :FzfSearchAll <C-r><C-w><Cr>
        xnoremap <nowait><C-f><Cr> :<C-u>FzfSearchAll <C-r>=GetVisualSelection()<Cr>
        nnoremap <nowait><C-f>. :FzfSearchAllLast<Cr>
    endif
else
    let g:searchall = 'GrepAll'
endif
" flygrep
if PlannedFzf()
    nnoremap <nowait><leader>/  :FzfRg<Cr>
    nnoremap <nowait><leader>?  :FzfGGrep<Cr>
    nnoremap <nowait><leader>\  :FzfRg <C-r><C-w><Cr>
    nnoremap <nowait><leader>\| :FzfGGrep <C-r><C-w><Cr>
    xnoremap <nowait><leader>\  :<C-u>FzfRg "<C-r>=GetVisualSelection()<Cr>"<Cr>
    xnoremap <nowait><leader>\| :<C-u>FzfGGrep "<C-r>=GetVisualSelection()<Cr>"<Cr>
    if exists(":LeaderfSearch")
        nnoremap <nowait><Tab>/  :Leaderf rg --no-ignore --auto-preview -L -S --wd-mode=f<Cr>
        nnoremap <nowait><Tab>?  :Leaderf rg --no-ignore --auto-preview -L -S<Cr>
        nnoremap <nowait><Tab>\  :Leaderf rg --no-ignore --auto-preview -L -S --wd-mode=f --cword<Cr>
        nnoremap <nowait><Tab>\| :Leaderf rg --no-ignore --auto-preview -L -S --cword<Cr>
        xnoremap <nowait><Tab>\  :<C-u>Leaderf rg --no-ignore --auto-preview -L -S --wd-mode=f "<C-r>=GetVisualSelection()<Cr>"<Cr>
        xnoremap <nowait><Tab>\| :<C-u>Leaderf rg --no-ignore --auto-preview -L -S "<C-r>=GetVisualSelection()<Cr>"<Cr>
    endif
elseif exists(":LeaderfSearch")
    nnoremap <nowait><leader>/  :Leaderf rg --no-ignore --auto-preview -L -S --wd-mode=f<Cr>
    nnoremap <nowait><leader>?  :Leaderf rg --no-ignore --auto-preview -L -S<Cr>
    nnoremap <nowait><leader>\  :Leaderf rg --no-ignore --auto-preview -L -S --wd-mode=f --cword<Cr>
    nnoremap <nowait><leader>\| :Leaderf rg --no-ignore --auto-preview -L -S --wd-mode=f<Cr>
    xnoremap <nowait><leader>\  :<C-u>Leaderf rg --no-ignore --auto-preview -L -S --wd-mode=f "<C-r>=GetVisualSelection()<Cr>"<Cr>
    xnoremap <nowait><leader>\| :<C-u>Leaderf rg --no-ignore --auto-preview -L -S "<C-r>=GetVisualSelection()<Cr>"<Cr>
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
    nnoremap <nowait><C-f>p :LeaderfSearchAll <C-r>=Expand("%:t:r")<Cr><Cr>
    nnoremap <nowait><C-f>d :LeaderfSearchAll <C-r>=split(Expand("%:p:h"), "/")[-1]<Cr><Cr>
elseif PlannedFzf()
    let g:search_tool = "fzf-grep"
    nnoremap <nowait><C-f>p :FzfSearchAll <C-r>=Expand("%:t:r")<Cr><Cr>
    nnoremap <nowait><C-f>d :FzfSearchAll <C-r>=split(Expand("%:p:h"), "/")[-1]<Cr><Cr>
else
    let g:search_tool = "grep"
endif
