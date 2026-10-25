" Skip in VSCode environment
if utils#is_vscode()
    finish
endif
" ---------------------------------
" git global set
" ---------------------------------
if executable('git') && get(g:, 'header_field_author', '') != '' && get(g:, 'header_field_author_email', '') != ''
    command! GitSet call utils#execute(printf(
                \ '!git config user.name "%s" && git config user.email "%s"',
                \ g:header_field_author,
                \ g:header_field_author_email))
    nnoremap <M-g>S :GitSet<Cr>
endif
" ----------------------------------------------------------------------
" git related functions
" ----------------------------------------------------------------------
augroup LcdAndGitUpdate
    au!
    autocmd BufEnter,WinEnter * call git#lcd_and_update()
augroup END
"------------------------------------
" fugitive and others git FileType
"------------------------------------
if pack#planned('vim-git-diffview')
    let g:gdv_keymap = 'df'
endif
if pack#planned('vim-fugitive')
    nnoremap <silent><M-g>a :Git add -A<CR>
    nnoremap <silent><M-g>u :Git push<CR>
    nnoremap <silent><M-g><Cr> :Git commit -av<Cr>
    nnoremap <M-G>  :Git
    nnoremap <M-g>U :Git push<Space>
    " fugitive log workspace: cursor on a commit, then
    "   df -> gdv commit diff view (g:gdv_keymap)
    "   <Tab>/<Space> -> Gvdiff/Gdiff that revision (FileType git maps)
    nnoremap <silent><M-g><M-g> :Git log --graph --oneline --decorate<Cr>
    nnoremap <silent><M-g>\ :Git log --oneline -- %<Cr>
    " compare with history version
    let g:fugitive_summary_format = "%as-[%an]: %s"
    au FileType git nnoremap <silent><buffer><tab> 0"ayiw:bw<cr>:rightbelow Gvdiff <c-r>a<cr>
    au FileType git nnoremap <silent><buffer><space> 0"ayiw:bw<cr>:rightbelow Gdiff <c-r>a<cr>
    au FileType git nnoremap <silent><buffer>\ <Nop>
    " git diff
    nnoremap <silent><M-g>] :Gvdiffsplit!<Cr>
    nnoremap <silent><M-g>[ :Gdiffsplit!<Cr>
    " buffer map, nnoremap
    au FileType fugitive,git,fugitiveblame,GV nnoremap <silent><buffer><nowait>q :q!<Cr>
    au FileType fugitive,git,GV nnoremap <silent><buffer><nowait>Q :q!<Cr>
    au FileType fugitive,git,GV nnoremap <silent><buffer><nowait><M-q> :q!<Cr>
    " buffer map, nmap
    au FileType fugitiveblame nmap <buffer><silent><nowait><Cr> o
    au FileType fugitive nnoremap <buffer><nowait>gg gg
    au FileType fugitive nmap <buffer><nowait><Space> =
    au FileType fugitive nmap <buffer><nowait><Tab> -
    au FileType fugitive nmap <buffer><nowait>s -
    " status header: extend "Help: g?" hint with c?/d?/r?
    au User FugitiveIndex call s:FugitiveHelpHint()
    function! s:FugitiveHelpHint() abort
        if &filetype !=# 'fugitive'
            return
        endif
        let lnum = match(getline(1, '$'), '^Help: g?$') + 1
        if lnum > 0
            setlocal modifiable noreadonly
            call setline(lnum, 'Help: <f1> g? c? d? r?')
            setlocal nomodifiable readonly
        endif
    endfunction
endif
" Current-file history list: best backend first; GV replaces only on vim
" without LeaderF (GV needs fugitive, zero python/node deps).
if pack#planned('diffview-plus.nvim')
    nnoremap <silent>g\ :DiffviewFileHistory %<Cr>
elseif pack#planned_leaderf()
    nnoremap <silent>g\ :Leaderf git log --side-by-side --current-file<Cr>
elseif pack#planned('gv.vim') && !has('nvim')
    nnoremap <silent>g\ :GV!<Cr>
endif
" inline blame: keep the shortcut stable while selecting the native backend.
if pack#installed('gitsigns.nvim')
    nnoremap <silent><Tab><Tab> :Gitsigns blame<Cr>
    nnoremap <silent><Tab><Cr> :Gitsigns toggle_current_line_blame<Cr>
    command! GCommands call FzfCallCommands('GCommands', 'Gitsigns', 'Diffview', 'LeaderfGit', 'G', ['LeaderfGitInlineBlame', 'Gutentag', 'Grep', 'Get'])
elseif pack#planned_leaderf()
    nnoremap <silent><Tab><Tab> :Leaderf git blame -w<Cr>
    if has('patch-9.0.200') || has('nvim')
        nnoremap <silent><Tab><Cr> :LeaderfGitInlineBlameToggle<Cr>
        command! GCommands call FzfCallCommands('GCommands', 'LeaderfGit', 'G', ['Gutentag', 'Grep', 'Get'])
    else
        command! GCommands call FzfCallCommands('GCommands', 'LeaderfGit', 'G', ['LeaderfGitInlineBlame', 'Gutentag', 'Grep', 'Get'])
    endif
else
    command! GCommands call FzfCallCommands('GCommands', 'G', ['Gutentag', 'Grep', 'Get'])
endif
nnoremap <silent><M-g>: :GCommands<Cr>
" ---------------------------------
" lazygit integrated
" ---------------------------------
if pack#installed('vim-floaterm') && executable('lazygit')
    command! GLazyGit exec "FloatermNew --height=0.9 --width=0.9 --title=lazygit --wintype=float --position=center lazygit"
    if has('nvim')
        nnoremap <M-g><M-l> :GLazyGit<Cr>
    else
        nnoremap <M-g><M-l> :GLazyGit<Cr>i
    endif
endif
" -----------------------------------------------------
" Primary diff workspace: preserve LeaderF and use editor-specific fallbacks.
" -----------------------------------------------------
if pack#planned('diffview-plus.nvim')
    nnoremap <silent>\| :DiffviewOpen<Cr>
elseif pack#planned_leaderf()
    nnoremap <silent>\| :Leaderf git status --side-by-side<Cr>
elseif pack#planned('vim-signify')
    function! s:signifyDiff() abort
        SignifyDiff
        if winnr('$') == 2
            wincmd H
        endif
    endfunction
    nnoremap <silent>\| :call <SID>signifyDiff()<CR>
endif
" Git browser shortcuts by backend.
if pack#planned_leaderf()
    let g:Lf_GitKeyMap = extend({
                \ 'previous_change': ',g',
                \ 'next_change': ';g',
                \ 'edit_file': '<CR>',
                \ 'open_navigation': '<',
                \ 'stage_unstage_hunk': 's',
                \ 'stage_unstage_all_hunk': 'S',
                \ 'discard_hunk': 'd',
                \ 'discard_hunk_no_prompt': 'D',
                \ 'diff_get_ours': '<leader>1',
                \ 'diff_get_base': '<leader>2',
                \ 'diff_get_theirs': '<leader>3',
                \ }, get(g:, 'Lf_GitKeyMap', {}))
    nnoremap <silent><M-g>i :Leaderf git<Cr>
    nnoremap <silent><M-g>o :Leaderf git log --side-by-side<Cr>
    nnoremap <silent><M-g>e :Leaderf git log --side-by-side --explorer<Cr>
    nnoremap <silent><M-g>f :Leaderf git log --side-by-side --current-file<Cr>
    nnoremap <silent><M-g>l :Leaderf git log --side-by-side --current-line<Cr>
elseif pack#planned('diffview-plus.nvim')
    nnoremap <silent><M-g>o :DiffviewFileHistory<Cr>
    nnoremap <silent><M-g>l :.DiffviewFileHistory --follow<Cr>
elseif pack#planned('gv.vim') && !has('nvim')
    nnoremap <silent><M-g>o :GV<Cr>
    nnoremap <silent><M-g>f :GV!<Cr>
    nnoremap <silent><M-g>l V:GV?<Cr>
    xnoremap <silent><M-g>l :GV?<Cr>
endif
" GV-unique features: -S origin search (when was the word/selection
" added or removed); command line stays open for extra git-log args.
" Range diff, `.` fugitive handoff and gb live inside the GV buffer.
if pack#planned('gv.vim')
    nnoremap <M-g>s :GV -S <C-r>=escape(expand('<cword>'), ' ')<Cr>
    xnoremap <M-g>s :GV -S <C-r>=escape(utils#get_visual(), ' ')<Cr>
endif
if pack#planned('vim-signify')
    let g:signify_disable_by_default = 0
    nnoremap \<Cr> :SignifyRefresh<Cr>
    nnoremap \<Tab> :SignifyToggle<Cr>
    nnoremap \<Space> :SignifyHunkDiff<Cr>
    nnoremap \<BackSpace> :SignifyHunkUndo<Cr>
    nmap ;g <plug>(signify-next-hunk)
    nmap ,g <plug>(signify-prev-hunk)
    omap ig <plug>(signify-motion-inner-pending)
    xmap ig <plug>(signify-motion-inner-visual)
    omap ag <plug>(signify-motion-outer-pending)
    xmap ag <plug>(signify-motion-outer-visual)
    nmap <leader>vg vig
    nmap <leader>vG vag
    " commands
    command! SignifyCommands call FzfCallCommands('SignifyCommands', 'Signify')
    nnoremap <silent>\: :SignifyCommands<Cr>
endif
" -----------------------------------------------------
" Merge
" -----------------------------------------------------
if pack#planned('diffview-plus.nvim')
    nnoremap <M-g>m :DiffviewMergeFiles<Space>
else
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
endif
