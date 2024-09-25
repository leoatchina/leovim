set foldenable
set foldlevel=99
set foldlevelstart=99
" basic fold
nmap <leader>za za
nmap ,za zA
nmap <leader>zz zfi{
nmap ,zz zfa{
nmap <leader>zi zfii
nmap ,zi zfai
nmap <leader>zc zfic
nmap ,zc zfac
nmap <leader>zf zfif
nmap ,zf zfaf
nmap <leader>zb zfiB
nmap ,zb zfaB
" ufo
if Installed('nvim-ufo')
    if Installed('nvim-treesitter') || AdvCompEngine()
        lua vim.keymap.set('n', 'ZO', require('ufo').openAllFolds)
        lua vim.keymap.set('n', 'ZC', require('ufo').closeAllFolds)
        if Installed('nvim-treesitter')
            lua require('ufo').setup({provider_selector = function(bufnr, filetype, buftype) return {'treesitter', 'indent'} end })
        else
            lua require('ufo').setup()
        endif
    else
        lua require('ufo').setup({provider_selector = function(bufnr, filetype, buftype) return {''} end })
    endif
endif
" fold search results only
nnoremap <silent>z/ :setlocal foldexpr=(getline(v:lnum)=~@/)?0:(getline(v:lnum-1)=~@/)\\|\\|(getline(v:lnum+1)=~@/)?1:2 foldmethod=expr foldlevel=0 foldcolumn=2<CR>:set foldmethod=manual<CR><CR0
