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

function! ToggleMarkdownNumbers(enable = 0) range
    let l:numbers = [0, 0, 0, 0]  " 存储每级标题的当前序号
    let l:last_level = 0          " 记录上一个标题的级别

    " 首先收集所有行
    let l:lines = getline(a:firstline, a:lastline)
    let l:new_lines = []
    
    for l:line in l:lines
        " 跳过空行
        if l:line =~# '^\s*$'
            call add(l:new_lines, l:line)
            continue
        endif

        " 检查是否是标题行
        if l:line =~# '^#\+\s'
            let l:level = s:get_header_level(l:line)
            if l:level > 4
                call add(l:new_lines, l:line)
                continue
            endif

            " 如果要添加序号
            if a:enable
                " 移除已存在的序号（如果有）
                let l:clean_line = substitute(l:line, '^#\+\s\+\(\d\+\.\)*\d\+\s\+', '#\1 ', '')
                let l:clean_line = substitute(l:clean_line, '^#\+\s\+[a-z])\s\+', '#\1 ', '')

                " 更新序号
                if l:level > l:last_level
                    " 进入更深层级
                    for l:i in range(l:last_level, l:level-1)
                        let l:numbers[l:i] = 1
                    endfor
                elseif l:level == l:last_level
                    " 同级标题
                    let l:numbers[l:level-1] += 1
                else
                    " 返回更浅层级
                    let l:numbers[l:level-1] += 1
                    for l:i in range(l:level, 3)
                        let l:numbers[l:i] = 0
                    endfor
                endif

                " 生成序号字符串
                let l:number_str = s:get_current_numbers(l:level, l:numbers)
                
                " 在标题文本前添加序号
                let l:new_line = substitute(l:clean_line, '^#\+\s\+', '\0' . l:number_str . ' ', '')
                call add(l:new_lines, l:new_line)
            else
                " 移除序号
                let l:clean_line = substitute(l:line, '^#\+\s\+\(\d\+\.\)*\d\+\s\+', '#\1 ', '')
                let l:clean_line = substitute(l:clean_line, '^#\+\s\+[a-z])\s\+', '#\1 ', '')
                call add(l:new_lines, l:clean_line)
            endif

            let l:last_level = l:level
        else
            " 非标题行直接添加
            call add(l:new_lines, l:line)
        endif
    endfor

    " 替换原文本
    execute a:firstline . ',' . a:lastline . 'delete'
    call append(a:firstline - 1, l:new_lines)
endfunction

" Add command for markdown number toggle
au FileType markdown command! -range -nargs=? MdNumber <line1>,<line2>call ToggleMarkdownNumbers(<args>)