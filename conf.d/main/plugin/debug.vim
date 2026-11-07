" Skip in VSCode environment
if utils#is_vscode()
    finish
endif
nnoremap - :call preview#errmsg("Please intalled debug plugins.")<Cr>
nnoremap _ -
if g:has_terminal == 0
    finish
endif
" ---------------------------------
" debug: load_json
" ---------------------------------
if pack#planned_fzf()
    function! debug#load_json(dap, ...)
        let dap = a:dap
        if a:0 && filereadable(a:1)
            let template_file = a:1
        else
            let template_file = ''
        endif
        if dap
            let json_file = fnamemodify(utils#get_root_dir() . '/.vim/dap.json', ':p')
            let json_dir = fnamemodify(utils#get_root_dir() . '/.vim', ':p')
            if !isdirectory(json_dir)
                try
                    call mkdir(json_dir, 'p')
                catch /.*/
                    call preview#errmsg('mkdir ' . json_dir . ' failed')
                    return
                endtry
            endif
        else
            let json_file = fnamemodify(utils#get_root_dir() . '/.vimspector.json', ':p')
        endif
        if filereadable(json_file)
            execute "tabe " . json_file
        else
            let json_dict = {}
            if dap
                let json_dict['version'] = "0.2.0"
                let json_dict['configurations'] = []
            else
                let json_dict['configurations'] = {}
            endif
            let json = json_encode(json_dict)
            call writefile(split(json, "\n"), json_file)
            execute "tabe " . json_file
            if executable('jq')
                execute '%!jq'
                w!
            endif
        endif
        if template_file != ''
            if &columns > &lines * 3
                execute "vsplit " . template_file
            else
                execute "split " . template_file
            endif
        endif
    endfunction
endif
" -----------------
" debug tool flag
" -----------------
if pack#planned('vimspector')
    let g:debug_tool = "vimspector"
elseif pack#installed_dap()
    let g:debug_tool = 'nvim-dap'
endif
" opened checkers shared with cfg/vimspector.vim and cfg/dap.vim
function! debug#vimspector_opened()
    return bufwinnr('vimspector.Variables') >= 0 || bufwinnr('vimspector.Watches') >= 0 || bufwinnr('vimspector.StackTrace') >= 0
endfunction
function! debug#dapui_opened()
    return bufwinnr("DAP Scopes") >= 0 || bufwinnr("DAP Watches") >= 0 || bufwinnr("DAP Stacks") >= 0
endfunction
" watch Variable
function! debug#watch() range
    if pack#installed('nvim-dap')
        if !debug#dapui_opened()
            call preview#errmsg("Please start nvim-dap session first.")
            return
        endif
    elseif pack#installed('vimspector')
        if !debug#vimspector_opened()
            call preview#errmsg("Please start vimspector session first.")
            return
        endif
    else
        call preview#errmsg("Could not watch")
    endif
    " Handle visual mode selection
    let l:selected_text = ''
    if mode() =~# "[vV\<C-v>]"
        let [line_start, column_start] = getpos("'<")[1:2]
        let [line_end, column_end] = getpos("'>")[1:2]
        let lines = getline(line_start, line_end)
        if empty(lines)
            call preview#errmsg("No text selected")
            return
        endif
        " Handle single line selection
        if line_start == line_end
            let l:selected_text = lines[0][column_start - 1 : column_end - 1]
        else
            " Handle multi-line selection
            let lines[-1] = lines[-1][: column_end - 1]
            let lines[0] = lines[0][column_start - 1:]
            let l:selected_text = join(lines, "\n")
        endif
    else
        " Handle normal mode (word under cursor)
        let l:selected_text = utils#expand('<cword>')
    endif
    " Trim whitespace
    let l:selected_text = utils#trim(l:selected_text)
    if !empty(l:selected_text)
        try
            if pack#installed('vimspector')
                call vimspector#AddWatch(l:selected_text)
            elseif pack#installed('nvim-dap')
                let cmd = "lua require'dapui'.elements.watches.add('" . substitute(l:selected_text, "'", "''", 'g') . "')"
                execute(cmd)
            endif
        catch
            call preview#errmsg("Failed to add watch for reason: " . v:exception)
        endtry
    else
        call preview#errmsg("No valid text to watch")
    endif
endfunction
command! -range WatchCword call debug#watch()
xnoremap - :WatchCword<CR>
nnoremap - :WatchCword<CR>
