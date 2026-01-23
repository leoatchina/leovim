let g:preview_markdown_vertical = 1
inoremap <buffer><C-w>1 <Space><C-u>#<Space>
inoremap <buffer><C-w>2 <Space><C-u>##<Space>
inoremap <buffer><C-w>3 <Space><C-u>###<Space>
inoremap <buffer><C-w>4 <Space><C-u>####<Space>
inoremap <buffer><C-w>5 <Space><C-u>#####<Space>
if pack#installed('md-img-paste.vim')
    let g:mdip_imgdir = utils#get_root_dir() . '/img'
    let g:mdip_imgname = 'attach'
    nnoremap <silent><buffer><leader>i :call mdip#MarkdownClipboardImage()<CR>
endif
if pack#installed('render-markdown.nvim')
    nnoremap <silent><buffer><M-F> :RenderMarkdown buf_toggle<Cr>
    augroup SetupRenderMarkdown
        autocmd!
        autocmd FileType markdown,vimwiki ++once lua utils#is_require('render-markdown').setup({ file_types = { "markdown", "vimwiki" }})
    augroup END
endif
if pack#installed('markdown-preview.nvim') || pack#installed('markdown-preview.vim')
    nnoremap <silent><buffer><M-R> :MarkdownPreview<Cr>
    nnoremap <silent><buffer><M-B> :MarkdownPreviewStop<Cr>
endif
" -----------------------------------------
" Markdown number toggle function
" -----------------------------------------
function! s:get_header_level(line)
    let l:match = matchstr(a:line, '^#\+')
    return len(l:match)
endfunction

function! s:get_current_numbers(level, numbers)
    if a:level <= 3
        return join(a:numbers[0:a:level-1], '.')
    elseif a:level == 4
        return nr2char(char2nr('a') + a:numbers[3] - 1) . ')'
    endif
    return ''
endfunction

function! s:ToggleMarkdownNumbers() range abort
    let l:lines = getline(a:firstline, a:lastline)
    " Detect if headers already have numbers (check first header found)
    let l:has_numbers = 0
    for l:line in l:lines
        if l:line =~# '^#\{1,4\}\s'
            let l:content = substitute(l:line, '^#\+\s*', '', '')
            if l:content =~# '^\(\d\+\.\)*\d\+\s' || l:content =~# '^[a-z])\s'
                let l:has_numbers = 1
            endif
            break
        endif
    endfor

    let l:enable = !l:has_numbers
    let l:numbers = [0, 0, 0, 0]
    let l:last_level = 0
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
            " Extract header prefix and content
            let l:prefix = matchstr(l:line, '^#\+')
            let l:content = substitute(l:line, '^#\+\s*', '', '')
            " Remove existing numbers from content
            let l:content = substitute(l:content, '^\(\d\+\.\)*\d\+\s\+', '', '')
            let l:content = substitute(l:content, '^[a-z])\s\+', '', '')

            if l:enable
                " Update sequence number based on level changes
                if l:level > l:last_level
                    for l:i in range(l:last_level, l:level-1)
                        let l:numbers[l:i] = 1
                    endfor
                elseif l:level == l:last_level
                    let l:numbers[l:level-1] += 1
                else
                    let l:numbers[l:level-1] += 1
                    for l:i in range(l:level, 3)
                        let l:numbers[l:i] = 0
                    endfor
                endif
                let l:number_str = s:get_current_numbers(l:level, l:numbers)
                let l:new_line = l:prefix . ' ' . l:number_str . ' ' . l:content
                call add(l:new_lines, l:new_line)
            else
                let l:new_line = l:prefix . ' ' . l:content
                call add(l:new_lines, l:new_line)
            endif
            let l:last_level = l:level
        else
            call add(l:new_lines, l:line)
        endif
    endfor
    execute a:firstline . ',' . a:lastline . 'delete'
    call append(a:firstline - 1, l:new_lines)
endfunction

command! -buffer -range=% ToggleMarkdownNumbers <line1>,<line2>call s:ToggleMarkdownNumbers()
nnoremap <silent><buffer><M-T> :ToggleMarkdownNumbers<Cr>
