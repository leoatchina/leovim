if Installed('ctrlsf.vim')
    let g:grep_tool = "ctrlsf"
    let g:ctrlsf_position='right'
    let g:ctrlsf_default_root='project'
    let g:ctrlsf_extra_root_markers=['.root', '.git', '.svn', '.hg']
    let g:ctrlsf_auto_close = {
                \ "normal" : 0,
                \ "compact": 0
                \ }
    nnoremap f<tab> :CtrlSF<Space>
    xnoremap f<tab> :<C-U>CtrlSF <C-R>=GetVisualSelection()<CR>
    nnoremap s<tab> :CtrlSFUpdate<Cr>
    xnoremap s<tab> :<C-U>CtrlSFUpdate<Cr>
    nnoremap q<tab> :CtrlSFToggle<Cr>
    xnoremap q<tab> :<C-U>CtrlSFToggle<Cr>
    nmap t<tab> <Plug>CtrlSFCwordPath
    xmap t<tab> <Plug>CtrlSFVwordPath
    nmap <M-f>/ <Plug>CtrlSFPwordPath
    nmap <M-f>b <Plug>CtrlSFCCwordPath
else
    let g:grep_tool = "far"
    if !exists('g:leovim_loaded')
        set rtp+=$ADDINS_PATH/far.vim
    endif
    let g:far#enable_undo=1
    nnoremap f<tab> :F <C-r><C-w>
    xnoremap f<tab> :<C-u>F <C-r>=GetVisualSelection()<Cr>
    nnoremap s<tab> :Farr<Cr>
    xnoremap s<tab> :<C-u>Farr<Cr>
    nnoremap t<tab> :Farf<Cr>
    xnoremap t<tab> :<C-u>Farf<Cr>
    " apply the far change
    au FileType far nnoremap <M-f>; :Fardo<Cr>
    au Filetype far nnoremap <M-f>. :Refar<Space>
    nnoremap <M-f>, :<C-u>Farundo<Cr>
endif
if !exists('g:leovim_loaded')
    set rtp+=$ADDINS_PATH/vim-grepper
endif
nmap gs <plug>(GrepperOperator)
xmap gs <plug>(GrepperOperator)
omap gs <plug>(GrepperOperator)
" leaderf or fzf using rg
if executable('rg')
    if !MACVIM() && Installed('LeaderF')
        let g:grep_tool .= "-leaderf"
    elseif Installed('coc.nvim')
        let g:grep_tool .= "-coc"
    endif
endif
if get(g:, 'grep_tool', '') =~ 'leaderf'
    if get(g:,'Lf_PreviewInPopup', 0) == 1
        let g:Lf_Rg_pos = "popup"
    else
        let g:Lf_Rg_pos = "bottom"
    endif
    " main
    nnoremap S :<C-R>=printf("Leaderf --%s rg -L %s", g:Lf_Rg_pos, expand("<cword>"))<CR><CR>
    nnoremap <leader>s :<C-R>=printf("Leaderf --%s rg -L %s", g:Lf_Rg_pos, expand("<cword>"))<CR>
    xnoremap <leader>s :<C-U><C-R>=printf("Leaderf --%s rg -L %s", g:Lf_Rg_pos, leaderf#Rg#visual())<CR>
    nnoremap <leader>/ :<C-R>=printf("Leaderf --%s rg -L ", g:Lf_Rg_pos)<CR><CR>
    xnoremap <leader>/ :<C-U><C-R>=printf("Leaderf --%s rg -L %s", g:Lf_Rg_pos, leaderf#Rg#visual())<CR>
    nnoremap <leader>. :Leaderf rg --recall<Cr>
    xnoremap <leader>. :<C-u>Leaderf rg --recall<Cr>
    " next prevous
    nnoremap <leader>; :Leaderf rg --next<Cr>
    xnoremap <leader>; :<C-U>Leaderf rg --next<Cr>
    nnoremap <leader>, :Leaderf rg --previous<Cr>
    xnoremap <leader>, :<C-U>Leaderf rg --previous<Cr>
    " M-f
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
    if get(g:, "grep_tool", '') =~ 'coc'
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
    let g:grep_tool .= '-fzf'
    if executable('rg')
        let s:fzf_flygrep_cmd  = 'FZFRg'
        let g:grep_tool .= 'rg'
    elseif executable('ag')
        let s:fzf_flygrep_cmd  = 'FZFAg'
        let g:grep_tool .= 'ag'
    elseif executable('git')
        let s:fzf_flygrep_cmd  = 'FZFGGrep'
        let g:grep_tool .= 'ggrep'
    else
        let s:fzf_flygrep_cmd  = 'FZFGrep'
        let g:grep_tool .= 'grep'
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
    nnoremap <leader>s :FZFSearchAll<Cr>
    " FZFSearchLast
    command! FZFSearchLast call s:fzf_flygrep(0)
    nnoremap <leader>. :FZFSearchLast<Cr>
    " FZFSearch
    command! -nargs=1 FZFSearch call s:fzf_flygrep(1, <f-args>)
    nnoremap S :FZFSearch <C-R><C-W><Cr>
    nnoremap <leader>s :FZFSearch <C-R><C-W>
    xnoremap <leader>s :<C-u>FZFSearch <C-R>=GetVisualSelection()<Cr>
    nnoremap <leader>/ :FZFSearch
    xnoremap <leader>/ :<C-u>FZFSearch <C-R>=GetVisualSelection()<Cr>
else
    let g:grep_tool .= '-grepper'
    let g:grepper = {'next_tool': 'S'}
    if executable('rg')
        let s:grepper_cmd = "GrepperRg"
    elseif executable('ag')
        let s:grepper_cmd = "GrepperAg"
    elseif executable('git')
        let s:grepper_cmd = "GrepperGit"
    elseif executable('ack')
        let s:grepper_cmd = "GrepperAck"
    elseif WINDOWS()
        let s:grepper_cmd = "GrepperFindstr"
    else
        let s:grepper_cmd = "GrepperGrep"
    endif
    execute("nnoremap S :" . s:grepper_cmd . " <C-R><C-W><Cr>")
    execute("nnoremap <leader>s :" . s:grepper_cmd . " <C-r><C-w>")
    execute("xnoremap <leader>s :<C-u>" . s:grepper_cmd . " <C-R>=GetVisualSelection()<Cr>")
    execute("nnoremap <leader>/ :" . s:grepper_cmd)
    execute("xnoremap <leader>/ :<C-u>" . s:grepper_cmd . " <C-R>=GetVisualSelection()<Cr>")
endif
