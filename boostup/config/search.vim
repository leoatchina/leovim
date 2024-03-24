if PrefFzf()
    nnoremap <silent><nowait><M-l><M-l> :FzfBLines<Cr>
    nnoremap <silent><nowait><M-l><M-a> :FzfLines<Cr>
elseif InstalledLeaderf()
    nnoremap <silent><nowait><M-l><M-l> :Leaderf line --no-sort<Cr>
    nnoremap <silent><nowait><M-l><M-a> :Leaderf line --all --no-sort<Cr>
else
    nnoremap <silent><nowait><M-l><M-l> :CtrlPLine<Cr>
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
            let t:grepper = expand('<cword>')
        else
            let t:grepper = a:1
        endif
    catch /.*/
        let t:grepper = ""
    endtry
    if empty(t:grepper)
        call preview#errmsg("No search word offered")
    else
        try
            execute 'vimgrep /' . t:grepper . "/j %"
            copen
        catch /.*/
            call preview#errmsg("vimgrep errors")
        endtry
    endif
endfunction
command! -nargs=? SearchCurrBuf call s:search_cur(<f-args>)
nnoremap \| :SearchCurrBuf <C-r><C-w><Cr>
xnoremap \| :<C-u>SearchCurrBuf <C-r>=GetVisualSelection()<Cr><Cr>
nnoremap s\ :SearchCurrBuf <C-r><C-w>
xnoremap s\ :<C-u>SearchCurrBuf <C-r>=GetVisualSelection()<Cr>
" ----------------------------
" grepsearch search
" ----------------------------
if executable('rg')
    set grepprg=rg\ --line-number\ --no-heading\ --smart-case
    set grepformat=%f:%l:%m,%f:%l,%f:%m,%f
    if InstalledLeaderf()
        nnoremap <C-f><Tab> :Leaderf rg --no-ignore<Space>
        if LINUX()
            let g:Lf_Rg = expand('~/.leovim.unix/linux/rg')
        elseif MACOS()
            let g:Lf_Rg = expand('~/.leovim.unix/macox/rg')
        elseif WINDOWS()
            let g:Lf_Rg = expand('~/.leovim.windows/tools/rg')
        endif
        function! s:todo_note(string, ...)
            let string = a:string[1:-2]
            let lst = split(string, "\|")
            call map(lst, 'v:val . ":"')
            call map(lst, '"\"" . v:val . "\""')
            let cmd = "Leaderf rg -e " . join(lst, " -e ")
            if a:0 && a:1 > 0
                let cmd .= ' --wd-mode=F'
            endif
            execute cmd
        endfunction
        command! TODO call s:todo_note(g:todo_patterns, 0)
        command! NOTE call s:todo_note(g:note_patterns, 0)
        command! Todo call s:todo_note(g:todo_patterns, 1)
        command! Note call s:todo_note(g:note_patterns, 1)
        nnoremap <silent><nowait><C-f>t :TODO<Cr>
        nnoremap <silent><nowait><C-f>n :NOTE<Cr>
        nnoremap <silent><nowait><C-f>T :Todo<Cr>
        nnoremap <silent><nowait><C-f>N :Note<Cr>
        let g:Lf_RgConfig = [
                    \ "--max-columns=10000",
                    \ "--glob=!{.git,.svn,.hg,.project}",
                    \ "--hidden"
                    \ ]
        let g:Lf_RgStorePattern = "e"
        " leaderf_search
        function! s:leaderf_search(all, ...) abort
            let cmd = 'Leaderf rg --no-ignore --bottom -L -S '
            if a:0 > 0
                let cmd = cmd . a:1
            endif
            if a:all == 0
                let cmd = cmd . ' --wd-mode=F'
            endif
            exec cmd
        endfunction
        command! -nargs=* LeaderfSearchAll call s:leaderf_search(1, <f-args>)
        command! -nargs=* LeaderfSearch    call s:leaderf_search(0, <f-args>)
    endif
endif
function! s:grep(...)
    if a:0 == 0
        return
    endif
    if a:0 == 1
        if a:1 == 1
            let t:grepper = get(g:, 'grepper_last', '')
        else
            let t:grepper = get(g:, 'grepper_all_last', '')
        endif
    elseif a:0 == 2
        let t:grepper = Escape(a:2)
        if a:1 == 1
            let g:grepper_last = t:grepper
        else
            let g:grepper_all_last = t:grepper
        endif
    endif
    " do the search
    if t:grepper == ''
        if a:0 == 1
            echo 'grep search last is empty'
        else
            echo 'grep search str is empty'
        endif
    else
        if a:1 == 1
            if executable('rg')
                let cmd = printf('silent! grep %s', t:grepper)
            else
                let cmd = printf('vimgrep /%s/j **/*', t:grepper)
            endif
        else
            if executable('rg')
                let cmd = printf('silent! grep %s %s', t:grepper, GetRootDir())
            else
                let cmd = printf('vimgrep /%s/j %s/**/*', t:grepper, GetRootDir())
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
nnoremap s; :GrepAll<Space>
" search
nnoremap s] :Grep <C-r><C-w><Cr>
xnoremap s] :<C-u>Grep <C-r>=GetVisualSelection()<Cr>
nnoremap s[ :GrepLast<Cr>
nnoremap s, :Grep<Space>
au FileType qf nnoremap <buffer>r :cdo s/<C-r>=get(t:, 'grepper', '')<Cr>//gc<Left><Left><Left>
au FileType qf nnoremap <buffer><M-r> :cdo s/<C-r>=get(t:, 'grepper', '')<Cr>//gc<Left><Left><Left>
au FileType qf nnoremap <buffer><M-S> :cfdo up
cnoremap <M-S> cfdo up
" --------------------------
" search all
" --------------------------
if InstalledFzf()
    if executable('rg')
        command! -bang -nargs=* FzfRG call fzf#vim#grep(
                    \ 'rg --vimgrep --no-heading --smart-case --color=always ' . shellescape(empty(<q-args>) ? '^' : <q-args>) . ' ' . FindRootDir(),
                    \ fzf#vim#with_preview(),
                    \ <bang>0)
    endif
    if executable('git')
        command! -bang -nargs=* FzfGGrep call fzf#vim#grep(
                    \ 'git grep -I -n --color=always ' . shellescape(empty(<q-args>) ? '^' : <q-args>) . ' -- ' . GitRootDir(),
                    \ fzf#vim#with_preview(),
                    \ <bang>0)
    endif
    if UNIX()
        command! -bang -nargs=* FzfGrep call fzf#vim#grep(
                    \ 'grep -I --line-number --color=always -r -- ' . shellescape(empty(<q-args>) ? '^' : <q-args>) . ' . ',
                    \ fzf#vim#with_preview(),
                    \ <bang>0)
    elseif executable('findstr')
        command! -bang -nargs=* FzfGrep call fzf#vim#grep(
                    \ 'findstr /N /S /I ' . shellescape(empty(<q-args>) ? '""' : <q-args>) . ' *.*',
                    \ fzf#vim#with_preview(),
                    \ <bang>0)
    endif
    function! s:fzf_search(...)
        " a:0 代表参数数量, a1 代表 第一个参数
        if a:0 == 0
            return
        endif
        if a:1 == 2
            let fzf_cmd = 'FzfGGrep'
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
if exists(":LeaderfSearchAll")
    let g:searchall = 'LeaderfSearchAll'
    if InstalledFzf()
        let g:search_tool = "fzf-leaderf"
    else
        let g:search_tool = "leaderf"
    endif
    nnoremap <C-f><Cr> :LeaderfSearchAll <C-r><C-w><Cr>
    xnoremap <C-f><Cr> :<C-u>LeaderfSearchAll <C-r>=GetVisualSelection()<Cr>
    nnoremap <C-f>] :LeaderfSearch <C-r><C-w><Cr>
    xnoremap <C-f>] :<C-u>LeaderfSearch <C-r>=GetVisualSelection()<Cr>
    nnoremap <C-f>/ :LeaderfSearchAll<Space>
    nnoremap <C-f>? :LeaderfSearch<Space>
    " recall previous next recall
    nnoremap <silent><nowait><C-f>; :Leaderf rg --next<Cr>
    nnoremap <silent><nowait><C-f>, :Leaderf rg --previous<Cr>
    nnoremap <silent><nowait><C-f>. :Leaderf rg --recal<Cr>
    " C-f map in bottom
    nnoremap <silent><nowait><C-f>e :Leaderf rg --bottom --no-ignore -L -S -e --cword
    xnoremap <silent><nowait><C-f>e :<C-u>Leaderf rg --bottom --no-ignore -L -S -e "<C-r>=GetVisualSelection()<Cr>"
    nnoremap <silent><nowait><C-f>b :Leaderf rg --bottom --no-ignore -L -S --all-buffers --cword
    xnoremap <silent><nowait><C-f>b :<C-u>Leaderf rg --bottom --no-ignore -L -S --all-buffers "<C-r>=GetVisualSelection()<Cr>"
    nnoremap <silent><nowait><C-f>w :Leaderf rg --bottom --no-ignore -L -S -w --cword
    xnoremap <silent><nowait><C-f>w :<C-u>Leaderf rg --bottom --no-ignore -L -S -w "<C-r>=GetVisualSelection()<Cr>"
    nnoremap <silent><nowait><C-f>f :Leaderf rg --bottom --no-ignore -L -S -F --cword
    xnoremap <silent><nowait><C-f>f :<C-u>Leaderf rg --bottom --no-ignore -L -S -F "<C-r>=GetVisualSelection()<Cr>"
    nnoremap <silent><nowait><C-f>x :Leaderf rg --bottom --no-ignore -L -S -x --cword
    xnoremap <silent><nowait><C-f>x :<C-u>Leaderf rg --bottom --no-ignore -L -S -x "<C-r>=GetVisualSelection()<Cr>"
    nnoremap <silent><nowait><C-f>a :Leaderf rg --bottom --no-ignore --append --cword
    xnoremap <silent><nowait><C-f>a :<C-u>Leaderf rg --bottom --no-ignore --append "<C-r>=GetVisualSelection()<Cr>"
    nnoremap <silent><nowait><C-f>i :LeaderfRgInteractive<Cr>
    " flygrep fuzzy mode
    nnoremap <silent><nowait>,/  :Leaderf rg --no-ignore --fuzzy -L -S --wd-mode=f<Cr>
    nnoremap <silent><nowait>,?  :Leaderf rg --no-ignore --fuzzy -L -S<Cr>
    nnoremap <silent><nowait>,\  :Leaderf rg --no-ignore --fuzzy -L -S --wd-mode=f --cword<Cr>
    nnoremap <silent><nowait>,\| :Leaderf rg --no-ignore --fuzzy -L -S --cword<Cr>
elseif InstalledFzf()
    let g:searchall = 'FzfSearchAll'
    let g:search_tool = 'fzf'
    " searchall
    nnoremap <silent><nowait><C-f><Cr> :FzfSearchAll <C-r><C-w><Cr>
    xnoremap <silent><nowait><C-f><Cr> :<C-u>FzfSearchAll <C-r>=GetVisualSelection()<Cr>
    nnoremap <silent><nowait><C-f>. :FzfSearchAllLast<Cr>
    nnoremap <silent><nowait><C-f>/ :FzfSearchAll<Space>
    " search
    nnoremap <silent><nowait><C-f>] :FzfSearch <C-r><C-w><Cr>
    xnoremap <silent><nowait><C-f>] :<C-u>FzfSearch <C-r>=GetVisualSelection()<Cr>
    nnoremap <silent><nowait><C-f>[ :FzfSearchLast<Cr>
    nnoremap <silent><nowait><C-f>? :FzfSearch<Space>
endif
" flygrep
if InstalledFzf()
    nnoremap <silent><nowait><leader>/  :FzfRg<Cr>
    nnoremap <silent><nowait><leader>?  :FzfGGrep<Cr>
    nnoremap <silent><nowait><leader>\  :FzfRg <C-r><C-w><Cr>
    nnoremap <silent><nowait><leader>\| :FzfGGrep <C-r><C-w><Cr>
    xnoremap <silent><nowait><leader>\  :<C-u>FzfRg "<C-r>=GetVisualSelection()<Cr>"<Cr>
    xnoremap <silent><nowait><leader>\| :<C-u>FzfGGrep "<C-r>=GetVisualSelection()<Cr>"<Cr>
    if exists(":LeaderfSearch")
        nnoremap <silent><nowait><Tab>/  :Leaderf rg --no-ignore --auto-preview -L -S --wd-mode=f<Cr>
        nnoremap <silent><nowait><Tab>?  :Leaderf rg --no-ignore --auto-preview -L -S<Cr>
        nnoremap <silent><nowait><Tab>\  :Leaderf rg --no-ignore --auto-preview -L -S --wd-mode=f --cword<Cr>
        nnoremap <silent><nowait><Tab>\| :Leaderf rg --no-ignore --auto-preview -L -S --cword<Cr>
        xnoremap <silent><nowait><Tab>\  :<C-u>Leaderf rg --no-ignore --auto-preview -L -S --wd-mode=f "<C-r>=GetVisualSelection()<Cr>"<Cr>
        xnoremap <silent><nowait><Tab>\| :<C-u>Leaderf rg --no-ignore --auto-preview -L -S "<C-r>=GetVisualSelection()<Cr>"<Cr>
    endif
elseif exists(":LeaderfSearch")
    nnoremap <silent><nowait><leader>/  :Leaderf rg --no-ignore --auto-preview -L -S --wd-mode=f<Cr>
    nnoremap <silent><nowait><leader>?  :Leaderf rg --no-ignore --auto-preview -L -S<Cr>
    nnoremap <silent><nowait><leader>\  :Leaderf rg --no-ignore --auto-preview -L -S --wd-mode=f --cword<Cr>
    nnoremap <silent><nowait><leader>\| :Leaderf rg --no-ignore --auto-preview -L -S --wd-mode=f<Cr>
    xnoremap <silent><nowait><leader>\  :<C-u>Leaderf rg --no-ignore --auto-preview -L -S --wd-mode=f "<C-r>=GetVisualSelection()<Cr>"<Cr>
    xnoremap <silent><nowait><leader>\| :<C-u>Leaderf rg --no-ignore --auto-preview -L -S "<C-r>=GetVisualSelection()<Cr>"<Cr>
endif
