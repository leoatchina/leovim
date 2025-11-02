if Installed('mason.nvim')
    lua require("cfg/mason")
endif
" ------------------------------
" AI complete
" ------------------------------
let g:max_tokens = get(g:, 'max_tokens', 8192)
if Installed('minuet-ai.nvim')
    lua require("cfg/api")
    lua require('cfg/minuet')
    let g:ai_complete_engine = 'minuet'
    let s:api_required = 1
elseif Installed('windsurf.vim')
    let g:codeium_disable_bindings = 1
    let g:codeium_manual = v:true
    imap <script><silent><nowait><expr> <M-i> codeium#Accept()
    imap <script><silent><nowait><expr> <M-}> codeium#AcceptNextWord()
    imap <script><silent><nowait><expr> <M-:> codeium#AcceptNextLine()
    imap <silent><script><nowait><expr> <M-/> codeium#Clear()
    imap <M-.> <Plug>(codeium-complete)
    imap <M-;> <Plug>(codeium-next)
    imap <M-,> <Plug>(codeium-previous)
    let g:ai_complete_engine = 'windsurf'
elseif Installed('copilot.vim')
    au BufEnter,BufWinEnter * let b:copilot_enabled = v:false
    let g:copilot_no_tab_map = v:true
    imap <silent><nowait><script><expr><M-i> copilot#Accept("\<CR>")
    imap <silent><nowait><M-.> <Plug>(copilot-suggest)
    imap <silent><nowait><M-/> <Plug>(copilot-dismiss)
    imap <silent><nowait><M-;> <Plug>(copilot-next)
    imap <silent><nowait><M-,> <Plug>(copilot-previous)
    imap <silent><nowait><M-}> <Plug>(copilot-accept-word)
    imap <silent><nowait><M-:> <Plug>(copilot-accept-line)
    let g:ai_complete_engine = 'copliot'
endif
if Installed('codecompanion.nvim', 'codecompanion-history.nvim', 'mcphub.nvim')
    if !get(s:, 'api_required', 0)
        lua require("cfg/api")
    endif
    lua require("cfg/codecompanion")
elseif !exists("g:ai_complete_engine")
    nnoremap <M-i> <Nop>
    xnoremap <M-i> <Nop>
    inoremap <M-i> <Nop>
endif
" -----------------------------
" lsp && vista_default_executive
" -----------------------------
if Installed('neoconf.nvim')
    lua require('cfg/neoconf')
endif
if InstalledLsp()
    let g:vista_default_executive = 'nvim_lsp'
    source $CFG_DIR/lsp.vim
elseif InstalledCoc()
    let g:vista_default_executive = 'coc'
elseif Planned('vista.vim')
    let g:vista_default_executive = 'ctags'
endif
" ------------------------------
" normal complete_engine
" ------------------------------
if InstalledLsp()
    if InstalledBlink()
        lua require("cfg/blink")
    else
        lua require("cfg/cmp")
    endif
elseif InstalledCoc()
    source $CFG_DIR/coc.vim
elseif g:complete_engine == 'mcm'
    PlugAddOpt 'vim-dict'
    source $CFG_DIR/mcm.vim
elseif g:complete_engine != ''
    if has('nvim-0.11')
        let g:complete_engine = 'builtin'
        lua require("cfg/builtin")
    elseif has('patch-9.1.1590')
        let g:complete_engine = 'builtin'
        source $CFG_DIR/builtin.vim
    else
        let g:complete_engine = 'mcm'
        PlugAddOpt 'vim-dict'
        source $CFG_DIR/mcm.vim
    endif
endif
" ------------------------------
" vsnip
" ------------------------------
if Planned('vim-vsnip')
    fun! CtrlFSkipBracket()
        call feedkeys(search('\%#[]>)}]', 'n') ? "\<Right>" : "\<C-o>A")
        return ''
    endfunction
    let g:vsnip_snippet_dir = expand("~/.leovim/conf.d/snippets")
    nnoremap <M-h>n :VsnipOpen<Cr>
    if PlannedLeaderf()
        nnoremap <silent><M-h>f :Leaderf file --no-sort ~/.leovim.d/pack/add/opt/friendly-snippets/snippets<Cr>
        nnoremap <silent><M-h>s :Leaderf file --no-sort ~/.leovim/conf.d/snippets<Cr>
    elseif PlannedFzf()
        nnoremap <silent><M-h>f :FzfFiles ~/.leovim.d/pack/add/opt/friendly-snippets/snippets<Cr>
        nnoremap <silent><M-h>s :FzfFiles ~/.leovim/conf.d/snippets<Cr>
    endif
    if InstalledCoc()
        call coc#config("snippets.userSnippetsDirectory", Expand("~/.leovim/conf.d/snippets"))
        let g:coc_snippet_next = "<C-f>"
        let g:coc_snippet_prev = "<C-b>"
        smap <silent><expr><C-f> coc#expandableOrJumpable() ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" : '<C-o>A'
        imap <silent><expr><C-f> coc#expandableOrJumpable() ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" : CtrlFSkipBracket()
    else
        smap <silent><expr><C-b> vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)' : '<C-o>I'
        smap <silent><expr><C-f> vsnip#jumpable(1)  ? '<Plug>(vsnip-jump-next)' : '<C-o>A'
        imap <silent><expr><C-b> vsnip#available(-1) ? '<Plug>(vsnip-jump-prev)' : '<C-o>I'
        imap <silent><expr><C-f> vsnip#available(1)  ? '<Plug>(vsnip-expand-or-jump)' : CtrlFSkipBracket()
    endif
else
    imap <silent><C-b> <C-o>I
    imap <silent><C-f> <C-o>A
endif
" -----------------------
" fzf snippet
" -----------------------
if PlannedFzf()
    imap <c-x><c-l> <plug>(fzf-complete-line)
    if UNIX()
        imap <c-x><c-f> <plug>(fzf-complete-path)
    endif
endif
" ------------------------------
" wilder.nvim
" ------------------------------
if Installed('wilder.nvim')
    " Default keys
    call wilder#setup({
                \ 'modes': [':', '/', '?'],
                \ 'next_key': '<Tab>',
                \ 'previous_key': '<S-Tab>',
                \ 'accept_key': '<Down>',
                \ 'reject_key': '<Up>',
                \ })
    cmap <expr><C-j> wilder#in_context() ? wilder#next() : "\<C-j>"
    cmap <expr><C-k> wilder#in_context() ? wilder#previous() : "\<C-k>"
    " using vim pipeline only
    call wilder#set_option('pipeline', [
                \   wilder#branch(
                \     wilder#cmdline_pipeline({'language': 'vim'}),
                \     wilder#vim_search_pipeline(),
                \   ),
                \ ])
    call wilder#set_option('renderer', wilder#popupmenu_renderer({
                \ 'highlighter': wilder#basic_highlighter(),
                \ }))
elseif !InstalledAdv()
    cnoremap <expr><C-j> pumvisible() ? "\<C-n>" : "\<C-j>"
    cnoremap <expr><C-k> pumvisible() ? "\<C-p>" : "\<C-k>"
    cnoremap <expr><C-n> pumvisible() ? "\<Down>" : "\<C-n>"
    cnoremap <expr><C-p> pumvisible() ? "\<Up>" : "\<C-p>"
endif
" ------------------------------
" pairs
" ------------------------------
if Planned('pear-tree')
    let g:pear_tree_map_special_keys = 0
endif
" ------------------------------
" web
" ------------------------------
if Planned('emmet-vim')
    for c in ['n', 'x', 'i']
        let cmd = printf('au FileType %s %smap <M-y> <C-y>,', join(g:web_filetypes, ','), c)
        exec cmd
    endfor
    let g:user_emmet_mode='a'
    let g:user_emmet_settings = {
                \ 'wxss': {
                \   'extends': 'css',
                \ },
                \ 'wxml': {
                \   'extends': 'html',
                \   'aliases': {
                \     'div': 'view',
                \     'span': 'text',
                \   },
                \   'default_attributes': {
                \     'block': [{'wx:for-items': '{{list}}','wx:for-item': '{{item}}'}],
                \     'navigator': [{'url': '', 'redirect': 'false'}],
                \     'scroll-view': [{'bindscroll': ''}],
                \     'swiper': [{'autoplay': 'false', 'current': '0'}],
                \     'icon': [{'type': 'success', 'size': '23'}],
                \     'progress': [{'precent': '0'}],
                \     'button': [{'size': 'default'}],
                \     'checkbox-group': [{'bindchange': ''}],
                \     'checkbox': [{'value': '', 'checked': ''}],
                \     'form': [{'bindsubmit': ''}],
                \     'input': [{'type': 'text'}],
                \     'label': [{'for': ''}],
                \     'picker': [{'bindchange': ''}],
                \     'radio-group': [{'bindchange': ''}],
                \     'radio': [{'checked': ''}],
                \     'switch': [{'checked': ''}],
                \     'slider': [{'value': ''}],
                \     'action-sheet': [{'bindchange': ''}],
                \     'modal': [{'title': ''}],
                \     'loading': [{'bindchange': ''}],
                \     'toast': [{'duration': '1500'}],
                \     'audio': [{'src': ''}],
                \     'video': [{'src': ''}],
                \     'image': [{'src': '', 'mode': 'scaleToFill'}],
                \   }
                \ }}
endif
" ------------------------------
" vim-go
" ------------------------------
if Planned('vim-go')
    let g:go_doc_balloon = 0
    let g:go_def_mapping_enabled = 0
    if InstalledAdv()
        let g:go_doc_keywordprg_enabled = 0
        let g:go_code_completion_enabled = 0
    else
        let g:go_doc_keywordprg_enabled = 1
        let g:go_code_completion_enabled = 1
    endif
endif
" --------------------------
" helpful
" --------------------------
au FileType vim,lua,help nnoremap <M-M> :HelpfulVersion<Space>
