autocmd! FileType fzf set laststatus=0 noshowmode noruler | autocmd BufLeave <buffer> set laststatus=2 showmode ruler
let $FZF_DEFAULT_OPTS = ' --reverse --info=inline --bind ctrl-b:preview-up,ctrl-f:preview-down,ctrl-a:select-all'
let g:fzf_vim = {}
au FileType fzf tnoremap <buffer> <C-j> <Down>
au FileType fzf tnoremap <buffer> <C-k> <Up>
au FileType fzf tnoremap <buffer> <C-n> <Nop>
au FileType fzf tnoremap <buffer> <C-p> <Nop>
" preview position
let g:fzf_vim.command_prefix = 'Fzf'
" [Buffers] Jump to the existing window if possible
let g:fzf_buffers_jump = 1
function! s:build_quickfix_list(lines)
    call setqflist(map(copy(a:lines), '{ "filename": v:val, "lnum": 1 }'))
    copen
endfunction
let g:fzf_action = {
            \ 'enter':  'edit',
            \ 'ctrl-t': 'tab split',
            \ 'ctrl-x': 'split',
            \ 'ctrl-]': 'vsplit',
            \ 'ctrl-q': function('s:build_quickfix_list'),
            \ }
" layout
if has('nvim') || has('patch-8.2.191')
    let g:fzf_layout = {
                \ 'window': {'width': 0.9, 'height': 0.9, 'border': 'rounded'}
                \ }
    function s:fzf_updata_position()
        if &columns > &lines * 3
            let g:fzf_vim.preview_window = ['right,45%', 'ctrl-l']
        else
            let g:fzf_vim.preview_window = ['up,40%', 'ctrl-l']
        endif
        let g:coc_fzf_preview = g:fzf_vim.preview_window
        let g:vista_fzf_preview = g:fzf_vim.preview_window
        let g:fzf_lsp_preview_window = g:fzf_vim.preview_window
    endfunction
    call s:fzf_updata_position()
    au VimResized * call s:fzf_updata_position()
else
    let g:fzf_layout = {'down': '~30%'}
    let g:fzf_vim.preview_window = ['right,45%', 'ctrl-l']
    let g:vista_fzf_preview = g:fzf_vim.preview_window
endif
" ---------------
" FzfFiles
" ---------------
command! -bang -nargs=? -complete=dir FzfFiles call fzf#vim#files(<q-args>, fzf#vim#with_preview({'options': ' --no-sort '}), <bang>0)
" ---------------
" fzf_commands
" ---------------
function FzfCallCommands(prompt, ...)
    let prompt = a:prompt
    if a:0 == 0
        return
    endif
    if a:0 > 1
        let last = a:000[-1]
        if type(last) == type([])
            let search_prefix = a:000[:-2]
            let ignore_cmds = [prompt] + last
        else
            let search_prefix = a:000
            let ignore_cmds = [prompt]
        endif
        if len(ignore_cmds) > 1
            let ignore_reg = join(ignore_cmds, '\|')
        else
            let ignore_reg = ignore_cmds[0]
        endif
    else
        let search_prefix = [a:1]
        let ignore_reg = prompt
    endif
    let results = ["Ctrl-e To Edit"]
    for search in search_prefix
        let commands = split(Execute("command " . search), '\n')[1:]
        for command in commands
            for sp in split(command, '\s\+')[:4]
                if count(results, sp) > 0
                    break
                elseif sp =~ '#'
                    break
                elseif sp =~ ',' || sp =~ '\.'
                    break
                elseif sp =~ '(' || sp =~ ')'
                    break
                elseif sp =~ '[' || sp =~ ']'
                    break
                elseif sp =~ '{' || sp =~ '}'
                    break
                elseif sp =~# "^" . search && sp !~# ignore_reg
                    call add(results, sp)
                    break
                endif
            endfor
        endfor
    endfor
    if g:has_popup_floating
        let height = len(results) + 4
        if height > 0.8 * &lines
            let height = float2nr(0.8 * &lines)
        endif
        let width = max(map(copy(results), 'len(v:val)')) * 2 - 2
        let l:fzf_layout = {
                    \ 'window': {'width': width, 'height': height, 'border': 'rounded'}
                    \ }
    else
        let l:fzf_layout = {'down': '~30%'}
    endif
    function! s:execute(item) abort
        let key = a:item[0]
        let cmd = a:item[1]
        call histadd(':', cmd)
        if key == 'ctrl-e'
            redraw
            call feedkeys(":\<up>", 'n')
        else
            execute cmd
        endif
    endfunction
    call fzf#run(extend({
                \ 'source': results,
                \ 'sink*': function('s:execute'),
                \ 'options': printf('+m --ansi --header-lines=1 --expect=ctrl-e --tiebreak=index --prompt "%s> "', prompt)
                \ }, l:fzf_layout), 0)
endfunction
