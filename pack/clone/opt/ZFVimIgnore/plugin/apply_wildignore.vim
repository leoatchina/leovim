
if !get(g:, 'ZFIgnore_apply_wildignore', 1)
    finish
endif

augroup ZFIgnore_apply_wildignore_augroup
    autocmd!
    autocmd User ZFIgnoreOnUpdate let &wildignore = join(ZFIgnoreToWildignore(ZFIgnoreGet(get(g:, 'ZFIgnoreOption_wildignore', {
                \   'bin' : 0,
                \   'common' : 1,
                \   'gitignore' : 1,
                \   'hidden' : 0,
                \   'media' : 0,
                \ }))), ',')
augroup END

