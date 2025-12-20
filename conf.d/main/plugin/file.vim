" Skip in VSCode environment
if utils#is_vscode()
    finish
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
command! CR execute('cd ' .  utils#get_root_dir())
command! CG execute('cd ' .  git#git_root_dir()
nnoremap cdr :CR<Cr>
nnoremap cdg :CG<Cr>
nnoremap cdl :lcd %:p:h<Cr>
"------------------------
" search files
"------------------------
if pack#planned_leaderf()
    nnoremap <silent><nowait><C-p> :LeaderfFile <C-r>=utils#get_root_dir()<Cr><Cr>
elseif pack#planned_fzf()
    nnoremap <silent><nowait><C-p> :FzfFiles <C-r>=utils#get_root_dir()<Cr><Cr>
else
    nnoremap <silent><nowait><C-p> :CtrlP <C-r>=utils#get_root_dir()<Cr><Cr>
endif
if pack#planned_leaderf()
    nnoremap <silent><nowait><leader>ff :LeaderfFile ./<Cr>
    nnoremap <silent><nowait><leader>p  :LeaderfFile <C-r>=git#git_root_dir()<Cr><Cr>
elseif pack#planned_fzf()
    nnoremap <silent><nowait><leader>ff :FzfFiles<Cr>
    nnoremap <silent><nowait><leader>p  :FzfGitFiles<Cr>
else
    nnoremap <silent><nowait><leader>ff :CtrlPCurFile<Cr>
    nnoremap <silent><nowait><leader>p  :CtrlP <C-r>=git#git_root_dir()<Cr><Cr>
endif
if pack#pref_fzf()
    nnoremap <nowait>\g :FzfGitFiles <C-r>=@"<Cr>
    xnoremap <nowait>\g :<C-u>FzfGitFiles <C-r>=GetVisualSelection()<Cr>
endif
" ---------------------------------
" open gitroot getroot
" ---------------------------------
nnoremap <leader><Cr> :e<Space>
nnoremap <leader>P :tabe <C-r>=git#git_root_dir()<Cr>/
nnoremap <leader>E :tabe <C-r>=utils#get_root_dir()<Cr>/
" ---------------------------------
" file browser
" ---------------------------------
if pack#installed('oil.nvim')
    lua require('cfg/oil')
    nnoremap <silent><nowait><leader>fo <Cmd>Oil --float<Cr>
endif
if pack#installed('vim-floaterm')
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
if utils#has_gui() || utils#is_win()
    imap <M-O> <C-o>O
    imap <M-o> <C-o>o
    nnoremap <silent><M-N> :tabm +1<Cr>
    nnoremap <silent><M-P> :tabm -1<Cr>
    nnoremap <M-]> :vsplit<Space>
    nnoremap <M-[> :split<Space>
    if pack#installed('oil.nvim')
        nnoremap <silent><nowait><M-o> <Cmd>Oil --float<Cr>
    elseif !has('nvim') && get(g:, 'use_system_browser', utils#is_win())
        let g:browsefilter = ''
        function! s:filter_push(desc, wildcard) abort
            let g:browsefilter .= a:desc . " (" . a:wildcard . ")\t" . a:wildcard . "\n"
        endfunc
        function! s:use_system_browser()
            let l:path = utils#abs_dir()
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
        nnoremap <silent><M-o> :UseSystemBrowser<Cr>
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
        let dir = utils#abs_dir()
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
    let fl = utils#get_root_dir() . '/' . a:fl
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
    nnoremap <silent><M-h>v :call TabeOpen("$INIT_DIR/vscode.vim")<Cr>
    nnoremap <silent><M-h>k :call TabeOpen("$INIT_DIR/keybindings.json")<Cr>
    nnoremap <silent><M-h>u :call TabeOpen("$INIT_DIR/autoload/utils.vim")<Cr>
    nnoremap <silent><M-h>e :call TabeOpen("$PACK_DIR/essential.vim")<Cr>
    nnoremap <silent><M-h>m :call TabeOpen("$MAIN_DIR/main.vim")<Cr>
    nnoremap <silent><M-h>O :call TabeOpen("$MAIN_DIR/opt.vim")<Cr>
    if pack#planned_leaderf()
        nnoremap <silent><M-h>p :Leaderf file --regex --no-sort ~/.leovim/conf.d/main/plugin<Cr>
        nnoremap <silent><M-h>d :Leaderf file --regex --no-sort ~/.leovim/conf.d<Cr>
        nnoremap <silent><M-h>l :Leaderf file --regex --no-sort ~/.leovim<Cr>
        if utils#is_unix()
            nnoremap <silent><M-h>L :Leaderf file --regex --no-sort ~/.local/bin<Cr>
        endif
    elseif pack#planned_fzf()
        nnoremap <silent><M-h>p :FzfFiles ~/.leovim/conf.d/main/plugin<Cr>
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
    nnoremap <silent><M-h>P :call <SID>open_or_create_file("~/.leovim.d/plug.vim")<Cr>
endif
" -----------------------------
" delete tmp files
" -----------------------------
if utils#is_win()
    nnoremap <leader>x :!powershell <C-r>=utils#expand("~/_leovim.clean.cmd")<Cr><Cr> \| e %<Cr><C-o>
else
    nnoremap <leader>x :!bash <C-r>=utils#expand("~/.leovim.clean")<Cr><Cr> \| e %<Cr><C-o>
endif
" -----------------------------
" save
" -----------------------------
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
" -----------------------------
" mklink
" -----------------------------
function! s:mklink(cmd, ...) abort
    if a:0 && a:1 > 0
        execute("!echo " . a:cmd)
    endif
    execute("!" . a:cmd)
endfunction
let s:editor_dirs = []
let s:editor_names = ["code", "trae", "kiro", "qoder", "lingma", "cursor", "windsurf", "positron"]
for editor in s:editor_names
    let dir = fnameescape(get(g:, editor . "_user_dir", ""))
    if utils#is_win()
        let dir = substitute(dir, '/', '\', 'g')
    endif
    call add(s:editor_dirs, dir)
endfor
function! s:link() abort
    for dir in s:editor_dirs
        if !isdirectory(dir)
            continue
        endif
        if utils#is_win()
            let delete_cmd = printf('del /Q /S %s\keybindings.json', dir)
            call s:mklink(delete_cmd)
            let rmdir_cmd = printf('rmdir /Q /S %s\snippets', dir)
            call s:mklink(rmdir_cmd)
            " mklink
            let mklink_cmd = printf('mklink %s %s', dir . '\keybindings.json', $INIT_DIR . '\keybindings.json')
            call s:mklink(mklink_cmd)
            let mklink_cmd = printf('mklink /d %s %s', dir . '\snippets', $CONF_D_DIR . '\snippets')
            call s:mklink(mklink_cmd)
        else
            let rm_cmd = printf('rm %s',  dir . '/keybindings.json')
            call s:mklink(rm_cmd)
            let rm_cmd = printf('rm -rf %s',  dir . '/snippets')
            call s:mklink(rm_cmd)
            " ln -sf
            let ln_cmd = printf('ln -sf %s %s', $INIT_DIR . '/keybindings.json', dir . '/keybindings.json')
            call s:mklink(ln_cmd, 1)
            let ln_cmd = printf('ln -sf %s %s', $CONF_D_DIR . '/snippets', dir)
            call s:mklink(ln_cmd, 1)
        endif
    endfor
endfunction
command! MkLinkKeyBindings call s:link()
nnoremap <M-h>K :MkLinkKeyBindings<Cr>
