let g:mdip_imgdir = '.'
let g:mdip_imgname = 'image'
let g:preview_markdown_vertical = 1
if Installed('markdown-preview.nvim') || Installed('markdown-preview.vim')
    nmap <buffer><M-B> :MarkdownPreview<Cr>
    nmap <buffer><M-X> :MarkdownPreviewStop<Cr>
endif
if Installed('preview-markdown.vim')
    nmap <silent><buffer><M-R> :PreviewMarkdown<Cr>
endif
if Installed('md-img-paste.vim')
    nmap <silent><leader>I :call mdip#MarkdownClipboardImage()<CR>
endif
inoremap <buffer><C-w>1 <Space><C-u>#<Space>
inoremap <buffer><C-w>2 <Space><C-u>##<Space>
inoremap <buffer><C-w>3 <Space><C-u>###<Space>
inoremap <buffer><C-w>4 <Space><C-u>####<Space>
inoremap <buffer><C-w>5 <Space><C-u>#####<Space>
