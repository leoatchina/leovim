" Paste
command! -range FzfRegisterPasteV call fzf#run(fzf#wrap('registers', {
            \ 'source': fzf#registers#source(),
            \ 'sink': function('fzf#registers#paste', {'visual': 1, 'paste': 'P'}),
            \ 'options': '--ansi -x --prompt "PasteV>"'
            \ }), 0)
command! FzfRegisterPaste call fzf#run(fzf#wrap('registers', {
            \ 'source': fzf#registers#source(),
            \ 'sink': function('fzf#registers#paste', {'visual': 0, 'paste': 'P'}),
            \ 'options': '--ansi -x --prompt "Paste>"'
            \ }), 0)

" Yank
command! -range FzfRegisterYankV call fzf#run(fzf#wrap('yank', {
            \ 'source': fzf#registers#source(1),
            \ 'sink': function('fzf#registers#yank', {'visual': 1}),
            \ 'options': '--ansi -x --prompt "YankV>"'
            \ }), 0)

command! -nargs=1 FzfRegisterYank call fzf#run(fzf#wrap('yank', {
            \ 'source': fzf#registers#source(1),
            \ 'sink': function('fzf#registers#yank', {'visual': 0, 'action': <q-args>}),
            \ 'options': '--ansi -x --prompt "Yank>"'
            \ }), 0)
