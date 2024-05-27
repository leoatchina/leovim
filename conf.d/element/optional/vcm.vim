vim9script
var options = {
    completor: { shuffleEqualPriority: true, postfixHighlight: true },
    buffer: { enable: true, priority: 10, urlComplete: true, envComplete: true },
    abbrev: { enable: true, priority: 10 },
    lsp: { enable: false, priority: 10, maxCount: 5 },
    omnifunc: { enable: true, priority: 8},
    vsnip: { enable: true, priority: 11 },
    vimscript: { enable: true, priority: 11 },
    ngram: {
        enable: true,
        priority: 10,
        bigram: false,
        filetypes: ['text', 'help', 'markdown'],
        filetypesComments: ['c', 'cpp', 'python', 'java'],
    },
}
autocmd VimEnter * g:VimCompleteOptionsSet(options)
