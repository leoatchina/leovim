let g:fern_disable_startup_warnings = 1
PlugAddOpt 'vim-fern'
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
" fern_open
function! s:fern_open(type) abort
    if a:type == 'cur'
        let l:dir = '.'
    elseif a:type == 'gitroot'
        let l:dir = GitRootDir()
    else
        let l:dir = GetRootDir()
    endif
    execute 'Fern ' .  l:dir . ' -drawer -stay -reveal=%:p'
endfunction
command! FernCur call s:fern_open('cur')
command! FernGitRoot call s:fern_open('gitroot')
command! FernGetRoot call s:fern_open('getroot')
nnoremap <leader>fn :Fern
nnoremap <silent><leader>fc :FernCur<Cr>
nnoremap <silent><leader>fg :FernGitRoot<Cr>
nnoremap <silent><leader>fr :FernGetRoot<Cr>
