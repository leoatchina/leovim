if utils#is_vscode()
    finish
endif
nnoremap <M-a><M-a> <C-w><C-w>
inoremap <M-a><M-a> <ESC><C-w><C-w>
xnoremap <M-a><M-a> <ESC><C-w><C-w>
if pack#installed('vim-floaterm-enhance') && exists('g:floaterm_ai_programs') && !empty(g:floaterm_ai_programs) && type(g:floaterm_ai_programs) == type([])
    tnoremap <M-a><M-a> <C-\><C-n><C-w><C-w>
    " start or cr
    nnoremap <silent><M-a><M-r> :FloatermAiStart<Cr>
    nnoremap <silent><M-a><M-i> :FloatermAiStart!<Cr>
    nnoremap <silent><M-a><Cr> :FloatermAiSendCr<Cr>
    " send, NOTE ! means start in curr editing buffer
    nnoremap <silent><M-a><BS> :FloatermAiSendLineRange!<Cr>
    nnoremap <silent><M-a>l    :FloatermAiSendLineRange<Cr>
    xnoremap <silent><M-a><BS> :FloatermAiSendLineRange!<Cr>
    xnoremap <silent><M-a>l    :FloatermAiSendLineRange<Cr>
    nnoremap <silent><M-a>=    :FloatermAiSendFile!<Cr>
    nnoremap <silent><M-a>f    :FloatermAiSendFile<Cr>
    nnoremap <silent><M-a>-    :FloatermAiSendDir!<Cr>
    nnoremap <silent><M-a>d    :FloatermAiSendDir<Cr>
    nnoremap <silent><M-a>0    :FloatermAiFzfFiles!<Cr>
    nnoremap <silent><M-a>i    :FloatermAiFzfFiles<Cr>
endif
if pack#installed('opencode.nvim')
    lua require('cfg/opencode')
endif
