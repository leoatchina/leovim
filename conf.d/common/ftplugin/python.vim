setlocal commentstring=#\ %s
au BufWritePre <buffer> :%retab
if Installed('vim-quickui')
    au BufNew,BufEnter,BufNewFile,BufRead * nnoremap gx :call quickui#tools#python_help("")<Cr>
endif
inoremap <buffer>>> ->
inoremap <buffer>!! !=
inoremap <buffer><M-e> # %%
inoremap <buffer><M-d> # STEP
inoremap <buffer><M-m> # In[]<Left>
" 检测项目目录中的venv并设置Python路径
function! s:SetPython3Host()
    if exists("g:python3_host_prog")
        return
    endif
    let l:root_dir = GetRootDir()
    let l:venv_path = ''
    " set names
    let l:venv_names = ['venv', '.venv', 'env', '.env']
    for l:venv_name in l:venv_names
        let l:possible_venv = l:root_dir . '/' . l:venv_name
        if isdirectory(l:possible_venv)
            let l:venv_path = l:possible_venv
            break
        endif
    endfor
    " 如果找到venv目录，设置Python路径
    if !empty(l:venv_path)
        " 根据操作系统选择正确的Python可执行文件路径
        if has('win32') || has('win64')
            let l:python_exe = l:venv_path . '/Scripts/python.exe'
        else
            let l:python_exe = l:venv_path . '/bin/python'
        endif
        " 确认可执行文件存在
        if filereadable(l:python_exe)
            " 设置vim的Python路径
            let g:python3_host_prog = l:python_exe
            " 如果使用ALE等lint工具，也可以设置它们的Python路径
            let g:ale_python_pylint_executable = l:python_exe
            let g:ale_python_flake8_executable = l:python_exe
            call preview#cmdmsg("Set g:python3_host_prog to " . g:python3_host_prog, 1)
        endif
    elseif executable('python3')
        let g:python3_host_prog = exepath('python3')
    endif
endfunction
" 当打开Python文件时自动调用
command! SetPython3Host call s:SetPython3Host()
nnoremap <buffer><silent><M-M> :SetPython3Host<Cr>
