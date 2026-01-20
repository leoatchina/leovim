if utils#is_vscode() || !pack#installed('vim-floaterm-enhance') || !exists('g:floaterm_ai_programs') || empty('g:floaterm_ai_programs')
    finish
endif
nnoremap <silent><M-i>r :FloatermAiStart<Cr>
nnoremap <silent><M-i><Cr> FloatermAiSendCrOrStart<Cr>
" send
nnoremap <silent><M-i>f     FloatermAiSendFile<Cr>
nnoremap <silent><M-i><M-f> FloatermAiSendFile!<Cr>
nnoremap <silent><M-i>d     FloatermAiSendDir<Cr>
nnoremap <silent><M-i><M-d> FloatermAiSendDir!<Cr>
nnoremap <silent><M-i>l     FloatermAiSendLineRange<Cr>
xnoremap <silent><M-i>l     FloatermAiSendLineRange<Cr>
nnoremap <silent><M-i><M-l> FloatermAiSendLineRange!<Cr>
xnoremap <silent><M-i><M-l> FloatermAiSendLineRange!<Cr>
nnoremap <silent><M-I>      FloatermAiFzfFiles<Cr>
nnoremap <silent><M-i><M-i> FloatermAiFzfFiles!<Cr>
