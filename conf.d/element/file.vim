try
    set nrformats+=unsigned
catch /.*/
    " pass
endtry
" ------------------------------
" file functions
" ------------------------------
function! FileDir(file) abort
    return Expand(fnamemodify(a:file , ':p:h'))
endfunction
function! FilePath(file) abort
    return Expand(fnamemodify(a:file , ':h'))
endfunction
function! FileReadonly()
    return &readonly && &filetype !=# 'help' ? 'RO' : ''
endfunction
function! GetRootDir(...)
    let init_dir = Expand('%:p:h')
    let curr_dir = init_dir
    while 1
        if WINDOWS() && curr_dir[-2:-1] == ':/' || UNIX() && curr_dir ==# '/'
            return init_dir
        endif
        for each in g:root_patterns + g:root_files
            let chk_path = curr_dir . '/' . each
            if isdirectory(chk_path) || filereadable(chk_path)
                if a:0 && a:1 > 0
                    return substitute(curr_dir, '/', '\', 'g')
                else
                    return curr_dir
                endif
            endif
        endfor
        let curr_dir = fnamemodify(curr_dir, ":h")
    endwhile
endfunction
nnoremap <M-h>R :echo GetRootDir()<Cr>
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
let g:ZFDirDiffKeymap_update = ['DL', '<C-l>']
let g:ZFDirDiffKeymap_updateParent = ['DH', '<C-h>']
let g:ZFDirDiffKeymap_open = ['<Cr>', 'o']
let g:ZFDirDiffKeymap_foldOpenAll = ['O']
let g:ZFDirDiffKeymap_foldOpenAllDiff = ['A']
let g:ZFDirDiffKeymap_foldClose = ['x']
let g:ZFDirDiffKeymap_foldCloseAll = ['X']
let g:ZFDirDiffKeymap_diffThisDir = ['DF', 'cd']
let g:ZFDirDiffKeymap_diffParentDir = ['u']
let g:ZFDirDiffKeymap_goParent = ['U', '<BS>']
let g:ZFDirDiffKeymap_markToDiff = ['DM']
let g:ZFDirDiffKeymap_markToSync = ['DS']
let g:ZFDirDiffKeymap_quit = ['q', '<leader>q', 'Q']
let g:ZFDirDiffKeymap_diffNext = [']c', 'DN']
let g:ZFDirDiffKeymap_diffPrev = ['[c', 'DP']
let g:ZFDirDiffKeymap_diffNextFile = ['DJ']
let g:ZFDirDiffKeymap_diffPrevFile = ['DK']
let g:ZFDirDiffKeymap_syncToHere = ['DO']
let g:ZFDirDiffKeymap_syncToThere = ['DT']
let g:ZFDirDiffKeymap_add = ['a', '+']
let g:ZFDirDiffKeymap_delete = ['dd']
let g:ZFDirDiffKeymap_getPath = ['y']
let g:ZFDirDiffKeymap_getFullPath = ['Y']
nnoremap <Leader>fd :ZFDirDiff<Space>
nnoremap <Leader>fm :ZFDirDiffMark<Cr>
nnoremap <Leader>fu :ZFDirDiffUnmark<Cr>
au FileType ZFDirDiff nnoremap M :tabe +180  $HOME/.leovim/conf.d/element/file.vim<Cr>
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
" using system file explorer
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
    endif
endif
" --------------------------
" open or add file
" --------------------------
function! s:open_or_create_file(file, ...) abort
    let file = Expand(a:file)
    if filereadable(file)
        try
            execute "tabe " . file
            return 1
        catch /.*/
            call preview#errmsg("Could not open file " . a:file)
            return 0
        endtry
    else
        let dir = FileDir(file)
        try
            if !isdirectory(dir)
                call mkdir(dir, "p")
            endif
            let content = []
            for each in a:000
                if type(each) == v:t_list
                    let content += each
                elseif type(each) == v:t_dict
                    let content += keys(each)
                elseif type(each) == v:t_number
                    call add(content, string(num))
                elseif type(each) == v:t_string
                    call add(content, each)
                elseif index([v:t_func, v:t_job, v:t_none, v:t_channel]) < 0
                    call add(content, string(each))
                endif
            endfor
            let b:content = content
            if len(content) > 0
                call writefile(content, file)
            endif
            execute "tabe " . file
            return 1
        catch /.*/
            call preview#errmsg("Could not create or write to file " . a:file)
            return 0
        endtry
    endif
endfunction
" ssh/config
nnoremap <M-h>c :call <SID>open_or_create_file("~/.ssh/config")<Cr>
" gitconfig
nnoremap <M-h>G :call <SID>open_or_create_file("~/.gitconfig")<Cr>
" bashrc
nnoremap <M-h>B :call <SID>open_or_create_file("~/.bashrc")<Cr>
" configrc
nnoremap <M-h>C :call <SID>open_or_create_file("~/.configrc")<Cr>
" ------------------
" create root file
" ------------------
function! s:open_or_create_rootfile(fl, ...) abort
    let fl = GetRootDir() . '/' . a:fl
    if a:0
        call s:open_or_create_file(fl, a:000)
    else
        call s:open_or_create_file(fl)
    endif
endfunction
command! OpenTODO call s:open_or_create_rootfile('TODO.md', '# TODO:', '- [ ]')
nnoremap <M-h>t :OpenTODO<Cr>
command! OpenREADME call s:open_or_create_rootfile('README.md', '# README')
nnoremap <M-h>r :OpenREADME<Cr>
command! OpenGitignore call s:open_or_create_rootfile('.gitignore')
nnoremap <M-h>g :OpenGitignore<Cr>
command! OpenWildignore call s:open_or_create_rootfile('.wildignore')
nnoremap <M-h>w :OpenWildignore<Cr>
" ------------------------
" open config file
" ------------------------
nnoremap <M-h><Cr> :source ~/.leovim/conf.d/init.vim<Cr>
nnoremap <M-h>o :tabe ~/.vimrc.opt<Cr>
function! TabeOpen(f) abort
    let f = expand(a:f)
    exec "tabe " . f
endfunction
if get(g:, 'leovim_openmap', 1)
    nnoremap <silent><M-h>O :tabe ~/.leovim/conf.d/optional/opt.vim<Cr>
    nnoremap <silent><M-h>i :call TabeOpen("$CONFIG_DIR/init.vim")<Cr>
    nnoremap <silent><M-h>b :call TabeOpen("$INSTALL_DIR/basement.vim")<Cr>
    nnoremap <silent><M-h>m :call TabeOpen("$INIT_DIR/main.vim")<Cr>
    nnoremap <silent><M-h>k :call TabeOpen("$INIT_DIR/keybindings.json")<Cr>
    nnoremap <silent><M-h>v :call TabeOpen("$INIT_DIR/vscode.vim")<Cr>
    if InstalledLeaderf()
        nnoremap <silent><M-h>f :Leaderf file --no-sort ~/.leovim/conf.d/after/ftplugin<Cr>
        nnoremap <silent><M-h>e :Leaderf file --no-sort ~/.leovim/conf.d/element<Cr>
        nnoremap <silent><M-h>p :Leaderf file --no-sort ~/.leovim/pack<Cr>
        nnoremap <silent><M-h>d :Leaderf file --no-sort ~/.leovim/conf.d<Cr>
        nnoremap <silent><M-h>l :Leaderf file --no-sort ~/.leovim<Cr>
    elseif InstalledFzf()
        nnoremap <silent><M-h>f :FzfFiles ~/.leovim/conf.d/after/ftplugin<Cr>
        nnoremap <silent><M-h>e :FzfFiles ~/.leovim/conf.d/element<Cr>
        nnoremap <silent><M-h>p :FzfFiles ~/.leovim/pack<Cr>
        nnoremap <silent><M-h>d :FzfFiles ~/.leovim/conf.d<Cr>
        nnoremap <silent><M-h>l :FzfFiles ~/.leovim<Cr>
    endif
    " --------------------------
    " open other ides config
    " --------------------------
    nnoremap <silent><M-h>V :call TabeOpen("$LEOVIM_DIR/msvc/vs.vim")<Cr>
    nnoremap <silent><M-h>I :call TabeOpen("$LEOVIM_DIR/jetbrains/idea.vim")<Cr>
    " --------------------------
    " addtional vim config
    " --------------------------
    if filereadable(expand("~/.leovim.d/after.vim"))
        source ~/.leovim.d/after.vim
    endif
    nnoremap <M-h>A :call <SID>open_or_create_file("~/.leovim.d/after.vim")<Cr>
    nnoremap <M-h>P :call <SID>open_or_create_file("~/.leovim.d/pack.vim")<Cr>
endif
" ------------------
" vscode cursor
" ------------------
let s:vscode_dir = substitute(fnameescape(get(g:, "vscode_keybindings_dir", "")), '/', '\', 'g')
let s:cursor_dir = substitute(fnameescape(get(g:, "cursor_keybindings_dir", "")), '/', '\', 'g')
if isdirectory(s:vscode_dir) || isdirectory(s:cursor_dir)
    function! s:link_keybindings() abort
        for dir in [s:vscode_dir, s:cursor_dir]
            if !isdirectory(dir)
                continue
            endif
            if WINDOWS()
                let delete_cmd = printf('!del /Q /S %s\keybindings.json', dir)
                execute(delete_cmd)
                let template = '!mklink %s %s'
                let cmd = printf(template, dir . '\keybindings.json', $INIT_DIR . '\keybindings.json')
            else
                let template = '!ln -sf %s %s'
                let cmd = printf(template, $INIT_DIR . '/keybindings.json', dir)
            endif
            execute(cmd)
        endfor
    endfunction
    command! LinkKeyBindings call s:link_keybindings()
    nnoremap <M-h>K :LinkKeyBindings<Cr>
endif
function! s:get_cursor_pos(text, col)
    " Find the start location
    let col = a:col
    while col >= 0 && a:text[col] =~ '\f'
        let col = col - 1
    endwhile
    let col = col + 1
    " Match file name and position
    let m = matchlist(a:text, '\v(\f+)%([#:](\d+))?%(:(\d+))?', col)
    if len(m) > 0
        return [m[1], m[2], m[3]]
    endif
    return []
endfunc
function! s:open_file_in_editor(editor, text, col)
    let location = s:get_cursor_pos(a:text, a:col)
    if a:editor == 'code'
        let editor = 'code --goto'
    else
        let editor = a:editor
    endif
    " location 0: file, 1: row, 2: column
    if location[0] != ''
        if location[1] != ''
            if location[2] != ''
                if editor =~ 'code'
                    let command = editor . " " . location[0] . ":" . str2nr(location[1]) . ":" . str2nr(location[2])
                else
                    let command = editor . " --column " . str2nr(location[2]) . " " . location[0] . ":" . str2nr(location[1])
                endif
                if Installed('asyncrun.vim')
                    exec "AsyncRun -silent " . command
                else
                    exec "! " . command
                endif
            else
                let command = editor . " " . location[0] . ":" . str2nr(location[1])
                if Installed('asyncrun.vim')
                    exec "AsyncRun -silent " . command
                else
                    exec "! " . command
                endif
            endif
        else
            let command = editor . " " . location[0]
            if Installed('asyncrun.vim')
                exec "AsyncRun -silent " . command
            else
                exec "! " . command
            endif
        endif
    else
        echo "Not a valid file path"
    endif
endfunc
if executable('code')
    function! s:open_in_vscode()
        if Installed('asyncrun.vim')
            let cmd = printf("AsyncRun code --goto %s:%d", expand("%:p"), line("."))
        else
            let cmd = printf("!code --goto %s:%d", expand("%:p"), line("."))
        endif
        silent! exec cmd
    endfunction
    command! OpenInVSCode call s:open_in_vscode()
    nnoremap <silent><M-j>o :OpenInVSCode<Cr>
    " NOTE: open file under line in vscode
    command! OpenFileLinkInVSCode call s:open_file_in_editor("code", getline("."), col("."))
    nnoremap <silent><M-j>f :OpenFileLinkInVSCode<cr>
endif