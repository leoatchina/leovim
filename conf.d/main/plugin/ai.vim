if utils#is_vscode()
    finish
endif
if pack#installed('vim-floaterm-enhance') && exists('g:floaterm_ai_programs') && !empty(g:floaterm_ai_programs) && type(g:floaterm_ai_programs) == type([])
    nnoremap <silent><M-i>r    :FloatermAiStart!<Cr>
    nnoremap <silent><M-i>R    :FloatermAiStart<Cr>
    nnoremap <silent><M-i><Cr> :FloatermAiSendCr<Cr>
    " send
    nnoremap <silent><M-I>      :FloatermAiFzfFiles!<Cr>
    nnoremap <silent><M-i><M-i> :FloatermAiFzfFiles<Cr>
    nnoremap <silent><M-i>f :FloatermAiSendFile!<Cr>
    nnoremap <silent><M-i>F :FloatermAiSendFile<Cr>
    nnoremap <silent><M-i>d :FloatermAiSendDir!<Cr>
    nnoremap <silent><M-i>D :FloatermAiSendDir<Cr>
    xnoremap <silent><M-i>l :FloatermAiSendLineRange!<Cr>
    nnoremap <silent><M-i>l :FloatermAiSendLineRange!<Cr>
    xnoremap <silent><M-i>L :FloatermAiSendLineRange<Cr>
    nnoremap <silent><M-i>L :FloatermAiSendLineRange<Cr>
endif
