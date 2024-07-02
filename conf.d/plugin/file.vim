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
"------------------------
" open files
"------------------------
nnoremap <M-j>e gf
nnoremap <M-j>t <C-w>gf
nnoremap <M-j>s <C-w>f
nnoremap <M-j>v <C-w>f<C-w>L
if PlannedFzf()
    nnoremap <silent><nowait><C-p> :FzfFiles <C-r>=GetRootDir()<Cr><Cr>
elseif PlannedLeaderf()
    nnoremap <silent><nowait><C-p> :LeaderfFile <C-r>=GetRootDir()<Cr><Cr>
else
    nnoremap <silent><nowait><C-p> :CtrlP <C-r>=GetRootDir()<Cr><Cr>
endif
if PrefFzf()
    nnoremap <silent><nowait><leader>ff :FzfFiles<Cr>
    nnoremap <silent><nowait><leader>fg :FzfGitFiles<Cr>
elseif PlannedLeaderf()
    nnoremap <silent><nowait><leader>ff :LeaderfFile ./<Cr>
    nnoremap <silent><nowait><leader>fg :LeaderfFile <C-r>=GitRootDir()<Cr><Cr>
else
    nnoremap <silent><nowait><leader>ff :CtrlPCurFile<Cr>
    nnoremap <silent><nowait><leader>fg :CtrlP <C-r>=GitRootDir()<Cr><Cr>
endif
nnoremap <leader><Cr> :e!<Cr>
nnoremap <leader>E :e<Space>
" ---------------------------------
" file browser
" ---------------------------------
if has('patch-8.1.2269') || has('nvim')
    source $ELEMENT_DIR/fern.vim
endif
if has('nvim') && PlannedCoc()
    function! s:coc_file() abort
        exec("CocCommand explorer --toggle --position floating --floating-width " . float2nr(&columns * 0.8) . " --floating-height " . float2nr(&lines * 0.8))
    endfunction
    command! CocFile call s:coc_file()
    nnoremap <silent><nowait><leader>e :CocFile<Cr>
elseif Installed('fern.vim')
    nnoremap <silent><nowait><leader>e :Fern . -reveal=%<Cr>
endif
" ---------------------------------
" Floaterm
" ---------------------------------
if Installed('vim-floaterm')
    function! s:floaterm(prg)
        let prg = a:prg
        if g:has_popup_floating
            execute printf("FloatermNew --title=%s --titleposition=right --wintype=float --position=center --width=0.9 --height=0.9 %s", prg, prg)
        else
            if &columns > &lines * 3
                execute printf("FloatermNew --title=%s --titleposition=right --wintype=vsplit --position=right --width=0.45 %s", prg, prg)
            else
                execute printf("FloatermNew --title=%s --titleposition=right --wintype=split --position=botright --height=0.6 %s", prg, prg)
            endif
        endif
    endfunction
    if executable('yazi')
        command! FloatermYazi call s:floaterm('yazi')
        nnoremap <silent><leader>` :FloatermYazi<Cr>
    elseif executable('ranger')
        command! FloatermRanger call s:floaterm('ranger')
        nnoremap <silent><leader>` :FloatermRanger<Cr>
    endif
endif
" --------------------------
" project
" --------------------------
if Planned('vim-project')
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
if get(g:, 'leovim_openmap', 1)
    function! TabeOpen(f) abort
        let f = expand(a:f)
        exec "tabe " . f
    endfunction
    nnoremap <silent><M-h>i :call TabeOpen("$CONFIG_DIR/init.vim")<Cr>
    nnoremap <silent><M-h>b :call TabeOpen("$INSTALL_DIR/basement.vim")<Cr>
    nnoremap <silent><M-h>m :call TabeOpen("$ELEMENT_DIR/main.vim")<Cr>
    nnoremap <silent><M-h>k :call TabeOpen("$ELEMENT_DIR/keybindings.json")<Cr>
    nnoremap <silent><M-h>v :call TabeOpen("$ELEMENT_DIR/vscode.vim")<Cr>
    nnoremap <silent><M-h>O :call TabeOpen("$ELEMENT_DIR/opt.vim")<Cr>
    if PlannedLeaderf()
        nnoremap <silent><M-h>f :Leaderf file --no-sort ~/.leovim/conf.d/common<Cr>
        nnoremap <silent><M-h>e :Leaderf file --no-sort ~/.leovim/conf.d/element<Cr>
        nnoremap <silent><M-h>p :Leaderf file --no-sort ~/.leovim/conf.d/plugin<Cr>
        nnoremap <silent><M-h>d :Leaderf file --no-sort ~/.leovim/conf.d<Cr>
        nnoremap <silent><M-h>l :Leaderf file --no-sort ~/.leovim<Cr>
    elseif PlannedFzf()
        nnoremap <silent><M-h>f :FzfFiles ~/.leovim/conf.d/common<Cr>
        nnoremap <silent><M-h>e :FzfFiles ~/.leovim/conf.d/element<Cr>
        nnoremap <silent><M-h>p :FzfFiles ~/.leovim/conf.d/plugin<Cr>
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
    nnoremap <silent><M-h>A :call <SID>open_or_create_file("~/.leovim.d/after.vim")<Cr>
    nnoremap <silent><M-h>P :call <SID>open_or_create_file("~/.leovim.d/pack.vim")<Cr>
endif
" ------------------
" vscode
" ------------------
if WINDOWS()
    let s:vscode_user_dir = substitute(fnameescape(get(g:, "vscode_user_dir", "")), '/', '\', 'g')
else
    let s:vscode_user_dir = fnameescape(get(g:, "vscode_user_dir", ""))
endif
if isdirectory(s:vscode_user_dir)
    function! s:link_keybindings() abort
        if WINDOWS()
            let delete_cmd = printf('!del /Q /S %s\keybindings.json', s:vscode_user_dir)
            execute(delete_cmd)
            let rmdir_cmd = printf('!rmdir /Q /S %s\snippets', s:vscode_user_dir)
            execute(rmdir_cmd)
            " create keybindings.json link
            let template = '!mklink %s %s'
            let cmd = printf(template, s:vscode_user_dir . '\keybindings.json', $ELEMENT_DIR . '\keybindings.json')
            execute(cmd)
            " create snippets link
            let template = '!mklink /d %s %s'
            let cmd = printf(template, s:vscode_user_dir . '\snippets', $LEOVIM_DIR . '\snippets')
            execute(cmd)
        else
            let template = '!ln -sf %s %s'
            let cmd = printf(template, $ELEMENT_DIR . '/keybindings.json', s:vscode_user_dir)
            execute(cmd)
            let cmd = printf(template, $LEOVIM_DIR . '/snippets', s:vscode_user_dir)
            execute(cmd)
        endif
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
            let cmd = printf("AsyncRun code --goto %s:%d", Expand("%:p"), line("."))
        else
            let cmd = printf("!code --goto %s:%d", Expand("%:p"), line("."))
        endif
        silent! exec cmd
    endfunction
    command! OpenInVSCode call s:open_in_vscode()
    nnoremap <silent><M-j>o :OpenInVSCode<Cr>
    " NOTE: open file under line in vscode
    command! OpenFileLinkInVSCode call s:open_file_in_editor("code", getline("."), col("."))
    nnoremap <silent><M-j>f :OpenFileLinkInVSCode<cr>
endif
" ------------------
" delete tmp files
" ------------------
if WINDOWS()
    nnoremap <leader>x :!powershell <C-r>=Expand("~/_leovim.clean.cmd")<Cr><Cr> \| e %<Cr><C-o>
else
    nnoremap <leader>x :!bash <C-r>=Expand("~/.leovim.clean")<Cr><Cr> \| e %<Cr><C-o>
endif
