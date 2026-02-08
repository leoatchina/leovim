set autocomplete
set completeopt=popup,menuone,noselect
" ============================================================
" 点号后自动触发 omnifunc（如 os.path.isf）
" ============================================================
function! s:DotOmni() abort
    if &omnifunc == ''
        return
    endif
    " 如果已经在 omni 补全模式中，不要重复触发
    if pumvisible() && complete_info(['mode']).mode ==# 'omni'
        return
    endif
    let line = getline('.')->strpart(0, col('.') - 1)
    " 匹配多种成员访问操作符：. -> :: （支持更多语言）
    if line =~ '\%(\.\|->\|::\)\k*$'
        " 关闭已有菜单并立即触发 omni，一次性发送避免 autocomplete 抢占
        call feedkeys(pumvisible() ? "\<C-e>\<C-x>\<C-o>" : "\<C-x>\<C-o>", 'n')
    endif
endfunction

augroup DotOmni
    autocmd!
    autocmd TextChangedI *.py,*.lua,*.js,*.java,*.c,*.cpp call <SID>DotOmni()
augroup END

if pack#planned('vim-vsnip')
    set complete=.,w,b,u,o,k,Fvsnip#completefunc
    inoremap <expr> <Tab> vsnip#expandable() ? "\<Plug>(vsnip-expand)"
            \ : vsnip#jumpable(1) ? "\<Plug>(vsnip-jump-next)"
            \ : pumvisible() && complete_info().selected >= 0 ? "\<C-y>"
            \ : "\<Tab>"
    snoremap <expr> <Tab> vsnip#jumpable(1) ? "\<Plug>(vsnip-jump-next)" : "\<Tab>"
else
    set complete=.,w,b,u,o,k
    inoremap <expr> <Tab> pumvisible() && complete_info().selected >= 0 ? "\<C-y>" : "\<Tab>"
    snoremap <expr> <Tab> pumvisible() ? "\<C-y>" : "\<Tab>"
endif
