setlocal conceallevel=1
if pack#installed('vimtex')
    let g:tex_flavor = get(g:, 'tex_flaver', 'latex')
    let g:tex_conceal = get(g:, 'tex_conceal', 'abdmg')
    let g:vimtex_quickfix_mode = get(g:, 'vimtex_quickfix_mode', 0)
endif
