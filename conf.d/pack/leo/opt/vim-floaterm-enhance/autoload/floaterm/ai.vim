" --------------------------------------------------------------
" send file path with line range to floaterm terminal
" format: @file_abs_path#L1-L10
" --------------------------------------------------------------
function! floaterm#ai#send_file_line_range() abort
    let range_str = floaterm#enhance#get_file_line_range()
    let curr_bufnr = floaterm#buflist#curr()
    if curr_bufnr <= 0
        call floaterm#enhance#showmsg('No floaterm window found', 1)
        return
    endif
    call floaterm#terminal#send(curr_bufnr, [range_str])
endfunction


" --------------------------------------------------------------
" fzf file picker with root dir files
" sink: send selected file paths to floaterm terminal (support multi-select)
" --------------------------------------------------------------
function! floaterm#ai#fzf_file_sink(lines) abort
    if empty(a:lines)
        call floaterm#enhance#showmsg('No file selected', 1)
        return
    endif
    let curr_bufnr = floaterm#buflist#curr()
    if curr_bufnr <= 0
        call floaterm#enhance#showmsg('No floaterm window found', 1)
        return
    endif
    for file_path in a:lines
        let msg = '@' . file_path
        call floaterm#terminal#send(curr_bufnr, [msg])
    endfor
    call floaterm#enhance#showmsg(printf('Sent %d file(s)', len(a:lines)))
endfunction

function! floaterm#ai#fzf_file_list() abort
    if !exists('*fzf#run')
        call floaterm#enhance#showmsg('fzf.vim is required for file picker', 1)
        return
    endif
    let root_dir = floaterm#path#get_root()
    let relative_dir = substitute(floaterm#enhance#get_file_absdir(), '^' . root_dir . '/', '', '')
    call fzf#vim#files(root_dir, fzf#vim#with_preview({
                \ 'sink*': function('floaterm#enhance#fzf_file_sink'),
                \ 'options': ['--multi', '--prompt', 'FloatermFzfFile> ', '--query', relative_dir]
                \ }), 0)
endfunctio