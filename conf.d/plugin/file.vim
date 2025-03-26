" --------------------------
" autoclose_ft_buf
" --------------------------
let g:autoclose_ft_buf = [
            \ 'netrw', 'tagbar', 'vista', 'vista_kind',
            \ 'qf', 'loclist', 'rg', 'outline',
            \ 'leaderf', 'fzf', 'help', 'man', 'startify',
            \ 'git', 'gitcommit', 'fugitive', 'fugtiveblame', 'diff',
            \ 'vimspector', 'vimspectorprompt',
            \ 'terminal', 'floaterm', 'popup', 'undotree',
            \ 'dropbar', 'dropbar_preview',
            \ ]
function! s:autoclose(...) abort
    let ft = tolower(getbufvar(winbufnr(winnr()), '&ft'))
    let bt = tolower(getbufvar(winbufnr(winnr()), '&bt'))
    if winnr("$") <= 1 && a:0 && a:1
        return index(g:autoclose_ft_buf, ft) >= 0 || index(g:autoclose_ft_buf, bt) >= 0
    elseif !a:0 || a:1 == 0
        return ft == '' || index(g:autoclose_ft_buf, ft) >= 0 || index(g:autoclose_ft_buf, bt) >= 0
    else
        return 0
    endif
endfunction
function! FtBtIgnored() abort
    return s:autoclose(0)
endfunction
function! AutoCloseLastWin() abort
    return s:autoclose(1)
endfunction
augroup AutoCloseLastWin
    autocmd!
    autocmd BufWinEnter * if AutoCloseLastWin() | q! | endif
augroup END
"----------------------------------------------------------------------
" Sudo
"----------------------------------------------------------------------
nnoremap <leader>su :Sudo
nnoremap <leader>se :SudoEdit<Space>
nnoremap <leader>sw :SudoWrite<Space>
"----------------------------------------------------------------------
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
" cd dir
"------------------------
command! CR execute('cd ' .  GetRootDir())
command! CG execute('cd ' .  GitRootDir())
nnoremap cdr :CR<Cr>
nnoremap cdg :CG<Cr>
nnoremap cdl :lcd %:p:h<Cr>
"------------------------
" search files
"------------------------
if PlannedFzf()
    nnoremap <silent><nowait><C-p> :FzfFiles <C-r>=GetRootDir()<Cr><Cr>
elseif PlannedLeaderf()
    nnoremap <silent><nowait><C-p> :LeaderfFile <C-r>=GetRootDir()<Cr><Cr>
else
    nnoremap <silent><nowait><C-p> :CtrlP <C-r>=GetRootDir()<Cr><Cr>
endif
if PrefFzf()
    nnoremap <silent><nowait><leader>ff :FzfFiles<Cr>
    nnoremap <silent><nowait><leader>p  :FzfGitFiles<Cr>
elseif PlannedLeaderf()
    nnoremap <silent><nowait><leader>ff :LeaderfFile ./<Cr>
    nnoremap <silent><nowait><leader>p  :LeaderfFile <C-r>=GitRootDir()<Cr><Cr>
else
    nnoremap <silent><nowait><leader>ff :CtrlPCurFile<Cr>
    nnoremap <silent><nowait><leader>p  :CtrlP <C-r>=GitRootDir()<Cr><Cr>
endif
if PlannedFzf()
    nnoremap <nowait>\g :FzfGitFiles <C-r>=@"<Cr>
    xnoremap <nowait>\g :<C-u>FzfGitFiles <C-r>=GetVisualSelection()<Cr>
endif
" ---------------------------------
" open gitroot getroot
" ---------------------------------
nnoremap <leader><Cr> :e<Space>
nnoremap <leader>P :tabe <C-r>=GitRootDir()<Cr>/
nnoremap <leader>E :tabe <C-r>=GetRootDir()<Cr>/
" ---------------------------------
" file browser
" ---------------------------------
if Installed('vim-floaterm')
    function! s:floaterm_float(prg)
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
    if InstalledCoc() && has('nvim')
        function! s:coc_file() abort
            exec("CocCommand explorer --toggle --position floating --floating-width " . float2nr(&columns * 0.8) . " --floating-height " . float2nr(&lines * 0.8))
        endfunction
        command! CocFile call s:coc_file()
        nnoremap <silent><nowait><leader>e :CocFile<Cr>
    elseif executable('yazi')
        command! FloatermYazi call s:floaterm_float('yazi')
        nnoremap <silent><nowait><leader>e :FloatermYazi<Cr>
    elseif executable('ranger')
        command! FloatermRanger call s:floaterm_float('ranger')
        nnoremap <silent><nowait><leader>e :FloatermRanger<Cr>
    elseif executable('lf')
        command! FloatermLF call s:floaterm_float('lf')
        nnoremap <silent><nowait><leader>e :FloatermLF<Cr>
    endif
endif
"------------------------
" open file
"------------------------
nnoremap <M-j>e gf
nnoremap <M-j>t <C-w>gf
nnoremap <M-j>s <C-w>f
nnoremap <M-j>v <C-w>f<C-w>L
" using system file explorer
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
            let l:path = AbsDir()
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
        nnoremap <silent><M-"> :UseSystemBrowser<Cr>
    endif
endif
" --------------------------
" open or add file
" --------------------------
function! s:open_or_create_file(file, ...) abort
    let file = Expand(a:file, 1)
    if filereadable(file)
        try
            execute "tabe " . file
            return 1
        catch /.*/
            call preview#errmsg("Could not open file " . a:file)
            return 0
        endtry
    else
        let dir = AbsDir()
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
" bashrc
nnoremap <M-h>b :call <SID>open_or_create_file("~/.bashrc")<Cr>
" zshrc
nnoremap <M-h>z :call <SID>open_or_create_file("~/.zshrc")<Cr>
" configrc
nnoremap <M-h>c :call <SID>open_or_create_file("~/.configrc")<Cr>
" ssh/config
nnoremap <M-h>S :call <SID>open_or_create_file("~/.ssh/config")<Cr>
" gitconfig
nnoremap <M-h>G :call <SID>open_or_create_file("~/.gitconfig")<Cr>
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
    nnoremap <silent><M-h>i :call TabeOpen("$CONF_D_DIR/init.vim")<Cr>
    nnoremap <silent><M-h>I :call TabeOpen("$INSTALL_DIR/install.vim")<Cr>
    nnoremap <silent><M-h>m :call TabeOpen("$CFG_DIR/main.vim")<Cr>
    nnoremap <silent><M-h>k :call TabeOpen("$CFG_DIR/keybindings.json")<Cr>
    nnoremap <silent><M-h>v :call TabeOpen("$CFG_DIR/vscode.vim")<Cr>
    nnoremap <silent><M-h>O :call TabeOpen("$CFG_DIR/opt.vim")<Cr>
    nnoremap <silent><M-h>f :call TabeOpen("$CONF_D_DIR/plugin/file.vim")<Cr>
    if PlannedLeaderf()
        nnoremap <silent><M-h>a :Leaderf file --regex --no-sort ~/.leovim/conf.d/autoload<Cr>
        nnoremap <silent><M-h>p :Leaderf file --regex --no-sort ~/.leovim/conf.d/plugin<Cr>
        nnoremap <silent><M-h>d :Leaderf file --regex --no-sort ~/.leovim/conf.d<Cr>
        nnoremap <silent><M-h>l :Leaderf file --regex --no-sort ~/.leovim<Cr>
        if UNIX()
            nnoremap <silent><M-h>L :Leaderf file --regex --no-sort ~/.local/bin<Cr>
        endif
    elseif PlannedFzf()
        nnoremap <silent><M-h>a :FzfFiles ~/.leovim/conf.d/autoload<Cr>
        nnoremap <silent><M-h>p :FzfFiles ~/.leovim/conf.d/plugin<Cr>
        nnoremap <silent><M-h>d :FzfFiles ~/.leovim/conf.d<Cr>
        nnoremap <silent><M-h>l :FzfFiles ~/.leovim<Cr>
        if UNIX()
            nnoremap <silent><M-h>L :FzfFiles ~/.local/bin<Cr>
        endif
    endif
    " addtional vim config
    if filereadable(expand("~/.leovim.d/after.vim"))
        source ~/.leovim.d/after.vim
    endif
    nnoremap <silent><M-h>A :call <SID>open_or_create_file("~/.leovim.d/after.vim")<Cr>
    nnoremap <silent><M-h>P :call <SID>open_or_create_file("~/.leovim.d/pack.vim")<Cr>
endif
" ------------------
" delete tmp files
" ------------------
if WINDOWS()
    nnoremap <leader>x :!powershell <C-r>=Expand("~/_leovim.clean.cmd")<Cr><Cr> \| e %<Cr><C-o>
else
    nnoremap <leader>x :!bash <C-r>=Expand("~/.leovim.clean")<Cr><Cr> \| e %<Cr><C-o>
endif
"----------------------------------------------------------------------
" save
"----------------------------------------------------------------------
nnoremap <Leader>W :wa!<Cr>
nnoremap <Leader>w :w!<Cr>
if v:version >= 800 || has('nvim')
    nnoremap <C-s> :w!<Cr>
    xnoremap <C-s> <ESC>:w!<Cr>gv
    cnoremap <C-s> w!<Cr>
    inoremap <C-s> <C-o>:w!<Cr>
    nnoremap <C-w><C-s> :redraw \| wa!<Cr>
    nnoremap <C-w><C-v> :redraw \| wa!<Cr>
endif
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
nnoremap <M-k><space> :ToggleModity<Cr>
" -------------------------
" confirem quit
" -------------------------
function! s:confirm_quit(type) abort
    let type = a:type
    if &ft == 'floaterm'
        FloatermKill
    elseif (&ft == '' || Expand('%') == '' || FtBtIgnored()) && type == 0
        q!
    else
        if type == 'all'
            let choices = ['Quit All']
            let title = "Do you want to quit all buffers? Ctrl+C to cancel"
        elseif type == 'direct'
            if &modified
                let choices = ['Save And Quit', 'Quit Only']
                let title = "Do you want to quit without save? Ctrl+C to cancel""
            else
                UndotreeHide
                q!
                return
            endif
        else
            let title = "Do you want to quit? Ctrl+C to cancel""
            if &modified
                let choices = ['Save And Quit', 'Quit Only']
            else
                let choices = ['Quit']
            endif
        endif
        if &modified && type == 'check'
            let choice = ChooseOne(choices, title, 0, 'Cancel')
            if choice =~# '^Save'
                UndotreeHide
                wq!
            elseif choice =~# '^Quit'
                UndotreeHide
                q!
            endif
        else
            let choice = ChooseOne(choices, title, 0, 'Cancel')
            if choice =~# '^Quit'
                if type == 'all'
                    UndotreeHide
                    if exists(':cquit')
                        cquit
                    else
                        qall!
                    endif
                else
                    UndotreeHide
                    q!
                endif
            elseif choice =~# '^Save'
                UndotreeHide
                wq!
            endif
        endif
    endif
endfun
command! ConfirmQuit call s:confirm_quit('check')
nnoremap <silent><M-q> :ConfirmQuit<Cr>
command! ConfirmQuitAll call s:confirm_quit('all')
nnoremap <silent><leader><BS> :ConfirmQuitAll<Cr>
command! Quit call s:confirm_quit('direct')
nnoremap <silent><leader>q :Quit<Cr>
