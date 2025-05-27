" -----------------------------------
" choosewin
" -----------------------------------
PlugAddOpt 'vim-choosewin'
nmap <silent><Tab><Cr> <Plug>(choosewin)
" ---------------------------------------
" choose tab using fuzzy_findeer
" ---------------------------------------
if PlannedFzf()
    PlugAddOpt 'fzf-tabs'
    nnoremap <silent><Tab><Tab> :FzfTabs<Cr>
endif
" ------------------------
" tab control
" ------------------------
set showtabline=2
set tabpagemax=10
" Tab move
nnoremap <silent><Tab>n :tabm +1<CR>
nnoremap <silent><Tab>p :tabm -1<CR>
nnoremap <Tab><Space> :tabm<Space>
" move current buffer to tab
nnoremap <C-w><Cr> <C-w>T
" round current buffer
nnoremap <C-w><Tab> <C-w>r
" open window in tab
nnoremap <leader><Tab> :tabe<Space>
" ------------------------------------
" XXX: basic tab label function
" ------------------------------------
function! Vim_NeatBuffer(bufnr, fullname)
    let l:name = bufname(a:bufnr)
    if getbufvar(a:bufnr, '&modifiable')
        if l:name == ''
            return '[No Name]'
        else
            if a:fullname
                return fnamemodify(l:name, ':p')
            else
                return fnamemodify(l:name, ':t')
            endif
        endif
    else
        let l:buftype = getbufvar(a:bufnr, '&buftype')
        if l:buftype == 'quickfix'
            return '[Quickfix]'
        elseif l:name != ''
            if a:fullname
                return '-'.fnamemodify(l:name, ':p')
            else
                return '-'.fnamemodify(l:name, ':t')
            endif
        else
            return '[No Name]'
        endif
    endif
endfunc
function! Vim_NeatTabLabel(n, ...)
    if a:0 && a:1
        let active = 1
    else
        let active = 0
    endif
    let l:buflist = tabpagebuflist(a:n)
    let l:winnr = tabpagewinnr(a:n)
    let l:bufnr = l:buflist[l:winnr - 1]
    let l:label = Vim_NeatBuffer(l:bufnr, active)
    if getbufvar(l:bufnr, '&modified')
        let l:label .= ' +'
    endif
    return l:label
endfun
" ---------------------------------
" make tabline in terminal mode
" ---------------------------------
hi link TabNumSel Type
function! Vim_NeatTabLine()
    let s = ''
    let taball = tabpagenr('$')
    for i in range(taball)
        let nr = i + 1
        " set the tab page number (for mouse clicks)
        let s .= '%' . nr . 'T'
        " select the highlighting
        let tabcur = tabpagenr()
        if nr == tabcur
            let s .= '%#TabLineSel#'
            let s .= '%#TabNumSel# ' . nr . ' %#TabLineSel# ' .  get(b:, 'file_icon', '')
        else
            let s .= '%#TabLine# ' . nr . ' '
        endif
        if nr == tabcur -1 || nr == tabcur || nr == taball
            let s .= '%{Vim_NeatTabLabel(' . nr . ')} '
        else
            let s .= '%{Vim_NeatTabLabel(' . nr . ')} |'
        endif
    endfor
    " after the last tab fill with TabLineFill and reset tab page nr
    let s .= '%#TabLineFill#%T'
    " right-align the label to close the current tab page
    if taball > 1
        let s .= '%=%#TabLine#%999XX'
    endif
    return s
endfunction
set tabline=%!Vim_NeatTabLine()
" Re-apply the tabline after a colorscheme change
augroup TablineColorschemeFix
    autocmd!
    autocmd ColorScheme * set tabline=%!Vim_NeatTabLine()
augroup END
" ---------------------------------
" make tabline in GuiMode
" ---------------------------------
 if !has('nvim-0.11')
    function! Vim_NeatGuiTabLabel()
        let l:num = v:lnum
        let l:buflist = tabpagebuflist(l:num)
        let l:winnr = tabpagewinnr(l:num)
        let l:bufnr = l:buflist[l:winnr - 1]
        return Vim_NeatBuffer(l:bufnr, 0)
    endfunc
    set guitablabel=%{Vim_NeatGuiTabLabel()}
endif
" ---------------------------------
" make tabline in tabpanel
" ---------------------------------
if exists('&showtabpanel')
    function! Vim_GetMaxTabNameLength()
        let l:max_length = 0
        let l:taball = tabpagenr('$')
        for i in range(l:taball)
            let l:tabnr = i + 1
            let l:buflist = tabpagebuflist(l:tabnr)
            let l:winnr = tabpagewinnr(l:tabnr)
            let l:bufnr = l:buflist[l:winnr - 1]
            let l:caption = Vim_NeatBuffer(l:bufnr, 0)
            let l:name_length = strwidth(l:caption)
            if l:name_length > l:max_length
                let l:max_length = l:name_length
            endif
        endfor
        " Add some padding for tab number and brackets
        return l:max_length + 25
    endfunction

    function! Vim_NeatTabPanelText()
        let l:tabnr = g:actual_curtabpage
        let l:buflist = tabpagebuflist(l:tabnr)
        let l:winnr = tabpagewinnr(l:tabnr)
        let l:bufnr = l:buflist[l:winnr - 1]
        let l:caption = Vim_NeatBuffer(l:bufnr, 0)
        
        " Check if this is the current active tab
        let l:curtabnr = tabpagenr()
        if l:tabnr == l:curtabnr
            " Highlight active tab
            return "%#TabNumSel#[".l:tabnr."]%#TabLineSel# ".l:caption." %#TabLineSel#"
        else
            " Normal tab display
            return "%#TabLine#[".l:tabnr."]%#TabLine# ".l:caption." %#TabLine#"
        endif
    endfunc
    function! Vim_UpdateTabPanelWidth()
        if exists('&tabpanelwidth')
            try
                let l:width = Vim_GetMaxTabNameLength()
                " Set minimum and maximum width constraints
                let l:width = max([15, min([l:width, 50])])
                execute 'set tabpanelwidth=' . l:width
            catch
                " Silently ignore errors
            endtry
        endif
    endfunction
    set tabpanel=%!Vim_NeatTabPanelText()

    " Update tabpanel width when tabs change
    augroup TabPanelWidthUpdate
        autocmd!
        autocmd TabNew,TabEnter,BufEnter,BufWritePost * call Vim_UpdateTabPanelWidth()
    augroup END

    " Initial setup for tabpanel visibility
    au TabNew,TabLeave * if tabpagenr('$') > 9 && &columns > &lines * 3 | set showtabpanel=1 showtabline=0 | else | set showtabpanel=0 showtabline=1 | endif

    " Initialize the tabpanel width
    call Vim_UpdateTabPanelWidth()
endif
" --------------------------
" TabSwitch / close
" --------------------------
nnoremap <M-n> gt
nnoremap <M-p> gT
nnoremap <silent><M-1> :tabn1<Cr>
nnoremap <silent><M-2> :tabn2<Cr>
nnoremap <silent><M-3> :tabn3<Cr>
nnoremap <silent><M-4> :tabn4<Cr>
nnoremap <silent><M-5> :tabn5<Cr>
nnoremap <silent><M-6> :tabn6<Cr>
nnoremap <silent><M-7> :tabn7<Cr>
nnoremap <silent><M-8> :tabn8<Cr>
nnoremap <silent><M-9> :tabn9<Cr>
nnoremap <silent><M-0> :tablast<Cr>
nnoremap <silent>1<Tab> :tabn1<Cr>
nnoremap <silent>2<Tab> :tabn2<Cr>
nnoremap <silent>3<Tab> :tabn3<Cr>
nnoremap <silent>4<Tab> :tabn4<Cr>
nnoremap <silent>5<Tab> :tabn5<Cr>
nnoremap <silent>6<Tab> :tabn6<Cr>
nnoremap <silent>7<Tab> :tabn7<Cr>
nnoremap <silent>8<Tab> :tabn8<Cr>
nnoremap <silent>9<Tab> :tabn9<Cr>
nnoremap <silent>0<Tab> :tablast<Cr>
nnoremap <silent><M-w> :tabclose!<Cr>
nnoremap <silent><M-W> :tabonly!<Cr>
" Map in terminal
if g:has_terminal == 0
    finish
endif
tnoremap <M-n> <C-\><C-n>gt
tnoremap <M-p> <C-\><C-n>gT
tnoremap <silent><M-1> <C-\><C-n>:tabn1<Cr>
tnoremap <silent><M-2> <C-\><C-n>:tabn2<Cr>
tnoremap <silent><M-3> <C-\><C-n>:tabn3<Cr>
tnoremap <silent><M-4> <C-\><C-n>:tabn4<Cr>
tnoremap <silent><M-5> <C-\><C-n>:tabn5<Cr>
tnoremap <silent><M-6> <C-\><C-n>:tabn6<Cr>
tnoremap <silent><M-7> <C-\><C-n>:tabn7<Cr>
tnoremap <silent><M-8> <C-\><C-n>:tabn8<Cr>
tnoremap <silent><M-9> <C-\><C-n>:tabn9<Cr>
tnoremap <silent><M-0> <C-\><C-n>:tablast<Cr>
tnoremap <silent><M-w> <C-\><C-n>:tabclose!<Cr>
tnoremap <silent><M-W> <C-\><C-n>:tabonly!<Cr>
