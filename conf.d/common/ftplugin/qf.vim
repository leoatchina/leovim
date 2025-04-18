setlocal nowrap
setlocal norelativenumber
setlocal foldcolumn=0 colorcolumn= cursorline
nnoremap <silent><buffer>q :q!<Cr>
nnoremap <silent><buffer>Q :q!<Cr>
nnoremap <silent><buffer>J <Nop>
nnoremap <silent><buffer>p <Nop>
nnoremap <silent><buffer>P <Nop>
nnoremap <silent><buffer><C-h> <Nop>
nnoremap <silent><buffer><M-c> <Nop>
nnoremap <silent><buffer><M-C> <Nop>
nnoremap <silent><buffer><M-.> <Nop>
nnoremap <silent><buffer><M-/> <Nop>
nnoremap <silent><buffer><M-?> <Nop>
nnoremap <silent><buffer><M-'> <Nop>
nnoremap <silent><buffer><M-"> <Nop>
" replace
nnoremap <buffer>r :cdo s/<C-r>=get(g:, 'grepper_word', '')<Cr>//gc<Left><Left><Left>
nnoremap <buffer>W :cfdo up
if Installed('nvim-bqf')
    nmap <silent><buffer>i zf
    nmap <silent><buffer>K :BqfToggle<Cr>
else
    nnoremap <silent><buffer><C-p> :PreviewQuickfix<Cr>
    nnoremap <silent><buffer><C-m> :PreviewQuickfix e<Cr>
    nnoremap <silent><buffer><C-g> :PreviewQuickfix e<Cr>:QuickfixClose<Cr>
    nnoremap <silent><buffer><C-]> :PreviewQuickfix vsplit<Cr>
    nnoremap <silent><buffer><C-x> :PreviewQuickfix split<Cr>
    nnoremap <silent><buffer><C-t> :PreviewQuickfix tabe<Cr>
    if Installed('vim-quickui')
        nnoremap <silent><buffer>K :call quickui#tools#preview_quickfix()<Cr>
        nnoremap <silent><buffer>n j:call quickui#tools#preview_quickfix()<Cr>
        nnoremap <silent><buffer>p k:call quickui#tools#preview_quickfix()<Cr>
        if exists('b:current_syntax')
            finish
        endif
        syn match	qfFileName	"^[^│]*" contains=qfLineNr
        syn match	qfSeparator	"│"
        syn match	qfLineNr	":\d*" contained
        " The default highlighting.
        hi def link qfFileName	Directory
        hi def link qfLineNr	LineNr
        hi def link qfSeparator	VertSplit
        let b:current_syntax = 'qf'
    else
        nnoremap <buffer>K <Nop>
    endif
endif
