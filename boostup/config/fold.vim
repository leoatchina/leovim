" basic fold
nmap <leader>za za
nmap <Tab>za    zA
nmap <leader>zz zfi{
nmap <Tab>zz    zfa{
nmap <leader>zi zfii
nmap <Tab>zi    zfai
nmap <leader>zc zfic
nmap <Tab>zc    zfac
nmap <leader>zf zfif
nmap <Tab>zf    zfaf
nmap <leader>zb zfiB
nmap <Tab>zb    zfaB
" fold search results
nnoremap <silent><leader>z/ :setlocal foldexpr=(getline(v:lnum)=~@/)?0:(getline(v:lnum-1)=~@/)\\|\\|(getline(v:lnum+1)=~@/)?1:2 foldmethod=expr foldlevel=0 foldcolumn=2<CR>:set foldmethod=manual<CR><CR>
" ufo
if Installed('nvim-ufo')
    if InstalledAdvCompEng()
        lua require('ufo').setup()
    elseif Installed('nvim-treesitter')
        lua require('ufo').setup({provider_selector = function(bufnr, filetype, buftype) return {'treesitter', 'indent'} end })
    else
        lua require('ufo').setup({provider_selector = function(bufnr, filetype, buftype) return {''} end })
    endif
endif
nmap <leader>zm zm
nmap <Tab>zm zM
nmap <leader>zr zr
nmap <Tab>zr zR
