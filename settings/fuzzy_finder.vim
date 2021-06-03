" --------------------
" fzf config
" --------------------
if Installed("fzf.vim") && Installed("fzf")
    if Installed("LeaderF")
        let g:fuzzy_finder = 'leaderf'
        let g:Lf_ShortcutF = ',f'
    else
        let g:fuzzy_finder = 'fzf'
        nnoremap ,f :FZFFiles<Cr>
    endif
    if get(g:, 'terminal_plus', '') =~ 'floaterm'
        if get(g:, 'fuzzy_finder', '') == 'leaderf'
            nnoremap <M-h>o :Leaderf floaterm<Cr>
        elseif Installed('fzf-floaterm')
            nnoremap <M-h>o :Floaterms<Cr>
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
    nmap m<tab> <plug>(fzf-maps-n)
    xmap m<tab> <plug>(fzf-maps-x)
    omap m<tab> <plug>(fzf-maps-o)
    " ----------------------
    " short cuts for fzf
    " ----------------------
    nnoremap z; :Fzf<tab><tab>
    nnoremap z, :FZF<tab>
    " locate file
    nnoremap <M-f>0 :FZFLocate<Space>
    if Installed('vim-yoink')
        let g:yoinkMaxItems = 100
        nmap <leader>yc :ClearYanks<Cr>
        nmap p   <plug>(YoinkPaste_p)
        nmap P   <plug>(YoinkPaste_P)
        " --------------------
        " FZFYank
        " --------------------
        function! s:yank_list()
            redir => ys
            silent Yanks
            redir END
            if len(ys) >= 1
                let lst = split(ys, '\n')[1:]
                " 如果Yank list第一个和"存储器内容不同，使用"存储器内容
                if @" != lst[0][4:]
                    if len(lst) == 1
                        let lst = ["\"   " . @"]
                    else
                        let lst = ["\"   " . @"] + lst[1:]
                    endif
                endif
                return lst
            else
                return ["\"   " . @"]
            endif
        endfunction
        function! s:paste_yank(select) dict
            if empty(a:select)
                echo "aborted register paste"
            else
                let select = a:select
                if select[0] != "\""
                    if select[1] == ' '
                        let idx = str2nr(select[0])
                    else
                        let idx = str2nr(select[:1])
                    endif
                    if idx > 0
                        call yoink#rotate(idx)
                    endif
                endif
                if self.visual == 0
                    call feedkeys(self.paste)
                else
                    call feedkeys('gv' . self.paste)
                endif
            endif
        endfunction
        command! -range FZFYankBefore call fzf#run(extend({
                    \ 'source': s:yank_list(),
                    \ 'sink': function('s:paste_yank', {'paste': 'P', 'visual': 0}),
                    \ 'options': '--ansi -x --prompt "YankBefore>"'
                    \ }, g:fzf_layout), 0)
        command! -range FZFYankAfter call fzf#run(extend({
                    \ 'source': s:yank_list(),
                    \ 'sink': function('s:paste_yank', {'paste': 'p', 'visual': 0}),
                    \ 'options': '--ansi -x --prompt "YankAfter>"'
                    \ }, g:fzf_layout), 0)
        command! -range FZFYankBeforeV call fzf#run(extend({
                    \ 'source': s:yank_list(),
                    \ 'sink': function('s:paste_yank', {'paste': 'P', 'visual': 1}),
                    \ 'options': '--ansi -x --prompt "YankBefore>"'
                    \ }, g:fzf_layout), 0)
        command! -range FZFYankAfterV call fzf#run(extend({
                    \ 'source': s:yank_list(),
                    \ 'sink': function('s:paste_yank', {'paste': 'p', 'visual': 1}),
                    \ 'options': '--ansi -x --prompt "YankAfter>"'
                    \ }, g:fzf_layout), 0)
        nnoremap <silent> ,i :FZFYankBefore<Cr>
        nnoremap <silent> ,p :FZFYankAfter<Cr>
        xnoremap <silent> ,i :<C-u>FZFYankBeforeV<Cr>
        xnoremap <silent> ,p :<C-u>FZFYankAfterV<Cr>
    endif
    " --------------------
    " FZFRegisters
    " --------------------
    function! s:fzf_registers()
        redir => registers
        silent registers
        redir END
        let reg_lst = split(registers, '\n')
        " cut head
        if reg_lst[0][0:3] == 'Type'
            let cut_head = 1
        else
            let cut_head = 0
        endif
        let lst = []
        for reg in reg_lst[1:]
            if cut_head > 0
                let reg = reg[5:]
            endif
            let reg = substitute(reg, "\\^J", "\\r", "g")
            call add(lst, reg)
        endfor
        return lst
    endfunction
    function! s:paste_select(select) dict
        " NOTE: select[1] is the name of register
        let reg = a:select[1]
        if self.visual == 0
            let cmd = "\"" . reg . self.paste
        else
            let cmd = "gv\"" . reg . self.paste
        endif
        call feedkeys(cmd)
    endfunction
    command! -range FZFRegisterBefore call fzf#run(extend({
            \ 'source': s:fzf_registers(),
            \ 'sink': function('s:paste_select', {'paste': 'P', 'visual': 0}),
            \ 'options': '--ansi -x --prompt "PasteBefore>"'
            \ }, g:fzf_layout), 0)
    command! -range FZFRegisterAfter call fzf#run(extend({
            \ 'source': s:fzf_registers(),
            \ 'sink': function('s:paste_select', {'paste': 'p', 'visual': 0}),
            \ 'options': '--ansi -x --prompt "PasteAfter>"'
            \ }, g:fzf_layout), 0)
    command! -range FZFRegisterBeforeV call fzf#run(extend({
            \ 'source': s:fzf_registers(),
            \ 'sink': function('s:paste_select', {'paste': 'P', 'visual': 1}),
            \ 'options': '--ansi -x --prompt "PasteBefore>"'
            \ }, g:fzf_layout), 0)
    command! -range FZFRegisterAfterV call fzf#run(extend({
            \ 'source': s:fzf_registers(),
            \ 'sink': function('s:paste_select', {'paste': 'p', 'visual': 1}),
            \ 'options': '--ansi -x --prompt "PasteAfter>"'
            \ }, g:fzf_layout), 0)
    nnoremap <silent> <leader>i :FZFRegisterBefore<Cr>
    nnoremap <silent> <leader>p :FZFRegisterAfter<Cr>
    xnoremap <silent> <leader>i :<C-u>FZFRegisterBeforeV<Cr>
    xnoremap <silent> <leader>p :<C-u>FZFRegisterAfterV<Cr>
    " --------------------
    " Jumps
    " --------------------
    if get(g:, 'fuzzy_finder', '') == 'leaderf'
        nnoremap <M-y> :Leaderf jumps --fullScreen<cr>
    elseif g:has_execute_func > 0
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
        function! s:jumpList() abort
            let l:jl = execute('jumps')
            return map(reverse(split(l:jl, '\n')[1:]), 's:jumpListFormat(v:val)')
        endfunction
        function! s:jumpHandler(jp)
            let l:l = matchlist(a:jp, '\(.\)\s\(.*\):\(\d\+\):\(\d\+\)\(.*\)')
            let [l:file_name, l:line, l:col, l:content] = l:l[2:5]
            if empty(l:file_name) || empty(l:line) | return | endif
            " 判断文件是否已经存在 buffer 中
            let l:bn = bufnr(l:file_name)
            " 未打开
            if l:bn == -1 | if filereadable(l:file_name) | execute 'e ' . 'l:file_name' | endif
            else | execute 'buffer ' . l:bn | endif
            call cursor(str2nr(l:line), str2nr(l:col))
            normal! zvzz
        endfunction
        function! s:FZFJumps() abort
            if WINDOWS()
                call fzf#run(fzf#wrap({
                        \ 'source': s:jumpList(),
                        \ 'sink': function('s:jumpHandler'),
                        \ 'options': [
                            \ '--prompt=Jumps>'
                        \ ],
                        \ }))
            else
                call fzf#run(fzf#wrap({
                        \ 'source': s:jumpList(),
                        \ 'sink': function('s:jumpHandler'),
                        \ 'options': [
                            \ '--prompt=Jumps>',
                            \ '--preview', $ADDINS_PATH . '/preview.sh {2}',
                            \ '--preview-window=up:35%'
                        \ ],
                        \ }))
            endif
        endfunction
        command! -bang -nargs=* FZFJumps call s:FZFJumps()
        nnoremap <M-y> :FZFJumps<cr>
    endif
endif
if get(g:, 'fuzzy_finder', '') == 'leaderf'
    au FileType leaderf set nonu
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
    let g:Lf_CommandMap = {'<C-]>': ['<C-V>'], '<C-V>': ['<M-v>', '<C-y>'], '<C-j>':['<Down>', '<C-j>'], '<C-k>':['<Up>', '<C-k>'], '<F5>': ['<C-e>']}
    " show fuzzy functions
    if !Installed('coc.nvim')
        nnoremap <silent><C-p> :Leaderf self<Cr>
    endif
    nnoremap <M-F> :Leaderf<Tab>
    " main selector
    nnoremap <leader>w :Leaderf window<Cr>
    nnoremap <leader>b :Leaderf buffer<Cr>
    if Installed('LeaderF-marks')
        nnoremap m<Cr> :Leaderf marks<Cr>
    endif
    nnoremap s<space>  :Leaderf searchHistory<Cr>
    nnoremap <Tab>f  :CloseQuickfix<Cr>:Leaderf quickfix<Cr>
    nnoremap <S-Tab> :CloseQuickfix<Cr>:Leaderf loclist<Cr>
    nnoremap <M-h>; :Leaderf --next<Cr>
    nnoremap <M-h>, :Leaderf --previous<Cr>
    nnoremap <M-h>. :Leaderf --recall<Cr>
    nnoremap <M-h>c :Leaderf cmdHistory<Cr>
    nnoremap <M-h>m :Leaderf mru<Cr>
    " replace origin command
    nnoremap <M-w>s :Leaderf colorscheme<Cr>
    nnoremap <M-w>t :Leaderf filetype<Cr>
    nnoremap <M-w>c :Leaderf command<Cr>
    " help tags
    nnoremap q<Space> :Leaderf help<Cr>
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
elseif get(g:, 'fuzzy_finder', '') == 'fzf'
    nnoremap <leader>b :FzfBuffers<CR>
    " replace origin command
    nnoremap <M-w>s :FzfColors<CR>
    nnoremap <M-w>t :FzfFiletypes<CR>
    nnoremap <M-w>c :FzfCommands<CR>
    if WINDOWS()
        nnoremap m<Cr>     :FzfMarks<CR>
        nnoremap <leader>w :FzfWindows<CR>
    " FZF
    else
        nnoremap m<Cr>     :FZFMarks<CR>
        nnoremap <leader>w :FZFWindows<CR>
    endif
    nnoremap \| :FZFBLines <C-R>=expand('<cword>')<Cr><Cr>
    xnoremap \| <ESC>:FZFBLines <C-R>=GetVisualSelection()<CR><CR>
    nnoremap g\| :FzfLines <C-R>=expand('<cword>')<Cr><Cr>
    xnoremap g\| <ESC>:FzfLines <C-R>=GetVisualSelection()<CR><CR>
    nnoremap <Tab>f   :CloseQuickfix<Cr>:FZFQuickFix<CR>
    nnoremap <S-tab>  :CloseQuickfix<Cr>:FZFLocList<CR>
    nnoremap s<space> :FZFHistory/<CR>
    nnoremap <M-h>c   :FZFHistory:<CR>
    nnoremap <M-h>m   :FZFMru<CR>
    nnoremap <M-k>l   :FZFBLines<CR>
    nnoremap <M-k>m   :FzfLines<CR>
    " helptags
    if executable('perl')
        nnoremap q<Space> :FzfHelptags<CR>
    endif
endif
if Installed('coc.nvim')
    let g:coc_data_home   = expand("~/.leovim.plug/coc")
    let g:coc_config_home = expand("~/.leovim.plug/coc-config")
    nnoremap <C-p>  :CocFzfList<CR>
    nnoremap <M-h>. :CocFzfListResume<CR>
    nnoremap <M-l>; :Coc
    nnoremap <M-l>, :CocInstall<Space>
    if Installed('LeaderF')
        nnoremap <M-h>p :CocFzfList<Space>
        nnoremap <M-h>P :CocList<Space>
    else
        nnoremap <M-F>  :CocFzfList<Space>
        nnoremap <M-h>p :CocList<Space>
    endif
    nnoremap <M-h>l :CocFzfList location<Cr>
    nnoremap <Tab>y :CocFzfList yank<Cr>
    nnoremap <M-k>o :CocFzfList outline<CR>
    nnoremap <M-l>c :CocFzfList commands<Cr>
    " Create mappings for function text object, requires document symbols feature of languageserver.
    xmap if <Plug>(coc-funcobj-i)
    xmap af <Plug>(coc-funcobj-a)
    omap if <Plug>(coc-funcobj-i)
    omap af <Plug>(coc-funcobj-a)
    " coc git
    " navigate chunks of current buffer
    nmap [g <Plug>(coc-git-prevchunk)
    nmap ]g <Plug>(coc-git-nextchunk)
    " create text object for git chunks
    omap ig <Plug>(coc-git-chunk-inner)
    xmap ig <Plug>(coc-git-chunk-inner)
    omap ag <Plug>(coc-git-chunk-outer)
    xmap ag <Plug>(coc-git-chunk-outer)
    call coc#config('git.enableGutters',   v:false)
    call coc#config('git.realtimeGutters', v:false)
    " coc-explorer
    call coc#config('explorer.keyMappings.global', {
            \ ",":       "actionMenu",
            \ "<tab>":   "toggleSelection",
            \ "<bs>":    "gotoParent",
            \ "<cr>":    "open",
            \ "r":       "rename",
            \ "t":       "open:tab",
            \ "v":       "open:vsplit",
            \ "x":       "open:split",
            \ "h":       "collapse",
            \ "l":       "expand",
            \ "<space>": "expandOrCollapse",
            \ "<C-j>":   ["normal:j"],
            \ "<C-k>":   ["normal:k"],
            \ "J":       ["toggleSelection", "normal:j"],
            \ "K":       ["toggleSelection", "normal:k"],
            \ "c":       "copyFilepath",
            \ "C":       "copyFilename",
            \ "y":       "copyFile",
            \ "m":       "cutFile",
            \ "p":       "pasteFile",
            \ "d":       "delete",
            \ "D":       "deleteForever",
            \ "a":       "addFile",
            \ "A":       "addDirectory",
            \ "<F1>":    "help",
            \ "H":       "toggleHidden",
            \ "<F5>":    "refresh",
            \ "q":       "quit",
            \ "X":       "systemExecute",
            \ "f":       "search",
            \ "F":       "searchRecursive",
            \ "gl":      "expandRecursive",
            \ "gh":      "collapseRecursive",
            \ "gp":      "diagnosticPrev",
            \ "gn":      "diagnosticNext",
            \ "gd":      "listDrive",
            \ ">>":      "gitStage",
            \ "<<":      "gitUnstage",
            \ })
    call coc#config('list', {
                \ 'nextKeymap':     '<C-j>',
                \ 'previousKeymap': '<C-k>',
                \ 'extendedSearchMode': v:true,
                \ })
    call coc#config('list.insertMappings', {
                \ '<C-n>': "",
                \ '<C-p>': "",
                \ '<C-j>': 'normal:j',
                \ '<C-k>': 'normal:k'
                \ })
    call coc#config('list.normalMappings', {
                \ '<C-n>': "",
                \ '<C-p>': "",
                \ '<C-j>': 'normal:next',
                \ '<C-k>': 'normal:previous'
                \ })
endif
if get(g:, 'fuzzy_finder', '') == '' || get(g:, 'fuzzy_finder', '') == 'fzf' || get(g:, 'fuzzy_finder', '') == 'ctrlp'
    if get(g:, 'fuzzy_finder', '') == ''
        let g:fuzzy_finder = 'ctrlp'
    endif
    let g:ctrlp_map        = '<leader>f'
    let g:ctrlp_extensions = ['menu', 'line', 'tag', 'buftag', 'funky', 'cmdline', 'files', 'yankring', 'buffer', 'quickfix', 'undo']
    if !exists('g:leovim_loaded')
        set rtp+=$ADDINS_PATH/ctrlp.vim
        set rtp+=$ADDINS_PATH/ctrlp-extensions.vim
        set rtp+=$ADDINS_PATH/ctrlp-funky
        command! CtrlPCmdline  call ctrlp#init(ctrlp#cmdline#id())
        command! CtrlPMenu     call ctrlp#init(ctrlp#menu#id())
        command! CtrlPYankring call ctrlp#init(ctrlp#yankring#id())
    endif
    nnoremap <M-F>          :CtrlP<tab>
    nnoremap <silent> <C-p> :CtrlPMenu<CR>
    if !Installed('vim-yoink')
        nnoremap <silent> <leader>i :CtrlPYankring<Cr>
    endif
    if !Installed('fzf-funky')
        nnoremap <silent> f<Cr> :CtrlPFunky<Cr>
    endif
    if get(g:, 'fuzzy_finder', '') == 'ctrlp'
        nnoremap <silent> <leader>p :registers<Cr>
        nnoremap <silent> <leader>b :CtrlPBuffer<CR>
        nnoremap <silent> <leader>u :CtrlPUndo<CR>
        nnoremap <silent> <M-h>/    :CtrlPCmdline<CR>
        nnoremap <silent> <M-h>m    :CtrlPMRU<CR>
        nnoremap <silent> <M-k>b    :CtrlPBufTag<CR>
        nnoremap <silent> <M-k>t    :CtrlPBufTagAll<CR>
        nnoremap <silent> <M-k>l    :CtrlPLine<Cr>
        nnoremap <silent> <Tab>f    :CloseQuickfix<Cr>:CtrlPQuickfix<Cr>
        if get(g:, 'symbol_tool', '') =~ 'tagbar' || get(g:, 'symbol_tool', '') =~ 'vista'
            nnoremap <silent> <M-k>t :CtrlPTag<CR>
        else
            nnoremap <silent> <leader>t :CtrlPTag<CR>
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
    endif
endif
if Installed('LeaderF-filer')
    nnoremap <leader>f :Leaderf filer<Cr>
elseif get(g:, 'complete_engine', '') == 'coc'
    nnoremap <leader>f :CocFile<Cr>
    function! CocFile() abort
        exec("CocCommand explorer --toggle --position floating --floating-width " . float2nr(&columns * 0.8) . " --floating-height " . float2nr(&lines * 0.8))
    endfunction
    command! CocFile call CocFile()
endif
" --------------------------
" quickui
" --------------------------
if Installed('vim-quickui')
    let g:quickui_border_style = 2
    nnoremap <leader>em :call quickui#tools#display_messages()<Cr>
    if !has('nvim')
        nnoremap <F13> :call quickui#preview#scroll(3)<Cr>
        nnoremap <F14> :call quickui#preview#scroll(-3)<Cr>
        nmap <silent><expr> <C-j> quickui#preview#visible() > 0 ? "\<F13>" : "\<C-j>"
        nmap <silent><expr> <C-k> quickui#preview#visible() > 0 ? "\<F14>" : "\<C-k>"
    endif
    " preview in popup
    function! s:PreviewFileW(filename) abort
        let filename = a:filename
        let fopts = {'cursor':-1, 'number':1, 'persist':0, 'w':80, 'h':64}
        call quickui#preview#open(filename, fopts)
    endfunction
    command! -nargs=1 -complete=file PreviewFileW call s:PreviewFileW(<f-args>)
    nnoremap ,<Tab> :PreviewFileW<Space>
    au FileType python nnoremap K :call quickui#tools#python_help("")<Cr>
endif

" ########## Diff Option ##########{{{
try
    set diffopt+=context:20
    set diffopt+=internal,algorithm:patience
    let g:diff_algorithms = [
                \ "myers",
                \ "minimal",
                \ "patience",
                \ "histogram",
                \ ]
    let g:diff_algorithm = "patience"

    func! DiffSwitchAlgorithm()
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

    func! DiffUpdateContext(contextLines)
        let l:opt = substitute(&diffopt, '\v(^\|,)context:\d+', '', 'g') . ",context:" . a:contextLines
        exec "set diffopt=" . l:opt
        windo diffupdate
    endfunc

    func! DiffToggleWhiteSpace()
        if stridx(&diffopt, "iwhite") >= 0
            set diffopt-=iwhite
            echo "Not ignoring whitespaces in diff"
        else
            set diffopt+=iwhite
            echo "Whitespaces ignored in diff"
        endif
        windo diffupdate
    endfunc

    command! DiffSwitchAlgorithm call DiffSwitchAlgorithm()
    command! DiffToggleWhiteSpace call DiffToggleWhiteSpace()
    command! -nargs=1 DiffUpdateContext call DiffUpdateContext(<f-args>)
    nnoremap <M-h>ds :DiffSwitchAlgorithm<Cr>
    nnoremap <M-h>dt :DiffToggleWhiteSpace<Cr>
    nnoremap <M-h>du :DiffUpdateContext<Space>
catch
    " pass
endtry
