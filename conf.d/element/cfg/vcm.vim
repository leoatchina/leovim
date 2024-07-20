vim9script
g:vimcomplete_tab_enable = 0
var options = {
    showSource: true,
    alwaysOn: false,
    completor: { shuffleEqualPriority: true, postfixHighlight: true },
    buffer: { enable: true, priority: 10, urlComplete: true, envComplete: true },
    abbrev: { enable: true, priority: 10 },
    omnifunc: { enable: true, priority: 8},
    vsnip: { enable: true, priority: 16 },
    vimscript: { enable: true, priority: 12 },
    lsp: { enable: false, priority: 10, maxCount: 5 },
    ngram: { enable: false, priority: 10 },
}
autocmd VimEnter,BufEnter * call g:VimCompleteOptionsSet(options)
