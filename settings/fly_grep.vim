if Installed('ctrlsf.vim')
    let g:fly_grep = "ctrlsf"
    let g:ctrlsf_position='right'
    let g:ctrlsf_default_root='project'
    let g:ctrlsf_extra_root_markers=['.root', '.git', '.svn', '.hg']
    let g:ctrlsf_auto_close = {
                \ "normal" : 0,
                \ "compact": 0
                \ }
    nnoremap <M-j>/ :CtrlSF<Space>
    nnoremap <M-j>, :CtrlSF <C-R><C-w>
    xnoremap <M-j>, :<C-U>CtrlSF <C-R>=GetVisualSelection()<CR>
    nnoremap <M-j>; :CtrlSF<Cr>
    xnoremap <M-j>; :<C-U>CtrlSF<Cr>
    nnoremap <M-j>. :CtrlSFUpdate<Cr>
    nnoremap <M-j>c :CtrlSFToggle<Cr>
    xmap <M-f>/ <Plug>CtrlSFVwordPath
    nmap <M-f>/ <Plug>CtrlSFCwordPath
    nmap <M-f>; <Plug>CtrlSFPwordPath
    nmap <M-f>, <Plug>CtrlSFCCwordPath
endif
if executable('rg')
    if !MACVIM() && Installed('LeaderF')
        if get(g:, 'fly_grep', '') == ''
            let g:fly_grep = "leaderf"
        else
            let g:fly_grep .= "-leaderf"
        endif
    elseif Installed('coc.nvim')
        if get(g:, 'fly_grep', '') == ''
            let g:fly_grep = "coc"
        else
            let g:fly_grep .= "-coc"
        endif
    endif
endif
if get(g:, 'fly_grep', '') =~ 'leaderf'
    if get(g:,'Lf_PreviewInPopup', 0) == 1
        let g:Lf_Rg_pos = "popup"
    else
        let g:Lf_Rg_pos = "bottom"
    endif
    nnoremap <leader>. :Leaderf rg --recall<Cr>
    nnoremap <leader>/ :<C-R>=printf("Leaderf --%s rg -L ",   g:Lf_Rg_pos)<CR><CR>
    xnoremap <leader>; :<C-U><C-R>=printf("Leaderf --%s rg -L %s", g:Lf_Rg_pos, leaderf#Rg#visual())<CR><CR>
    nnoremap <leader>; :<C-R>=printf("Leaderf --%s rg -L %s", g:Lf_Rg_pos, expand("<cword>"))<CR><CR>
    xnoremap <leader>, :<C-U><C-R>=printf("Leaderf --%s rg -L %s", g:Lf_Rg_pos, leaderf#Rg#visual())<CR>
    nnoremap <leader>, :<C-R>=printf("Leaderf --%s rg -L %s", g:Lf_Rg_pos, expand("<cword>"))<CR>
    nnoremap <M-f>s :<C-r>=printf("Leaderf! --stayOpen --right rg -L")<CR>
    xnoremap <M-f>c :<C-U><C-R>=printf("Leaderf! --stayOpen --right rg -L --current-buffer %s", leaderf#Rg#visual())<CR>
    nnoremap <M-f>c :<C-R>=printf("Leaderf! --stayOpen --right rg -L --current-buffer %s", expand("<cword>"))<CR>
    xnoremap <M-f>e :<C-U><C-R>=printf("Leaderf! --stayOpen --right rg -L -e %s", leaderf#Rg#visual())<CR>
    nnoremap <M-f>e :<C-R>=printf("Leaderf! --stayOpen --right rg -L -e %s", expand("<cword>"))<CR>
    xnoremap <M-f>w :<C-U><C-R>=printf("Leaderf! --stayOpen --right rg -L -w %s", leaderf#Rg#visual())<CR>
    nnoremap <M-f>w :<C-R>=printf("Leaderf! --stayOpen --right rg -L -w %s", expand("<cword>"))<CR>
    xnoremap <M-f>f :<C-U><C-R>=printf("Leaderf! --stayOpen --right rg -L -F %s", leaderf#Rg#visual())<CR>
    nnoremap <M-f>f :<C-R>=printf("Leaderf! --stayOpen --right rg -L -F %s", expand("<cword>"))<CR>
    xnoremap <M-f>x :<C-U><C-R>=printf("Leaderf! --stayOpen --right rg -L -x %s", leaderf#Rg#visual())<CR>
    nnoremap <M-f>x :<C-R>=printf("Leaderf! --stayOpen --right rg -L -x %s", expand("<cword>"))<CR>
    xnoremap <M-f>a :<C-U><C-R>=printf("Leaderf! --stayOpen --right rg --append %s ", leaderf#Rg#visual())<CR>
    nnoremap <M-f>a :<C-R>=printf("Leaderf! --stayOpen --right rg --append %s ", expand("<cword>"))<CR>
elseif g:fuzzy_finder != 'ctrlp'
    if get(g:, "fly_grep", '') =~ 'coc'
        nnoremap <M-f>s :CocSearch -S -L<Space>
        nnoremap <M-f>c :CocSearch -S -L <C-R>=expand("<cword>")<CR><CR>
        xnoremap <M-f>c :<C-U>CocSearch -S -L <C-R>=GetVisualSelection()<CR><CR>
        nnoremap <M-f>e :CocSearch -S -L -e <C-R>=expand("<cword>")<CR>
        xnoremap <M-f>e :<C-U>CocSearch -S -L -e <C-R>=GetVisualSelection()<CR>
        nnoremap <M-f>w :CocSearch -S -L -w <C-R>=expand("<cword>")<CR>
        xnoremap <M-f>w :<C-U>CocSearch -S -L -w <C-R>=GetVisualSelection()<CR>
        nnoremap <M-f>f :CocSearch -S -L -F <C-R>=expand("<cword>")<CR>
        xnoremap <M-f>f :<C-U>CocSearch -S -L -F <C-R>=GetVisualSelection()<CR>
        nnoremap <M-f>x :CocSearch -S -L -x <C-R>=expand("<cword>")<CR>
        xnoremap <M-f>x :<C-U>CocSearch -S -L -x <C-R>=GetVisualSelection()<CR>
    endif
    if get(g:, 'fly_grep', '') == ''
        let g:fly_grep  = 'fzf'
    else
        let g:fly_grep .= '-fzf'
    endif
    if executable('rg')
        let s:fzf_flygrep_cmd  = 'FZFRg'
        let g:fly_grep .= 'rg'
    elseif executable('ag')
        let s:fzf_flygrep_cmd  = 'FZFAg'
        let g:fly_grep .= 'ag'
    elseif executable('git')
        let s:fzf_flygrep_cmd  = 'FZFGGrep'
        let g:fly_grep .= 'ggrep'
    else
        let s:fzf_flygrep_cmd  = 'FZFGrep'
        let g:fly_grep .= 'grep'
    endif
    function! s:fzf_flygrep(...)
        let fzf_flygrep_cmd = s:fzf_flygrep_cmd
        if a:0 > 2
            execute fzf_flygrep_cmd
        endif
        if a:0 == 0
            execute fzf_flygrep_cmd
        else
            if a:0 == 1 || a:1 == 0
                let search = get(g:, 'fzf_last_search', '')
            else
                let search = substitute(a:2, '[\/]\+$', '', '')
                let g:fzf_last_search = search
            endif
            execute fzf_flygrep_cmd . ' ' . search
        endif
    endfunction
    " FZFSearchAll
    command! FZFSearchAll call s:fzf_flygrep()
    nnoremap <leader>/ :FZFSearchAll<Cr>
    " FZFSearchLast
    command! FZFSearchLast call s:fzf_flygrep(0)
    nnoremap <leader>. :FZFSearchLast<Cr>
    " FZFSearch
    command! -nargs=1 FZFSearch call s:fzf_flygrep(1, <f-args>)
    nnoremap <leader>; :FZFSearch <C-R><C-W><Cr>
    xnoremap <leader>; :<C-u>FZFSearch <C-R>=GetVisualSelection()<Cr><Cr>
    nnoremap <leader>, :FZFSearch <C-R><C-W>
    xnoremap <leader>, :<C-u>FZFSearch <C-R>=GetVisualSelection()<Cr>
endif
