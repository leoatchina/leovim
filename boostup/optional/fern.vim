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
