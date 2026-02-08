set autocomplete
set completeopt=popup,menuone,noselect
" ============================================================
" 点号后自动触发 omnifunc（如 os.path.isf）
" ============================================================
function! s:DotOmniComplete(timer) abort
    if mode() !=# 'i' || &omnifunc == ''
        return
    endif
    " Step 1: call omnifunc(1, '') to get the start column
    let start = call(&omnifunc, [1, ''])
    if start < 0
        return
    endif
    " Step 2: extract base text (chars typed after the dot)
    let base = getline('.')[start : col('.') - 2]
    " Step 3: call omnifunc(0, base) to get completion items
    let items = call(&omnifunc, [0, base])
    if type(items) == v:t_dict
        let items = get(items, 'words', [])
    endif
    if empty(items)
        return
    endif
    " Step 4: suppress autocomplete and show omni results via complete()
    set noautocomplete
    call complete(start + 1, items)
endfunction

function! s:DotOmni() abort
    if &omnifunc == ''
        return
    endif
    let line = getline('.')->strpart(0, col('.') - 1)
    if line =~ '\%(\.\|->\|::\)$'
        " Delay to let Vim finish processing input events
        call timer_start(50, function('s:DotOmniComplete'))
    endif
endfunction

augroup DotOmni
    autocmd!
    autocmd TextChangedI *.py,*.lua,*.js,*.java,*.c,*.cpp call <SID>DotOmni()
    " Restore autocomplete after completion is done
    autocmd CompleteDone * if !&autocomplete | set autocomplete | endif
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
