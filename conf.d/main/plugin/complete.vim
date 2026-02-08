" Skip in VSCode environment
if utils#is_vscode()
    finish
endif
" --------------------------
" complete options
" --------------------------
set completeopt=menu,menuone
if has('patch-9.0.1568')
    set sms
endif
if has('patch-8.1.1270')
    set shortmess+=S
endif
if has('patch-7.4.1829')
    set shortmess+=a
    set shortmess+=c
endif
" completion options settings - based on precise version judgment
if has('patch-7.4.775')
    set completeopt+=noselect
endif
if has('patch-7.4.784')
    set completeopt+=noinsert
endif
if has('nvim-0.11')
    set completeopt+=fuzzy
endif
" Vim 8.1.1880+ popup completion window (requires textprop support, Neovim uses floating window)
if !has('nvim') && has('patch-8.1.1880') && has('textprop') && exists('+completepopup')
    set completeopt+=popup
    set completepopup=align:menu,border:off,highlight:WildMenu
endif
" completion menu size settings
set pumheight=20
if exists('+pumwidth')
    set pumwidth=50
endif
" -----------------------------
" lsp && vista_default_executive
" -----------------------------
if pack#installed('mason.nvim')
    lua require("cfg/mason")
endif
if pack#installed('codesettings.nvim')
    lua require('cfg/codesettings')
endif
if pack#installed_lsp()
    let g:vista_default_executive = 'nvim_lsp'
    source $CFG_DIR/lsp.vim
elseif pack#installed_coc()
    let g:vista_default_executive = 'coc'
elseif pack#planned('vista.vim')
    let g:vista_default_executive = 'ctags'
endif
" ------------------------------
" normal complete_engine
" ------------------------------
if pack#installed_lsp()
    if pack#installed_blink()
        lua require("cfg/blink")
    elseif pack#installed_cmp()
        lua require("cfg/cmp")
    endif
elseif pack#installed_coc()
    source $CFG_DIR/coc.vim
elseif g:complete_engine != ''
    if has('nvim-0.11')
        let g:complete_engine = 'builtin'
        lua require("cfg/builtin")
    elseif has('patch-9.1.1590')
        let g:complete_engine = 'builtin'
        source $CFG_DIR/builtin.vim
    else
        let g:complete_engine = 'mcm'
        source $CFG_DIR/mcm.vim
    endif
endif
" ------------------------------
" vsnip
" ------------------------------
if pack#planned('vim-vsnip')
    fun! CtrlFSkipBracket()
        call feedkeys(search('\%#[]>)}]', 'n') ? "\<Right>" : "\<C-o>A")
        return ''
    endfunction
    let g:vsnip_snippet_dir = utils#expand("~/.leovim/conf.d/snippets")
    nnoremap <M-h>n :VsnipOpen<Cr>
    if pack#planned_leaderf()
        nnoremap <silent><M-h>f :Leaderf file --no-sort ~/.leovim.d/pack/add/opt/friendly-snippets/snippets<Cr>
        nnoremap <silent><M-h>s :Leaderf file --no-sort ~/.leovim/conf.d/snippets<Cr>
    elseif pack#planned_fzf()
        nnoremap <silent><M-h>f :FzfFiles ~/.leovim.d/pack/add/opt/friendly-snippets/snippets<Cr>
        nnoremap <silent><M-h>s :FzfFiles ~/.leovim/conf.d/snippets<Cr>
    endif
    if pack#installed_coc()
        call coc#config("snippets.userSnippetsDirectory", utils#expand("~/.leovim/conf.d/snippets"))
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
if pack#planned_fzf()
    imap <c-x><c-l> <plug>(fzf-complete-line)
    if utils#is_unix()
        imap <c-x><c-f> <plug>(fzf-complete-path)
    endif
endif
" ------------------------------
" wilder.nvim
" ------------------------------
if pack#installed('wilder.nvim')
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
elseif !pack#installed_adv()
    cnoremap <expr><C-j> pumvisible() ? "\<C-n>" : "\<C-j>"
    cnoremap <expr><C-k> pumvisible() ? "\<C-p>" : "\<C-k>"
    cnoremap <expr><C-n> pumvisible() ? "\<Down>" : "\<C-n>"
    cnoremap <expr><C-p> pumvisible() ? "\<Up>" : "\<C-p>"
endif
" ------------------------------
" pairs
" ------------------------------
if pack#planned('pear-tree')
    let g:pear_tree_map_special_keys = 0
endif
" ------------------------------
" web
" ------------------------------
if pack#planned('emmet-vim')
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
if pack#planned('vim-go')
    let g:go_doc_balloon = 0
    let g:go_def_mapping_enabled = 0
    if pack#installed_adv()
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
