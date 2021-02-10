if get(g:, 'markdown_tool', '') =~ 'markdown'
    " insert image
    autocmd FileType markdown nmap <buffer><silent> <leader>I :call mdip#MarkdownClipboardImage()<CR>
    let g:mdip_imgdir = '.'
    let g:mdip_imgname = 'image'
    " markdown.preview
    if get(g:, 'markdown_tool', '') =~ 'nvim'
        au FileType markdown nmap <leader>R <Plug>MarkdownPreview
        au FileType markdown nmap <leader>S <Plug>StopMarkdownPreview
    elseif get(g:, 'markdown_tool', '') =~ 'vim'
        au FileType markdown nmap <leader>R <Plug>MarkdownPreview
        au FileType markdown nmap <leader>S <Plug>MarkdownPreviewStop
    endif
endif
