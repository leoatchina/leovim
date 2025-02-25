" ---------------------------------
" git global set
" ---------------------------------
if executable('git') && get(g:, 'header_field_author', '') != '' && get(g:, 'header_field_author_email', '') != ''
    command! GitSet execute(printf(
                \ '!git config --global user.name "%s" && git config --global user.email "%s"',
                \ g:header_field_author,
                \ g:header_field_author_email))
    nnoremap <M-g>S :GitSet<Cr>
endif
"------------------------
" git related function
"------------------------
function! GitBranch()
    return get(b:, 'git_branch', '')
endfunction
function! GitRootDir()
    return get(b:, 'git_root_dir', '')
endfunction
function! UpdateBufGit()
    if WINDOWS()
        let idx = -1
    else
        let idx = 0
    endif


    if g:git_version > 1.8
        " 确保在当前buffer目录下执行git命令
        let l:cur_dir = expand('%:p:h')
        if l:cur_dir != ''
            execute 'lcd ' . l:cur_dir
        endif
        try
            " 使用静默模式执行git命令
            let l:git_root = system('git -C ' . shellescape(l:cur_dir) . ' rev-parse --show-toplevel 2>/dev/null')
            let b:git_root_dir = substitute(l:git_root, '\n\+$', '', '')

            if v:shell_error != 0 || b:git_root_dir =~ 'fatal:' || b:git_root_dir == ''
                let b:git_root_dir = ''
                let b:git_branch = ''
            else
                try
                    let l:branch = system('git -C ' . shellescape(l:cur_dir) . ' rev-parse --abbrev-ref HEAD 2>/dev/null')
                    let b:git_branch = substitute(l:branch, '\n\+$', '', '')

                    if v:shell_error != 0 || b:git_branch =~ 'fatal:' || b:git_branch == ''
                        let b:git_root_dir = ''
                        let b:git_branch = ''
                    endif
                catch /.*/
                    let b:git_root_dir = ''
                    let b:git_branch = ''
                endtry
            endif
        catch /.*/
            let b:git_root_dir = ''
            let b:git_branch = ''
        endtry
        " 恢复到之前的目录
        if l:cur_dir != ''
            execute 'lcd -'
        endif
    else
        let b:git_root_dir = ''
        let b:git_branch = ''
    endif

endfunction
autocmd WinEnter,BufCreate,BufEnter * call UpdateBufGit()
"------------------------
" fugitve and others
"------------------------
if Planned('vim-fugitive')
    nnoremap <silent><M-g>a :Git add -A<CR>
    nnoremap <silent><M-g>u :Git push<CR>
    nnoremap <silent><M-g><Cr> :Git commit -av<Cr>
    nnoremap <M-G>  :Git
    nnoremap <M-g>U :Git push<Space>
    " compare with history version
    let g:fugitive_summary_format = "%as-[%an]: %s"
    nnoremap <silent>g\ :Git log --pretty=format:"%h\|\|%as-[%an]: %s" -- %<cr>
    au FileType git nnoremap <silent><buffer><tab> 0"ayiw:bw<cr>:rightbelow Gvdiff <c-r>a<cr>
    au FileType git nnoremap <silent><buffer><space> 0"ayiw:bw<cr>:rightbelow Gdiff <c-r>a<cr>
    au FileType git nnoremap <silent><buffer>q <Nop>
    au FileType git nnoremap <silent><buffer>\ <Nop>
    " git diff
    nnoremap <silent><M-g>] :Gvdiffsplit!<Cr>
    nnoremap <silent><M-g>[ :Gdiffsplit!<Cr>
    " GV
    if Planned('GV.vim')
        nnoremap <silent><M-g>! :GV!<Cr>
        nnoremap <silent><M-g>v :GV<Cr>
        nnoremap <silent><M-g>? :GV?<Cr>
        xnoremap <silent><M-g>v :GV<Cr>
        xnoremap <silent><M-g>? :GV?<Cr>
        au FileType GV nmap <buffer><nowait><Space> .
        au FileType GV nmap <buffer><nowait><Tab> O
        au FileType GV nmap <buffer><nowait><M-q> q
        au FileType GV nmap <buffer><nowait>Q q
        au FileType GV nmap <buffer><nowait>, gb
    endif
    " buffer map
    au FileType fugitiveblame nnoremap <buffer><silent><nowait>q :quit<Cr>
    au FileType fugitive,git nnoremap <silent><buffer><nowait>q :q!<Cr>
    au FileType fugitive,git nnoremap <silent><buffer><nowait>Q :q!<Cr>
    au FileType fugitive,git nnoremap <silent><buffer><nowait><M-q> :q!<Cr>
    au FileType fugitive nnoremap <buffer><nowait>gg gg
    au FileType fugitive nmap <buffer><nowait><Space> =
    au FileType fugitive nmap <buffer><nowait><Tab> -
    au FileType fugitive nmap <buffer><nowait>, g?
    au FileType fugitive nmap <buffer><nowait>\ c?
else
    nnoremap <silent><M-g>v :vdiffsplit<Cr>
    nnoremap <silent><M-g>s :diffsplit<Cr>
    if Installed('asyncrun.vim') && g:has_terminal && UNIX()
        nnoremap <silent><M-g>a :AsyncRun -mode=term -focus=1 add -A<Cr>
        nnoremap <silent><M-g>u :AsyncRun -mode=term -focus=1 git push<Cr>
        nnoremap <silent><M-g><Cr> :AsyncRun -mode=term -focus=1 git commit -a -m ""<Left>
        nnoremap <M-G> :AsyncRun -mode=term -focus=1 git
        nnoremap <M-g>U :AsyncRun -mode=term -focus=1 git push<Space>
    else
        nnoremap <silent><M-g>a :!git add -A<Cr>
        nnoremap <silent><M-g>u :!git push<Cr>
        nnoremap <silent><M-g><Cr> :!git commit -a -m ""<Left>
        nnoremap <M-G> :!git
        nnoremap <M-g>U :!git push<Space>
    endif
endif
" blamer on left
if PlannedLeaderf()
    nnoremap <silent><M-g>i :Leaderf git<Cr>
    nnoremap <silent><M-g>h :Leaderf git diff HEAD --directly<Cr>
    nnoremap <silent><M-g>l :Leaderf git log<Cr>
    nnoremap <silent><M-g>o :Leaderf git log --current-file<Cr>
    nnoremap <silent>g\| :Leaderf git diff --current-file --side-by-side<Cr>
    nnoremap <silent>g<Tab> :Leaderf git blame<Cr>
elseif Installed('vim-fugitive')
    nnoremap <silent>g<Tab> :Git blame<Cr>
endif
" inline blame
if Installed('blamer.nvim')
    let g:blamer_date_format = '%Y/%m/%d'
    let g:blamer_show_in_insert_modes = 0
    let g:blamer_prefix = ' >> '
    let g:blamer_delay = 500
    nnoremap <silent>g<Cr> :BlamerToggle<Cr>
    command! GCommands call FzfCallCommands('GCommands','LeaderfGit','G', ['LeaderfGitInlineBlame', 'Gutentag', 'Grep', 'Get'])
elseif PlannedLeaderf()
    if has('patch-9.0.200') || has('nvim')
        nnoremap <silent>g<Cr> :LeaderfGitInlineBlameToggle<Cr>
        command! GCommands call FzfCallCommands('GCommands','LeaderfGit','G', ['Gutentag', 'Grep', 'Get'])
    else
        command! GCommands call FzfCallCommands('GCommands','LeaderfGit','G', ['LeaderfGitInlineBlame', 'Gutentag', 'Grep', 'Get'])
    endif
else
    command! GCommands call FzfCallCommands('GCommands', 'G', ['Gutentag', 'Grep', 'Get'])
endif
nnoremap <silent><M-g>: :GCommands<Cr>
" ---------------------------------
" lazygit intergrated
" ---------------------------------
if Installed('vim-floaterm') && executable('lazygit')
    command! GLazyGit exec "FloatermNew --height=0.9 --width=0.9 --title=lazygit --wintype=float --position=center lazygit"
    if has('nvim')
        nnoremap <silent><M-g>f :GLazyGit<Cr>
    else
        nnoremap <silent><M-g>f :GLazyGit<Cr>i
    endif
endif
"########## Merge ##########{{{
let s:mergeSources = {
            \  'L':      1,
            \  'LOCAL':  1,
            \  'B':      2,
            \  'BASE':   2,
            \  'R':      3,
            \  'REMOTE': 3,
            \  'M':      4,
            \  'MERGE':  4,
            \}
function! s:createMergeTab(...)
    " Map source name to buffer number
    if a:0 > 0
        let l:sources = []
        for item in a:000
            if has_key(s:mergeSources, toupper(item))
                call add(l:sources, get(s:mergeSources, toupper(item)))
            else
                echo 'Unrecognized source: ' . item
                return
            endif
        endfor
    else
        let l:sources = [1, 4, 3]
    endif
    let l:mergeBufIndex = max([index(l:sources, 4), 0]) + 1
    tabnew
    let i = 0
    while i < len(l:sources) - 1
        exec 'buf ' . l:sources[i]
        rightbelow vsp
        let i = i + 1
    endwhile
    exec 'buf ' . l:sources[i]
    windo diffthis
    exec l:mergeBufIndex . 'wincmd w'
endfunc
command! -nargs=* GMergeTab call s:createMergeTab(<f-args>)
nnoremap <M-g>m :GMergeTab<space>
" -----------------------------------------------------
" vim-signify
" -----------------------------------------------------
if has('nvim') || has('patch-8.0.902')
    let g:signify_disable_by_default = 0
    function! s:SignifyDiff()
        SignifyDiff
        if winnr('$') == 2
            wincmd H
        endif
    endfunction
    nnoremap \| :call <SID>SignifyDiff()<CR>
    nnoremap \<Tab> :SignifyToggle<Cr>
    nnoremap \<Space> :SignifyRefresh<Cr>
    nmap ;g <plug>(signify-next-hunk)
    nmap ,g <plug>(signify-prev-hunk)
    omap im <plug>(signify-motion-inner-pending)
    xmap im <plug>(signify-motion-inner-visual)
    omap am <plug>(signify-motion-outer-pending)
    xmap am <plug>(signify-motion-outer-visual)
    nmap <leader>vm vim
    nmap <leader>vM vam
    PlugAddOpt 'vim-signify'
    " commands
    command! SignifyCommands call FzfCallCommands('SignifyCommands', 'Signify')
    nnoremap \: :SignifyCommands<Cr>
endif
