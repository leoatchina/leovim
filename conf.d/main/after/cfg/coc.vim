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
" ColorScheme
" ------------------------
hi! link CocCodeLens CocListBgGrey
augroup FixCocColorScheme
    autocmd!
    autocmd ColorScheme edge,sonokai,gruvbox-material,gruvbox hi! CocExplorerIndentLine ctermbg=NONE guibg=NONE
augroup END
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
inoremap <silent><expr><Cr> coc#pum#visible() ? coc#pum#select_confirm(): "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"
let g:coc_snippet_next = '<tab>'
inoremap <silent><expr><TAB> coc#pum#visible() ? coc#pum#next(1) :
            \ utils#has_backspace() ? "\<TAB>" :
            \ coc#refresh()
inoremap <silent><expr><S-TAB> coc#pum#visible() ? coc#pum#prev(0) : "\<C-h>"
inoremap <silent><expr><C-e> coc#pum#visible() ? coc#pum#cancel() : "\<C-e>"
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
            \ 'coc-lists',
            \ 'coc-marketplace',
            \ 'coc-snippets',
            \ 'coc-yank',
            \ 'coc-highlight',
            \ 'coc-git',
            \ 'coc-json',
            \ 'coc-sql',
            \ 'coc-xml',
            \ 'coc-sh',
            \ 'coc-vimls',
            \ 'coc-basedpyright',
            \ '@yaegassy/coc-ruff',
            \ ]
if utils#is_unix()
    let g:coc_global_extensions += ['coc-lua']
elseif utils#is_win()
    let g:coc_global_extensions += ['coc-powershell']
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
if pack#get('ccls') && g:ccls_exe != ''
    call coc#config('languageserver.ccls', {
                \ "command": "ccls",
                \ "filetypes": g:c_filetypes,
                \ "rootPatterns": g:root_patterns,
                \ "initializationOptions": {
                \ "cache": {
                \ "directory": $HOME . "/.leovim.d/ccls"
                \ }}})
endif
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
