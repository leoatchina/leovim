let g:fern_disable_startup_warnings = 1
PlugAddOpt 'vim-fern'
nnoremap <leader>fn :Fern
nnoremap <leader>fr :Fern . -drawer -reveal=%<Cr>
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
