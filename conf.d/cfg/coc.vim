" ------------------------
" coc-fzf
" ------------------------
let g:coc_fzf_location_delay = 100
" ----------------------------
" Disable file with size > 1MB
" ----------------------------
autocmd BufAdd * if getfsize(expand('<afile>')) > 1024*1024 |
            \ let b:coc_enabled=0 |
            \ endif
" ----------------------------
" set coc data $PATH
" ----------------------------
let g:coc_config_home = expand("$CFG_DIR")
if WINDOWS()
    let g:coc_data_home = $DEPLOY_DIR . "\\coc"
else
    let g:coc_data_home = $DEPLOY_DIR . "/coc"
endif
" ------------------------
" coc-global-extensions
" ------------------------
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
            \ 'coc-vimlsp',
            \ 'coc-pyright',
            \ ]
if UNIX()
    let g:coc_global_extensions += ['coc-lua']
elseif WINDOWS()
    let g:coc_global_extensions += ['coc-powershell']
endif
if has('nvim')
    let g:coc_global_extensions += ['coc-symbol-line']
endif
if Require('web')
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
if Require('c')
    let g:coc_global_extensions += ['coc-cmake']
    if g:clangd_exe != ''
        let g:coc_global_extensions += ['coc-clangd']
    endif
endif
if Require('ccls') && g:ccls_exe != ''
    call coc#config('languageserver.ccls', {
                \ "command": "ccls",
                \ "filetypes": g:c_filetypes,
                \ "rootPatterns": g:root_patterns,
                \ "initializationOptions": {
                \ "cache": {
                \ "directory": $HOME . "/.leovim.d/ccls"
                \ }}})
endif
if Require('R') && g:R_exe != ''
    let g:coc_global_extensions += ['coc-r-lsp']
endif
if Require('rust') && g:cargo_exe != ''
    let g:coc_global_extensions += ['coc-rust-analyzer']
endif
if Require('java') && executable('java')
    let g:coc_global_extensions += ['coc-java', 'coc-java-intellicode']
endif
if Require('go') && g:gobin_exe != ''
    let g:coc_global_extensions += ['coc-go']
endif
if Require('writing')
    let g:coc_global_extensions += ['coc-vimtex']
endif
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
" ------------------------
" icons
" ------------------------
if Planned('nvim-web-devicons')
    call coc#config('explorer.icon.source', 'nvim-web-devicons')
elseif Planned('vim-devicons')
    call coc#config('explorer.icon.source', 'vim-devicons')
endif
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
nnoremap <silent><leader>t :Vista finder coc<Cr>
inoremap <silent><C-x><C-x> <C-r>=CocActionAsync('showSignatureHelp')<Cr>
" completion map
function! s:has_backspace() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1] =~ '\s'
endfunction
inoremap <silent><expr> <Cr> coc#pum#visible() ? coc#pum#stop() : "\<C-g>u\<Cr>\<C-r>=coc#on_enter()\<Cr>"
inoremap <silent><expr> <TAB> coc#pum#visible() == v:false ? "\<Tab>" :
            \ coc#expandableOrJumpable() ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<Cr>" :
            \ <SID>has_backspace() ? coc#refresh() :
            \ coc#_select_confirm()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"
inoremap <silent><expr><C-l> coc#refresh()
" c-e/c-y
imap <silent><expr><C-e> coc#pum#visible() ? coc#pum#cancel() : "\<C-e>"
imap <silent><expr><C-y> coc#pum#visible() ? coc#pum#stop() : "\<C-y>"
" scroll
imap <silent><expr><C-j> coc#float#has_scroll() ? "\<C-r>=coc#float#scroll(1)\<Cr>" : "\<C-\><C-n>:call MoveToEndAndAddSemicolon()\<CR>"
imap <silent><expr><C-k> coc#float#has_scroll() ? "\<C-r>=coc#float#scroll(0)\<Cr>" : "\<C-k>"
" call hierarchy
nnoremap <silent>gh :call CocAction('showIncomingCalls')<Cr>
nnoremap <silent>gl :call CocAction('showOutgoingCalls')<Cr>
nnoremap <silent>gs :call CocAction('showSubTypes')<Cr>
nnoremap <silent>gS :call CocAction('showSuperTypes')<Cr>
" refactor
nmap <nowait><silent>gr <Plug>(coc-refactor)
" ----------------------------
" actions
" ----------------------------
" foxmat
xmap <C-q> <Plug>(coc-format-selected)
nmap <C-q> <Plug>(coc-format)
" Use CTRL-s for selections ranges.
" Requires 'textDocument/selectionRange' support of language server.
" Add `:Format` command to format current buffeX.
command! -nargs=0 Format :call CocAction('format')
" Add `:Fold` command to fold current buffer.
command! -nargs=? Fold :call CocAction('fold', <f-args>)
" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR :call CocAction('runCommand', 'editor.action.organizeImport')
" ----------------------------
" inlayHint/codeLens/codeaction
" ----------------------------
call coc#config('python.pythonPath', g:python_prog)
call coc#config('python.venvPath', ['.venv'])
if has('nvim') || has('patch-9.0.0252')
    call coc#config('inlayHint.enable', v:true)
    nnoremap <silent><leader>i :CocCommand document.toggleInlayHint<Cr>
else
    call coc#config('inlayHint.enable', v:false)
endif
if has('nvim') || has('patch-9.0.0438')
    hi! link CocCodeLens CocListBgGrey
    call coc#config('codeLens.enable', v:true)
    nnoremap <leader>C :CocCommand document.toggleCodeLens<Cr>
else
    call coc#config('codeLens.enable', v:false)
endif
nmap <silent><F2> <Plug>(coc-rename)
xmap <silent><leader>X <Plug>(coc-fix-current)
nmap <silent><leader>X <Plug>(coc-fix-current)
nmap <silent><leader>R <Plug>(coc-codeaction-refactor-selected)
xmap <silent><leader>R <Plug>(coc-codeaction-refactor-selected)
nmap <silent><leader>a <Plug>(coc-codeaction-selected)
xmap <silent><leader>a <Plug>(coc-codeaction-selected)
nmap <silent><leader>ar <Plug>(coc-codeaction-refactor)
nmap <silent><leader>as <Plug>(coc-codeaction-source)
nmap <silent><leader>ac <Plug>(coc-codeaction-cursor)
nmap <silent><M-a> <Plug>(coc-codelens-action)
nmap <silent><leader>A :CocFzfList actions<Cr>
" ------------------------
" coc git
" ------------------------
omap ig <Plug>(coc-git-chunk-inner)
xmap ig <Plug>(coc-git-chunk-inner)
omap ag <Plug>(coc-git-chunk-outer)
xmap ag <Plug>(coc-git-chunk-outer)
nmap <leader>vg vig
nmap <leader>vG vag
" ------------------------
" textobject using coc lsp
" ------------------------
xmap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap if <Plug>(coc-funcobj-i)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ic <Plug>(coc-classobj-i)
omap ac <Plug>(coc-classobj-a)
" ------------------------
" symbol line and other
" ------------------------
if has('nvim')
    call coc#config("coc.preferences.currentFunctionSymbolAutoUpdate", v:false)
    nnoremap <Leader>W :CocFzfList symbols<Cr>
else
    call coc#config("coc.preferences.currentFunctionSymbolAutoUpdate", v:true)
endif
" ------------------------
" ColorScheme
" ------------------------
call coc#config('go.goplsOptions.semanticTokens', v:true)
augroup FixCocColorScheme
    autocmd!
    autocmd ColorScheme edge,sonokai,gruvbox-material,gruvbox hi! CocExplorerIndentLine ctermbg=NONE guibg=NONE
augroup END
