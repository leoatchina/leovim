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
    imap <M-e> <c-x><c-l>
    imap <M-f> <c-x><c-f>
    " ----------------------
    " short cuts for fzf
    " ----------------------
    nnoremap z; :Fzf<tab><tab>
    nnoremap z, :FZF<tab>
    " locate file
    nnoremap <M-f>l :FZFLocate<Space>
    if Installed('vim-yoink')
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
            " NOTE select[1] is the name of register
            let reg = a:select[1]
            let cmd = "\"" . reg . self.paste
            call feedkeys(cmd)
        endfunction
        command! -range FZFRegisterBefore call fzf#run(extend({
                \ 'source': s:fzf_registers(),
                \ 'sink': function('s:paste_select', {'paste': 'P', 'range': <range>}),
                \ 'options': '--ansi -x --prompt "PasteBefore>"'
                \ }, g:fzf_layout), 0)
        command! -range FZFRegisterAfter call fzf#run(extend({
                \ 'source': s:fzf_registers(),
                \ 'sink': function('s:paste_select', {'paste': 'p', 'range': <range>}),
                \ 'options': '--ansi -x --prompt "PasteAfter>"'
                \ }, g:fzf_layout), 0)
        nnoremap <silent> <leader>p :FZFRegisterBefore<Cr>
        nnoremap <silent> <leader>P :FZFRegisterAfter<Cr>
        xnoremap <silent> <leader>p :<C-u>FZFRegisterBefore<Cr>
        xnoremap <silent> <leader>P :<C-u>FZFRegisterAfter<Cr>
        " --------------------
        " FZFYank
        " --------------------
        let g:yoinkMaxItems = 100
        nmap ,yb <plug>(YoinkPostPasteSwapBack)
        nmap ,yf <plug>(YoinkPostPasteSwapForward)
        nmap ,yp <plug>(YoinkRotateBack)
        nmap ,yn <plug>(YoinkRotateForward)
        nmap ,yy <plug>(YoinkPostPasteToggleFormat)
        nmap ,yc :ClearYanks<Cr>
        nmap p   <plug>(YoinkPaste_p)
        nmap P   <plug>(YoinkPaste_P)
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
            endtry
        endfunction
        function! s:paste_yank(select) dict
            if empty(a:select)
                echo "aborted register paste"
            else
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
                call feedkeys(self.paste)
            endif
        endfunction
        command! -range FZFYankBefore call fzf#run(extend({
                    \ 'source': s:yank_list(),
                    \ 'sink': function('s:paste_yank', {'paste': 'P', 'range': <range>}),
                    \ 'options': '--ansi -x --prompt "YankBefore>"'
                    \ }, g:fzf_layout), 0)
        command! -range FZFYankAfter call fzf#run(extend({
                    \ 'source': s:yank_list(),
                    \ 'sink': function('s:paste_yank', {'paste': 'p', 'range': <range>}),
                    \ 'options': '--ansi -x --prompt "YankAfter>"'
                    \ }, g:fzf_layout), 0)
        nnoremap <silent> ,p :FZFYankBefore<Cr>
        nnoremap <silent> ,P :FZFYankAfter<Cr>
        xnoremap <silent> ,p :<C-u>FZFYankBefore<Cr>
        xnoremap <silent> ,P :<C-u>FZFYankAfter<Cr>
    endif
    " --------------------
    " FZFJumps
    " --------------------
    if g:has_execute_func > 0
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
                            \ '--prompt=Jumps'
                        \ ],
                        \ }))
            else
                call fzf#run(fzf#wrap({
                        \ 'source': s:jumpList(),
                        \ 'sink': function('s:jumpHandler'),
                        \ 'options': [
                            \ '--prompt=Jumps',
                            \ '--preview', $ADDINS_PATH . '/preview.sh {2}',
                            \ '--preview-window=up:35%'
                        \ ],
                        \ }))
            endif
        endfunction
        command! -bang -nargs=* FZFJumps call s:FZFJumps()
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
    let g:Lf_CommandMap = {'<C-]>': ['<C-V>'], '<C-V>': ['<M-v>', '<C-y>'], '<C-j>':['<Down>', '<C-j>'], '<C-k>':['<Up>', '<C-k>'], '<F5>': ['<C-e>']}
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
    " help tags
    nnoremap <M-h>h :Leaderf help<Cr>
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
    " helptags
    if executable('perl')
        nnoremap <M-h>h :FzfHelptags<CR>
    endif
    " fzf-funky
    if Installed('fzf-funky')
        nnoremap f<Cr> :FzfFunky<Cr>
    endif
endif
if Installed('coc.nvim')
    let g:coc_data_home   = expand("~/.leovim.plug/coc")
    let g:coc_config_home = expand("~/.leovim.plug/coc-config")
    nnoremap <C-p>  :CocFzfList<CR>
    nnoremap <M-h>; :CocList<Space>
    nnoremap <M-h>. :CocFzfListResume<CR>
    nnoremap <M-h>l :CocFzfList location<Cr>
    nnoremap <M-k>o :CocFzfList outline<CR>
    nnoremap <M-l>c :CocFzfList commands<Cr>
    nnoremap <M-l>; :Coc
    nnoremap <M-l>, :CocInstall<Space>
    " CocFile
    nnoremap <leader>f :CocFile<Cr>
    function! CocFile() abort
        exec("CocCommand explorer --toggle --position floating --floating-width " . float2nr(&columns * 0.8) . " --floating-height " . float2nr(&lines * 0.8))
    endfunction
    command! CocFile call CocFile()
    " codeaction and others
    xmap ,c; <Plug>(coc-codeaction-selected)
    nmap ,c; <Plug>(coc-codeaction)
    nmap ,c, <Plug>(coc-codelens)
    nmap ,ca :CocFzfList actions<Cr>
    nmap ,cl <Plug>(coc-codeaction-line)
    xmap ,cf <Plug>(coc-format-selected)
    nmap ,cf <Plug>(coc-format)
    nmap ,cn <Plug>(coc-rename)
    nmap ,cc <Plug>(coc-fix-current)
    nmap ,cs <Plug>(coc-range-select)
    " multi cursors
    nmap ,cp <Plug>(coc-cursors-position)
    nmap ,co <Plug>(coc-cursors-operator)
    " Fix autofix problem of current line
    nmap ,cq <Plug>(coc-fix-current)
    " more
    nmap ,ch <Plug>(coc-float-hide)
    nmap ,cj <Plug>(coc-float-jump)
    " Create mappings for function text object, requires document symbols feature of languageserver.
    xmap if <Plug>(coc-funcobj-i)
    xmap af <Plug>(coc-funcobj-a)
    omap if <Plug>(coc-funcobj-i)
    omap af <Plug>(coc-funcobj-a)
    " Do default action for next item.
    nnoremap <silent> ,cn :CocNext<CR>
    " Do default action for previous item.
    nnoremap <silent> ,cp :CocPrev<CR>
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
            \ "n":       "rename",
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
            \ "r":       "refresh",
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
    function! FloatScroll(forward) abort
        let float = coc#util#get_float()
        if !float | return '' | endif
        let buf = nvim_win_get_buf(float)
        let buf_height = nvim_buf_line_count(buf)
        let win_height = nvim_win_get_height(float)
        if buf_height < win_height | return '' | endif
        let pos = nvim_win_get_cursor(float)
        if a:forward
            if pos[0] == 1
                let pos[0] += 3 * win_height / 4
            elseif pos[0] + win_height / 2 + 1 < buf_height
                let pos[0] += win_height / 2 + 1
            else
                let pos[0] = buf_height
            endif
        else
            if pos[0] == buf_height
                let pos[0] -= 3 * win_height / 4
            elseif pos[0] - win_height / 2 + 1  > 1
                let pos[0] -= win_height / 2 + 1
            else
                let pos[0] = 1
            endif
        endif
        call nvim_win_set_cursor(float, pos)
        return ''
    endfunction
    inoremap <silent><expr> <M-E>  coc#util#has_float() ? FloatScroll(1) : "\<Down>"
    inoremap <silent><expr> <M-Y>  coc#util#has_float() ? FloatScroll(0) : "\<Up>""
    inoremap <silent><expr> <Down> coc#util#has_float() ? FloatScroll(1) : "\<Down>"
    inoremap <silent><expr> <Up>   coc#util#has_float() ? FloatScroll(0) : "\<Up>""
else
    let g:ctrlp_map        = '<leader>f'
    let g:fuzzy_finder     = get(g:, 'fuzzy_finder', 'ctrlp')
    let g:ctrlp_extensions = ['menu', 'line', 'tag', 'buftag', 'funky', 'cmdline', 'files', 'yankring', 'buffer', 'quickfix', 'undo']
    if !exists('g:leovim_loaded')
        set rtp+=$ADDINS_PATH/ctrlp.vim
        set rtp+=$ADDINS_PATH/ctrlp-extensions.vim
        set rtp+=$ADDINS_PATH/ctrlp-funky
        command! CtrlPCmdline call ctrlp#init(ctrlp#cmdline#id())
        command! CtrlPMenu call ctrlp#init(ctrlp#menu#id())
        command! CtrlPYankring call ctrlp#init(ctrlp#yankring#id())
    endif
    nnoremap <M-h>;         :CtrlP<tab>
    nnoremap <silent> <C-p> :CtrlPMenu<CR>
    if !Installed('vim-yoink')
        nnoremap <silent> ,p :CtrlPYankring<Cr>
    endif
    if !Installed('fzf-funky')
        nnoremap <silent> f<Cr> :CtrlPFunky<Cr>
    endif
    if g:fuzzy_finder == 'ctrlp'
        nnoremap <silent> ,p        :CtrlPYankring<Cr>
        nnoremap <silent> <leader>p :registers<Cr>
        nnoremap <silent> <leader>b :CtrlPBuffer<CR>
        nnoremap <silent> <leader>u :CtrlPUndo<CR>
        nnoremap <silent> <M-h>,    :CtrlPCmdline<CR>
        nnoremap <silent> <M-h>m    :CtrlPMRU<CR>
        nnoremap <silent> <M-k>b    :CtrlPBufTag<CR>
        nnoremap <silent> <M-k>a    :CtrlPBufTagAll<CR>
        nnoremap <silent> <M-k>l    :CtrlPLine<Cr>
        if get(g:, 'symbol_tool', '') =~ 'tagbar' || get(g:, 'symbol_tool', '') =~ 'vista'
            nnoremap <silent> <M-k>t :CtrlPTag<CR>
        else
            nnoremap <silent> <M-t> :CtrlPTag<CR>
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
" --------------------------
" quickui
" --------------------------
if Installed('vim-quickui')
    let g:quickui_border_style = 2
    nnoremap <leader>em :call quickui#tools#display_messages()<Cr>
    nnoremap <silent><M-down> :call quickui#preview#scroll(1)<Cr>
    nnoremap <silent><M-up>   :call quickui#preview#scroll(-1)<Cr>
endif
