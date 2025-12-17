let g:preview_markdown_vertical = 1
inoremap <buffer><C-w>1 <Space><C-u>#<Space>
inoremap <buffer><C-w>2 <Space><C-u>##<Space>
inoremap <buffer><C-w>3 <Space><C-u>###<Space>
inoremap <buffer><C-w>4 <Space><C-u>####<Space>
inoremap <buffer><C-w>5 <Space><C-u>#####<Space>
if plug#installed('md-img-paste.vim')
    let g:mdip_imgdir = './'
    let g:mdip_imgname = 'attach'
    nnoremap <silent><buffer><leader>i :call mdip#MarkdownClipboardImage()<CR>
endif
if plug#installed('preview-markdown.vim')
    function! s:smart_preview_markdown()
        if &columns > &lines * 3
            PreviewMarkdown right
        else
            PreviewMarkdown bottom
        endif
    endfunction
    command! SmartPreviewMarkdown call s:smart_preview_markdown()
    nnoremap <silent><buffer><M-R> :SmartPreviewMarkdown<Cr>
endif
if plug#installed('render-markdown.nvim')
    nnoremap <silent><buffer><M-B> :RenderMarkdown buf_toggle<Cr>
    augroup SetupRenderMarkdown
        autocmd!
        autocmd User codecompanion.nvim,mini.pick ++once lua utils#is_require('render-markdown').setup({ file_types = { "markdown", "vimwiki" }})
        autocmd FileType markdown,vimwiki ++once lua utils#is_require('render-markdown').setup({ file_types = { "markdown", "vimwiki" }})
    augroup END
endif
if plug#installed('markdown-preview.nvim') || plug#installed('markdown-preview.vim')
    nnoremap <silent><buffer><M-F> :MarkdownPreview<Cr>
    nnoremap <silent><buffer><Tab>q :MarkdownPreviewStop<Cr>
endif
" Markdown number toggle function
function! s:get_header_level(line)
    let l:count = 0
    let l:i = 0
    while l:i < len(a:line) && a:line[l:i] ==# '#'
        let l:count += 1
        let l:i += 1
    endwhile
    return l:count
endfunction
function! s:get_current_numbers(level, numbers)
    if a:level <= 3
        return join(a:numbers[0:a:level-1], '.')
    elseif a:level == 4
        return nr2char(char2nr('a') + a:numbers[3] - 1) . ')'
    endif
    return ''
endfunction
" FIXME: this function is not completed
function! s:ToggleMarkdownNumbers(enable) range
    let l:numbers = [0, 0, 0, 0]  " Store current sequence number for each header level
    let l:last_level = 0          " Record previous header level
    " First collect all lines
    let l:lines = getline(a:firstline, a:lastline)
    let l:new_lines = []
    for l:line in l:lines
        " Skip empty lines
        if l:line =~# '^\s*$'
            call add(l:new_lines, l:line)
            continue
        endif
        " Check if it's a header
        if l:line =~# '^#\+\s'
            let l:level = s:get_header_level(l:line)
            if l:level > 4
                call add(l:new_lines, l:line)
                continue
            endif
            " If need to add sequence number
            if a:enable
                " Remove existing sequence numbers (if any)
                let l:clean_line = substitute(l:line, '^#\+\s\+\(\d\+\.\)*\d\+\s\+', '#\1 ', '')
                let l:clean_line = substitute(l:clean_line, '^#\+\s\+[a-z])\s\+', '#\1 ', '')
                " Update sequence number
                if l:level > l:last_level
                    " Enter deeper level
                    for l:i in range(l:last_level, l:level-1)
                        let l:numbers[l:i] = 1
                    endfor
                elseif l:level == l:last_level
                    " Same level header
                    let l:numbers[l:level-1] += 1
                else
                    " Return to shallower level
                    let l:numbers[l:level-1] += 1
                    for l:i in range(l:level, 3)
                        let l:numbers[l:i] = 0
                    endfor
                endif
                " Generate sequence number string
                let l:number_str = s:get_current_numbers(l:level, l:numbers)
                " Add sequence number before header text
                let l:new_line = substitute(l:clean_line, '^#\+\s\+', '\0' . l:number_str . ' ', '')
                call add(l:new_lines, l:new_line)
            else
                " Remove sequence number
                let l:clean_line = substitute(l:line, '^#\+\s\+\(\d\+\.\)*\d\+\s\+', '#\1 ', '')
                let l:clean_line = substitute(l:clean_line, '^#\+\s\+[a-z])\s\+', '#\1 ', '')
                call add(l:new_lines, l:clean_line)
            endif
            let l:last_level = l:level
        else
            " Non-header lines added directly
            call add(l:new_lines, l:line)
        endif
    endfor
    " Replace original text
    execute a:firstline . ',' . a:lastline . 'delete'
    call append(a:firstline - 1, l:new_lines)
endfunction
" Add command for markdown number toggle
au FileType markdown command! -range -nargs=? ToggleMarkdownNumbers <line1>,<line2>call s:ToggleMarkdownNumbers(<args>)
nnoremap <silent><buffer><M-T> :ToggleMarkdownNumbers<Cr>

