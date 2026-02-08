set autocomplete
set complete=.^5,o^5,t^5,k^5,w^5,b^5,u^5
let g:auto_omni_busy = v:false
function! builtin#autoomni() abort
    " 1. popup 已存在 → 不干扰
    if pumvisible()
        return
    endif
    " 2. 正在触发中 → 防止递归
    if g:auto_omni_busy
        return
    endif
    " 3. omnifunc 未设置 → 不触发
    if &omnifunc == ''
        return
    endif
    " 4. 光标前不是字母/数字 → 不触发
    if col('.') <= 1 || getline('.')[col('.') - 2] !~ '\k'
        return
    endif
    " 5. 标记忙碌
    let g:auto_omni_busy = v:true
    " 6. 延迟触发 omni（关键）
    call timer_start(20, {-> execute("call feedkeys(\"\\<C-x>\\<C-o>\", 'n')")})
    " 7. 解除锁（再延迟一点）
    call timer_start(50, {-> execute("let g:auto_omni_busy = v:false")})
endfunction
augroup AutoOmni
    autocmd!
    autocmd TextChangedI *.py,*.lua,*.js,*.java,*.vim,*.c,*.cpp call builtin#autoomni()
augroup END
if pack#installed('vim-vsnip')
    set completefunc=vsnip#complete
    inoremap <expr> <Tab> vsnip#expandable() ? "\<Plug>(vsnip-expand)"
            \ : vsnip#jumpable(1) ? "\<Plug>(vsnip-jump-next)"
            \ : pumvisible() && complete_info().selected >= 0 ? "\<C-y>"
            \ : "\<Tab>"
    snoremap <expr> <Tab> vsnip#jumpable(1) ? "\<Plug>(vsnip-jump-next)" : "\<Tab>"
else
    inoremap <expr> <Tab> pumvisible() && complete_info().selected >= 0 ? "\<C-y>" : "\<Tab>"

    snoremap <expr> <Tab> pumvisible() ? "\<C-y>" : "\<Tab>"
endif
