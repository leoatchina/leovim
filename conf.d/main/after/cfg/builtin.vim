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
    let ft = &filetype
    let trigger = 0
    " 默认：匹配 obj. 或 obj.prop（要求点号前有标识符，避免 .class 误触发）
    if line =~ '\k\+\.\k*$'
        let trigger = 1
    endif
    " C/C++：额外支持 ptr-> 与 ns:: 形式
    if !trigger && ft =~# '^\%(c\|cpp\|objc\|objcpp\)$' && line =~ '\k\+\%(->\|::\)\k*$'
        let trigger = 1
    endif
    " Lua/Vim：额外支持 method: 形式
    if !trigger && ft =~# '^\%(lua\|vim\)$' && line =~ '\k\+:\k*$'
        let trigger = 1
    endif
    if trigger
        " 关闭已有菜单并立即触发 omni，一次性发送避免 autocomplete 抢占
        call feedkeys(pumvisible() ? "\<C-e>\<C-x>\<C-o>" : "\<C-x>\<C-o>", 'n')
    endif
endfunction

augroup DotOmni
    autocmd!
    autocmd TextChangedI *.py,*.lua,*.vim,*.sh,*.bash,*.zsh,*.rb,*.pl,*.c,*.h,*.cpp,*.hpp,*.cc,*.hh,*.html,*.htm,*.xhtml,*.xml,*.css,*.js,*.ts,*.json,*.sql,*.tex call <SID>DotOmni()
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
