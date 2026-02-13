if utils#is_vscode()
    finish
endif
nnoremap <M-i><M-i> <C-w><C-w>
xnoremap <M-i><M-i> <ESC><C-w><C-w>
if pack#installed('vim-floaterm-enhance') && exists('g:floaterm_ai_programs') && !empty(g:floaterm_ai_programs) && type(g:floaterm_ai_programs) == type([])
    tnoremap <M-i><M-i> <C-\><C-n><C-w><C-w>
    " start or cr
    nnoremap <silent><M-i><M-r>   :FloatermAiStart<Cr>
    nnoremap <silent><M-i><Cr>    :FloatermAiStart!<Cr>
    nnoremap <silent><M-i><Space> :FloatermAiSendCr<Cr>
    " send, NOTE ! means start in curr editing buffer
    nnoremap <silent><M-i>l :FloatermAiSendLine<Cr>
    xnoremap <silent><M-i>l :FloatermAiSendLine<Cr>
    nnoremap <silent><M-i>f :FloatermAiSendFile<Cr>
    nnoremap <silent><M-i>d :FloatermAiSendDir<Cr>
    nnoremap <silent><M-i>p :FloatermAiFzfFiles<Cr>
    nnoremap <silent><M-i><M-l> :FloatermAiSendLine!<Cr>
    xnoremap <silent><M-i><M-l> :FloatermAiSendLine!<Cr>
    nnoremap <silent><M-i><M-f> :FloatermAiSendFile!<Cr>
    nnoremap <silent><M-i><M-d> :FloatermAiSendDir!<Cr>
    nnoremap <silent><M-i><M-p> :FloatermAiFzfFiles!<Cr>
endif
if pack#installed('opencode.nvim')
    lua require('cfg/opencode')
endif
