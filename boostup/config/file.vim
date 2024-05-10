try
    set nrformats+=unsigned
catch /.*/
    " pass
endtry
" ------------------------------
" vim-header
" ------------------------------
let g:header_auto_add_header = 0
let g:header_auto_update_header = 0
let g:header_field_timestamp_format = '%Y.%m.%d'
PlugAddOpt 'vim-header'
nnoremap <M-h>a :AddHeader<Cr>
nnoremap <M-h>h :AddBangHeader<Cr>
" ------------------------
" toggle_modify
" ------------------------
function! s:toggle_modify() abort
    if &modifiable
        setl nomodifiable
        echo 'Current buffer is now non-modifiable'
    else
        setl modifiable
        echo 'Current buffer is now modifiable'
    endif
endfunction
command! ToggleModity call s:toggle_modify()
nnoremap <silent> <M-k><space> :ToggleModity<Cr>
" ------------------------
" basic toggle and set
" ------------------------
nnoremap <Bs> :set nohlsearch? nohlsearch!<Cr>
nnoremap <M-k>f :set nofoldenable! nofoldenable?<Cr>
nnoremap <M-k>w :set nowrap! nowrap?<Cr>
" --------------------------
" Quit Config
" --------------------------
let s:autoclose_ft_buf = [
            \ 'netrw', 'coc-explorer', 'neo-tree', 'fern',
            \ 'qf', 'preview', 'loclist',
            \ 'vista', 'tagbar', 'leaderf',
            \ 'help', 'gitcommit', 'man', 'fugitive',
            \ 'terminal', 'floaterm', 'popup'
            \ ]
function! s:autoclose(check_last) abort
    if winnr("$") <= 1 && a:check_last || !a:check_last
        return index(s:autoclose_ft_buf, getbufvar(winbufnr(winnr()), &ft)) >= 0 ||
                    \  index(s:autoclose_ft_buf, getbufvar(winbufnr(winnr()), &bt)) >= 0
    else
        return 0
    endif
endfunction
autocmd WinEnter * if s:autoclose(1) | q! | endif
" confirem quit
function! s:confirm_quit(all) abort
    let all = a:all
    if Expand('%') == '' && all == 0
        q!
    elseif s:autoclose(0) && all == 0
        q!
    else
        let title = 'Want to quit'
        if all
            let title .= " all?"
        else
            let title .= "?"
        endif
        if &ft == 'floaterm'
            FloatermKill
        elseif &buftype == 'terminal'
            q!
        elseif index(['', 'fugitiveblame', 'gitcommit'], &ft) >= 0
            q!
        elseif &modified && all == 0
            let choices = ['Save And Quit', 'Quit']
            let confirmed = ChooseOne(choices, title, 0, 'Cancel')
            if confirmed =~# '^Save'
                wq!
            elseif confirmed =~# '^Quit'
                q!
            endif
        else
            let choices = ['Quit']
            let confirmed = ChooseOne(choices, title, 0, 'Cancel')
            if confirmed ==# 'Quit'
                if all
                    qall!
                else
                    q!
                endif
            endif
        endif
    endif
endfun
command! ConfirmQuit call s:confirm_quit(0)
nnoremap <silent><M-q> :ConfirmQuit<Cr>
command! ConfirmQuitAll call s:confirm_quit(1)
nnoremap <silent><leader><BS> :ConfirmQuitAll<Cr>
" quit directly
function! s:quit() abort
    if &modified
        let choices = ['Save And Quit', 'Quit']
        let confirmed = ChooseOne(choices, 'Save && Quit || Quit only', 0, 'Cancel')
        if confirmed =~# '^Save'
            wq!
        elseif confirmed =~# '^Quit'
            q!
        endif
    else
        q!
    endif
endfunction
command! Quit call s:quit()
nnoremap <silent><leader>q :Quit<Cr>
"------------------------
" cd dir
"------------------------
command! CR execute('cd ' .  GetRootDir())
nnoremap cdr :CR<Cr>
nnoremap cdl :lcd %:p:h<Cr>
" --------------------
" ZFIgnore
" --------------------
function! s:ZFIgnore_LeaderF()
    let ignore = ZFIgnoreGet()
    let g:Lf_WildIgnore = {'file' : ignore['file'], 'dir' : ignore['dir']}
endfunction
autocmd User ZFIgnoreOnUpdate call s:ZFIgnore_LeaderF()
autocmd User ZFIgnoreOnUpdate let &wildignore = join(ZFIgnoreToWildignore(ZFIgnoreGet()), ',')
let g:ZFIgnoreOption_ZFDirDiff = {
            \ 'bin' : 0,
            \ 'media' : 0,
            \ 'ZFDirDiff' : 1,
            \ }
let g:ZFIgnore_ignore_gitignore_detectOption = {
        \ 'pattern' : '\.wildignore',
        \ 'path' : '',
        \ 'cur' : 1,
        \ 'parent' : 1,
        \ 'parentRecursive' : 0,
        \ }
PlugAddOpt 'ZFVimIgnore'
PlugAddOpt 'ZFVimJob'
" --------------------
" ZFVimDirDiff
" --------------------
let g:ZFDirDiff_ignoreEmptyDir = 1
let g:ZFDirDiffKeymap_update = ['DD', '<Tab>']
let g:ZFDirDiffKeymap_updateParent = ['DU']
let g:ZFDirDiffKeymap_open = ['<cr>', 'o']
let g:ZFDirDiffKeymap_foldOpenAll = ['DO']
let g:ZFDirDiffKeymap_foldOpenAllDiff = ['O']
let g:ZFDirDiffKeymap_foldClose = ['x']
let g:ZFDirDiffKeymap_foldCloseAll = ['X']
let g:ZFDirDiffKeymap_diffThisDir = ['DL', 'cd']
let g:ZFDirDiffKeymap_diffParentDir = ['u']
let g:ZFDirDiffKeymap_goParent = ['U']
let g:ZFDirDiffKeymap_markToDiff = ['DM']
let g:ZFDirDiffKeymap_markToSync = ['DS']
let g:ZFDirDiffKeymap_quit = ['q', '<leader>q', 'Q']
let g:ZFDirDiffKeymap_diffNext = [']c', 'DN']
let g:ZFDirDiffKeymap_diffPrev = ['[c', 'DP']
let g:ZFDirDiffKeymap_diffNextFile = ['DJ']
let g:ZFDirDiffKeymap_diffPrevFile = ['DK']
let g:ZFDirDiffKeymap_syncToHere = ['DH']
let g:ZFDirDiffKeymap_syncToThere = ['DT']
let g:ZFDirDiffKeymap_add = ['a', '+']
let g:ZFDirDiffKeymap_delete = ['dd']
let g:ZFDirDiffKeymap_getPath = ['y', 'p']
let g:ZFDirDiffKeymap_getFullPath = ['Y', 'P']
nnoremap <Leader>fd :ZFDirDiff<Space>
nnoremap <Leader>fm :ZFDirDiffMark<Cr>
nnoremap <Leader>fu :ZFDirDiffUnmark<Cr>
PlugAddOpt 'ZFVimDirDiff'
" --------------------
" ZFVimBackup
" --------------------
let g:ZFBackup_autoEnable = 0
nnoremap <M-j><M-s> :ZFBackupSave<Cr>
nnoremap <M-j><M-l> :ZFBackupList<Cr>
nnoremap <M-j><M-d> :ZFBackupListDir<Cr>
nnoremap <M-j><M-m> :ZFBackupRemove<Cr>
nnoremap <M-j><M-r> :ZFBackupRemoveDir<Cr>
function! s:zfbackup_cleanup() abort
    let confirm = ChooseOne(['yes', 'no'], "Cleanup all ZFBackup files")
    if confirm == 'yes'
        if WINDOWS()
            exec printf('!del %s\*.* /a /f /q', ZFBackup_backupDir())
        else
            exec printf('!rm -rf %s/*.*', ZFBackup_backupDir())
        endif
    endif
endfunction
nnoremap <silent><M-j><M-c> :call <SID>zfbackup_cleanup()<Cr>
function! s:zfbackup_savedir() abort
    let confirm = ChooseOne(['yes', 'no'], "Save current dir using ZFBackup?")
    if confirm == 'yes'
        call preview#cmdmsg("Start to save files under current dir", 1)
        ZFBackupSaveDir
    endif
endfunction
nnoremap <silent><M-j><M-b> :call <SID>zfbackup_savedir()<Cr>
PlugAddOpt 'ZFVimBackup'
" ----------------------------------------------------
" ########## Diff Option ##########
" ----------------------------------------------------
if Installed('ZFVimDirDiff', 'ZFVimJob')
    nnoremap <leader>fm :ZFDirDiffMark<Cr>
    nnoremap <leader>fd :ZFDirDiff<Space>
endif
if Installed('ZFVimIgnore')
    autocmd User ZFIgnoreOnToggle let &wildignore = join(ZFIgnoreToWildignore(ZFIgnoreGet()), ',')
endif
try
    set diffopt+=context:20
    set diffopt+=internal,algorithm:patience
catch
    finish
endtry
let g:diff_algorithms = [
            \ "myers",
            \ "minimal",
            \ "patience",
            \ "histogram",
            \ ]
let g:diff_algorithm = "patience"
func! s:DiffToggleAlgorithm()
    let l:total_diff_algos = len(g:diff_algorithms)
    let l:i = 0
    while l:i < l:total_diff_algos && g:diff_algorithms[l:i] !=# g:diff_algorithm
        let l:i += 1
    endwhile
    if l:i < l:total_diff_algos
        let g:diff_algorithm = g:diff_algorithms[(l:i + 1) % l:total_diff_algos]
    else
        let g:diff_algorithm = "patience"
    endif
    for l:algo in g:diff_algorithms
        exec "set diffopt-=algorithm:" . l:algo
    endfor
    exec "set diffopt+=algorithm:" . g:diff_algorithm
    echo "Diff algorithm switched to " . g:diff_algorithm
    windo diffupdate
endfunc
func! s:DiffToggleContext(contextLines)
    let l:opt = substitute(&diffopt, '\v(^\|,)context:\d+', '', 'g') . ",context:" . a:contextLines
    exec "set diffopt=" . l:opt
    windo diffupdate
endfunc
func! s:DiffToggleWhiteSpace()
    if stridx(&diffopt, "iwhite") >= 0
        set diffopt-=iwhite
        echo "Not ignoring whitespaces in diff"
    else
        set diffopt+=iwhite
        echo "Whitespaces ignored in diff"
    endif
    windo diffupdate
endfunc
command! DiffToggleAlgorithm call s:DiffToggleAlgorithm()
command! DiffToggleWhiteSpace call s:DiffToggleWhiteSpace()
command! -nargs=1 DiffToggleContext call s:DiffToggleContext(<f-args>)
nnoremap <leader>fta :DiffToggleAlgorithm<Cr>
nnoremap <leader>ftw :DiffToggleWhiteSpace<Cr>
nnoremap <leader>ftc :DiffToggleContext<Space>
"----------------------------------------------------------------------
" display side by side diff in a new tabpage
" usage: DiffVsp <left_file> <right_file>
"----------------------------------------------------------------------
command! -nargs=+ -complete=file DiffVsp call s:DiffVsp(<f-args>)
function! s:DiffVsp(...) abort
    if a:0 != 2
        echohl ErrorMsg
        echom 'ERROR: Require two file names.'
        echohl None
    else
        exec 'tabe ' . fnameescape(a:1)
        exec 'rightbelow vert diffsplit ' . fnameescape(a:2)
        setlocal foldlevel=20
        exec 'wincmd p'
        setlocal foldlevel=20
        exec 'normal! gg]c'
    endif
endfunc
nnoremap <leader>fv :DiffVsp<Space>
"------------------------
" open files
"------------------------
nnoremap <M-j>e gf
nnoremap <M-j>t <C-w>gf
nnoremap <M-j>s <C-w>f
nnoremap <M-j>v <C-w>f<C-w>L
if PrefFzf()
    nnoremap <silent><nowait><leader>ff :FzfFiles<Cr>
    nnoremap <silent><nowait><leader>fg :FzfGitFiles<Cr>
    nnoremap <silent><nowait><C-p> :FzfFiles <C-r>=GetRootDir()<Cr><Cr>
elseif InstalledLeaderf()
    nnoremap <silent><nowait><leader>ff :LeaderfFile ./<Cr>
    nnoremap <silent><nowait><leader>fg :LeaderfFile <C-r>=GitRootDir()<Cr><Cr>
    nnoremap <silent><nowait><C-p> :LeaderfFile <C-r>=GetRootDir()<Cr><Cr>
else
    nnoremap <silent><nowait><leader>ff :CtrlPCurFile<Cr>
    nnoremap <silent><nowait><leader>fg :CtrlP <C-r>=GitRootDir()<Cr><Cr>
    nnoremap <silent><nowait><C-p> :CtrlP <C-r>=GetRootDir()<Cr><Cr>
endif
if (has('patch-8.1.2269') || has('nvim')) && !Require('netrw')
    source $OPTIONAL_DIR/fern.vim
endif
if has('nvim') && InstalledCoc()
    function! s:coc_file() abort
        exec("CocCommand explorer --toggle --position floating --floating-width " . float2nr(&columns * 0.8) . " --floating-height " . float2nr(&lines * 0.8))
    endfunction
    command! CocFile call s:coc_file()
    nnoremap <silent><nowait><leader>e :CocFile<Cr>
elseif Installed('vim-floaterm') && executable('yazi')
    command! Yazi FloatermNew --wintype=float --position=center --width=0.8 --height=0.8 yazi
    nnoremap <silent><nowait><leader>e :Yazi<Cr>
elseif Installed('fern.vim')
    nnoremap <silent><nowait><leader>e :Fern . -reveal=%<Cr>
endif
nnoremap <leader><Cr> :e!<Cr>
nnoremap <leader>E :e<Space>
" --------------------------
" project
" --------------------------
if Installed('vim-project')
    nnoremap <leader>pp :Project
    nnoremap <leader>pa :Project <C-r>=GetRootDir()<Cr>
    nnoremap <leader>pI :ProjectIgnore<Space>
    nnoremap <leader>po :ProjectOpen<Space>
    nnoremap <leader>pR :ProjectRemove<Space>
    nnoremap <leader>pn :ProjectRename<Space>
    nnoremap <leader>p/ :ProjectFindInFiles<Space>
    nnoremap <silent><nowait><leader>pl :ProjectList<Cr>
    nnoremap <silent><nowait><leader>pA :ProjectAllInfo<Cr>
    nnoremap <silent><nowait><leader>pc :ProjectConfig<Cr>
    nnoremap <silent><nowait><leader>pC :ProjectAllConfig<Cr>
    nnoremap <silent><nowait><leader>pr :ProjectRoot<Cr>
    nnoremap <silent><nowait><leader>pi :ProjectInfo<Cr>
    nnoremap <silent><nowait><leader>pq :ProjectQuit<Cr>
    nnoremap <silent><nowait><leader>pf :ProjectSearchFiles<Cr>
    command! ProjectCommands call FzfCallCommands('ProjectCommands', 'Project')
    nnoremap <silent><nowait><leader>P :ProjectCommands<Cr>
endif
" -----------------------------------
" tmux is ignore in gui or windows
" -----------------------------------
if HAS_GUI() || WINDOWS()
    imap <M-O> <C-o>O
    nmap <M-O> O
    imap <M-o> <C-o>o
    nmap <M-o> o
    nnoremap <silent><M-N> :tabm +1<Cr>
    nnoremap <silent><M-P> :tabm -1<Cr>
    nnoremap <M-]> :vsplit<Space>
    nnoremap <M-[> :split<Space>
    if !has('nvim') && get(g:, 'use_system_browser', WINDOWS())
        let g:browsefilter = ''
        function! s:filter_push(desc, wildcard) abort
            let g:browsefilter .= a:desc . " (" . a:wildcard . ")\t" . a:wildcard . "\n"
        endfunc
        function! s:use_system_browser()
            let l:path = Expand("%:p:h")
            if l:path == '' | let l:path = getcwd() | endif
            if exists('g:browsefilter') && exists('b:browsefilter')
                if g:browsefilter != ''
                    let b:browsefilter = g:browsefilter
                endif
            endif
            exec 'browse tabnew '.fnameescape(l:path)
        endfunc
        call s:filter_push("All Files", "*")
        call s:filter_push("Python", "*.py;*.pyw")
        call s:filter_push("C/C++/Object-C", "*.c;*.cpp;*.cc;*.h;*.hh;*.hpp;*.m;*.mm")
        call s:filter_push("Rust", "*.rs")
        call s:filter_push("Java", "*.java")
        call s:filter_push("Text", "*.txt")
        call s:filter_push("R", "*.r;*.rmd")
        call s:filter_push("Text", "*.txt")
        call s:filter_push("Log", "*.log")
        call s:filter_push("LaTeX", "*.tex")
        call s:filter_push("JavaScript", "*.js;*.vue")
        call s:filter_push("TypeScript", "*.ts")
        call s:filter_push("Php", "*.php")
        call s:filter_push("Vim Script", "*.vim")
        command! UseSystemBrowser call s:use_system_browser()
        nnoremap <silent><M-\> :UseSystemBrowser<Cr>
        nnoremap <silent><M-\|> :UseSystemBrowser<Cr>
    endif
endif
