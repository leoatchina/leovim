let g:Lf_ShortcutF = '<leader>fp'
let g:Lf_RootMarkers  = g:root_patterns
let g:Lf_DefaultMode  = 'Regex'
let g:Lf_ReverseOrder = 0
let g:Lf_NoChdir      = 1
let g:Lf_QuickSelect  = 0
let g:Lf_PythonVersion = get(g:, 'Lf_PythonVersion', float2nr(g:python_version))
let g:Lf_WorkingDirectoryMode = 'AF'
" icons
if utils#is_installed('nvim-web-devicons') || utils#is_installed('vim-devicons')
    let g:Lf_ShowDevIcons = 1
else
    let g:Lf_ShowDevIcons = 0
endif
" popup
if g:has_popup_floating
    highlight Lf_hl_popupBorder guifg=#ffffff guibg=#021316
    let g:Lf_WindowPosition = 'popup'
    let g:Lf_PopupColorscheme = 'default'
    let g:Lf_PopupShowBorder = 1
    let g:Lf_PopupBorders = ["â”€","â”?,"â”€","â”?,"â”?,"â”?,"â”?,"â”?]
    let g:Lf_PopupHeight    = 0.7
    let g:Lf_PreviewInPopup = 1
    function s:Lf_Preview_Position()
        if &columns > &lines * 3
            let g:Lf_PopupWidth = 0.5
            let g:Lf_PopupPosition = [12, 0]
            let g:Lf_PopupPreviewPosition = 'right'
        else
            let g:Lf_PopupWidth = 0.8
            let g:Lf_PopupPosition = [20, 0]
            let g:Lf_PopupPreviewPosition = 'top'
        endif
    endfunction
    call s:Lf_Preview_Position()
    au VimResized * call s:Lf_Preview_Position()
else
    let g:Lf_PreviewPosition = 'top'
    let g:Lf_WindowPosition = 'bottom'
endif
let g:Lf_PreviewResult = {
            \ 'Buffer': 1,
            \ 'Tab': 1,
            \ 'Colorscheme': 1,
            \ 'File': 1,
            \ 'Mru': 1,
            \ 'Rg': 1,
            \ 'Function': 1,
            \ 'Line': 1,
            \ 'BufTag': 1,
            \ 'Tag': 1,
            \ 'Gtags': 1,
            \ }
function! s:ZFIgnore_LeaderF()
    let ignore = ZFIgnoreGet()
    let g:Lf_WildIgnore = {'file' : ignore['file'], 'dir' : ignore['dir'] + g:root_patterns}
endfunction
autocmd User ZFIgnoreOnUpdate call s:ZFIgnore_LeaderF()
" command_map
let g:Lf_CommandMap = {
            \ '<C-p>': ['<C-g>'],
            \ '<C-f>': ['<C-e>'],
            \ '<BS>': ['<BS>', '<C-h>'],
            \ '<Up>': ['<C-p>'],
            \ '<Down>': ['<C-n>'],
            \ '<C-Up>': ['<Up>', '<C-b>'],
            \ '<C-Down>': ['<Down>', '<C-f>'],
            \ '<C-v>': ['<C-v>', '<C-y>'],
            \ '<ESC>': ['<ESC>', '<C-c>', '<C-a>'],
            \ }
let g:Lf_NormalCommandMap = {
            \ "*":{
            \   "v": "<C-]>",
            \   "x": "<C-x>",
            \   "t": "<C-t>"
            \ },
            \ "File": {
            \   "q": "<Esc>",
            \   "a": "<C-A>",
            \   "<Esc>": "<C-W>"
            \ },
            \ "Buffer": {},
            \ "Mru":    {},
            \ "Tag":    {},
            \ "BufTag": {},
            \ "Function": {},
            \ "Line":   {},
            \ "History":{},
            \ "Help":   {},
            \ "Rg":     {},
            \ "Gtags":  {},
            \ "Colorscheme": {}
            \ }
" gtags
let g:Lf_Gtags = 'gtags'
let g:Lf_Global = "global"
