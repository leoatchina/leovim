let g:mdip_imgdir = '.'
let g:mdip_imgname = 'image'
let g:preview_markdown_vertical = 1
if Installed('markdown-preview.nvim') || Installed('markdown-preview.vim')
    nmap <silent><buffer><M-R> :MarkdownPreview<Cr>
    nmap <silent><buffer><Tab>q :MarkdownPreviewStop<Cr>
endif
if Installed('md-img-paste.vim')
    nmap <silent><buffer><leader>I :call mdip#MarkdownClipboardImage()<CR>
endif
inoremap <buffer><C-w>1 <Space><C-u>#<Space>
inoremap <buffer><C-w>2 <Space><C-u>##<Space>
inoremap <buffer><C-w>3 <Space><C-u>###<Space>
inoremap <buffer><C-w>4 <Space><C-u>####<Space>
inoremap <buffer><C-w>5 <Space><C-u>#####<Space>
if Installed('preview-markdown.vim')
    function! s:smart_preview_markdown()
        if &columns > &lines * 3
            PreviewMarkdown right
        else
            PreviewMarkdown bottom
        endif
    endfunction
    command! SmartPreviewMarkdown call s:smart_preview_markdown()
    nmap <silent><buffer><M-B> :SmartPreviewMarkdown<Cr>
endif
