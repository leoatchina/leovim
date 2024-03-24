if PrefFzf()
    nnoremap <silent><leader>m :FzfHistory<Cr>
elseif InstalledLeaderf()
    nnoremap <silent><leader>m :LeaderfMru<Cr>
else
    nnoremap <silent><leader>m :CtrlPMRU<Cr>
endif
" --------------------------
" undo
" --------------------------
if Installed('nvim-fundo')
    lua require('fundo').setup()
endif
" undotree
if Installed('undotree')
    let g:undotree_WindowLayout = 4
    nnoremap <leader>u :UndotreeToggle<Cr>
endif
" ------------------------------
" Fzf jumps
" ------------------------------
if PrefFzf()
    function! s:jump_list_format(val) abort
        let l:file_name = bufname('%')
        let l:file_name = empty(l:file_name) ? 'Unknown file name' : l:file_name
        let l:curpos = getcurpos()
        let l:l = matchlist(a:val, '\(>\?\)\s*\(\d*\)\s*\(\d*\)\s*\(\d*\) \?\(.*\)')
        let [l:mark, l:jump, l:line, l:col, l:content] = l:l[1:5]
        if empty(Trim(l:mark)) | let l:mark = '-' | endif
        if filereadable(Expand(fnameescape(l:content)))
            let l:file_name = Expand(l:content)
            let l:bn = bufnr(l:file_name)
            if l:bn > -1 && buflisted(l:bn) > 0
                let l:content = getbufline(l:bn, l:line)
                let l:content = empty(l:content) ? "" : l:content[0]
            else
                let l:content = system("sed -n " . l:line . "p " . l:file_name)
            endif
        elseif empty(Trim(l:content))
            if empty(Trim(l:line))
                let [l:line, l:col] = l:curpos[1:2]
            endif
            let l:content = getline(l:line, l:line)[0]
        endif
        return l:mark . " " . l:file_name . ":" . l:line . ":" . l:col . " " . l:content
    endfunction
    function! s:jump_list() abort
        let l:jl = Execute('jumps')
        return map(reverse(split(l:jl, '\n')[1:]), 's:jump_list_format(v:val)')
    endfunction
    function! s:jump_handler(jp) abort
        let l:l = matchlist(a:jp, '\(.\)\s\(.*\):\(\d\+\):\(\d\+\)\(.*\)')
        let [l:file_name, l:line, l:col, l:content] = l:l[2:5]
        if empty(l:file_name) || empty(l:line) | return | endif
        " 判断文件是否已经存在 buffer 中
        let l:bn = bufnr(l:file_name)
        " 未打开
        if l:bn == -1
            if filereadable(l:file_name)
                execute 'e ' . 'l:file_name'
            endif
        else
            execute 'buffer ' . l:bn
        endif
        call cursor(str2nr(l:line), str2nr(l:col))
        normal! zvzz
    endfunction
    function! s:fzf_jumps() abort
        call fzf#run(fzf#wrap({
                    \ 'source': s:jump_list(),
                    \ 'sink': function('s:jump_handler'),
                    \ 'options': [
                        \ '--prompt=Jumps>'
                        \ ],
                        \ }))
    endfunction
    command! -bang -nargs=* FzfJumps call s:fzf_jumps()
    nnoremap <silent><M-j><M-j> :FzfJumps<cr>
    nnoremap <silent><M-k>/ :FzfHistory/<Cr>
    nnoremap <silent><M-k>: :FzfHistory:<Cr>
elseif Installed('leaderf')
    nnoremap <silent><M-j><M-j> :Leaderf jumps<cr>
    nnoremap <silent><M-k>/ :LeaderfHistorySearch<Cr>
    nnoremap <silent><M-k>: :LeaderfHistoryCmd<Cr>
endif
