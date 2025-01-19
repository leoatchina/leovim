if Installed('mason.nvim')
    lua require("cfg/mason")
endif
" ------------------------------
" vim-header
" ------------------------------
let g:header_auto_add_header = 0
let g:header_auto_update_header = 0
let g:header_field_timestamp_format = '%Y.%m.%d'
PlugAddOpt 'vim-header'
nnoremap <M-k>a :AddHeader<Cr>
nnoremap <M-k>h :AddBangHeader<Cr>
" ------------------------------
" AI complete
" ------------------------------
let g:max_tokens = get(g:, 'max_tokens', 8192)
if Planned('codeium.vim')
    let g:codeium_disable_bindings = 1
    let g:codeium_manual = v:true
    imap <script><silent><nowait><expr> <M-i> codeium#Accept()
    imap <script><silent><nowait><expr> <M-}> codeium#AcceptNextWord()
    imap <script><silent><nowait><expr> <M-{> codeium#AcceptNextLine()
    imap <silent><script><nowait><expr> <M-/> codeium#Clear()
    imap <M-.> <Plug>(codeium-complete)
    imap <M-;> <Plug>(codeium-next)
    imap <M-,> <Plug>(codeium-previous)
    let g:ai_complete_engine = 'codeium'
elseif Planned('copilot.vim')
    au BufEnter,BufWinEnter * let b:copilot_enabled = v:false
    let g:copilot_no_tab_map = v:true
    imap <silent><nowait><script><expr><M-i> copilot#Accept("\<CR>")
    imap <silent><nowait><M-.> <Plug>(copilot-suggest)
    imap <silent><nowait><M-/> <Plug>(copilot-dismiss)
    imap <silent><nowait><M-;> <Plug>(copilot-next)
    imap <silent><nowait><M-,> <Plug>(copilot-previous)
    imap <silent><nowait><M-}> <Plug>(copilot-accept-word)
    imap <silent><nowait><M-{> <Plug>(copilot-accept-line)
    let g:ai_complete_engine = 'copliot'
endif
if Installed('codecompanion.nvim')
    lua require("cfg/ai")
    lua require("cfg/codecompanion")
elseif Installed('avante.nvim')
    command! AvanteCommands call FzfCallCommands('AvanteCommands', 'Avante')
    lua require("cfg/ai")
    lua require("cfg/avante")
elseif !exists("g:ai_complete_engine")
    nnoremap <M-i> <Nop>
    xnoremap <M-i> <Nop>
    inoremap <M-i> <Nop>
endif
" -----------------------------
" vista_default_executive
" -----------------------------
if InstalledNvimLsp()
    let g:vista_default_executive = 'nvim_lsp'
    source $CFG_DIR/lsp.vim
else
    if has('nvim-0.9')
        lua vim.diagnostic.disable()
    endif
    if Installed('coc.nvim')
        let g:vista_default_executive = 'coc'
    else
        let g:vista_default_executive = 'ctags'
    endif
endif
" ------------------------------
" normal complete_engine
" ------------------------------
if InstalledCmp()
    lua require("cfg/cmp")
elseif Installed('coc.nvim')
    source $CFG_DIR/coc.vim
elseif g:complete_engine == 'apm'
    source $CFG_DIR/apm.vim
elseif g:complete_engine != ''
    let g:complete_engine = 'mcm'
    source $CFG_DIR/mcm.vim
endif
" ------------------------------
" vsnip
" ------------------------------
if Planned('vim-vsnip')
    fun! CtrlFSkipBracket()
        call feedkeys(search('\%#[]>)}]', 'n') ? "\<Right>" : "\<C-o>A")
        return ''
    endfunction
    let g:vsnip_snippet_dir = expand("~/.leovim/snippets")
    nnoremap <M-h>e :VsnipOpen<Cr>
    if PlannedLeaderf()
        nnoremap <M-h>s :Leaderf file --no-sort ~/.leovim/snippets<Cr>
    elseif PlannedFzf()
        nnoremap <M-h>s :FzfFiles ~/.leovim/snippets<Cr>
    endif
    if Installed('coc.nvim')
        call coc#config("snippets.userSnippetsDirectory", Expand("~/.leovim/snippets"))
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
    if !AdvCompEngine()
        function! MapTabCr(tab) abort
            if pumvisible()
                if a:tab
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
                if a:tab
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
elseif !InstalledCmp()
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
    if AdvCompEngine()
        let g:go_doc_keywordprg_enabled = 0
        let g:go_code_completion_enabled = 0
    else
        let g:go_doc_keywordprg_enabled = 1
        let g:go_code_completion_enabled = 1
    endif
endif
