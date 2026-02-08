set autocomplete
set complete=.^5,o^5,t^5,k^5,w^5,b^5,u^5

function! builtin#autoomni() abort
    " 1. popup 已存在 → 不干扰
    if pumvisible()
        return
    endif
    " 2. 正在触发中 → 防止递归
    if g:auto_omni_busy
        return
    endif
    " 3. 光标前不是字母/数字 → 不触发
    if col('.') <= 1 || getline('.')[col('.') - 2] !~ '\k'
        return
    endif
    " 4. 标记忙碌
    let b:auto_omni_busy = v:true
    " 5. 延迟触发 omni（关键）
    call timer_start(20, {-> execute("call feedkeys(\"\\<C-x>\\<C-o>\", 'n')")})
    " 6. 解除锁（再延迟一点）
    call timer_start(50, {-> execute("let b:auto_omni_busy = v:false")})
endfunction

augroup AutoOmni
    autocmd!
    autocmd TextChangedP *.py,*.lua,*.js,*.java,*.vim,*.c,*.cpp call builtin#autoomni()
augroup END

inoremap <expr> <Tab> pumvisible() && complete_info().selected >= 0 ? "\<C-y>" : "\<Tab>"
