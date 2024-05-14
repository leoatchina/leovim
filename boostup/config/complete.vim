function! HasBackSpace() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1] =~ '\s'
endfunction
if Installed('mason.nvim')
    luafile $LUA_DIR/mason.lua
endif
if InstalledCmp()
    luafile $LUA_DIR/cmp.lua
elseif InstalledCoc()
    source $OPTIONAL_DIR/coc.vim
elseif g:complete_engine == 'apm'
    source $OPTIONAL_DIR/apm.vim
elseif g:complete_engine != ''
    let g:complete_engine = 'mcm'
    source $OPTIONAL_DIR/mcm.vim
endif
if InstalledCoc()
    let g:vista_default_executive = 'coc'
elseif InstalledNvimLsp()
    let g:vista_default_executive = 'nvim_lsp'
    if g:node_version > 14
        let g:ensure_installed = ['vimls', 'lua_ls', 'vale']
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
    if Require('rust')
        let g:ensure_installed += ['rust_analyzer']
    endif
    if Require('go')
        let g:ensure_installed += ['gopls']
    endif
    if Require('R') && executable('R')
        let g:ensure_installed += ['r_language_server']
    endif
    if Require('java') && executable('java')
        let g:ensure_installed += ['jdtls']
    endif
    luafile $LUA_DIR/lsp.lua
elseif Installed('vista.vim')
    let g:vista_default_executive = 'ctags'
endif
imap <M-n> <C-n>
imap <M-p> <C-p>
" ------------------------------
" vsnip
" ------------------------------
if Installed('vim-vsnip')
    let g:vsnip_snippet_dir = expand("~/.leovim/snippets")
    nnoremap <M-h>s :VsnipOpen<Space>
    nnoremap <M-h>S :tabe ~/.leovim/snippets
endif
fun! CtrlFSkipBracket()
    call feedkeys(search('\%#[]>)}]', 'n') ? "\<Right>" : "\<C-o>A")
    return ''
endfunction
if Installed('vim-vsnip-integ') && Installed('vim-vsnip')
    smap <silent><expr><C-b> vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)' : '<C-o>I'
    smap <silent><expr><C-f> vsnip#jumpable(1)  ? '<Plug>(vsnip-jump-next)' : '<C-o>A'
    imap <silent><expr><C-b> vsnip#available(-1) ? '<Plug>(vsnip-jump-prev)' : '<C-o>I'
    imap <silent><expr><C-f> vsnip#available(1)  ? '<Plug>(vsnip-expand-or-jump)' : CtrlFSkipBracket()
elseif InstalledCoc() && Installed('vim-vsnip')
    let g:coc_snippet_next = "<C-f>"
    let g:coc_snippet_prev = "<C-b>"
    smap <silent><expr><C-f> coc#jumpable() ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" : '<C-o>A'
    imap <silent><expr><C-f> coc#jumpable() ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" : CtrlFSkipBracket()
elseif Installed('luasnip')
    smap <silent><C-b> <cmd>lua require('luasnip').jump(-1)<Cr>
    smap <silent><C-f> <cmd>lua require('luasnip').jump(1)<Cr>
    imap <silent><expr><C-b> luasnip#jumpable(-1) ? '<Plug>luasnip-jump-prev' : '<C-o>I'
    imap <silent><expr><C-f> luasnip#jumpable(1)  ? '<Plug>luasnip-jump-next' : CtrlFSkipBracket()
else
    imap <silent><C-b> <C-o>I
    imap <silent><C-f> <C-o>A
endif
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
" codeium
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
" completedone
" ------------------------------
augroup CompleteModeChange
    " 离开InsertMode时，关闭补全，非paste模式
    autocmd InsertLeave * set nopaste
    " 补全完成后关闭预览窗口
    autocmd InsertLeave, CompleteDone * if pumvisible() == 0 | pclose | endif
augroup END
" ------------------------------
" pairs
" ------------------------------
if Installed('pear-tree')
    let g:pear_tree_map_special_keys = 0
endif
" ------------------------------
" vim-go
" ------------------------------
if Installed('vim-go')
    command! GoCommands call FzfCallCommands('GoCommands', 'Go')
endif
