let $FZF_DEFAULT_OPTS='--layout=reverse --inline-info --bind ctrl-b:preview-up,ctrl-f:preview-down,ctrl-a:select-all'
let g:fzf_vim = {}
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
        let g:vista_fzf_preview = g:fzf_vim.preview_window
        let g:coc_fzf_preview = g:fzf_vim.preview_window
    endfunction
    call s:fzf_updata_position()
    au VimResized * call s:fzf_updata_position()
else
    let g:fzf_layout = {'down': '~30%'}
    let g:vista_fzf_preview = g:fzf_vim.preview_window
    let g:fzf_vim.preview_window = ['right,45%', 'ctrl-l']
endif
" Use fzf to view highlight configuration
function! s:get_highlight_list()
    redir => l:highlight_output
    silent highlight
    redir END
    let l:highlight_lines = split(l:highlight_output, '\n')
    let l:highlight_groups = []
    for l:line in l:highlight_lines
        if l:line =~ '^\S\+\s\+xxx\s\+'
            call add(l:highlight_groups, l:line)
        endif
    endfor
    return l:highlight_groups
endfunction
command! -nargs=? FzfHighlight call fzf#run(fzf#wrap({
    \ 'source': s:get_highlight_list(),
    \ 'sink': function('s:highlight_sink'),
    \ }))
function! s:highlight_sink(line)
    let l:group = split(a:line)[0]
    execute 'highlight ' . l:group
endfunction
nnoremap <silent><M-k>h :FzfHighlight<Cr>
" ---------------
" FzfFiles
" ---------------
command! -bang -nargs=? -complete=dir FzfFilesNoSort call fzf#vim#files(<q-args>, fzf#vim#with_preview({'options': ' --no-sort '}), <bang>0)
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
        " if last parameter is list, it is the ignore list
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
        let commands = split(utils#execute("command " . search), '\n')[1:]
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
    function! s:fzf_execute(item) abort
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
                \ 'sink*': function('s:fzf_execute'),
                \ 'options': printf('+m --ansi --header-lines=1 --expect=ctrl-e --tiebreak=index --prompt "%s> "', prompt)
                \ }, l:fzf_layout), 0)
endfunction

function! s:fzf_quickfix_accept(item) abort
    if len(a:item) < 2
        return
    endif
    let key = empty(a:item[0]) ? 'enter' : a:item[0]
    let fields = split(a:item[1], "\t")
    if len(fields) < 2
        return
    endif
    let action = get(g:fzf_action, key, 'edit')
    if type(action) != type('')
        let action = 'edit'
    endif
    execute action . ' ' . fnameescape(fields[0])
    call cursor(str2nr(fields[1]), 1)
endfunction

function! fzf#open_qfloc()
    let list_name = 'Quickfix'
    let qf_items = getqflist()
    if empty(qf_items)
        let qf_items = getloclist(0)
        let list_name = 'Loclist'
    endif
    if empty(qf_items)
        call preview#errmsg("No Quickfix/Loclist")
        return
    endif
    let results = []
    for item in qf_items
        let filename = get(item, 'filename', '')
        if empty(filename) && get(item, 'bufnr', 0) > 0
            let filename = bufname(item.bufnr)
        endif
        if empty(filename)
            continue
        endif
        let lnum = get(item, 'lnum', 1)
        let text = substitute(get(item, 'text', ''), "\t", ' ', 'g')
        call add(results, printf("%s\t%d\t%s", filename, lnum, text))
    endfor
    if empty(results)
        call preview#errmsg("No Quickfix/Loclist")
        return
    endif
    let preview_window = get(get(g:, 'fzf_vim', {}), 'preview_window', ['right,45%'])[0]
    let options = [
                \ '+m',
                \ '--delimiter=' . "\t",
                \ '--with-nth=3..,1,2',
                \ '--expect=ctrl-t,ctrl-x,ctrl-]',
                \ '--tiebreak=index',
                \ '--prompt', list_name . '> ',
                \ '--preview-window', preview_window . ',+{2}-/2'
                \ ]
    let options = fzf#vim#with_preview({'options': options, 'placeholder': ' {1}:{2}'}).options
    call fzf#run(extend({
                \ 'source': results,
                \ 'sink*': function('s:fzf_quickfix_accept'),
                \ 'options': options
                \ }, deepcopy(get(g:, 'fzf_layout', {'down': '~30%'}))), 0)
endfunction
