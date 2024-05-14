" ----------------------------
" Disable file with size > 1MB
" ----------------------------
autocmd BufAdd * if getfsize(expand('<afile>')) > 1024*1024 |
            \ let b:coc_enabled=0 |
            \ endif
" ----------------------------
" set coc data $PATH
" ----------------------------
let g:coc_config_home = expand("$OPTIONAL_DIR")
if WINDOWS()
    let g:coc_data_home = $DEPLOY_DIR . "\\coc"
else
    let g:coc_data_home = $DEPLOY_DIR . "/coc"
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
if Installed('nvim-web-devicons')
    call coc#config('explorer.icon.source', 'nvim-web-devicons')
elseif Installed('vim-devicons')
    call coc#config('explorer.icon.source', 'vim-devicons')
endif
" ----------------------------
" extensions
" ----------------------------
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
    let g:coc_global_extensions += ['coc-explorer', 'coc-symbol-line']
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
    if executable('clangd')
        let g:coc_global_extensions += ['coc-clangd']
    endif
endif
if executable('ccls') && Require('ccls')
    call coc#config('languageserver.ccls', {
                \ "command": "ccls",
                \ "filetypes": g:c_filetypes,
                \ "rootPatterns": g:root_patterns,
                \ "initializationOptions": {
                    \ "cache": {
                        \ "directory": $HOME . "/.leovim.d/ccls"
                        \ }
                    \ }
                \ })
endif
if Require('R')
    let g:coc_global_extensions += ['coc-r-lsp']
endif
if Require('rust')
    let g:coc_global_extensions += ['coc-rust-analyzer']
endif
if Require('go') && executable('go')
    let g:coc_global_extensions += ['coc-go']
endif
if Require('java') && executable('java')
    let g:coc_global_extensions += ['coc-java', 'coc-java-intellicode']
endif
if Require('writing')
    let g:coc_global_extensions += ['coc-vimtex']
endif
" ----------------------------
" map
" ----------------------------
nnoremap <silent><M-l>i :CocInfo<Cr>
nnoremap <silent><M-l>r :CocRestart<Cr><Cr>
nnoremap <silent><M-V>  :CocFzfList yank<Cr>
nnoremap <silent><M-l>e :CocFzfList extensions<Cr>
nnoremap <silent><M-l>M :CocFzfList marketplace<Cr>
nnoremap <silent><M-l>c :CocFzfList commands<Cr>
nnoremap <silent><M-l>. :call CocAction('repeatCommand')<Cr>
nnoremap <silent><M-l>; :CocNext<Cr>
nnoremap <silent><M-l>, :CocPrev<Cr>
nnoremap <silent><M-l><M-c> :CocFzfList<Cr>
nnoremap <silent><M-l><M-r> :CocFzfListResume<Cr>
" symbol
nnoremap <silent><leader>s :Vista finder<Cr>
nnoremap <silent><leader>S :CocFzfList symbols<Cr>
inoremap <silent><C-x><C-x> <C-r>=CocActionAsync('showSignatureHelp')<Cr>
" completion map
inoremap <silent><expr> <Cr>  coc#pum#visible() ? coc#pum#stop() : "\<C-g>u\<Cr>\<C-r>=coc#on_enter()\<Cr>"
inoremap <silent><expr> <TAB> coc#pum#visible() == v:false ? "\<Tab>" :
            \ coc#pum#info()['index'] < 0 ? coc#pum#next(1) :
            \ coc#expandableOrJumpable() ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<Cr>" :
            \ HasBackSpace() ? coc#refresh() :
            \ coc#_select_confirm()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"
inoremap <silent><expr> <C-e> coc#pum#visible() ? coc#pum#cancel() : "\<C-o>A"
inoremap <silent><expr> <C-space> coc#refresh()
inoremap <silent><expr> <C-@> coc#refresh()
" scroll
imap <silent><expr><C-j> coc#float#has_scroll() ? "\<C-r>=coc#float#scroll(1)\<Cr>" : "\<C-\><C-n>:call MoveToEndAndAddSemicolon(1)\<CR>"
imap <silent><expr><C-k> coc#float#has_scroll() ? "\<C-r>=coc#float#scroll(0)\<Cr>" : "\<C-\><C-n>:call MoveToEndAndAddSemicolon(0)\<CR>"
xmap <silent><expr><C-j> coc#float#has_scroll() ? coc#float#scroll(1) : "\%"
xmap <silent><expr><C-k> coc#float#has_scroll() ? coc#float#scroll(0) : "\g%"
" call hierarchy
nnoremap <silent>gh :call CocAction('showIncomingCalls')<Cr>
nnoremap <silent>gl :call CocAction('showOutgoingCalls')<Cr>
nnoremap <silent>gs :call CocAction('showSubTypes')<Cr>
nnoremap <silent>gS :call CocAction('showSuperTypes')<Cr>
" refactor
nmap <silent><leader>R <Plug>(coc-refactor)
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
if has('nvim') || has('patch-9.0.0252')
    call coc#config('inlayHint.enable', v:true)
    nnoremap <leader>I :CocCommand document.toggleInlayHint<Cr>
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
nmap <silent><leader>ae <Plug>(coc-codeaction-refactor)
nmap <silent><leader>ao <Plug>(coc-codeaction-source)
nmap <silent><leader>as <Plug>(coc-codeaction-selected)
xmap <silent><leader>as <Plug>(coc-codeaction-selected)
nmap <silent><leader>ar <Plug>(coc-codeaction-refactor-selected)
xmap <silent><leader>ar <Plug>(coc-codeaction-refactor-selected)
nmap <silent><leader>A <Plug>(coc-codeaction-cursor)
nmap <silent><M-a> <Plug>(coc-codelens-action)
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
" symbol line
" ------------------------
if has('nvim')
    call coc#config("coc.preferences.currentFunctionSymbolAutoUpdate", v:false)
    luafile $LUA_DIR/coc.lua
else
    call coc#config("coc.preferences.currentFunctionSymbolAutoUpdate", v:true)
endif
augroup FixCocColorScheme
    autocmd!
    autocmd ColorScheme edge,sonokai,gruvbox-material,gruvbox hi! CocExplorerIndentLine ctermbg=NONE guibg=NONE
augroup END
" ------------------------
" snippets
" ------------------------
call coc#config("snippets.userSnippetsDirectory", expand("~/.leovim/vsnip"))
" ------------------------
" coc-fzf
" ------------------------
let g:coc_fzf_location_delay = 100
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
