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
" ----------------------------------------------------------------------
" git related functions
" ----------------------------------------------------------------------
function! GitBranch()
    return get(b:, 'git_branch', '')
endfunction
function! GitRootDir()
    return get(b:, 'git_root_dir', '')
endfunction
function! LcdAndGitUpdate() abort
    if FtBtIgnored() || tolower(getbufvar(winbufnr(winnr()), '&ft')) =~ 'fern' || tolower(getbufvar(winbufnr(winnr()), '&bt')) == 'nofile'
        return
    endif
    try
        let l:cur_dir = AbsDir()
        if l:cur_dir != ''
            execute 'lcd ' . l:cur_dir
        endif
    catch
        return
    endtry
    if g:git_version > 1.8
        try
            let l:git_root = system('git -C ' . l:cur_dir . ' rev-parse --show-toplevel')
            let b:git_root_dir = substitute(l:git_root, '\n\+$', '', '')
            if v:shell_error != 0 || b:git_root_dir =~ 'fatal:' || b:git_root_dir == ''
                let b:git_root_dir = ''
                let b:git_branch = ''
            else
                let l:branch = system('git -C ' . l:cur_dir . ' rev-parse --abbrev-ref HEAD')
                " TODO: change branch icon according to branch status, referring https://www.nerdfonts.com/cheat-sheet
                let icon = ' '
                let b:git_branch = icon . substitute(l:branch, '\n\+$', '', '')
                if v:shell_error != 0 || b:git_branch =~ 'fatal:' || b:git_branch == ''
                    let b:git_root_dir = ''
                    let b:git_branch = ''
                endif
            endif
        catch
            let b:git_root_dir = ''
            let b:git_branch = ''
        endtry
    else
        let b:git_root_dir = ''
        let b:git_branch = ''
    endif
endfunction
augroup LcdAndGitUpdate
    au!
    autocmd BufWinEnter * call LcdAndGitUpdate()
augroup END
" ----------------------
" relative dir && path
" ----------------------
function! RelativeDir() abort
    let absdir = AbsDir()
    let gitroot = GitRootDir()
    if gitroot != '' && len(absdir) > len(gitroot)
        return gitroot
    else
        return absdir
    endif
endfunction
function! RelativePath() abort
    let abspath = AbsPath()
    let gitroot = GitRootDir()
    if gitroot != '' && len(abspath) > len(gitroot)
        return abspath[len(gitroot)+1:]
    else
        return Expand("%:t", 1)
    endif
endfunction
"------------------------
" fugitve and others
"------------------------
if Planned('vim-fugitive')
    nnoremap <silent><Tab><Tab> :Git blame -w<Cr>
    nnoremap <silent><M-g>a :Git add -A<CR>
    nnoremap <silent><M-g>u :Git push<CR>
    nnoremap <silent><M-g><M-u> :Git push<CR>
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
    " buffer map, nnoremap
    au FileType fugitiveblame nnoremap <buffer><silent><nowait>q :quit<Cr>
    au FileType fugitive,git nnoremap <silent><buffer><nowait>q :q!<Cr>
    au FileType fugitive,git nnoremap <silent><buffer><nowait>Q :q!<Cr>
    au FileType fugitive,git nnoremap <silent><buffer><nowait><M-q> :q!<Cr>
    au FileType fugitive nnoremap <buffer><nowait>gg gg
    " buffer map, nmap
    au FileType fugitiveblame nmap <buffer><silent><nowait><Cr> o
    au FileType fugitive nmap <buffer><nowait><Space> =
    au FileType fugitive nmap <buffer><nowait><Tab> -
    au FileType fugitive nmap <buffer><nowait>, g?
    au FileType fugitive nmap <buffer><nowait>\ c?
else
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
    nnoremap <silent><M-g>e :Leaderf git log --side-by-side --explorer<Cr>
    nnoremap <silent><M-g>. :Leaderf git log --side-by-side --current-file<Cr>
    nnoremap <silent><M-g>l :Leaderf git log --side-by-side<Cr>
    nnoremap <silent><M-g>b :Leaderf git blame -w<Cr>
endif
" inline blame
if Installed('blamer.nvim')
    let g:blamer_date_format = '%Y/%m/%d'
    let g:blamer_show_in_insert_modes = 0
    let g:blamer_prefix = ' >> '
    let g:blamer_delay = 500
    nnoremap <silent><Tab><Cr> :BlamerToggle<Cr>
    command! GCommands call FzfCallCommands('GCommands','LeaderfGit','G', ['LeaderfGitInlineBlame', 'Gutentag', 'Grep', 'Get'])
elseif PlannedLeaderf()
    if has('patch-9.0.200') || has('nvim')
        nnoremap <silent><Tab><Cr> :LeaderfGitInlineBlameToggle<Cr>
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
        nnoremap <silent><M-g><M-g> :GLazyGit<Cr>
    else
        nnoremap <silent><M-g><M-g> :GLazyGit<Cr>i
    endif
endif
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
    nnoremap <silent>\| :call <SID>SignifyDiff()<CR>
    nnoremap \<Cr> :SignifyRefresh<Cr>
    nnoremap \<Tab> :SignifyToggle<Cr>
    nnoremap \<Space> :SignifyHunkDiff<Cr>
    nnoremap \<BackSpace> :SignifyHunkUndo<Cr>
    nmap ;h <plug>(signify-next-hunk)
    nmap ,h <plug>(signify-prev-hunk)
    omap im <plug>(signify-motion-inner-pending)
    xmap im <plug>(signify-motion-inner-visual)
    omap am <plug>(signify-motion-outer-pending)
    xmap am <plug>(signify-motion-outer-visual)
    nmap <leader>vm vim
    nmap <leader>vM vam
    PlugAddOpt 'vim-signify'
    " commands
    command! SignifyCommands call FzfCallCommands('SignifyCommands', 'Signify')
    nnoremap <silent>\: :SignifyCommands<Cr>
endif
" -----------------------------------------------------
" Merge
" -----------------------------------------------------
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
