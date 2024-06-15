" ---------------------------------
" git global set
" ---------------------------------
if executable('git') && get(g:, 'header_field_author', '') != '' && get(g:, 'header_field_author_email', '') != ''
    command! GitSet execute(printf(
                \ '%s git config --global user.name "%s" && git config --global user.email "%s"',
                \ Installed('asyncrun.vim') ? 'AsyncRun!' : '!',
                \ g:header_field_author,
                \ g:header_field_author_email))
    nnoremap <M-g>g :GitSet<Cr>
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
        let b:git_root_dir = split(system('git rev-parse --show-toplevel'), "\\n")[idx]
        if b:git_root_dir =~ 'fatal:' && b:git_root_dir =~ 'git'
            let b:git_branch = ''
            let b:git_root_dir = ''
        else
            if Expand('%:t') !~? 'Tagbar\|Vista\|Gundo\|NERD\|coc\|fern\|netrw\|neo-tree' && &ft !~ 'vimfiler' && index(['nofile', 'popup'], &buftype) < 0
                try
                    let b:git_branch = split(system('git rev-parse --abbrev-ref HEAD'), "\\n")[idx]
                    if b:git_branch =~ 'fatal:'
                        let b:git_branch = ''
                        let b:git_root_dir = ''
                    endif
                catch /.*/
                    let b:git_branch = ''
                    let b:git_root_dir = ''
                endtry
            else
                let b:git_branch = ''
                let b:git_root_dir = ''
            endif
        endif
    else
        let b:git_branch = ''
        let b:git_root_dir = ''
    endif
endfunction
augroup UpdateBufGit
    autocmd!
    autocmd WinEnter,BufCreate,BufEnter * call UpdateBufGit()
augroup END
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
    nnoremap <silent><M-g>/ :Git log --pretty=format:"%h\|\|%as-[%an]: %s" -- %<cr>
    au FileType git nnoremap <silent><buffer><tab> 0"ayiw:bw<cr>:rightbelow Gvdiff <c-r>a<cr>
    au FileType git nnoremap <silent><buffer><space> 0"ayiw:bw<cr>:rightbelow Gdiff <c-r>a<cr>
    au FileType git nnoremap <silent><buffer>, <Nop>
    au FileType git nnoremap <silent><buffer>\ <Nop>
    " git diff
    nnoremap <silent><M-g>] :Gvdiffsplit!<Cr>
    nnoremap <silent><M-g>[ :Gdiffsplit!<Cr>
    " gitblame
    nnoremap <silent>,<Tab> :Git blame<Cr>
    " GV
    if Planned('GV.vim')
        nnoremap <silent><M-g>c :GV!<Cr>
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
if Planned('blamer.nvim')
    let g:blamer_date_format = '%Y/%m/%d %H:%M'
    let g:blamer_show_in_insert_modes = 0
    let g:blamer_prefix = ' >> '
    nnoremap ,<Cr> :BlamerToggle<Cr>
endif
if PlannedLeaderf()
    nnoremap <silent><M-g><M-i> :Leaderf git<Cr>
    nnoremap <silent><M-g><M-h> :Leaderf git diff HEAD --directly<Cr>
    nnoremap <silent><M-g><M-l> :Leaderf git log<Cr>
    nnoremap <silent><M-g><M-c> :Leaderf git log --current-file<Cr>
    nnoremap <silent><M-g><M-/> :Leaderf git diff --current-file --side-by-side<Cr>
endi
if PlannedFzf()
    command! GCommands call FzfCallCommands('GCommands', 'G', ['Glance', 'Gutentag', 'Grep', 'Get'])
    nnoremap <silent><M-g><M-g> :GCommands<Cr>
endif
" ---------------------------------
" tig lazygit intergrated
" ---------------------------------
if g:has_popup_floating && g:has_terminal && executable('lazygit')
    command! GLazyGit exec "FloatermNew --height=0.9 --width=0.9 --title=lazygit --wintype=float --position=center lazygit"
    if has('nvim')
        nnoremap <silent>,<Space> :GLazyGit<Cr>
    else
        nnoremap <silent>,<Space> :GLazyGit<Cr>i
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
