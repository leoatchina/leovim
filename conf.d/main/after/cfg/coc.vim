" ----------------------------
" set coc data $PATH
" ----------------------------
let g:coc_config_home = utils#expand("$CFG_DIR")
let g:coc_fzf_location_delay = 100
" ----------------------------
" Disable file with size > 1MB
" ----------------------------
autocmd BufAdd * if getfsize(utils#expand('<afile>')) > 1024*1024 |
            \ let b:coc_enabled=0 |
            \ endif
" ------------------------
" coc root_patterns
" ------------------------
autocmd FileType css,html let b:coc_additional_keywords = ["-"] + g:root_patterns
autocmd FileType php let b:coc_root_patterns = ['.htaccess', '.phpproject'] + g:root_patterns
autocmd FileType javascript let b:coc_root_patterns = ['.jsproject'] + g:root_patterns
autocmd FileType java let b:coc_root_patterns = ['.javasproject'] + g:root_patterns
autocmd FileType python let b:coc_root_patterns = ['.pyproject'] + g:root_patterns
autocmd FileType c,cpp let b:coc_root_patterns = ['.htaccess', '.cproject'] + g:root_patterns
" ----------------------------
" basic config
" ----------------------------
augroup CocGroup
    autocmd!
    " Setup formatexpr specified filetype(s).
    autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
    " Update signature help on jump placeholder.
    autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
    " Highlight the symbol and its references when holding the cursor.
    autocmd CursorHold * silent call CocActionAsync('highlight')
augroup END
" Add `:Format` command to format current buffeX.
command! -nargs=0 Format :call CocAction('format')
" Add `:Fold` command to fold current buffer.
command! -nargs=? Fold :call CocAction('fold', <f-args>)
" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR :call CocAction('runCommand', 'editor.action.organizeImport')
" ----------------------------
" completion map
" ----------------------------
let g:coc_snippet_next = '<tab>'
" 菜单未选中时回车仅结束补全，保留输入且不换行；选中后保持原确认逻辑。
imap <silent><expr><Cr> coc#pum#visible() ?
            \ !coc#pum#has_item_selected() ? coc#pum#stop() :
            \ coc#expandableOrJumpable() ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<Cr>" : coc#pum#confirm()
            \ : "\<CR>"
" Tab / Shift-Tab 与 C-n / C-p 使用同一套 Coc 菜单导航接口。
inoremap <silent><expr><TAB> coc#pum#visible() ? coc#pum#next(1) : utils#has_backspace() ? "\<TAB>" : coc#refresh()
inoremap <silent><expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<S-Tab>"
inoremap <silent><expr><C-n>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<C-n>" :
      \ coc#refresh()
inoremap <silent><expr><C-p> coc#pum#visible() ? coc#pum#prev(1) : "\<C-p>"
inoremap <silent><expr><C-e> coc#pum#visible() ? coc#pum#cancel()
            \ : pumvisible() ? "\<C-e>" : "\<C-o>A"
inoremap <silent><expr><C-y> coc#pum#visible() ? coc#pum#stop() : "\<C-y>"
" ----------------------------
" map
" ----------------------------
nnoremap <silent><M-l>i :CocInfo<Cr>
nnoremap <silent><M-l>r :CocRestart<Cr><Cr>
nnoremap <silent><M-V>  :CocFzfList yank<Cr>
nnoremap <silent><M-l>e :CocFzfList extensions<Cr>
nnoremap <silent><M-l>M :CocFzfList marketplace<Cr>
nnoremap <silent><M-l>: :CocFzfList commands<Cr>
nnoremap <silent><M-l>. :call CocAction('repeatCommand')<Cr>
nnoremap <silent><M-l>; :CocNext<Cr>
nnoremap <silent><M-l>, :CocPrev<Cr>
nnoremap <silent><M-l><M-c> :CocFzfList<Cr>
nnoremap <silent><M-l><M-r> :CocFzfListResume<Cr>
" symbol
inoremap <silent><C-x><C-x> <C-r>=CocActionAsync('showSignatureHelp')<Cr>
nnoremap <leader>w :CocFzfList symbols <C-r><C-w>
xnoremap <leader>w :<C-u>CocFzfList symbols <C-r>=utils#get_visual()<Cr>
" scroll
imap <silent><expr><C-j> coc#float#has_scroll() ? "\<C-r>=coc#float#scroll(1)\<Cr>" : "\<C-\><C-n>:call utils#move_to_end_and_add_semicolon()\<CR>"
imap <silent><expr><C-k> coc#float#has_scroll() ? "\<C-r>=coc#float#scroll(0)\<Cr>" : "\<C-k>"
" inlayHint/codeLens/codeaction
nmap <silent><leader>i :CocCommand document.toggleInlayHint<Cr>
nmap <leader>C :CocCommand document.toggleCodeLens<Cr>
nmap <M-c> <Plug>(coc-codelens-action)
" call hierarchy
nnoremap <silent>gh :call CocAction('showIncomingCalls')<Cr>
nnoremap <silent>gl :call CocAction('showOutgoingCalls')<Cr>
nnoremap <silent>gs :call CocAction('showSubTypes')<Cr>
nnoremap <silent>gS :call CocAction('showSuperTypes')<Cr>
" refactor
nmap <nowait><silent>gr <Plug>(coc-refactor)
xmap <C-q> <Plug>(coc-format-selected)
nmap <C-q> <Plug>(coc-format)
nmap <silent><F2> <Plug>(coc-rename)
nmap <silent><M-C> :CocFzfList actions<Cr>
xmap <silent><leader>R <Plug>(coc-codeaction-refactor-selected)
nmap <silent><leader>R <Plug>(coc-codeaction-refactor)
" fix
nmap <silent><leader>X <Plug>(coc-fix-current)
xmap <silent><leader>X <Plug>(coc-fix-current)
" codeaction
xmap <silent><leader>a  <Plug>(coc-codeaction-selected)
nmap <silent><leader>a  <Plug>(coc-codeaction)
nmap <silent><leader>ar <Plug>(coc-codeaction-refactor)
nmap <silent><leader>as <Plug>(coc-codeaction-source)
nmap <silent><leader>ac <Plug>(coc-codeaction-cursor)
" textobject using coc lsp
xmap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap if <Plug>(coc-funcobj-i)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ic <Plug>(coc-classobj-i)
omap ac <Plug>(coc-classobj-a)
" ------------------------
" coc-global-extensions
" ------------------------
if utils#is_win()
    let g:coc_data_home = $LEOVIMD_DIR . "\\coc"
else
    let g:coc_data_home = $LEOVIMD_DIR . "/coc"
endif
let g:coc_global_extensions = [
            \ 'coc-lua',
            \ 'coc-lists',
            \ 'coc-marketplace',
            \ 'coc-snippets',
            \ 'coc-symbol-line',
            \ 'coc-yank',
            \ 'coc-highlight',
            \ 'coc-git',
            \ 'coc-json',
            \ 'coc-sql',
            \ 'coc-xml',
            \ 'coc-sh',
            \ 'coc-pairs',
            \ 'coc-basedpyright',
            \ '@yaegassy/coc-ruff',
            \ ]
if utils#is_win()
    let g:coc_global_extensions += ['coc-powershell', 'coc-vimls']
else
    let g:coc_global_extensions += ['coc-vimls']
endif
if pack#get('web')
    let g:coc_global_extensions += [
                \ 'coc-html',
                \ 'coc-css',
                \ 'coc-yaml',
                \ 'coc-phpls',
                \ 'coc-tsserver',
                \ 'coc-angular',
                \ 'coc-vetur',
                \ ]
endif
if pack#get('c')
    let g:coc_global_extensions += ['coc-cmake']
    if g:clangd_exe != ''
        let g:coc_global_extensions += ['coc-clangd']
    endif
endif
call coc#config('python.pythonPath', g:python_prog)
if pack#get('R') && g:R_exe != ''
    let g:coc_global_extensions += ['coc-r-lsp']
endif
if pack#get('rust') && g:cargo_exe != ''
    let g:coc_global_extensions += ['coc-rust-analyzer']
endif
if pack#get('java') && executable('java')
    let g:coc_global_extensions += ['coc-java', 'coc-java-intellicode']
endif
if pack#get('go') && g:gobin_exe != ''
    let g:coc_global_extensions += ['coc-go']
endif
if pack#get('writing')
    let g:coc_global_extensions += ['coc-vimtex']
endif
" ------------------------
" ColorScheme
" ------------------------
hi! link CocCodeLens CocListBgGrey
augroup FixCocColorScheme
    autocmd!
    autocmd ColorScheme edge,sonokai,gruvbox-material,gruvbox hi! CocExplorerIndentLine ctermbg=NONE guibg=NONE
    " Patch: coc Vim popup 第一行有时压到 cursor line，最上面的候选 label
    " 会与 buffer 文本/光标重叠。SafeStateAgain 后检测 overlap 并下移 pum。
    " 同时用窗口内 matchaddpos 补画选中行（match 随滚动正确重绘）。
    " 仅 Vim（popup_list 是 Vim 专有）。
    function! s:CocPumSelFix() abort
        if !exists('*coc#pum#visible') || !coc#pum#visible()
            return
        endif
        let info = coc#pum#info()
        let line = info['index'] < 0 ? 0 : info['reversed'] ? info['size'] - info['index'] : info['index'] + 1
        " coc pum 窗口带 winvar kind == 'pum'（coc pum.vim setwinvar）
        for winid in popup_list()
            if winbufnr(winid) > 0 && getwinvar(winid, 'kind', '') ==# 'pum'
                " coc Vim popup 在部分终端/字体下会把第一行压到 cursor line，
                " 导致最上面的候选 label 与 buffer 文本/光标重叠。检测并下移一行。
                let pos = popup_getpos(winid)
                let cur = screenpos(0, line('.'), col('.'))
                if get(pos, 'line', 0) <= cur['row'] && get(pos, 'line', 0) + get(pos, 'core_height', get(pos, 'height', 0)) > cur['row']
                    call popup_move(winid, {'line': cur['row'] + 1})
                endif
                call win_execute(winid, 'silent! call clearmatches()')
                if line > 0
                    call win_execute(winid, 'call matchaddpos(''CocMenuSel'', ['.line.'])')
                endif
            endif
        endfor
    endfunction
    autocmd SafeStateAgain,InsertEnter * call s:CocPumSelFix()
augroup END
" ----------------------------
" 符号局部使用跳转 (供 tags.vim 单向调用，纯同步服务，无反向依赖)
" 返回值: 1 表示跳转成功, 0 表示未找到或不可用
" ----------------------------
function! s:compare_pos(l1, c1, l2, c2) abort
    if a:l1 != a:l2 | return a:l1 < a:l2 ? -1 : 1 | endif
    if a:c1 != a:c2 | return a:c1 < a:c2 ? -1 : 1 | endif
    return 0
endfunction

function! s:to_vim_range(range) abort
    if type(a:range) == type([])
        return [a:range[0][0], a:range[0][1], a:range[1][0], a:range[1][1]]
    endif
    return [a:range.start.line + 1, a:range.start.character + 1,
          \ a:range.end.line + 1, a:range.end.character + 1]
endfunction

function! CocUsageSearch(direction) abort
    if empty(expand('<cword>')) || !get(g:, 'coc_service_initialized', 0)
        return 0
    endif

    try
        let ranges = CocAction('symbolRanges')
        let symbols = CocAction('documentSymbols')
    catch
        return 0
    endtry

    if type(ranges) != type([]) || empty(ranges) || type(symbols) != type([])
        return 0
    endif

    " 1. 获取包含当前光标的最内层作用域（行数跨度最小的那个函数或类）
    let [cl, cc] = getcurpos()[1:2]
    let scope = []
    let min_lines = -1

    for sym in symbols
        if type(sym) == type({}) && has_key(sym, 'range')
            let [sl, sc, el, ec] = s:to_vim_range(sym.range)
            if s:compare_pos(sl, sc, cl, cc) <= 0 && s:compare_pos(cl, cc, el, ec) <= 0
                let lines = el - sl
                if min_lines < 0 || lines < min_lines
                    let min_lines = lines
                    let scope = [sl, sc, el, ec]
                endif
            endif
        endif
    endfor

    if empty(scope)
        return 0
    endif

    " 2. 筛选出完全在当前作用域内部的所有引用位置
    let targets = []
    for r in ranges
        if type(r) == type({}) || type(r) == type([])
            let [sl, sc, el, ec] = s:to_vim_range(r)
            if s:compare_pos(scope[0], scope[1], sl, sc) <= 0 && s:compare_pos(el, ec, scope[2], scope[3]) <= 0
                call add(targets, [sl, sc, el, ec])
            endif
        endif
    endfor

    if empty(targets)
        return 0
    endif

    " 3. 按文本先后顺序排序并去重
    call sort(targets, {a, b -> s:compare_pos(a[0], a[1], b[0], b[1])})
    let uniq = []
    for t in targets
        if empty(uniq) || s:compare_pos(uniq[-1][0], uniq[-1][1], t[0], t[1]) != 0
            call add(uniq, t)
        endif
    endfor

    " 4. 根据方向跳转
    "    first: 作用域内第一处定义
    "    prev : 当前光标前最后一个位置 (首尾循环)
    "    next : 当前光标后第一个位置 (首尾循环)
    let dest = []
    if a:direction ==# 'first'
        let dest = uniq[0]
    elseif a:direction ==# 'prev'
        for t in reverse(copy(uniq))
            if s:compare_pos(t[2], t[3], cl, cc) < 0
                let dest = t
                break
            endif
        endfor
        let dest = empty(dest) ? uniq[-1] : dest
    else
        for t in uniq
            if s:compare_pos(t[0], t[1], cl, cc) > 0
                let dest = t
                break
            endif
        endfor
        let dest = empty(dest) ? uniq[0] : dest
    endif

    call cursor(dest[0], dest[1])
    return 1
endfunction
