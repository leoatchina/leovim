try
    set nrformats+=unsigned
catch /.*/
    " pass
endtry
"----------------------------------------------------------------------
" save
"----------------------------------------------------------------------
nnoremap <C-s> :w!<Cr>
cnoremap <C-s> w!<Cr>
inoremap <C-s> <C-o>:w!<Cr>
xnoremap <C-s> <ESC>:w!<Cr>gv
nnoremap <Leader>w :wa!<Cr>
onoremap <Leader>w :wa!<Cr>
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
nnoremap <M-k>a :AddHeader<Cr>
nnoremap <M-k>h :AddBangHeader<Cr>
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
endif
" ---------------------------------
" file browser
" ---------------------------------
if has('patch-8.1.2269') || has('nvim')
    source $CFG_DIR/fern.vim
endif
if has('nvim') && PlannedCoc()
    function! s:coc_file() abort
        exec("CocCommand explorer --toggle --position floating --floating-width " . float2nr(&columns * 0.8) . " --floating-height " . float2nr(&lines * 0.8))
    endfunction
    command! CocFile call s:coc_file()
    nnoremap <silent><nowait><leader>e :CocFile<Cr>
elseif executable('yazi') && g:has_popup_floating && (UNIX() || WINDOWS() && has('nvim'))
    command! FloatermYazi call s:floaterm('yazi')
    nnoremap <silent><nowait><leader>e :FloatermYazi<Cr>
elseif executable('ranger') && g:has_popup_floating
    command! FloatermRanger call s:floaterm('ranger')
    nnoremap <silent><nowait><leader>e :FloatermRanger<Cr>
elseif Installed('fern.vim')
    nnoremap <silent><nowait><leader>e :Fern . -reveal=%<Cr>
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
        nnoremap <silent><M-"> :UseSystemBrowser<Cr>
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
    nnoremap <silent><M-h>i :call TabeOpen("$CONF_D_DIR/init.vim")<Cr>
    nnoremap <silent><M-h>b :call TabeOpen("$INSTALL_DIR/basement.vim")<Cr>
    nnoremap <silent><M-h>k :call TabeOpen("$CFG_DIR/keybindings.json")<Cr>
    nnoremap <silent><M-h>v :call TabeOpen("$CFG_DIR/vscode.vim")<Cr>
    nnoremap <silent><M-h>m :call TabeOpen("$CFG_DIR/main.vim")<Cr>
    nnoremap <silent><M-h>O :call TabeOpen("$CFG_DIR/opt.vim")<Cr>
    nnoremap <silent><M-h>f :call TabeOpen("$CONF_D_DIR/plugin/file.vim")<Cr>
    if PlannedLeaderf()
        nnoremap <silent><M-h>a :Leaderf file --fuzzy --no-sort ~/.leovim/conf.d/autoload<Cr>
        nnoremap <silent><M-h>e :Leaderf file --fuzzy --no-sort ~/.leovim/conf.d/element<Cr>
        nnoremap <silent><M-h>p :Leaderf file --fuzzy --no-sort ~/.leovim/conf.d/plugin<Cr>
        nnoremap <silent><M-h>d :Leaderf file --fuzzy --no-sort ~/.leovim/conf.d<Cr>
        nnoremap <silent><M-h>l :Leaderf file --fuzzy --no-sort ~/.leovim<Cr>
        if UNIX()
            nnoremap <silent><M-h>L :Leaderf file --fuzzy --no-sort ~/.local/bin<Cr>
        endif
    elseif PlannedFzf()
        nnoremap <silent><M-h>a :FzfFiles ~/.leovim/conf.d/autoload<Cr>
        nnoremap <silent><M-h>e :FzfFiles ~/.leovim/conf.d/element<Cr>
        nnoremap <silent><M-h>p :FzfFiles ~/.leovim/conf.d/plugin<Cr>
        nnoremap <silent><M-h>d :FzfFiles ~/.leovim/conf.d<Cr>
        nnoremap <silent><M-h>l :FzfFiles ~/.leovim<Cr>
        if UNIX()
            nnoremap <silent><M-h>L :FzfFiles ~/.local/bin<Cr>
        endif
    endif
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
    let s:cursor_user_dir = substitute(fnameescape(get(g:, "cursor_user_dir", "")), '/', '\', 'g')
else
    let s:vscode_user_dir = fnameescape(get(g:, "vscode_user_dir", ""))
    let s:cursor_user_dir = fnameescape(get(g:, "cursor_user_dir", ""))
endif
let s:theia_user_dir = Expand('~/.theia-ide')
silent! call mkdir(s:theia_user_dir, 'p')
function! s:link_keybindings() abort
    if WINDOWS()
        for dir in [s:cursor_user_dir, s:vscode_user_dir]
            if isdirectory(dir)
                let delete_cmd = printf('!del /Q /S %s\keybindings.json', dir)
                execute(delete_cmd)
                let rmdir_cmd = printf('!rmdir /Q /S %s\snippets', dir)
                execute(rmdir_cmd)
                " create keybindings.json link
                let mklink_cmd = printf('!mklink %s %s', dir . '\keybindings.json', $CFG_DIR . '\keybindings.json')
                execute(mklink_cmd)
                " create snippets link
                let mklink_cmd = printf('!mklink /d %s %s', dir . '\snippets', $LEOVIM_DIR . '\snippets')
                execute(mklink_cmd)
            endif
        endfor
        let delete_cmd = printf('!del /Q /S %s\keymaps.json', s:theia_user_dir)
        execute(delete_cmd)
        let mklink_cmd = printf('!mklink %s %s', s:theia_user_dir . '\keymaps.json', $CFG_DIR . '\keymaps.json')
        execute(mklink_cmd)
    else
        for dir in [s:cursor_user_dir, s:vscode_user_dir]
            if isdirectory(dir)
                let ln_cmd = printf('!ln -sf %s %s', $CFG_DIR . '/keybindings.json', dir . '/keybindings.json')
                execute(ln_cmd)
                let ln_cmd = printf('!ln -sf %s %s', $LEOVIM_DIR . '/snippets', dir . '/snippets')
                execute(ln_cmd)
            endif
        endfor
        let ln_cmd = printf('!ln -sf %s %s', $CFG_DIR . '/keymaps.json', s:theia_user_dir . '/keymaps.json')
        execute(ln_cmd)
    endif
endfunction
command! LinkKeyBindings call s:link_keybindings()
nnoremap <M-h>K :LinkKeyBindings<Cr>
" ------------------
" delete tmp files
" ------------------
if WINDOWS()
    nnoremap <leader>x :!powershell <C-r>=Expand("~/_leovim.clean.cmd")<Cr><Cr> \| e %<Cr><C-o>
else
    nnoremap <leader>x :!bash <C-r>=Expand("~/.leovim.clean")<Cr><Cr> \| e %<Cr><C-o>
endif
" --------------------------
" file templates
" --------------------------
autocmd BufNewFile .lintr          0r $CONF_D_DIR/templates/lintr.spec
autocmd BufNewFile .Rprofile       0r $CONF_D_DIR/templates/Rprofile.spec
autocmd BufNewFile .gitconfig      0r $CONF_D_DIR/templates/gitconfig.spec
autocmd BufNewFile .gitignore      0r $CONF_D_DIR/templates/gitignore.spec
autocmd BufNewFile .wildignore     0r $CONF_D_DIR/templates/wildignore.spec
autocmd BufNewFile .radian_profile 0r $CONF_D_DIR/templates/radian_profile.spec
" --------------------
" diff opt
" --------------------
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
