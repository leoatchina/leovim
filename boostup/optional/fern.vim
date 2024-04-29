PlugAddOpt 'fern.vim'
nnoremap <leader>fn :Fern
nnoremap <leader>fr :Fern . -drawer -reveal=%<Cr>
nnoremap <leader>fo :Fern . -opener=tabedit<Cr>
" icons
let g:fern#renderer = "nerdfont"
PlugAddOpt 'nerdfont.vim'
PlugAddOpt 'glyph-palette.vim'
PlugAddOpt 'fern-renderer-nerdfont.vim'
augroup my-glyph-palette
    autocmd! *
    autocmd FileType fern,startify call glyph_palette#apply()
augroup END
" enhance
PlugAddOpt 'fern-git-status.vim'
PlugAddOpt 'fern-mapping-git.vim'
PlugAddOpt 'fern-hijack.vim'
PlugAddOpt 'fern-preview.vim'
" fern init
function! s:fern_init() abort
    nmap <silent><buffer> <Plug>(fern-action-open) <Plug>(fern-action-open:select)
    nmap <silent><buffer> <C-]> <Plug>(fern-action-open:vsplit)
    nmap <silent><buffer> <C-x> <Plug>(fern-action-open:split)
    nmap <silent><buffer> <C-t> <Plug>(fern-action-open:tabedit)
    " preview
    nmap <silent><buffer> P     <Plug>(fern-action-preview:toggle)
    nmap <silent><buffer> <C-p> <Plug>(fern-action-preview:auto:toggle)
    nmap <silent><buffer> <C-d> <Plug>(fern-action-preview:scroll:down:half)
    nmap <silent><buffer> <C-u> <Plug>(fern-action-preview:scroll:up:half)
    " smart close preview
    nmap <silent><buffer> q     <Plug>(fern-quit-or-close-preview)
    nmap <silent><buffer> Q     <Plug>(fern-quit-or-close-preview)
    nmap <silent><buffer> <M-q> <Plug>(fern-quit-or-close-preview)
    nmap <silent><buffer> <C-c> <Plug>(fern-quit-or-close-preview)
    nmap <silent><buffer> <expr><Plug>(fern-quit-or-close-preview) fern_preview#smart_preview("\<Plug>(fern-action-preview:close)", ":q\<CR>")
endfunction
augroup FernInit
    autocmd!
    autocmd FileType fern call s:fern_init()
augroup END
" ---------------
" fzf-fern
" ---------------
if UNIX()
    function! Fern_mapping_fzf_customize_option(spec)
        let a:spec.options .= ' --multi'
        " Note that fzf#vim#with_preview comes from fzf.vim
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
        execute "FernReveal -wait" a:dict.relative_path
        execute "normal \<Plug>(fern-action-mark:set)"
    endfunction
    let g:Fern_mapping_fzf_file_sink = function('s:reveal')
    let g:Fern_mapping_fzf_dir_sink = function('s:reveal')
    PlugAddOpt 'fern-mapping-fzf.vim'
endif
