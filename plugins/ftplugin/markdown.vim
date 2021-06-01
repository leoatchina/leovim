" insert image
if Installed("md-img-paste.vim")
    nmap <buffer><silent> <leader>I :call mdip#MarkdownClipboardImage()<CR>
    let g:mdip_imgdir = '.'
    let g:mdip_imgname = 'image'
endif
if get(g:, 'markdown_tool', '') =~ 'markdown'
    " markdown.preview
    if get(g:, 'markdown_tool', '') =~ 'nvim'
        nmap <leader>R <Plug>MarkdownPreview
        nmap <leader>S <Plug>StopMarkdownPreview
    elseif get(g:, 'markdown_tool', '') =~ 'vim'
        nmap <leader>R <Plug>MarkdownPreview
        nmap <leader>S <Plug>MarkdownPreviewStop
    endif
endif
if Installed("preview-markdown.vim")
    nmap <leader>M :PreviewMarkdown<cr>
    let g:preview_markdown_vertical = 1
endif
