" ------------------------------
" vim-header
" ------------------------------
if get(g:, 'header_field_author', '') != ''
    nnoremap <M-k>a :AddHeader<Cr>
    let g:header_auto_add_header = 0
    let g:header_auto_update_header = 0
    let g:header_field_timestamp_format = '%Y.%m.%d'
    PlugOpt 'vim-header'
endif
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
if utils#pref_fzf()
    nnoremap <silent><nowait><C-p> :FzfFiles <C-r>=GetRootDir()<Cr><Cr>
elseif utils#is_planned_leaderf()
    nnoremap <silent><nowait><C-p> :LeaderfFile <C-r>=GetRootDir()<Cr><Cr>
else
    nnoremap <silent><nowait><C-p> :CtrlP <C-r>=GetRootDir()<Cr><Cr>
endif
if utils#pref_fzf()
    nnoremap <silent><nowait><leader>ff :FzfFiles<Cr>
    nnoremap <silent><nowait><leader>p  :FzfGitFiles<Cr>
elseif utils#is_planned_leaderf()
    nnoremap <silent><nowait><leader>ff :LeaderfFile ./<Cr>
    nnoremap <silent><nowait><leader>p  :LeaderfFile <C-r>=GitRootDir()<Cr><Cr>
else
    nnoremap <silent><nowait><leader>ff :CtrlPCurFile<Cr>
    nnoremap <silent><nowait><leader>p  :CtrlP <C-r>=GitRootDir()<Cr><Cr>
endif
if utils#pref_fzf()
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
if utils#is_installed('oil.nvim')
    lua require('cfg/oil')
    nnoremap <silent><nowait><leader>fo <Cmd>Oil --float<Cr>
endif
if utils#is_installed('vim-floaterm')
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
    if executable('yazi')
        command! FloatermYazi call s:floaterm_float('yazi')
        nnoremap <silent><nowait>\ff :FloatermYazi<Cr>
    elseif executable('ranger')
        command! FloatermRanger call s:floaterm_float('ranger')
        nnoremap <silent><nowait>\ff :FloatermRanger<Cr>
    endif
endif
"------------------------
" open file
"------------------------
nnoremap <M-j>e gf
nnoremap <M-j>t <C-w>gf
nnoremap <M-j>] <C-w>f<C-w>L
nnoremap <M-j>[ <C-w>f
" using system file explorer
if utils#has_gui() || utils#is_windows()
    imap <M-O> <C-o>O
    nmap <M-O> O
    imap <M-o> <C-o>o
    nmap <M-o> o
    nnoremap <silent><M-N> :tabm +1<Cr>
    nnoremap <silent><M-P> :tabm -1<Cr>
    nnoremap <M-]> :vsplit<Space>
    nnoremap <M-[> :split<Space>
    if !has('nvim') && get(g:, 'use_system_browser', utils#is_windows())
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
    let file = utils#expand(a:file, 1)
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
" ssh/config
nnoremap <M-h>C :call <SID>open_or_create_file("~/.ssh/config")<Cr>
" gitconfig
nnoremap <M-h>G :call <SID>open_or_create_file("~/.gitconfig")<Cr>
if utils#is_unix()
    " bashrc
    nnoremap <M-h>b :call <SID>open_or_create_file("~/.bashrc")<Cr>
    " zshrc
    nnoremap <M-h>z :call <SID>open_or_create_file("~/.zshrc")<Cr>
    " configrc
    nnoremap <M-h>c :call <SID>open_or_create_file("~/.configrc")<Cr>
endif
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
        let f = utils#expand(a:f)
        exec "tabe " . f
    endfunction
    nnoremap <silent><M-h>i :call TabeOpen("$CONF_D_DIR/init.vim")<Cr>
    nnoremap <silent><M-h>v :call TabeOpen("$CONF_D_DIR/vscode.vim")<Cr>
    nnoremap <silent><M-h>k :call TabeOpen("$CONF_D_DIR/keybindings.json")<Cr>
    nnoremap <silent><M-h>I :call TabeOpen("$MODULE_DIR/install.vim")<Cr>
    nnoremap <silent><M-h>O :call TabeOpen("$RTP_DIR/opt.vim")<Cr>
    nnoremap <silent><M-h>m :call TabeOpen("$RTP_DIR/main.vim")<Cr>
    if utils#is_planned_leaderf()
        nnoremap <silent><M-h>d :Leaderf file --regex --no-sort ~/.leovim/conf.d<Cr>
        nnoremap <silent><M-h>l :Leaderf file --regex --no-sort ~/.leovim<Cr>
        if utils#is_unix()
            nnoremap <silent><M-h>L :Leaderf file --regex --no-sort ~/.local/bin<Cr>
        endif
    elseif PlannedFzf()
        nnoremap <silent><M-h>d :FzfFiles ~/.leovim/conf.d<Cr>
        nnoremap <silent><M-h>l :FzfFiles ~/.leovim<Cr>
        if utils#is_unix()
            nnoremap <silent><M-h>L :FzfFiles ~/.local/bin<Cr>
        endif
    endif
    " addtional vim config
    if filereadable(utils#expand("~/.leovim.d/after.vim"))
        source ~/.leovim.d/after.vim
    endif
    nnoremap <silent><M-h>A :call <SID>open_or_create_file("~/.leovim.d/after.vim")<Cr>
    nnoremap <silent><M-h>P :call <SID>open_or_create_file("~/.leovim.d/pack.vim")<Cr>
endif
" ------------------
" delete tmp files
" ------------------
if utils#is_windows()
    nnoremap <leader>x :!powershell <C-r>=utils#expand("~/_leovim.clean.cmd")<Cr><Cr> \| e %<Cr><C-o>
else
    nnoremap <leader>x :!bash <C-r>=utils#expand("~/.leovim.clean")<Cr><Cr> \| e %<Cr><C-o>
endif
"----------------------------------------------------------------------
" save
"----------------------------------------------------------------------
if v:version >= 800 || has('nvim')
    nnoremap <C-s> :w!<Cr>
    xnoremap <C-s> <ESC>:w!<Cr>gv
    cnoremap <C-s> w!<Cr>
    inoremap <C-s> <C-o>:w!<Cr>
    nnoremap <C-w><C-s> :redraw \| wa!<Cr>
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
