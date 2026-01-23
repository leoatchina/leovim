if utils#is_vscode()
    finish
endif
nnoremap <M-e><M-e> <C-w><C-w>
inoremap <M-e><M-e> <ESC><C-w><C-w>
xnoremap <M-e><M-e> <ESC><C-w><C-w>
if pack#installed('vim-floaterm-enhance') && exists('g:floaterm_ai_programs') && !empty(g:floaterm_ai_programs) && type(g:floaterm_ai_programs) == type([])
    tnoremap <M-e><M-e> <C-\><C-n><C-w><C-w>
    " start or cr
    nnoremap <silent><M-e>r :FloatermAiStart!<Cr>
    nnoremap <silent><M-e>; :FloatermAiStart<Cr>
    nnoremap <silent><M-e><Cr> :FloatermAiSendCr<Cr>
    " send, NOTE ! means start in curr
    nnoremap <silent><M-e><M-l> :FloatermAiSendLineRange!<Cr>
    nnoremap <silent><M-e>l     :FloatermAiSendLineRange<Cr>
    xnoremap <silent><M-e><M-l> :FloatermAiSendLineRange!<Cr>
    xnoremap <silent><M-e>l     :FloatermAiSendLineRange<Cr>
    nnoremap <silent><M-e><M-f> :FloatermAiSendFile!<Cr>
    nnoremap <silent><M-e>f     :FloatermAiSendFile<Cr>
    nnoremap <silent><M-e><M-d> :FloatermAiSendDir!<Cr>
    nnoremap <silent><M-e>d     :FloatermAiSendDir<Cr>
    nnoremap <silent><M-e><M-F> :FloatermAiFzfFiles!<Cr>
    nnoremap <silent><M-e>F     :FloatermAiFzfFiles<Cr>
endif
