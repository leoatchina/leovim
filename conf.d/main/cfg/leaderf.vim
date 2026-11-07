let g:Lf_ShortcutF = '<leader>fp'
let g:Lf_RootMarkers  = g:root_patterns
let g:Lf_DefaultMode  = 'Regex'
let g:Lf_ReverseOrder = 0
let g:Lf_NoChdir      = 1
let g:Lf_QuickSelect  = 0
let g:Lf_PythonVersion = get(g:, 'Lf_PythonVersion', float2nr(g:python_version))
let g:Lf_WorkingDirectoryMode = 'AF'
" icons
if pack#installed('nvim-web-devicons') || pack#installed('vim-devicons')
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
    let g:Lf_PopupBorders = ["─","│","─","│","┌","┐","┘","└"]
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
let g:Lf_Global = "global"
let g:Lf_Gtags = "gtags"

" --------------------------
" leaderf search commands (moved from plugin/search.vim)
" --------------------------
if executable('rg')
    let g:Lf_DefaultExternalTool = "rg"
    " LeaderfLast
    nnoremap <nowait><C-f>. :Leaderf rg --recal<Cr>
    " next/previous
    nnoremap <nowait><C-f>; :Leaderf rg --next<Cr>
    nnoremap <nowait><C-f>, :Leaderf rg --previous<Cr>
    " C-f map in bottom
    nnoremap <nowait><C-f>e :Leaderf rg --bottom --no-ignore -L -S -e --cword
    xnoremap <nowait><C-f>e :<C-u>Leaderf rg --bottom --no-ignore -L -S -e "<C-r>=utils#get_visual()<Cr>"
    nnoremap <nowait><C-f>b :Leaderf rg --bottom --no-ignore -L -S --all-buffers --cword
    xnoremap <nowait><C-f>b :<C-u>Leaderf rg --bottom --no-ignore -L -S --all-buffers "<C-r>=utils#get_visual()<Cr>"
    nnoremap <nowait><C-f>w :Leaderf rg --bottom --no-ignore -L -S -w --cword
    xnoremap <nowait><C-f>w :<C-u>Leaderf rg --bottom --no-ignore -L -S -w "<C-r>=utils#get_visual()<Cr>"
    nnoremap <nowait><C-f>f :Leaderf rg --bottom --no-ignore -L -S -F --cword
    xnoremap <nowait><C-f>f :<C-u>Leaderf rg --bottom --no-ignore -L -S -F "<C-r>=utils#get_visual()<Cr>"
    nnoremap <nowait><C-f>x :Leaderf rg --bottom --no-ignore -L -S -x --cword
    xnoremap <nowait><C-f>x :<C-u>Leaderf rg --bottom --no-ignore -L -S -x "<C-r>=utils#get_visual()<Cr>"
    nnoremap <nowait><C-f>a :Leaderf rg --bottom --no-ignore --append --cword
    xnoremap <nowait><C-f>a :<C-u>Leaderf rg --bottom --no-ignore --append "<C-r>=utils#get_visual()<Cr>"
    nnoremap <nowait><C-f>i :LeaderfRgInteractive<Cr>
    let g:Lf_RgConfig = [
                \ "--max-columns=10000",
                \ "--glob=!{.git,.svn,.hg,.project,.vscode,.idea,.vim}",
                \ "--hidden"
                \ ]
    let g:Lf_RgStorePattern = "e"
    nnoremap <C-f><Tab> :Leaderf rg --no-ignore<Space>
    function! s:todo_note(string, ...)
        let string = a:string[1:-2]
        let lst = split(string, "\|")
        call map(lst, 'v:val . ":"')
        call map(lst, '"\"" . v:val . "\""')
        let cmd = "Leaderf rg -e " . join(lst, " -e ")
        " NOTE:  --wd-mode=F means 'local only'
        if a:0 && a:1
            let cmd .= ' --wd-mode=F'
        endif
        execute cmd
    endfunction
    command! LeaderfTODO call s:todo_note(g:todo_patterns, 0)
    command! LeaderfNOTE call s:todo_note(g:note_patterns, 0)
    command! LeaderfTodo call s:todo_note(g:todo_patterns, 1)
    command! LeaderfNote call s:todo_note(g:note_patterns, 1)
    nnoremap <nowait><C-f>t :LeaderfTODO<Cr>
    nnoremap <nowait><C-f>n :LeaderfNOTE<Cr>
    nnoremap <nowait><C-f>T :LeaderfTodo<Cr>
    nnoremap <nowait><C-f>N :LeaderfNote<Cr>
    " leaderf_search
    function! s:leaderf_search(...) abort
        let cmd = 'Leaderf rg --no-ignore --bottom -L -S '
        " NOTE: a:1 == 'local only'
        if a:0 >= 2 && a:000[-1] == 1
            let cmd = cmd . ' --wd-mode=f'
            let cmd = cmd . ' ' . join(a:000[:-2])
        elseif a:0
            let cmd = cmd . ' ' . join(a:000)
        endif
        exec cmd
    endfunction
    command! -nargs=* -complete=dir LeaderfSearch call s:leaderf_search(<f-args>, 1)
    command! -nargs=* LeaderfSearchAll call s:leaderf_search(<f-args>)
    " map LeaderfSearch
    let g:search_all_cmd = 'LeaderfSearchAll'
    nnoremap <nowait><C-f>/ :LeaderfSearchAll <C-r><C-w><Cr>
    xnoremap <nowait><C-f>/ :<C-u>LeaderfSearchAll <C-r>=utils#get_visual()<Cr><Cr>
    nnoremap <nowait><C-f>\ :LeaderfSearchAll <C-r><C-w>
    xnoremap <nowait><C-f>\ :<C-u>LeaderfSearchAll <C-r>=utils#get_visual()<Cr>
    nnoremap <nowait><C-f>? :Leaderf rg --no-ignore --auto-preview -L -S <C-r>=@"<Cr>
    nnoremap <nowait><C-f><Cr> :LeaderfSearch <C-r><C-w><Cr>
    xnoremap <nowait><C-f><Cr> :<C-u>LeaderfSearch <C-r>=utils#get_visual()<Cr><Cr>
    nnoremap <nowait><C-f><C-f> :LeaderfSearch <C-r><C-w>
    xnoremap <nowait><C-f><C-f> :<C-u>LeaderfSearch <C-r>=utils#get_visual()<Cr>
    " flygrep
    nnoremap <nowait><C-f>] :Leaderf rg --no-ignore --auto-preview -L -S --cword<Cr>
    xnoremap <nowait><C-f>] :<C-u>Leaderf rg --no-ignore --auto-preview -L -S "<C-r>=utils#get_visual()<Cr>"<Cr>
    nnoremap <nowait><C-f><C-]> :Leaderf rg --no-ignore --auto-preview -L -S --wd-mode=f --cword<Cr>
    xnoremap <nowait><C-f><C-]> :<C-u>Leaderf rg --no-ignore --auto-preview -L -S --wd-mode=f "<C-r>=utils#get_visual()<Cr>"<Cr>
endif
