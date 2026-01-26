if utils#is_vscode()
    finish
endif
nnoremap <M-e><M-e> <C-w><C-w>
inoremap <M-e><M-e> <ESC><C-w><C-w>
xnoremap <M-e><M-e> <ESC><C-w><C-w>
if pack#installed('vim-floaterm-enhance') && exists('g:floaterm_ai_programs') && !empty(g:floaterm_ai_programs) && type(g:floaterm_ai_programs) == type([])
    tnoremap <M-e><M-e> <C-\><C-n><C-w><C-w>
    " start or cr
    nnoremap <silent><M-e><M-r> :FloatermAiStart<Cr>
    nnoremap <silent><M-e>r :FloatermAiStart!<Cr>
    nnoremap <silent><M-e><Cr> :FloatermAiSendCr<Cr>
    " send, NOTE ! means start in curr editing buffer
    nnoremap <silent><M-e><BS> :FloatermAiSendLineRange!<Cr>
    nnoremap <silent><M-e>l    :FloatermAiSendLineRange<Cr>
    xnoremap <silent><M-e><BS> :FloatermAiSendLineRange!<Cr>
    xnoremap <silent><M-e>l    :FloatermAiSendLineRange<Cr>
    nnoremap <silent><M-e>=    :FloatermAiSendFile!<Cr>
    nnoremap <silent><M-e>f    :FloatermAiSendFile<Cr>
    nnoremap <silent><M-e>-    :FloatermAiSendDir!<Cr>
    nnoremap <silent><M-e>d    :FloatermAiSendDir<Cr>
    nnoremap <silent><M-e>0    :FloatermAiFzfFiles!<Cr>
    nnoremap <silent><M-e>i    :FloatermAiFzfFiles<Cr>
endif
if pack#installed('opencode.nvim')
    lua require('cfg/opencode')
endif
