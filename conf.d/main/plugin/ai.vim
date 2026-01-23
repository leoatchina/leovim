if utils#is_vscode()
    finish
endif
if pack#installed('vim-floaterm-enhance') && exists('g:floaterm_ai_programs') && !empty(g:floaterm_ai_programs) && type(g:floaterm_ai_programs) == type([])
    nnoremap <silent><M-e>r     :FloatermAiStart!<Cr>
    nnoremap <silent><M-e><Tab> :FloatermAiStart<Cr>
    nnoremap <silent><M-e><Cr>  :FloatermAiSendCr<Cr>
    " send
    nnoremap <silent><M-e><M-l> :FloatermAiSendLineRange!<Cr>
    nnoremap <silent><M-e>l     :FloatermAiSendLineRange<Cr>
    xnoremap <silent><M-e><M-l> :FloatermAiSendLineRange!<Cr>
    xnoremap <silent><M-e>l     :FloatermAiSendLineRange<Cr>
    nnoremap <silent><M-e><M-f> :FloatermAiSendFile!<Cr>
    nnoremap <silent><M-e>f     :FloatermAiSendFile<Cr>
    nnoremap <silent><M-e><M-d> :FloatermAiSendDir!<Cr>
    nnoremap <silent><M-e>d     :FloatermAiSendDir<Cr>
    nnoremap <silent><M-e><M-e> :FloatermAiFzfFiles!<Cr>
    nnoremap <silent><M-e>e     :FloatermAiFzfFiles<Cr>
endif
