" --------------------
" fzf config
" --------------------
if Installed("fzf.vim") && Installed("fzf")
    if Installed("LeaderF")
        let g:fuzzy_finder = 'leaderf'
    else
        let g:fuzzy_finder = 'fzf'
    endif
    if get(g:, 'terminal_plus', '') =~ 'floaterm'
        if g:fuzzy_finder == 'leaderf'
            nnoremap <M-h>f :Leaderf floaterm<Cr>
        elseif Installed('fzf-floaterm')
            nnoremap <M-h>f :Floaterms<Cr>
        endif
    endif
    if has('nvim') || has('patch-8.2.191')
        let g:fzf_layout = {'up':'~90%', 'window': {'width': 0.8, 'height': 0.8, 'yoffset': 0.5, 'xoffset': 0.5, 'highlight': 'Todo', 'border': 'sharp'}}
        if WINDOWS()
            let g:fzf_preview_window = ['up:30%:hidden', 'ctrl-/']
        else
            let g:fzf_preview_window = ['up:30%', 'ctrl-/']
        endif
    else
        let g:fzf_layout = {'down': '~30%'}
    endif
    let $FZF_DEFAULT_OPTS = '--layout=reverse-list'
    au FileType fzf tnoremap <buffer> <C-j> <Down>
    au FileType fzf tnoremap <buffer> <C-k> <Up>
    au FileType fzf tnoremap <buffer> <C-n> <Nop>
    au FileType fzf tnoremap <buffer> <C-p> <Nop>
    " preview position
    let g:fzf_command_prefix = 'Fzf'
    " [Buffers] Jump to the existing window if possible
    let g:fzf_buffers_jump = 1
    " [[B]Commits] Customize the options used by 'git log':
    let g:fzf_commits_log_options = '--graph --color=always --format="%C(auto)%h%d %s %C(black)%C(bold)%cr"'
    " [Tags] Command to generate tags fil
    let g:fzf_tags_command = 'ctags -R'
    " [Commands] --expect expression for directly executing the command
    let g:fzf_commands_expect = 'alt-enter'
    function! s:build_quickfix_list(lines)
        call setqflist(map(copy(a:lines), '{ "filename": v:val }'))
        copen
        cc
    endfunction
    let g:fzf_action = {
                \ 'ctrl-e': function('s:build_quickfix_list'),
                \ 'ctrl-t': 'tab split',
                \ 'ctrl-x': 'split',
                \ 'ctrl-v': 'vsplit'
                \ }
    " basic shortcuts for all fuzzy_finders
    nmap t<tab> <plug>(fzf-maps-n)
    xmap t<tab> <plug>(fzf-maps-x)
    omap t<tab> <plug>(fzf-maps-o)
    imap <c-x><c-f> <plug>(fzf-complete-path)
    if executable('rg')
        imap <expr> <c-x><c-l> fzf#vim#complete(fzf#wrap({
                    \ 'prefix': '^.*$',
                    \ 'source': 'rg -n ^ --color always',
                    \ 'options': '--ansi --delimiter : --nth 3..',
                    \ 'reducer': { lines -> join(split(lines[0], ':\zs')[2:], '') }}
                    \ ))
    else
        imap <c-x><c-l> <plug>(fzf-complete-line)
    endif
    " ----------------------
    " short cuts for fzf
    " ----------------------
    nnoremap z; :Fzf
    nnoremap z, :FZF
    " locate file
    nnoremap <M-f>l :FZFLocate<Space>
    " for git
    nnoremap <M-g>b :FzfBCommits<Cr>
    nnoremap <M-g>c :FzfCommits<Cr>
    nnoremap <M-g>f :FzfGFiles?<CR>
    " helptags
    if executable('perl')
        nnoremap <M-h>h :FzfHelptags<CR>
    endif
    " --------------------
    " FzfRegisters
    " --------------------
    function! s:paste_select(select) abort
        let reg = a:select[1]
        call feedkeys("\"" . reg . "p")
    endfunction
    function! s:Paste_select(select) abort
        let reg = a:select[1]
        call feedkeys("\"" . reg . "P")
    endfunction
    function! s:fzf_registers(bang) abort
        let bang = a:bang
        redir => registers
        silent registers
        redir END
        let reg_lst = split(registers, '\n')
        " cut head
        if reg_lst[0][0:3] == 'Type'
            let cut5 = 1
        else
            let cut5 = 0
        endif
        let lst = []
        for reg in reg_lst[1:]
            if cut5 > 0
                let reg = reg[5:]
            endif
            let reg = substitute(reg, "\\^J", "\\r", "g")
            call add(lst, reg)
        endfor
        if bang > 0
            let opts = {
                \ 'source':  lst,
                \ 'sink':    function('s:Paste_select'),
                \ 'options': '--ansi -x --prompt "Registers_P>"'
                \ }
        else
            let opts = {
                \ 'source':  lst,
                \ 'sink':    function('s:paste_select'),
                \ 'options': '--ansi -x --prompt "Registers_p>"'
                \ }
        endif
        let opts = extend(opts, g:fzf_layout)
        call fzf#run(opts, 0)
    endfunction
    command! -bang FzfRegistersp call s:fzf_registers(<bang>0)
    command! -bang FzfRegistersP call s:fzf_registers(<bang>1)
    nnoremap <silent> <leader>p :FzfRegistersP<Cr>
    nnoremap <silent> ,p        :FzfRegistersp<Cr>
    xnoremap <silent> <leader>p :<C-u>FzfRegistersP<Cr>
    xnoremap <silent> ,p        :<C-u>FzfRegistersp<Cr>
    " --------------------
    " history jumps
    " --------------------
    function! s:jumpListFormat(val) abort
        let l:file_name = bufname('%')
        let l:file_name = empty(l:file_name) ? 'Unknown file name' : l:file_name
        let l:curpos = getcurpos()
        let l:l = matchlist(a:val, '\(>\?\)\s*\(\d*\)\s*\(\d*\)\s*\(\d*\) \?\(.*\)')
        let [l:mark, l:jump, l:line, l:col, l:content] = l:l[1:5]
        if empty(trim(l:mark)) | let l:mark = '-' | endif
        if filereadable(expand(fnameescape(l:content)))
            let l:file_name = expand(l:content)
            let l:bn = bufnr(l:file_name)
            if l:bn > -1 && buflisted(l:bn) > 0
                let l:content = getbufline(l:bn, l:line)
                let l:content = empty(l:content) ? "" : l:content[0]
            else
                let l:content = system("sed -n " . l:line . "p " . l:file_name)
            endif
        elseif empty(trim(l:content))
            if empty(trim(l:line))
                let [l:line, l:col] = l:curpos[1:2]
            endif
            let l:content = getline(l:line, l:line)[0]
        endif
        return l:mark . " " . l:file_name . ":" . l:line . ":" . l:col . " " . l:content
    endfunction
    if g:has_execute_func > 0
        function! s:jumpList() abort
            let l:jl = execute('jumps')
            return map(reverse(split(l:jl, '\n')[1:]), 's:jumpListFormat(v:val)')
        endfunction
        function! s:jumpHandler(jp)
            let l:l = matchlist(a:jp, '\(.\)\s\(.*\):\(\d\+\):\(\d\+\)\(.*\)')
            let [l:file_name, l:line, l:col, l:content] = l:l[2:5]
            if empty(l:file_name) || empty(l:line) | return | endif
            " 判断文件是否已经存在buffer中
            let l:bn = bufnr(l:file_name)
            " 未打开
            if l:bn == -1 | if filereadable(l:file_name) | execute 'e ' . 'l:file_name' | endif
            else | execute 'buffer ' . l:bn | endif
            call cursor(str2nr(l:line), str2nr(l:col))
            normal! zvzz
        endfunction
        function! s:FzfJumps() abort
            if WINDOWS()
                call fzf#run(fzf#wrap({
                        \ 'source': s:jumpList(),
                        \ 'sink': function('<SID>jumpHandler'),
                        \ 'options': [
                            \ '--prompt=Jumps'
                        \ ],
                        \ }))
            else
                call fzf#run(fzf#wrap({
                        \ 'source': s:jumpList(),
                        \ 'sink': function('<SID>jumpHandler'),
                        \ 'options': [
                            \ '--prompt=Jumps',
                            \ '--preview', $ADDINS_PATH . '/preview.sh {2}',
                            \ '--preview-window=up:35%'
                        \ ],
                        \ }))
            endif
        endfunction
        command! -bang -nargs=* FZFJumps call s:FzfJumps()
        nnoremap <M-h>j :FZFJumps<cr>
    endif
endif
if g:fuzzy_finder == 'leaderf'
    au FileType leaderf set nonu
    if executable('ctags')
        if WINDOWS()
            let g:Lf_Ctags = "ctags"
        else
            let g:Lf_Ctags = "ctags 2>/dev/null"
        endif
    endif
    let g:Lf_DefaultMode       = 'Fuzzy'
    let g:Lf_ReverseOrder      = 0
    let g:Lf_NoChdir           = 1
    let g:Lf_ShowDevIcons      = 0
    let g:Lf_PythonVersion     = float2nr(g:python_version)
    if has('nvim') || has('patch-8.1.1615')
        let g:Lf_PreviewInPopup = 1
        let g:Lf_WindowPosition = 'popup'
        let g:Lf_PopupWidth     = 0.85
        let g:Lf_PopupHeight    = 0.7
    else
        let g:Lf_PreviewInPopup = 0
    endif
    let g:Lf_WildIgnore = {
                \ 'dir': ['.svn','.git','.hg', '.root'],
                \ 'file': ['*.sw?','~$*','*.bak','*.exe','*.o','*.so','*.py[co]', '*tags']
                \ }
    let g:Lf_NormalMap = {
                \ "File":        [["<ESC>", ':exec g:Lf_py "fileExplManager.quit()"<CR>']],
                \ "Filer":       [["<ESC>", ':exec g:Lf_py "filerExplManager.quit()"<CR>']],
                \ "Buffer":      [["<ESC>", ':exec g:Lf_py "bufExplManager.quit()"<CR>']],
                \ "Mru":         [["<ESC>", ':exec g:Lf_py "mruExplManager.quit()"<CR>']],
                \ "Tag":         [["<ESC>", ':exec g:Lf_py "tagExplManager.quit()"<CR>']],
                \ "Function":    [["<ESC>", ':exec g:Lf_py "functionExplManager.quit()"<CR>']],
                \ "Colorscheme": [["<ESC>", ':exec g:Lf_py "colorschemeExplManager.quit()"<CR>']],
                \ }
    let g:Lf_CommandMap = {'<C-]>': ['<C-V>'], '<C-V>': ['<M-v>'], '<C-j>':['<Down>', '<C-j>'], '<C-k>':['<Up>', '<C-k>']}
    " show fuzzy functions
    nnoremap <silent><C-p> :Leaderf self<Cr>
    " main selector
    nnoremap <leader>w :Leaderf window<Cr>
    nnoremap <leader>b :Leaderf buffer<Cr>
    if Installed('LeaderF-filer')
        nnoremap <leader>f :Leaderf filer<Cr>
        let g:Lf_ShortcutF = ',f'
    else
        let g:Lf_ShortcutF = '<leader>f'
    endif
    if Installed('LeaderF-marks')
        nnoremap m<Tab> :Leaderf marks<Cr>
    endif
    nnoremap qf :Leaderf quickfix<Cr>
    nnoremap ql :Leaderf loclist<Cr>
    nnoremap f<Cr>  :Leaderf function<Cr>
    nnoremap F<Cr>  :Leaderf function --all<Cr>
    nnoremap <M-h>, :Leaderf searchHistory<Cr>
    nnoremap <M-h>; :Leaderf<Space>
    nnoremap <M-h>. :Leaderf --recall<Cr>
    nnoremap <M-h>c :Leaderf cmdHistory<Cr>
    nnoremap <M-h>m :Leaderf mru<Cr>
    nnoremap <M-k>t :Leaderf tag<Cr>
    nnoremap <M-k>b :Leaderf bufTag<cr>
    nnoremap <M-k>a :Leaderf bufTag --all<cr>
    " replace origin command
    nnoremap <M-m>s :Leaderf colorscheme<Cr>
    nnoremap <M-m>t :Leaderf filetype<Cr>
    nnoremap <M-m>c :Leaderf command<Cr>
    " search cword
    nnoremap \| :Leaderf line --no-sort --cword<Cr>
    xnoremap \| <ESC>:Leaderf line --no-sort --input <C-R>=GetVisualSelection()<CR><CR>
    nnoremap g\| :Leaderf line --all --no-sort --cword<Cr>
    xnoremap g\| <ESC>:Leaderf line --all --no-sort --input <C-R>=GetVisualSelection()<CR><CR>
    nnoremap <M-k>l :Leaderf line --no-sort<Cr>
    nnoremap <M-k>m :Leaderf line --all --no-sort<Cr>
    " leader-filer
    let g:Lf_FilerShowPromptPath = 1
    " normal mode
    let g:Lf_FilerUseDefaultNormalMap = 0
    let g:Lf_FilerNormalMap = {
                \ '<C-h>': 'open_parent',
                \ '<C-l>': 'open_current',
                \ '~':     'goto_root_marker_dir',
                \ 'H':     'toggle_hidden_files',
                \ 'j':     'down',
                \ 'k':     'up',
                \ '<F1>':  'toggle_help',
                \ '<F2>':  'rename',
                \ '<F3>':  'clear_selections',
                \ '<Tab>': 'switch_insert_mode',
                \ 'i':     'switch_insert_mode',
                \ 'p':     'preview',
                \ 'q':     'quit',
                \ 'o':     'accept',
                \ '<CR>':  'accept',
                \ '<C-x>': 'accept_horizontal',
                \ '<C-v>': 'accept_vertical',
                \ '<C-t>': 'accept_tab',
                \ '<C-k>': 'page_up_in_preview',
                \ '<C-j>': 'page_down_in_preview',
                \ '<Esc>': 'close_preview_popup',
                \ 's':     'add_selections',
                \ '<C-a>': 'select_all',
                \ 'K':     'mkdir',
                \ 'C':     'copy',
                \ 'P':     'paste',
                \ 'O':     'create_file',
                \ '@':     'change_directory',
                \}
    " insert mode
    let g:Lf_FilerUseDefaultInsertMap = 0
    let g:Lf_FilerInsertMap = {
                \ '<C-h>':              'open_parent_or_backspace',
                \ '<C-l>':              'open_current',
                \ '<C-y>':              'toggle_hidden_files',
                \ '<C-g>':              'goto_root_marker_dir',
                \ '<Esc>':              'quit',
                \ '<C-c>':              'quit',
                \ '<CR>':               'accept',
                \ '<C-s>':              'accept_horizontal',
                \ '<C-v>':              'accept_vertical',
                \ '<C-t>':              'accept_tab',
                \ '<C-r>':              'toggle_regex',
                \ '<BS>':               'backspace',
                \ '<C-u>':              'clear_line',
                \ '<C-w>':              'delete_left_word',
                \ '<C-d>':              'delete',
                \ '<C-o>':              'paste',
                \ '<C-a>':              'home',
                \ '<C-e>':              'end',
                \ '<C-b>':              'left',
                \ '<C-f>':              'right',
                \ '<C-j>':              'down',
                \ '<C-k>':              'up',
                \ '<C-p>':              'prev_history',
                \ '<C-n>':              'next_history',
                \ '<C-q>':              'preview',
                \ '<Tab>':              'switch_normal_mode',
                \ '<C-Up>':             'page_up_in_preview',
                \ '<C-Down>':           'page_down_in_preview',
                \ '<ScroollWhellUp>':   'up3',
                \ '<ScroollWhellDown>': 'down3',
                \}
    " Customize normal mode mapping using g:Lf_NormalMap
    let g:Lf_NormalMap.Filer = [['B', ':LeaderfBookmark<CR>']]
elseif g:fuzzy_finder == 'fzf'
    if has('nvim')
        nnoremap <C-p> :FZF<C-i>
    else
        nnoremap <C-p> :FZF
    endif
    nnoremap ,f        :FZFFiles<Cr>
    nnoremap <leader>b :FzfBuffers<CR>
    " replace origin command
    nnoremap <M-m>s :FzfColors<CR>
    nnoremap <M-m>t :FzfFiletypes<CR>
    nnoremap <M-m>c :FzfCommands<CR>
    if WINDOWS()
        nnoremap m<Tab>    :FzfMarks<CR>
        nnoremap <leader>w :FzfWindows<CR>
    " FZF
    else
        nnoremap m<Tab>    :FZFMarks<CR>
        nnoremap <leader>w :FZFWindows<CR>
    endif
    nnoremap \| :FZFBLines <C-R>=expand('<cword>')<Cr><Cr>
    xnoremap \| <ESC>:FZFBLines <C-R>=GetVisualSelection()<CR><CR>
    nnoremap g\| :FzfLines <C-R>=expand('<cword>')<Cr><Cr>
    xnoremap g\| <ESC>:FzfLines <C-R>=GetVisualSelection()<CR><CR>
    nnoremap qf :FZFQuickFix<CR>
    nnoremap ql :FZFLocList<CR>
    nnoremap <M-h>, :FZFHistory/<CR>
    nnoremap <M-h>c :FZFHistory:<CR>
    nnoremap <M-h>m :FZFMru<CR>
    nnoremap <M-k>l :FZFBLines<CR>
    nnoremap <M-k>b :FZFBTags<CR>
    nnoremap <M-k>m :FzfLines<CR>
endif
if g:fuzzy_finder == 'ctrlp' || g:fuzzy_finder == 'fzf' && Installed('fzf.vim')
    if !exists('g:leovim_loaded')
        set rtp+=$ADDINS_PATH/ctrlp.vim
        set rtp+=$ADDINS_PATH/ctrlp-extensions.vim
        command! CtrlPCmdline call ctrlp#init(ctrlp#cmdline#id())
        command! CtrlPMenu call ctrlp#init(ctrlp#menu#id())
        command! CtrlPYankring call ctrlp#init(ctrlp#yankring#id())
    endif
    nnoremap <silent> <C-p>  :CtrlPMenu<CR>
    nnoremap <silent> <M-h>y :CtrlPYankring<Cr>
    nnoremap <M-h>;   :CtrlP
    let g:ctrlp_map = '<leader>f'
    let g:ctrlp_extensions = ['menu', 'line', 'tag', 'buftag', 'funky', 'cmdline', 'files', 'yankring', 'buffer', 'quickfix', 'undo']
    if g:fuzzy_finder == 'ctrlp'
        nnoremap <silent> <leader>b :CtrlPBuffer<CR>
        nnoremap <silent> <leader>u :CtrlPUndo<CR>
        nnoremap <silent> <M-h>,    :CtrlPCmdline<CR>
        nnoremap <silent> <M-h>m    :CtrlPMRU<CR>
        nnoremap <silent> <M-k>b    :CtrlPBufTag<CR>
        nnoremap <silent> <M-k>a    :CtrlPBufTagAll<CR>
        nnoremap <silent> <M-k>l    :CtrlPLine<Cr>
        if &rtp !~ 'quickui' && !exists('g:leovim_loaded')
            set rtp+=$ADDINS_PATH/ctrlp-funky
            nnoremap <silent> f<Cr> :CtrlPFunky<Cr>
        endif
        if get(g:, 'symbol_tool', '') =~ 'tagbar' || get(g:, 'symbol_tool', '') =~ 'vista'
            nnoremap <silent> <M-t> :CtrlPTag<CR>
        else
            nnoremap <silent> <M-k>t :CtrlPTag<CR>
        endif
        let g:ctrlp_working_path_mode = 'ra'
        let g:ctrlp_custom_ignore = {
                    \ 'dir':  '\v[\/]\.(git|hg|svn|root)$',
                    \ 'file': '\v\.(exe|so|dll|pyd|pyc)$',
                    \ }
        if WINDOWS()
            let s:ctrlp_fallback = 'dir %s /-n /b /s /a-d'
        else
            let $PATH = $ADDINS_PATH . "/bin:". $PATH
            let s:ctrlp_fallback = '[ $PWD == $HOME ] && echo "In HOME Directory" || ack %s --nocolor -f'
        endif
        if exists("g:ctrlp_user_command")
            unlet g:ctrlp_user_command
        endif
        let g:ctrlp_user_command = {
                    \ 'types': {
                    \ 1: ['.git', 'cd %s && git ls-files . --cached --exclude-standard --others'],
                    \ 2: ['.hg', 'hg --cwd %s locate -I .'],
                    \ },
                    \ 'fallback': s:ctrlp_fallback
                    \ }
        if g:python_version > 2
            set rtp+=$ADDINS_PATH/ctrlp-py-matcher
            let g:ctrlp_match_func = {'match': 'pymatcher#PyMatch'}
        endif
    endif
endif
" --------------------
" tree_browser
" --------------------
let g:netrw_banner       = 0
let g:netrw_liststyle    = 3
let g:netrw_browse_split = 4
let g:netrw_winsize      = 16
if Installed('fern.vim')
    let g:tree_browser = 'fern'
    let g:fern#renderer#default#leaf_symbol = ' '
    function! s:init_fern() abort
        " Use 'select' instead of 'edit' for default 'open' action
        set nonu
        nmap <buffer> <Plug>(fern-action-open) <Plug>(fern-action-open:select)
        nmap <buffer> v <Plug>(fern-action-open:vsplit)
        nmap <buffer> x <Plug>(fern-action-open:split)
        nmap <buffer> t <Plug>(fern-action-open:tabedit)
        nmap <buffer> V <Plug>(fern-action-open:edit/vsplit)
        nmap <buffer> X <Plug>(fern-action-open:edit/split)
        nmap <buffer> T <Plug>(fern-action-open:edit/tabedit)
        nmap <buffer> n <Plug>(fern-action-rename)
    endfunction
    augroup init_fern
        autocmd! *
        autocmd FileType fern call s:init_fern()
    augroup END
    nnoremap <silent> <leader>N :Fern . -drawer -reveal=%<Cr>
    nnoremap <silent> <leader>O :Fern . -reveal=%<Cr>
    nnoremap qn :Fern -drawer -stay -toggle<Space>
    nnoremap qo :Fern<Space>
else
    " --------------------------
    " netrw with vim-vinegar
    " --------------------------
    let g:tree_browser = 'netrw'
    if !exists('g:leovim_loaded')
        set rtp+=$ADDINS_PATH/vim-vinegar
    endif
    function! CloseNetrw()
        try
            let expl_win_num = bufwinnr(t:expl_buf_num)
            if expl_win_num != -1
                let cur_win_nr = winnr()
                exec expl_win_num . 'wincmd w'
                close
                execute winbufnr(cur_win_nr) . "wincmd w"
            endif
        catch /.*/
            " PASS
        endtry
        unlet t:expl_buf_num
    endfunction
    command! CloseNetrw call CloseNetrw()
    function! OpenNetrw()
        Vexplore
        let t:expl_buf_num = bufnr("%")
        execute winnr('#') . "wincmd w"
    endfunction
    command! OpenNetrw call OpenNetrw()
    function! ToggleNetrw()
        if exists("t:expl_buf_num")
            CloseNetrw
        else
            OpenNetrw
        endif
    endfunction
    command! ToggleNetrw call ToggleNetrw()
    au FileType netrw nmap <buffer> <C-l> <Nop>
    au FileType netrw nmap <buffer> <M-r> <Plug>NetrwFresh
    if !Installed('sidebar.vim')
        nnoremap <leader>n :ToggleNetrw<CR>
    endif
endif
" --------------------------
" quickui
" --------------------------
if Installed('vim-quickui')
    let g:quickui_border_style = 2
    nnoremap <leader>em :call quickui#tools#display_messages()<Cr>
    nnoremap <silent><M-down> :call quickui#preview#scroll(1)<Cr>
    nnoremap <silent><M-up>   :call quickui#preview#scroll(-1)<Cr>
    if g:fuzzy_finder != 'leaderf'
        nnoremap <silent> f<Cr> :call quickui#tools#list_function()<Cr>
    endif
endif
