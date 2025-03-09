let g:fern_disable_startup_warnings = 1
PlugAddOpt 'vim-fern'
" icons
let g:fern#renderer = "nerdfont"
PlugAddOpt 'vim-nerdfont'
PlugAddOpt 'vim-glyph-palette'
PlugAddOpt 'vim-fern-renderer-nerdfont'
augroup my-glyph-palette
    autocmd!
    autocmd FileType fern,startify call glyph_palette#apply()
augroup END
" enhance
PlugAddOpt 'vim-fern-git-status'
PlugAddOpt 'vim-fern-hijack'
" fern_open
function! s:fern_open(type, ...) abort
    let l:opts = get(a:, 1, {})
    if a:type == 'lcd'
        let l:dir = '.'
    elseif a:type == 'gitroot'
        let l:dir = GitRootDir()
    else
        let l:dir = GetRootDir()
    endif
    let l:cmd = 'Fern ' . l:dir
    if !has_key(l:opts, 'popup')
        let l:cmd .= ' -drawer -stay -reveal=%:p'
    endif
    execute l:cmd
endfunction
command! FernLCD call s:fern_open('lcd')
command! FernGitRoot call s:fern_open('gitroot')
command! FernGetRoot call s:fern_open('getroot')
nnoremap <leader>fn :Fern
nnoremap <silent><leader>fl :FernLCD<Cr>
nnoremap <silent><leader>fg :FernGitRoot<Cr>
nnoremap <silent><leader>fr :FernGetRoot<Cr>
" ---------------
" fzf
" ---------------
function! Fern_mapping_fzf_customize_option(spec)
    let a:spec.options .= ' --multi'
    if exists('*fzf#vim#with_preview')
        return fzf#vim#with_preview(a:spec)
    else
        return a:spec
    endif
endfunction
function! Fern_mapping_fzf_before_all(dict)
    if !len(a:dict.lines)
        return
    endif
    return a:dict.fern_helper.async.update_marks([])
endfunction
function! s:reveal(dict)
    execute "Fern . -opener=edit/split -stay -reveal=%:p"
    execute "normal \<Plug>(fern-action-mark:set)"
endfunction
let g:Fern_mapping_fzf_file_sink = function('s:reveal')
let g:Fern_mapping_fzf_dir_sink = function('s:reveal')
PlugAddOpt 'fern-mapping-fzf.vim'
" ---------------
" preview
" ---------------
function! s:fern_settings() abort
    nmap <silent> <buffer>p      <Plug>(fern-action-preview:toggle)
    nmap <silent> <buffer><C-p>  <Plug>(fern-action-preview:auto:toggle)
    nmap <silent> <buffer><C-f>  <Plug>(fern-action-preview:scroll:down:half)
    nmap <silent> <buffer><C-b>  <Plug>(fern-action-preview:scroll:up:half)
    nmap <silent> <buffer><expr> <Plug>(fern-quit-or-close-preview) fern_preview#smart_preview("\<Plug>(fern-action-preview:close)", ":q\<CR>")
    nmap <silent> <buffer>q      <Plug>(fern-quit-or-close-preview)
    nmap <silent> <buffer><M-q>  <Plug>(fern-quit-or-close-preview)
endfunction
augroup fern-settings
    autocmd!
    autocmd FileType fern call s:fern_settings()
augroup END
PlugAddOpt 'fern-preview.vim'
" --------------------
" fern explore
" --------------------
if g:has_popup_floating
    function! s:fern_explorer() abort
        let l:width = float2nr(&columns * 0.8)
        let l:height = float2nr(&lines * 0.8)
        let l:row = float2nr((&lines - l:height) / 2)
        let l:col = float2nr((&columns - l:width) / 2)
        let l:current_dir = AbsDir()
        if has('nvim')
            " Neovim: 使用floating window
            let l:floating_opts = {
                        \ 'relative': 'editor',
                        \ 'row': l:row,
                        \ 'col': l:col,
                        \ 'width': l:width,
                        \ 'height': l:height,
                        \ 'style': 'minimal',
                        \ 'border': 'rounded'
                        \ }
            let l:buf = nvim_create_buf(v:false, v:true)
            let l:win = nvim_open_win(l:buf, v:true, l:floating_opts)
            call s:fern_open('lcd', {'popup': 1})
        else
            " 创建一个新的buffer
            let l:popbuf = bufadd('')
            call bufload(l:popbuf)
            call setbufvar(l:popbuf, '&buftype', 'nofile')
            call setbufvar(l:popbuf, '&bufhidden', 'wipe')
            " 创建popup window
            let l:popup_opts = {
                        \ 'line': l:row,
                        \ 'col': l:col,
                        \ 'minwidth': l:width,
                        \ 'minheight': l:height,
                        \ 'title': ' Fern Explorer ',
                        \ 'border': [1,1,1,1],
                        \ 'padding': [0,1,0,1],
                        \ 'highlight': 'Normal',
                        \ 'borderhighlight': ['PopupBorder'],
                        \ 'scrollbar': 1,
                        \ 'close': 'button',
                        \ 'resize': 1,
                        \ 'drag': 1,
                        \ 'mapping': 0,
                        \ 'filter': 'popup_filter_yesno',
                        \ 'callback': {-> execute('bdelete! ' . l:popbuf)}
                        \ }
            let l:winid = popup_create(l:popbuf, l:popup_opts)
            call win_execute(l:winid, 'Fern ' . l:current_dir)
        endif
    endfunction
    command! FernExplorer call s:fern_explorer()
    nnoremap <silent><leader>fe :FernExplorer<Cr>
endif
