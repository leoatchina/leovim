nnoremap SS :call textobj#viw()<Cr>
if pack#installed("vim-textobj-user")
    call textobj#user#plugin('line', {
                \   '-': {
                \     'select-a-function': 'textobj#current_lina_a',
                \     'select-a': 'ak',
                \     'select-i-function': 'textobj#current_line_i',
                \     'select-i': 'ik',
                \   },
                \ })
    vnoremap ik ^o$h
    onoremap ik :normal vik<Cr>
    vnoremap ak ^o$
    onoremap ak :normal vak<Cr>
    nmap <leader>vk vik
    nmap <leader>vK vak
    " find block
    let s:block_str = '^# In\[\d*\]\|^# %%\|^# STEP\d\+'
    " Block TextObj functions moved to utils.vim
    call textobj#user#plugin('block', {
                \ 'block': {
                \  'select-a-function': 'textobj#block_a',
                \  'select-a': 'av',
                \  'select-i-function': 'textobj#block_i',
                \  'select-i': 'iv',
                \  'region-type': 'V'
                \ },
                \ })
    nmap <leader>vv viv
    nmap <leader>vV vav
endif

