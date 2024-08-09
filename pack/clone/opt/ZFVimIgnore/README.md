
# Intro

util to make `wildignore` and similars more friendly and easier to config

if you like my work, [check here](https://github.com/ZSaberLv0?utf8=%E2%9C%93&tab=repositories&q=ZFVim) for a list of my vim plugins,
or [buy me a coffee](https://github.com/ZSaberLv0/ZSaberLv0)

---

**NOTE:
by default, this plugin would recognize `.gitignore` and modify `wildignore`,
which may affect `expand()` `glob()` functions**
see [#1](https://github.com/ZSaberLv0/ZFVimIgnore/issues/1) for more info

---


# Usage

1. Install

    ```
    Plug 'ZSaberLv0/ZFVimIgnore'
    ```

1. make your plugin or configs adapt to ignore setting

    ```
    autocmd User ZFIgnoreOnUpdate let &wildignore = join(ZFIgnoreToWildignore(ZFIgnoreGet()), ',')
    autocmd User ZFIgnoreOnUpdate let g:NERDTreeIgnore = ZFIgnoreToRegexp(ZFIgnoreGet({
            \   'bin' : 0,
            \   'media' : 0,
            \ }))
    ```

    by default:

    * some common ignore are added
    * `.gitignore` under current dir and all parent dirs would be recognized
    * `wildignore` would be applied automatically

1. you may add or remove custom ignore at runtime

    ```
    :ZFIgnoreAdd *.obj
    :ZFIgnoreRemove build
    ```

    supported patterns:

    * see `:h wildcards`
    * supported: `?` `*` `[abc]`
    * not supported: `**` `*/`

    or completely enable or disable by `:ZFIgnoreToggle`


# Typical config

here are some typical config for other plugins

```
" vim-easygrep
autocmd User ZFIgnoreOnUpdate let g:EasyGrepFilesToExclude = join(ZFIgnoreToWildignore(ZFIgnoreGet()), ',')

" LeaderF
function! s:ZFIgnore_LeaderF()
    let ignore = ZFIgnoreGet()
    let g:Lf_WildIgnore = {'file' : ignore['file'], 'dir' : ignore['dir']}
endfunction
autocmd User ZFIgnoreOnUpdate call s:ZFIgnore_LeaderF()

" NERDTree
let g:NERDTreeIgnore = ZFIgnoreToRegexp(ZFIgnoreGet({
        \   'bin' : 0,
        \   'media' : 0,
        \ }))
```

# Ignore options

we have some builtin ignore options, and all of them are enabled by default:

* `bin` : binary files (`*.dll`, `*.so`, etc) and `bin` dir
* `common` : common files (swap file, build cache, etc)
* `gitignore` : according to `.gitignore` under `getcwd()` and all parent dir

    * the default `.gitignore` detect option can be specified by:

        ```
        let g:ZFIgnore_ignore_gitignore_detectOption = {
                \   'pattern' : '\.gitignore', // pattern of gitignore file
                \   'path' : '', // find for specified path, can be string or list
                \   'cur' : 1, // find for getcwd()
                \   'parent' : 1, // find in all parents until find one
                \   'parentRecursive' : 1, // find in all parents even if found one
                \   'callback' : function(), // func that return a list of gitignore file
                \ }
        ```

* `hidden` : hidden files (`.*`, `*?~`, `~?*`)
* `media` : common media files (`*.avi`, `*.jpg`, etc)

all currently registered option can be checked and modified by `g:ZFIgnoreOptionDefault`

you can also supply custom ignore options, see below


# For impl to extend ignore options

for impl:

```
" declare your option and default value
if !exists('g:ZFIgnoreOptionDefault')
    let g:ZFIgnoreOptionDefault = {}
endif
if !exists("g:ZFIgnoreOptionDefault['YourOptionName']")
    let g:ZFIgnoreOptionDefault['YourOptionName'] = 1
endif

" if the ignore item is simple
if !exists('g:ZFIgnoreData')
    let g:ZFIgnoreData = {}
endif
let g:ZFIgnoreData['YourImplName'] = {
        \   'common' : {
        \       'file' : {'*.obj':1, '*.bin':1},
        \       'dir' : {'build':1},
        \   },
        \   'YourOptionName' : {...},
        \ }

" if you want to implement more complex ignore detect at runtime
autocmd User ZFIgnoreOnSetup call YourSetup()
function! YourSetup()
    let g:ZFIgnoreData['YourImplName'] = {
            \   'common' : {
            \       'file' : {'*.obj':1, '*.bin':1},
            \       'dir' : {'build':1},
            \   },
            \   'YourOptionName' : {...},
            \ }
endfunction
```

for users:

```
" access ignore data as usual
let ignore = ZFIgnoreGet()

" or enable/disable by option name
let ignore = ZFIgnoreGet({'YourOptionName' : 1})

" or change default option
let g:ZFIgnoreOptionDefault['YourOptionName'] = 0
let ignore = ZFIgnoreGet()
```


# FAQ

* Q: `E40: Can't open errorfile`

    A: typically occur on Windows only,
    if you have many ignore items,
    the final command may be very long (`grep` for example),
    which may exceeds Windows' command line limit,
    see also:
    https://support.microsoft.com/en-us/help/830473/command-prompt-cmd-exe-command-line-string-limitation

    to resolve this, try use a temp file to store exclude pattern, for example

    * use `--exclude-from` (for GNU `grep` only)


* Q: files or dirs are accidently ignored, how to "ignore" some of ignore?

    A: you may use `g:ZFIgnoreFilter` to filter the final ignore setting

    ```
    function! s:myFilter(ignore)
        let i = len(a:ignore['dir']) - 1
        while i >= 0
            if a:ignore['dir'][i] == '.LfCache'
                call add(a:ignore['dir_filtered'], remove(a:ignore['dir'], i))
            endif
            let i -= 1
        endwhile
    endfunction

    if !exists('g:ZFIgnoreFilter')
        let g:ZFIgnoreFilter = {}
    endif
    let g:ZFIgnoreFilter['yourModuleName1'] = function('s:myFilter')
    let g:ZFIgnoreFilter['yourModuleName2'] = {
            \   'YourImplName' : {
            \     'file' : {
            \       '*.mp3' : 1,
            \       ...
            \     },
            \     'dir' : {
            \       '.LfCache' : 1,
            \       ...
            \     },
            \   },
            \   'OtherImplName' : {
            \     ...
            \   },
            \ }
    ```

    by default, for safety, these items are automatically filtered:

    * cwd and all of it's parent
    * `~`
    * special patterns like `.` or `*`
    * `rtp` (`:h rtp`)

    also, consider use the `nosuf` argument for `expand()` `glob()` and similar functions


* Q: how to check what pattern has matched?

    A: you may use `ZFIgnoreCheck(text, ...)` to check matched rules

    ```
    " param: {
    "   'option' : {...}, // optional, ZFIgnoreGet option if ignoreData not supply
    "   'ignoreData' : {...}, // optional, use specified ignoreData
    "   'fileRuleOnDir' : 1, // optional, whether apply 'file' rules on dir
    " }
    " return: {
    "   'text' : 'some_text', // original text used to match
    "   'list' : [ // empty if no match
    "     {
    "       'type' : 'file / dir', // what type of the rule matched
    "       'rule' : 'some_ignore_rule', // what ignore rule matched
    "       'matched' : 'some_text', // what part of the text matched the rule
    "       'filtered' : 'some_text', // what filter rule cause the ignroe being filtered, empty if not filtered
    "     },
    "     ...
    "   ],
    " }
    ```

