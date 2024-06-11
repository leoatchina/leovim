function! HasBackSpace() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1] =~ '\s'
endfunction
if Installed('mason.nvim')
    luafile $LUA_DIR/mason.lua
endif
if Installed('vimcomplete')
    source $OPTIONAL_DIR/vcm.vim
elseif InstalledCmp()
    luafile $LUA_DIR/cmp.lua
elseif InstalledCoc()
    source $OPTIONAL_DIR/coc.vim
elseif g:complete_engine == 'apm'
    source $OPTIONAL_DIR/apm.vim
elseif g:complete_engine != ''
    let g:complete_engine = 'mcm'
    source $OPTIONAL_DIR/mcm.vim
endif
if InstalledNvimLsp()
    let g:vista_default_executive = 'nvim_lsp'
    if g:node_version > 14
        let g:ensure_installed = ['vimls', 'lua_ls', 'vale_ls']
    else
        let g:ensure_installed = []
    endif
    if g:node_version > 14 && (g:python_version > 3.06 && !Require('pylsp') || g:python_version <= 3.06)
        let g:ensure_installed += ['pyright']
    elseif g:python_version > 3.06
        let g:ensure_installed += ['pylsp']
    endif
    if Require('web') && g:node_version > 14
        let g:ensure_installed += ['cssls', 'tsserver', 'eslint', 'html', 'vuels', 'angularls']
    endif
    if Require('c')
        let g:ensure_installed += ['cmake']
        if executable('clangd')
            let g:ensure_installed += ['clangd']
        endif
    endif
    if Require('rust') && g:cargo_exe != ''
        let g:ensure_installed += ['rust_analyzer']
    endif
    if Require('R') && g:R_exe != ''
        let g:ensure_installed += ['r_language_server']
    endif
    if Require('go') && g:go_exe != ''
        let g:ensure_installed += ['gopls']
    endif
    if Installed('nvim-java', 'lua-async-await', 'nvim-java-refactor', 'nvim-java-core', 'nvim-java-test', 'nvim-java-dap')
        let g:nvim_java = 1
        lua require('java').setup()
    else
        let g:nvim_java = 0
    endif
    luafile $LUA_DIR/lsp.lua
elseif InstalledCoc()
    let g:vista_default_executive = 'coc'
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
    if Require('ccls') && g:ccls_exe != ''
        call coc#config('languageserver.ccls', {
                    \ "command": "ccls",
                    \ "filetypes": g:cfile_types,
                    \ "rootPatterns": g:root_patterns,
                    \ "initializationOptions": {
                    \ "cache": {
                    \ "directory": $HOME . "/.leovim.d/ccls"
                    \ }
                    \ }
                    \ })
    endif
    if Require('R') && g:R_exe != ''
        let g:coc_global_extensions += ['coc-r-lsp']
    endif
    if Require('rust') && g:cargo_exe != ''
        let g:coc_global_extensions += ['coc-rust-analyzer']
    endif
    if Require('java') && g:java_exe != ''
        let g:coc_global_extensions += ['coc-java', 'coc-java-intellicode']
    endif
    if Require('go') && g:go_exe != ''
        let g:coc_global_extensions += ['coc-go']
    endif
    if Require('writing')
        let g:coc_global_extensions += ['coc-vimtex']
    endif
elseif Installed('vista.vim')
    let g:vista_default_executive = 'ctags'
endif
" ------------------------------
" vsnip
" ------------------------------
fun! CtrlFSkipBracket()
    call feedkeys(search('\%#[]>)}]', 'n') ? "\<Right>" : "\<C-o>A")
    return ''
endfunction
if Installed('vim-vsnip')
    let g:vsnip_snippet_dir = expand("~/.leovim/snippets")
    nnoremap <M-h>n :VsnipOpen<Space>
    if InstalledLeaderf()
        nnoremap <silent><M-h>s :Leaderf file --no-sort  ~/.leovim/snippets<Cr>
    elseif InstalledFzf()
        nnoremap <silent><M-h>s :FzfFiles ~/.leovim/snippets<Cr>
    endif
endif
if Installed('vim-vsnip')
    if InstalledCoc()
        let g:coc_snippet_next = "<C-f>"
        let g:coc_snippet_prev = "<C-b>"
        smap <silent><expr><C-f> coc#jumpable() ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" : '<C-o>A'
        imap <silent><expr><C-f> coc#jumpable() ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" : CtrlFSkipBracket()
    else
        smap <silent><expr><C-b> vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)' : '<C-o>I'
        smap <silent><expr><C-f> vsnip#jumpable(1)  ? '<Plug>(vsnip-jump-next)' : '<C-o>A'
        imap <silent><expr><C-b> vsnip#available(-1) ? '<Plug>(vsnip-jump-prev)' : '<C-o>I'
        imap <silent><expr><C-f> vsnip#available(1)  ? '<Plug>(vsnip-expand-or-jump)' : CtrlFSkipBracket()
    endif
    if Installed('vim-vsnip-integ')
        function! MapTabCr(istab) abort
            let istab = a:istab
            if pumvisible()
                if istab
                    if empty(get(v:, 'completed_item', {}))
                        return "\<C-n>"
                    elseif vsnip#available(1)
                        return "\<Plug>(vsnip-expand-or-jump)"
                    else
                        return "\<C-y>"
                    endif
                else
                    return "\<C-y>"
                endif
            else
                if istab
                    return "\<Tab>"
                else
                    return "\<Cr>"
                endif
            endif
        endfunction
        au WinEnter,BufEnter * imap <silent><Tab> <C-R>=MapTabCr(1)<Cr>
        au WinEnter,BufEnter * imap <silent><Cr> <C-R>=MapTabCr(0)<Cr>
        if g:complete_engine == 'mcm'
            au WinEnter,BufEnter * imap <expr><down> mucomplete#extend_fwd("\<down>")
        endif
    endif
else
    imap <silent><C-b> <C-o>I
    imap <silent><C-f> <C-o>A
endif
imap <M-n> <C-n>
imap <M-p> <C-p>
" -----------------------
" fzf snippet
" -----------------------
if InstalledFzf()
    imap <c-x><c-l> <plug>(fzf-complete-line)
    if UNIX()
        imap <c-x><c-f> <plug>(fzf-complete-path)
    endif
endif
" ------------------------------
" AI complete
" ------------------------------
if Installed('codeium.vim')
    let g:codeium_disable_bindings = 1
    let g:codeium_manual = v:true
    imap <silent><nowait><script><expr><M-i> codeium#Accept()
    imap <silent><nowait><script><expr><M-.> codeium#Complete()
    imap <silent><nowait><script><expr><M-/> codeium#Clear()
    imap <silent><nowait><script><expr><M-;> codeium#CycleCompletions(1)
    imap <silent><nowait><script><expr><M-,> codeium#CycleCompletions(-1)
elseif Installed('copilot.vim')
    au BufEnter,BufWinEnter * let b:copilot_enabled = v:false
    let g:copilot_no_tab_map = v:true
    imap <silent><nowait><script><expr><M-i> copilot#Accept("\<CR>")
    imap <silent><nowait><M-.> <Plug>(copilot-suggest)
    imap <silent><nowait><M-/> <Plug>(copilot-dismiss)
    imap <silent><nowait><M-;> <Plug>(copilot-next)
    imap <silent><nowait><M-,> <Plug>(copilot-previous)
    imap <silent><nowait><M-}> <Plug>(copilot-accept-word)
    imap <silent><nowait><M-{> <Plug>(copilot-accept-line)
    if Installed('CopilotChat.nvim')
        luafile $LUA_DIR/copilotchat.lua
        command! CopilotChatCommands call FzfCallCommands('CopilotChatCommands', 'CopilotChat')
        nnoremap <silent><M-i>g :CopilotChatCommands<Cr>
        nnoremap <M-i>c :CopliotChat<Space>
        nnoremap <M-i>s :CopliotChatSave<Space>
        nnoremap <M-i>l :CopliotChatLoad<Space>
        luafile $LUA_DIR/copilotchat.lua
    endif
endif
if Installed('gp.nvim')
    luafile $LUA_DIR/gp.lua
    function! s:gp_toggle()
        if &columns > &lines * 3
            GpChatToggle vsplit
        else
            GpChatToggle split
        endif
    endfunction
    command! GpChatToggleSmartPosition call s:gp_toggle()
    command! GpCommands call FzfCallCommands('GpCommands', 'Gp')
    nnoremap <silent><M-i><M-g> :GpCommands<Cr>
endif
" ------------------------------
" pairs
" ------------------------------
if Installed('pear-tree')
    let g:pear_tree_map_special_keys = 0
endif
