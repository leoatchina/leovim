set foldenable
set foldlevel=99
set foldlevelstart=99
" basic fold
nmap <leader>za za
nmap <Tab>za zA
nmap <leader>zz zfi{
nmap <Tab>zz zfa{
nmap <leader>zi zfii
nmap <Tab>zi zfai
nmap <leader>zc zfic
nmap <Tab>zc zfac
nmap <leader>zf zfif
nmap <Tab>zf zfaf
nmap <leader>zb zfiB
nmap <Tab>zb zfaB
" ufo
if Installed('nvim-ufo')
    lua vim.keymap.set('n', 'z<cr>', require('ufo').openAllFolds)
    lua vim.keymap.set('n', 'z<tab>', require('ufo').closeAllFolds)
    if Installed('nvim-treesitter')
        lua require('ufo').setup({provider_selector = function(bufnr, filetype, buftype) return {'treesitter', 'indent'} end })
    elseif AdvCompEngine()
        lua require('ufo').setup()
    else
        lua require('ufo').setup({provider_selector = function(bufnr, filetype, buftype) return {''} end })
    endif
endif
