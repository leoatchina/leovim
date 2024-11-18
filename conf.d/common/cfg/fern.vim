let g:fern_disable_startup_warnings = 1
PlugAddOpt 'vim-fern'
nnoremap <leader>fn :Fern
nnoremap <leader>fr :Fern . -drawer -reveal=%<Cr>
nnoremap <leader>fo :Fern . -opener=tabedit<Cr>
" icons
let g:fern#renderer = "nerdfont"
PlugAddOpt 'vim-nerdfont'
PlugAddOpt 'vim-glyph-palette'
PlugAddOpt 'vim-fern-renderer-nerdfont'
augroup my-glyph-palette
    autocmd! *
    autocmd FileType fern,startify call glyph_palette#apply()
augroup END
" enhance
PlugAddOpt 'vim-fern-git-status'
PlugAddOpt 'vim-fern-hijack'
" ---------------
" 3rd plugins
" ---------------
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
PlugAddOpt 'fern-preview.vim'
