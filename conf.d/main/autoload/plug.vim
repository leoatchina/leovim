" vim-plug: Vim plugin manager
" ============================
"
" Download plug.vim and put it in ~/.vim/autoload
"
"   curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
"     https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
"
" Edit your .vimrc
"
"   call plug#begin('~/.vim/plugged')
"
"   " Make sure you use single quotes
"
"   " Shorthand notation; fetches https://github.com/junegunn/vim-easy-align
"   Plug 'junegunn/vim-easy-align'
"
"   " Any valid git URL is allowed
"   Plug 'https://github.com/junegunn/vim-github-dashboard.git'
"
"   " Multiple Plug commands can be written in a single line using | separators
"   Plug 'SirVer/ultisnips' | Plug 'honza/vim-snippets'
"
"   " On-demand loading
"   Plug 'preservim/nerdtree', { 'on': 'NERDTreeToggle' }
"   Plug 'tpope/vim-fireplace', { 'for': 'clojure' }
"
"   " Using a non-default branch
"   Plug 'rdnetto/YCM-Generator', { 'branch': 'stable' }
"
"   " Using a tagged release; wildcard allowed (requires git 1.9.2 or above)
"   Plug 'fatih/vim-go', { 'tag': '*' }
"
"   " Plugin options
"   Plug 'nsf/gocode', { 'tag': 'v.20150303', 'rtp': 'vim' }
"
"   " Plugin outside ~/.vim/plugged with post-update hook
"   Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
"
"   " Unmanaged plugin (manually installed and updated)
"   Plug '~/my-prototype-plugin'
"
"   " Initialize plugin system
"   call plug#end()
"
" Then reload .vimrc and :PlugInstall to install plugins.
"
" Plug options:
"
"| Option                  | Description                                      |
"| ----------------------- | ------------------------------------------------ |
"| `branch`/`tag`/`commit` | Branch/tag/commit of the repository to use       |
"| `rtp`                   | Subdirectory that contains Vim plugin            |
"| `dir`                   | Custom directory for the plugin                  |
"| `as`                    | Use different name for the plugin                |
"| `do`                    | Post-update hook (string or funcref)             |
"| `on`                    | On-demand loading: Commands or `<Plug>`-mappings |
"| `for`                   | On-demand loading: File types                    |
"| `frozen`                | Do not update unless explicitly specified        |
"
" More information: https://github.com/junegunn/vim-plug
"
"
" Copyright (c) 2017 Junegunn Choi
"
" MIT License
"
" Permission is hereby granted, free of charge, to any person obtaining
" a copy of this software and associated documentation files (the
" "Software"), to deal in the Software without restriction, including
" without limitation the rights to use, copy, modify, merge, publish,
" distribute, sublicense, and/or sell copies of the Software, and to
" permit persons to whom the Software is furnished to do so, subject to
" the following conditions:
"
" The above copyright notice and this permission notice shall be
" included in all copies or substantial portions of the Software.
"
" THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
" EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
" MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
" NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
" LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
" OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
" WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

if exists('g:loaded_plug')
    finish
endif
let g:loaded_plug = 1

let s:cpo_save = &cpo
set cpo&vim

let s:rtp = &rtp
let s:plug_src = 'https://github.com/junegunn/vim-plug.git'
let s:plug_tab = get(s:, 'plug_tab', -1)
let s:plug_buf = get(s:, 'plug_buf', -1)
let s:mac_gui = has('gui_macvim') && has('gui_running')
let s:is_win = has('win32')
let s:nvim = has('nvim-0.2') || (has('nvim') && exists('*jobwait') && !s:is_win)
let s:vim8 = has('patch-8.0.0039') && exists('*job_start')
let s:packadd = exists(':packadd') > 0
if s:is_win && &shellslash
    set noshellslash
    let s:me = resolve(expand('<sfile>:p'))
    set shellslash
else
    let s:me = resolve(expand('<sfile>:p'))
endif
let s:base_spec = { 'branch': '', 'frozen': 0 }
let s:TYPE = {
            \   'string':  type(''),
            \   'list':    type([]),
            \   'dict':    type({}),
            \   'funcref': type(function('call'))
            \ }
let s:loaded = get(s:, 'loaded', {})
let s:triggers = get(s:, 'triggers', {})

function! plug#is_powershell(shell)
    return a:shell =~# 'powershell\(\.exe\)\?$' || a:shell =~# 'pwsh\(\.exe\)\?$'
endfunction

function! plug#isabsolute(dir) abort
    return a:dir =~# '^/' || (has('win32') && a:dir =~? '^\%(\\\|[A-Z]:\)')
endfunction

function! plug#git_dir(dir) abort
    let gitdir = plug#trim(a:dir) . '/.git'
    if isdirectory(gitdir)
        return gitdir
    endif
    if !filereadable(gitdir)
        return ''
    endif
    let gitdir = matchstr(get(readfile(gitdir), 0, ''), '^gitdir: \zs.*')
    if len(gitdir) && !plug#isabsolute(gitdir)
        let gitdir = a:dir . '/' . gitdir
    endif
    return isdirectory(gitdir) ? gitdir : ''
endfunction

function! plug#git_origin_url(dir) abort
    let gitdir = plug#git_dir(a:dir)
    let config = gitdir . '/config'
    if empty(gitdir) || !filereadable(config)
        return ''
    endif
    return matchstr(join(readfile(config)), '\[remote "origin"\].\{-}url\s*=\s*\zs\S*\ze')
endfunction

function! plug#git_revision(dir) abort
    let gitdir = plug#git_dir(a:dir)
    let head = gitdir . '/HEAD'
    if empty(gitdir) || !filereadable(head)
        return ''
    endif
    let line = get(readfile(head), 0, '')
    let ref = matchstr(line, '^ref: \zs.*')
    if empty(ref)
        return line
    endif
    if filereadable(gitdir . '/' . ref)
        return get(readfile(gitdir . '/' . ref), 0, '')
    endif

    if filereadable(gitdir . '/packed-refs')
        for line in readfile(gitdir . '/packed-refs')
            if line =~# ' ' . ref
                return matchstr(line, '^[0-9a-f]*')
            endif
        endfor
    endif
    return ''
endfunction

function! plug#git_local_branch(dir) abort
    let gitdir = plug#git_dir(a:dir)
    let head = gitdir . '/HEAD'
    if empty(gitdir) || !filereadable(head)
        return ''
    endif
    let branch = matchstr(get(readfile(head), 0, ''), '^ref: refs/heads/\zs.*')
    return len(branch) ? branch : 'HEAD'
endfunction

function! plug#git_origin_branch(spec)
    if len(a:spec.branch)
        return a:spec.branch
    endif
    " The file may not be present if this is a local repository
    let gitdir = plug#git_dir(a:spec.dir)
    let origin_head = gitdir.'/refs/remotes/origin/HEAD'
    if len(gitdir) && filereadable(origin_head)
        return matchstr(get(readfile(origin_head), 0, ''),
                    \ '^ref: refs/remotes/origin/\zs.*')
    endif
    " The command may not return the name of a branch in detached HEAD state
    let result = plug#lines(plug#system('git symbolic-ref --short HEAD', a:spec.dir))
    return v:shell_error ? '' : result[-1]
endfunction

if s:is_win
    function! plug#plug_call(fn, ...)
        let shellslash = &shellslash
        try
            set noshellslash
            return call(a:fn, a:000)
        finally
            let &shellslash = shellslash
        endtry
    endfunction
else
    function! plug#plug_call(fn, ...)
        return call(a:fn, a:000)
    endfunction
endif

function! plug#plug_getcwd()
    return plug#plug_call('getcwd')
endfunction

function! plug#plug_fnamemodify(fname, mods)
    return plug#plug_call('fnamemodify', a:fname, a:mods)
endfunction

function! plug#plug_expand(fmt)
    return plug#plug_call('expand', a:fmt, 1)
endfunction

function! plug#plug_tempname()
    return plug#plug_call('tempname')
endfunction

function! plug#begin(...)
    if a:0 > 0
        let s:plug_home_org = a:1
        let home = plug#path(plug#plug_fnamemodify(plug#plug_expand(a:1), ':p'))
    elseif exists('g:plug_home')
        let home = plug#path(g:plug_home)
    elseif has('nvim')
        let home = stdpath('data') . '/plugged'
    elseif !empty(&rtp)
        let home = plug#path(split(&rtp, ',')[0]) . '/plugged'
    else
        return plug#err('Unable to determine plug home. Try calling plug#begin() with a path argument.')
    endif
    if plug#plug_fnamemodify(home, ':t') ==# 'plugin' && plug#plug_fnamemodify(home, ':h') ==# s:first_rtp
        return plug#err('Invalid plug home. '.home.' is a standard Vim runtime path and is not allowed.')
    endif

    let g:plug_home = home
    let g:plugs = {}
    let g:plugs_order = []
    let s:triggers = {}
    call plug#define_commands()
    return 1
endfunction

function! plug#define_commands()
    command! -nargs=+ -bar Plug call plug#(<args>)
    if !executable('git')
        return plug#err('`git` executable not found. Most commands will not be available. To suppress this message, prepend `silent!` to `call plug#begin(...)`.')
    endif
    if has('win32')
                \ && &shellslash
                \ && (&shell =~# 'cmd\(\.exe\)\?$' || plug#is_powershell(&shell))
        return plug#err('vim-plug does not support shell, ' . &shell . ', when shellslash is set.')
    endif
    if !has('nvim')
                \ && (has('win32') || has('win32unix'))
                \ && !has('multi_byte')
        return plug#err('Vim needs +multi_byte feature on Windows to run shell commands. Enable +iconv for best results.')
    endif
    command! -nargs=* -bar -bang -complete=customlist,plug#names PlugInstall call plug#install(<bang>0, [<f-args>])
    command! -nargs=* -bar -bang -complete=customlist,plug#names PlugUpdate  call plug#update(<bang>0, [<f-args>])
    command! -nargs=0 -bar -bang PlugClean call plug#clean(<bang>0)
    command! -nargs=0 -bar PlugUpgrade if plug#upgrade() | execute 'source' plug#esc(s:me) | endif
    command! -nargs=0 -bar PlugStatus  call plug#status()
    command! -nargs=0 -bar PlugDiff    call plug#diff()
    command! -nargs=? -bar -bang -complete=file PlugSnapshot call plug#snapshot(<bang>0, <f-args>)
endfunction

function! plug#to_a(v)
    return type(a:v) == s:TYPE.list ? a:v : [a:v]
endfunction

function! plug#to_s(v)
    return type(a:v) == s:TYPE.string ? a:v : join(a:v, "\n") . "\n"
endfunction

function! plug#glob(from, pattern)
    return plug#lines(globpath(a:from, a:pattern))
endfunction

function! plug#source(from, ...)
    let found = 0
    for pattern in a:000
        for vim in plug#glob(a:from, pattern)
            execute 'source' plug#esc(vim)
            let found = 1
        endfor
    endfor
    return found
endfunction

function! plug#assoc(dict, key, val)
    let a:dict[a:key] = add(get(a:dict, a:key, []), a:val)
endfunction

function! plug#ask(message, ...)
    call inputsave()
    echohl WarningMsg
    let answer = input(a:message.(a:0 ? ' (y/N/a) ' : ' (y/N) '))
    echohl None
    call inputrestore()
    echo "\r"
    return (a:0 && answer =~? '^a') ? 2 : (answer =~? '^y') ? 1 : 0
endfunction

function! plug#ask_no_interrupt(...)
    try
        return call('plug#ask', a:000)
    catch
        return 0
    endtry
endfunction

function! plug#lazy(plug, opt)
    return has_key(a:plug, a:opt) &&
                \ (empty(plug#to_a(a:plug[a:opt]))         ||
                \  !isdirectory(a:plug.dir)             ||
                \  len(plug#glob(plug#rtp(a:plug), 'plugin')) ||
                \  len(plug#glob(plug#rtp(a:plug), 'after/plugin')))
endfunction

function! plug#end()
    if !exists('g:plugs')
        return plug#err('plug#end() called without calling plug#begin() first')
    endif

    if exists('#PlugLOD')
        augroup PlugLOD
            autocmd!
        augroup END
        augroup! PlugLOD
    endif
    let lod = { 'ft': {}, 'map': {}, 'cmd': {} }

    if get(g:, 'did_load_filetypes', 0)
        filetype off
    endif
    for name in g:plugs_order
        if !has_key(g:plugs, name)
            continue
        endif
        let plug = g:plugs[name]
        if get(s:loaded, name, 0) || !plug#lazy(plug, 'on') && !plug#lazy(plug, 'for')
            let s:loaded[name] = 1
            continue
        endif

        if has_key(plug, 'on')
            let s:triggers[name] = { 'map': [], 'cmd': [] }
            for cmd in plug#to_a(plug.on)
                if cmd =~? '^<Plug>.\+'
                    if empty(mapcheck(cmd)) && empty(mapcheck(cmd, 'i'))
                        call plug#assoc(lod.map, cmd, name)
                    endif
                    call add(s:triggers[name].map, cmd)
                elseif cmd =~# '^[A-Z]'
                    let cmd = substitute(cmd, '!*$', '', '')
                    if exists(':'.cmd) != 2
                        call plug#assoc(lod.cmd, cmd, name)
                    endif
                    call add(s:triggers[name].cmd, cmd)
                else
                    call plug#err('Invalid `on` option: '.cmd.
                                \ '. Should start with an uppercase letter or `<Plug>`.')
                endif
            endfor
        endif

        if has_key(plug, 'for')
            let types = plug#to_a(plug.for)
            if !empty(types)
                augroup filetypedetect
                    call plug#source(plug#rtp(plug), 'ftdetect/**/*.vim', 'after/ftdetect/**/*.vim')
                    if has('nvim-0.5.0')
                        call plug#source(plug#rtp(plug), 'ftdetect/**/*.lua', 'after/ftdetect/**/*.lua')
                    endif
                augroup END
            endif
            for type in types
                call plug#assoc(lod.ft, type, name)
            endfor
        endif
    endfor

    for [cmd, names] in items(lod.cmd)
        execute printf(
                    \ has('patch-7.4.1898')
                    \ ? 'command! -nargs=* -range -bang -complete=file %s call plug#lod_cmd(%s, "<bang>", <line1>, <line2>, <q-args>, <q-mods>, %s)'
                    \ : 'command! -nargs=* -range -bang -complete=file %s call plug#lod_cmd(%s, "<bang>", <line1>, <line2>, <q-args>, %s)',
                    \ cmd, string(cmd), string(names))
    endfor

    for [map, names] in items(lod.map)
        for [mode, map_prefix, key_prefix] in
                    \ [['i', '<C-\><C-O>', ''], ['n', '', ''], ['v', '', 'gv'], ['o', '', '']]
            execute printf(
                        \ '%snoremap <silent> %s %s:<C-U>call plug#lod_map(%s, %s, %s, "%s")<CR>',
                        \ mode, map, map_prefix, string(map), string(names), mode != 'i', key_prefix)
        endfor
    endfor

    for [ft, names] in items(lod.ft)
        augroup PlugLOD
            execute printf('autocmd FileType %s call plug#lod_ft(%s, %s)',
                        \ ft, string(ft), string(names))
        augroup END
    endfor

    call plug#reorg_rtp()
    filetype plugin indent on
    if has('vim_starting')
        if has('syntax') && !exists('g:syntax_on')
            syntax enable
        endif
    else
        call plug#reload_plugins()
    endif
endfunction

function! plug#loaded_names()
    return filter(copy(g:plugs_order), 'get(s:loaded, v:val, 0)')
endfunction

function! plug#load_plugin(spec)
    call plug#source(plug#rtp(a:spec), 'plugin/**/*.vim', 'after/plugin/**/*.vim')
    if has('nvim-0.5.0')
        call plug#source(plug#rtp(a:spec), 'plugin/**/*.lua', 'after/plugin/**/*.lua')
    endif
endfunction

function! plug#reload_plugins()
    for name in plug#loaded_names()
        call plug#load_plugin(g:plugs[name])
    endfor
endfunction

function! plug#trim(str)
    return substitute(a:str, '[\/]\+$', '', '')
endfunction

function! plug#version_requirement(val, min)
    for idx in range(0, len(a:min) - 1)
        let v = get(a:val, idx, 0)
        if     v < a:min[idx] | return 0
        elseif v > a:min[idx] | return 1
        endif
    endfor
    return 1
endfunction

function! plug#git_version_requirement(...)
    if !exists('s:git_version')
        let s:git_version = map(split(split(plug#system(['git', '--version']))[2], '\.'), 'str2nr(v:val)')
    endif
    return plug#version_requirement(s:git_version, a:000)
endfunction

function! plug#progress_opt(base)
    return a:base && !s:is_win &&
                \ plug#git_version_requirement(1, 7, 1) ? '--progress' : ''
endfunction

function! plug#rtp(spec)
    return plug#path(a:spec.dir . get(a:spec, 'rtp', ''))
endfunction

if s:is_win
    function! plug#path(path)
        return plug#trim(substitute(a:path, '/', '\', 'g'))
    endfunction

    function! plug#dirpath(path)
        return plug#path(a:path) . '\'
    endfunction

    function! plug#is_local_plug(repo)
        return a:repo =~? '^[a-z]:\|^[%~]'
    endfunction

    " Copied from fzf
    function! plug#wrap_cmds(cmds)
        let cmds = [
                    \ '@echo off',
                    \ 'setlocal enabledelayedexpansion']
                    \ + (type(a:cmds) == type([]) ? a:cmds : [a:cmds])
                    \ + ['endlocal']
        if has('iconv')
            if !exists('s:codepage')
                let s:codepage = libcallnr('kernel32.dll', 'GetACP', 0)
            endif
            return map(cmds, printf('iconv(v:val."\r", "%s", "cp%d")', &encoding, s:codepage))
        endif
        return map(cmds, 'v:val."\r"')
    endfunction

    function! plug#batchfile(cmd)
        let batchfile = plug#plug_tempname().'.bat'
        call writefile(plug#wrap_cmds(a:cmd), batchfile)
        let cmd = plug#shellescape(batchfile, {'shell': &shell, 'script': 0})
        if plug#is_powershell(&shell)
            let cmd = '& ' . cmd
        endif
        return [batchfile, cmd]
    endfunction
else
    function! plug#path(path)
        return plug#trim(a:path)
    endfunction

    function! plug#dirpath(path)
        return substitute(a:path, '[/\\]*$', '/', '')
    endfunction

    function! plug#is_local_plug(repo)
        return a:repo[0] =~ '[/$~]'
    endfunction
endif

function! plug#err(msg)
    echohl ErrorMsg
    echom '[vim-plug] '.a:msg
    echohl None
endfunction

function! plug#warn(cmd, msg)
    echohl WarningMsg
    execute a:cmd 'a:msg'
    echohl None
endfunction

function! plug#esc(path)
    return escape(a:path, ' ')
endfunction

function! plug#escrtp(path)
    return escape(a:path, ' ,')
endfunction

function! plug#remove_rtp()
    for name in plug#loaded_names()
        let rtp = plug#rtp(g:plugs[name])
        execute 'set rtp-='.plug#escrtp(rtp)
        let after = globpath(rtp, 'after')
        if isdirectory(after)
            execute 'set rtp-='.plug#escrtp(after)
        endif
    endfor
endfunction

function! plug#reorg_rtp()
    if !empty(s:first_rtp)
        execute 'set rtp-='.s:first_rtp
        execute 'set rtp-='.s:last_rtp
    endif

    " &rtp is modified from outside
    if exists('s:prtp') && s:prtp !=# &rtp
        call plug#remove_rtp()
        unlet! s:middle
    endif

    let s:middle = get(s:, 'middle', &rtp)
    let rtps     = map(plug#loaded_names(), 'plug#rtp(g:plugs[v:val])')
    let afters   = filter(map(copy(rtps), 'globpath(v:val, "after")'), '!empty(v:val)')
    let rtp      = join(map(rtps, 'escape(v:val, ",")'), ',')
                \ . ','.s:middle.','
                \ . join(map(afters, 'escape(v:val, ",")'), ',')
    let &rtp     = substitute(substitute(rtp, ',,*', ',', 'g'), '^,\|,$', '', 'g')
    let s:prtp   = &rtp

    if !empty(s:first_rtp)
        execute 'set rtp^='.s:first_rtp
        execute 'set rtp+='.s:last_rtp
    endif
endfunction

function! plug#doautocmd(...)
    if exists('#'.join(a:000, '#'))
        execute 'doautocmd' ((v:version > 703 || has('patch442')) ? '<nomodeline>' : '') join(a:000)
    endif
endfunction

function! plug#dobufread(names)
    for name in a:names
        let path = plug#rtp(g:plugs[name])
        for dir in ['ftdetect', 'ftplugin', 'after/ftdetect', 'after/ftplugin']
            if len(finddir(dir, path))
                if exists('#BufRead')
                    doautocmd BufRead
                endif
                return
            endif
        endfor
    endfor
endfunction

function! plug#load(...)
    if a:0 == 0
        return plug#err('Argument missing: plugin name(s) required')
    endif
    if !exists('g:plugs')
        return plug#err('plug#begin was not called')
    endif
    let names = a:0 == 1 && type(a:1) == s:TYPE.list ? a:1 : a:000
    let unknowns = filter(copy(names), '!has_key(g:plugs, v:val)')
    if !empty(unknowns)
        let s = len(unknowns) > 1 ? 's' : ''
        return plug#err(printf('Unknown plugin%s: %s', s, join(unknowns, ', ')))
    endif
    let unloaded = filter(copy(names), '!get(s:loaded, v:val, 0)')
    if !empty(unloaded)
        for name in unloaded
            call plug#lod([name], ['ftdetect', 'after/ftdetect', 'plugin', 'after/plugin'])
        endfor
        call plug#dobufread(unloaded)
        return 1
    endif
    return 0
endfunction

function! plug#remove_triggers(name)
    if !has_key(s:triggers, a:name)
        return
    endif
    for cmd in s:triggers[a:name].cmd
        execute 'silent! delc' cmd
    endfor
    for map in s:triggers[a:name].map
        execute 'silent! unmap' map
        execute 'silent! iunmap' map
    endfor
    call remove(s:triggers, a:name)
endfunction

function! plug#lod(names, types, ...)
    for name in a:names
        call plug#remove_triggers(name)
        let s:loaded[name] = 1
    endfor
    call plug#reorg_rtp()

    for name in a:names
        let rtp = plug#rtp(g:plugs[name])
        for dir in a:types
            call plug#source(rtp, dir.'/**/*.vim')
            if has('nvim-0.5.0')  " see neovim#14686
                call plug#source(rtp, dir.'/**/*.lua')
            endif
        endfor
        if a:0
            if !plug#source(rtp, a:1) && !empty(plug#glob(rtp, a:2))
                execute 'runtime' a:1
            endif
            call plug#source(rtp, a:2)
        endif
        call plug#doautocmd('User', name)
    endfor
endfunction

function! plug#lod_ft(pat, names)
    let syn = 'syntax/'.a:pat.'.vim'
    call plug#lod(a:names, ['plugin', 'after/plugin'], syn, 'after/'.syn)
    execute 'autocmd! PlugLOD FileType' a:pat
    call plug#doautocmd('filetypeplugin', 'FileType')
    call plug#doautocmd('filetypeindent', 'FileType')
endfunction

if has('patch-7.4.1898')
    function! plug#lod_cmd(cmd, bang, l1, l2, args, mods, names)
        call plug#lod(a:names, ['ftdetect', 'after/ftdetect', 'plugin', 'after/plugin'])
        call plug#dobufread(a:names)
        execute printf('%s %s%s%s %s', a:mods, (a:l1 == a:l2 ? '' : (a:l1.','.a:l2)), a:cmd, a:bang, a:args)
    endfunction
else
    function! plug#lod_cmd(cmd, bang, l1, l2, args, names)
        call plug#lod(a:names, ['ftdetect', 'after/ftdetect', 'plugin', 'after/plugin'])
        call plug#dobufread(a:names)
        execute printf('%s%s%s %s', (a:l1 == a:l2 ? '' : (a:l1.','.a:l2)), a:cmd, a:bang, a:args)
    endfunction
endif

function! plug#lod_map(map, names, with_prefix, prefix)
    call plug#lod(a:names, ['ftdetect', 'after/ftdetect', 'plugin', 'after/plugin'])
    call plug#dobufread(a:names)
    let extra = ''
    while 1
        let c = getchar(0)
        if c == 0
            break
        endif
        let extra .= nr2char(c)
    endwhile

    if a:with_prefix
        let prefix = v:count ? v:count : ''
        let prefix .= '"'.v:register.a:prefix
        if mode(1) == 'no'
            if v:operator == 'c'
                let prefix = "\<esc>" . prefix
            endif
            let prefix .= v:operator
        endif
        call feedkeys(prefix, 'n')
    endif
    call feedkeys(substitute(a:map, '^<Plug>', "\<Plug>", '') . extra)
endfunction

function! plug#(repo, ...)
    if a:0 > 1
        return plug#err('Invalid number of arguments (1..2)')
    endif

    try
        let repo = plug#trim(a:repo)
        let opts = a:0 == 1 ? plug#parse_options(a:1) : s:base_spec
        let name = get(opts, 'as', plug#plug_fnamemodify(repo, ':t:s?\.git$??'))
        let spec = extend(plug#infer_properties(name, repo), opts)
        if !has_key(g:plugs, name)
            call add(g:plugs_order, name)
        endif
        let g:plugs[name] = spec
        let s:loaded[name] = get(s:loaded, name, 0)
    catch
        return plug#err(repo . ' ' . v:exception)
    endtry
endfunction

function! plug#parse_options(arg)
    let opts = copy(s:base_spec)
    let type = type(a:arg)
    let opt_errfmt = 'Invalid argument for "%s" option of :Plug (expected: %s)'
    if type == s:TYPE.string
        if empty(a:arg)
            throw printf(opt_errfmt, 'tag', 'string')
        endif
        let opts.tag = a:arg
    elseif type == s:TYPE.dict
        for opt in ['branch', 'tag', 'commit', 'rtp', 'dir', 'as']
            if has_key(a:arg, opt)
                        \ && (type(a:arg[opt]) != s:TYPE.string || empty(a:arg[opt]))
                throw printf(opt_errfmt, opt, 'string')
            endif
        endfor
        for opt in ['on', 'for']
            if has_key(a:arg, opt)
                        \ && type(a:arg[opt]) != s:TYPE.list
                        \ && (type(a:arg[opt]) != s:TYPE.string || empty(a:arg[opt]))
                throw printf(opt_errfmt, opt, 'string or list')
            endif
        endfor
        if has_key(a:arg, 'do')
                    \ && type(a:arg.do) != s:TYPE.funcref
                    \ && (type(a:arg.do) != s:TYPE.string || empty(a:arg.do))
            throw printf(opt_errfmt, 'do', 'string or funcref')
        endif
        call extend(opts, a:arg)
        if has_key(opts, 'dir')
            let opts.dir = plug#dirpath(plug#plug_expand(opts.dir))
        endif
    else
        throw 'Invalid argument type (expected: string or dictionary)'
    endif
    return opts
endfunction

function! plug#infer_properties(name, repo)
    let repo = a:repo
    if plug#is_local_plug(repo)
        return { 'dir': plug#dirpath(plug#plug_expand(repo)) }
    else
        if repo =~ ':'
            let uri = repo
        else
            if repo !~ '/'
                throw printf('Invalid argument: %s (implicit `vim-scripts'' expansion is deprecated)', repo)
            endif
            let fmt = get(g:, 'plug_url_format', 'https://git::@github.com/%s.git')
            let uri = printf(fmt, repo)
        endif
        return { 'dir': plug#dirpath(g:plug_home.'/'.a:name), 'uri': uri }
    endif
endfunction

function! plug#install(force, names)
    call plug#update_impl(0, a:force, a:names)
endfunction

function! plug#update(force, names)
    call plug#update_impl(1, a:force, a:names)
endfunction

function! plug#helptags()
    if !exists('g:plugs')
        return plug#err('plug#begin was not called')
    endif
    for spec in values(g:plugs)
        let docd = join([plug#rtp(spec), 'doc'], '/')
        if isdirectory(docd)
            silent! execute 'helptags' plug#esc(docd)
        endif
    endfor
    return 1
endfunction

function! plug#syntax()
    syntax clear
    syntax region plug1 start=/\%1l/ end=/\%2l/ contains=plugNumber
    syntax region plug2 start=/\%2l/ end=/\%3l/ contains=plugBracket,plugX,plugAbort
    syn match plugNumber /[0-9]\+[0-9.]*/ contained
    syn match plugBracket /[[\]]/ contained
    syn match plugX /x/ contained
    syn match plugAbort /\~/ contained
    syn match plugDash /^-\{1}\ /
    syn match plugPlus /^+/
    syn match plugStar /^*/
    syn match plugMessage /\(^- \)\@<=.*/
    syn match plugName /\(^- \)\@<=[^ ]*:/
    syn match plugSha /\%(: \)\@<=[0-9a-f]\{4,}$/
    syn match plugTag /(tag: [^)]\+)/
    syn match plugInstall /\(^+ \)\@<=[^:]*/
    syn match plugUpdate /\(^* \)\@<=[^:]*/
    syn match plugCommit /^  \X*[0-9a-f]\{7,9} .*/ contains=plugRelDate,plugEdge,plugTag
    syn match plugEdge /^  \X\+$/
    syn match plugEdge /^  \X*/ contained nextgroup=plugSha
    syn match plugSha /[0-9a-f]\{7,9}/ contained
    syn match plugRelDate /([^)]*)$/ contained
    syn match plugNotLoaded /(not loaded)$/
    syn match plugError /^x.*/
    syn region plugDeleted start=/^\~ .*/ end=/^\ze\S/
    syn match plugH2 /^.*:\n-\+$/
    syn match plugH2 /^-\{2,}/
    syn keyword Function PlugInstall PlugStatus PlugUpdate PlugClean
    hi def link plug1       Title
    hi def link plug2       Repeat
    hi def link plugH2      Type
    hi def link plugX       Exception
    hi def link plugAbort   Ignore
    hi def link plugBracket Structure
    hi def link plugNumber  Number

    hi def link plugDash    Special
    hi def link plugPlus    Constant
    hi def link plugStar    Boolean

    hi def link plugMessage Function
    hi def link plugName    Label
    hi def link plugInstall Function
    hi def link plugUpdate  Type

    hi def link plugError   Error
    hi def link plugDeleted Ignore
    hi def link plugRelDate Comment
    hi def link plugEdge    PreProc
    hi def link plugSha     Identifier
    hi def link plugTag     Constant

    hi def link plugNotLoaded Comment
endfunction

function! plug#lpad(str, len)
    return a:str . repeat(' ', a:len - len(a:str))
endfunction

function! plug#lines(msg)
    return split(a:msg, "[\r\n]")
endfunction

function! plug#lastline(msg)
    return get(plug#lines(a:msg), -1, '')
endfunction

function! plug#new_window()
    execute get(g:, 'plug_window', '-tabnew')
endfunction

function! plug#plug_window_exists()
    let buflist = tabpagebuflist(s:plug_tab)
    return !empty(buflist) && index(buflist, s:plug_buf) >= 0
endfunction

function! plug#switch_in()
    if !plug#plug_window_exists()
        return 0
    endif

    if winbufnr(0) != s:plug_buf
        let s:pos = [tabpagenr(), winnr(), winsaveview()]
        execute 'normal!' s:plug_tab.'gt'
        let winnr = bufwinnr(s:plug_buf)
        execute winnr.'wincmd w'
        call add(s:pos, winsaveview())
    else
        let s:pos = [winsaveview()]
    endif

    setlocal modifiable
    return 1
endfunction

function! plug#switch_out(...)
    call winrestview(s:pos[-1])
    setlocal nomodifiable
    if a:0 > 0
        execute a:1
    endif

    if len(s:pos) > 1
        execute 'normal!' s:pos[0].'gt'
        execute s:pos[1] 'wincmd w'
        call winrestview(s:pos[2])
    endif
endfunction

function! plug#finish_bindings()
    nnoremap <silent> <buffer> R  :call plug#retry()<cr>
    nnoremap <silent> <buffer> D  :PlugDiff<cr>
    nnoremap <silent> <buffer> S  :PlugStatus<cr>
    nnoremap <silent> <buffer> U  :call plug#status_update()<cr>
    xnoremap <silent> <buffer> U  :call plug#status_update()<cr>
    nnoremap <silent> <buffer> ]] :silent! call plug#section('')<cr>
    nnoremap <silent> <buffer> [[ :silent! call plug#section('b')<cr>
endfunction

function! plug#prepare(...)
    if empty(plug#plug_getcwd())
        throw 'Invalid current working directory. Cannot proceed.'
    endif

    for evar in ['$GIT_DIR', '$GIT_WORK_TREE']
        if exists(evar)
            throw evar.' detected. Cannot proceed.'
        endif
    endfor

    call plug#job_abort(0)
    if plug#switch_in()
        if b:plug_preview == 1
            pc
        endif
        enew
    else
        call plug#new_window()
    endif

    nnoremap <silent> <buffer> q :call plug#close_pane()<cr>
    if a:0 == 0
        call plug#finish_bindings()
    endif
    let b:plug_preview = -1
    let s:plug_tab = tabpagenr()
    let s:plug_buf = winbufnr(0)
    call plug#assign_name()

    for k in ['<cr>', 'L', 'o', 'X', 'd', 'dd']
        execute 'silent! unmap <buffer>' k
    endfor
    setlocal buftype=nofile bufhidden=wipe nobuflisted nolist noswapfile nowrap cursorline modifiable nospell
    if exists('+colorcolumn')
        setlocal colorcolumn=
    endif
    setf vim-plug
    if exists('g:syntax_on')
        call plug#syntax()
    endif
endfunction

function! plug#close_pane()
    if b:plug_preview == 1
        pc
        let b:plug_preview = -1
    elseif exists('s:jobs') && !empty(s:jobs)
        call plug#job_abort(1)
    else
        bd
    endif
endfunction

function! plug#assign_name()
    " Assign buffer name
    let prefix = '[Plugins]'
    let name   = prefix
    let idx    = 2
    while bufexists(name)
        let name = printf('%s (%s)', prefix, idx)
        let idx = idx + 1
    endwhile
    silent! execute 'f' fnameescape(name)
endfunction

function! plug#chsh(swap)
    let prev = [&shell, &shellcmdflag, &shellredir]
    if !s:is_win
        set shell=sh
    endif
    if a:swap
        if plug#is_powershell(&shell)
            let &shellredir = '2>&1 | Out-File -Encoding UTF8 %s'
        elseif &shell =~# 'sh' || &shell =~# 'cmd\(\.exe\)\?$'
            set shellredir=>%s\ 2>&1
        endif
    endif
    return prev
endfunction

function! plug#bang(cmd, ...)
    let batchfile = ''
    try
        let [sh, shellcmdflag, shrd] = plug#chsh(a:0)
        " FIXME: Escaping is incomplete. We could use shellescape with eval,
        "        but it won't work on Windows.
        let cmd = a:0 ? plug#with_cd(a:cmd, a:1) : a:cmd
        if s:is_win
            let [batchfile, cmd] = plug#batchfile(cmd)
        endif
        let g:_plug_bang = (s:is_win && has('gui_running') ? 'silent ' : '').'!'.escape(cmd, '#!%')
        execute "normal! :execute g:_plug_bang\<cr>\<cr>"
    finally
        unlet g:_plug_bang
        let [&shell, &shellcmdflag, &shellredir] = [sh, shellcmdflag, shrd]
        if s:is_win && filereadable(batchfile)
            call delete(batchfile)
        endif
    endtry
    return v:shell_error ? 'Exit status: ' . v:shell_error : ''
endfunction

function! plug#regress_bar()
    let bar = substitute(getline(2)[1:-2], '.*\zs=', 'x', '')
    call plug#progress_bar(2, bar, len(bar))
endfunction

function! plug#is_updated(dir)
    return !empty(plug#system_chomp(['git', 'log', '--pretty=format:%h', 'HEAD...HEAD@{1}'], a:dir))
endfunction

function! plug#do(pull, force, todo)
    if has('nvim')
        " Reset &rtp to invalidate Neovim cache of loaded Lua modules
        " See https://github.com/junegunn/vim-plug/pull/1157#issuecomment-1809226110
        let &rtp = &rtp
    endif
    for [name, spec] in items(a:todo)
        if !isdirectory(spec.dir)
            continue
        endif
        let installed = has_key(s:update.new, name)
        let updated = installed ? 0 :
                    \ (a:pull && index(s:update.errors, name) < 0 && plug#is_updated(spec.dir))
        if a:force || installed || updated
            execute 'cd' plug#esc(spec.dir)
            call append(3, '- Post-update hook for '. name .' ... ')
            let error = ''
            let type = type(spec.do)
            if type == s:TYPE.string
                if spec.do[0] == ':'
                    if !get(s:loaded, name, 0)
                        let s:loaded[name] = 1
                        call plug#reorg_rtp()
                    endif
                    call plug#load_plugin(spec)
                    try
                        execute spec.do[1:]
                    catch
                        let error = v:exception
                    endtry
                    if !plug#plug_window_exists()
                        cd -
                        throw 'Warning: vim-plug was terminated by the post-update hook of '.name
                    endif
                else
                    let error = plug#bang(spec.do)
                endif
            elseif type == s:TYPE.funcref
                try
                    call plug#load_plugin(spec)
                    let status = installed ? 'installed' : (updated ? 'updated' : 'unchanged')
                    call spec.do({ 'name': name, 'status': status, 'force': a:force })
                catch
                    let error = v:exception
                endtry
            else
                let error = 'Invalid hook type'
            endif
            call plug#switch_in()
            call setline(4, empty(error) ? (getline(4) . 'OK')
                        \ : ('x' . getline(4)[1:] . error))
            if !empty(error)
                call add(s:update.errors, name)
                call plug#regress_bar()
            endif
            cd -
        endif
    endfor
endfunction

function! plug#hash_match(a, b)
    return stridx(a:a, a:b) == 0 || stridx(a:b, a:a) == 0
endfunction

function! plug#disable_credential_helper()
    return plug#git_version_requirement(2) && get(g:, 'plug_disable_credential_helper', 1)
endfunction

function! plug#checkout(spec)
    let sha = a:spec.commit
    let output = plug#git_revision(a:spec.dir)
    let error = 0
    if !empty(output) && !plug#hash_match(sha, plug#lines(output)[0])
        let credential_helper = plug#disable_credential_helper() ? '-c credential.helper= ' : ''
        let output = plug#system(
                    \ 'git '.credential_helper.'fetch --depth 999999 && git checkout '.plug#shellescape(sha).' --', a:spec.dir)
        let error = v:shell_error
    endif
    return [output, error]
endfunction

function! plug#finish(pull)
    let new_frozen = len(filter(keys(s:update.new), 'g:plugs[v:val].frozen'))
    if new_frozen
        let s = new_frozen > 1 ? 's' : ''
        call append(3, printf('- Installed %d frozen plugin%s', new_frozen, s))
    endif
    call append(3, '- Finishing ... ') | 4
    redraw
    call plug#helptags()
    call plug#end()
    call setline(4, getline(4) . 'Done!')
    redraw
    let msgs = []
    if !empty(s:update.errors)
        call add(msgs, "Press 'R' to retry.")
    endif
    if a:pull && len(s:update.new) < len(filter(getline(5, '$'),
                \ "v:val =~ '^- ' && v:val !~# 'Already up.to.date'"))
        call add(msgs, "Press 'D' to see the updated changes.")
    endif
    echo join(msgs, ' ')
    call plug#finish_bindings()
endfunction

function! plug#retry()
    if empty(s:update.errors)
        return
    endif
    echo
    call plug#update_impl(s:update.pull, s:update.force,
                \ extend(copy(s:update.errors), [s:update.threads]))
endfunction

function! plug#is_managed(name)
    return has_key(g:plugs[a:name], 'uri')
endfunction

function! plug#names(...)
    return sort(filter(keys(g:plugs), 'stridx(v:val, a:1) == 0 && plug#is_managed(v:val)'))
endfunction

function! plug#check_ruby()
    silent! ruby require 'thread'; VIM::command("let g:plug_ruby = '#{RUBY_VERSION}'")
    if !exists('g:plug_ruby')
        redraw!
        return plug#warn('echom', 'Warning: Ruby interface is broken')
    endif
    let ruby_version = split(g:plug_ruby, '\.')
    unlet g:plug_ruby
    return plug#version_requirement(ruby_version, [1, 8, 7])
endfunction

function! plug#update_impl(pull, force, args) abort
    let sync = index(a:args, '--sync') >= 0 || has('vim_starting')
    let args = filter(copy(a:args), 'v:val != "--sync"')
    let threads = (len(args) > 0 && args[-1] =~ '^[1-9][0-9]*$') ?
                \ remove(args, -1) : get(g:, 'plug_threads', 16)

    let managed = filter(deepcopy(g:plugs), 'plug#is_managed(v:key)')
    let todo = empty(args) ? filter(managed, '!v:val.frozen || !isdirectory(v:val.dir)') :
                \ filter(managed, 'index(args, v:key) >= 0')

    if empty(todo)
        return plug#warn('echo', 'No plugin to '. (a:pull ? 'update' : 'install'))
    endif

    if !s:is_win && plug#git_version_requirement(2, 3)
        let s:git_terminal_prompt = exists('$GIT_TERMINAL_PROMPT') ? $GIT_TERMINAL_PROMPT : ''
        let $GIT_TERMINAL_PROMPT = 0
        for plug in values(todo)
            let plug.uri = substitute(plug.uri,
                        \ '^https://git::@github\.com', 'https://github.com', '')
        endfor
    endif

    if !isdirectory(g:plug_home)
        try
            call mkdir(g:plug_home, 'p')
        catch
            return plug#err(printf('Invalid plug directory: %s. '.
                        \ 'Try to call plug#begin with a valid directory', g:plug_home))
        endtry
    endif

    if has('nvim') && !exists('*jobwait') && threads > 1
        call plug#warn('echom', '[vim-plug] Update Neovim for parallel installer')
    endif

    let use_job = s:nvim || s:vim8

    let s:update = {
                \ 'start':   reltime(),
                \ 'all':     todo,
                \ 'todo':    copy(todo),
                \ 'errors':  [],
                \ 'pull':    a:pull,
                \ 'force':   a:force,
                \ 'new':     {},
                \ 'threads': use_job ? min([len(todo), threads]) : 1,
                \ 'bar':     '',
                \ 'fin':     0
                \ }

    call plug#prepare(1)
    call append(0, ['', ''])
    normal! 2G
    silent! redraw

    " Set remote name, overriding a possible user git config's clone.defaultRemoteName
    let s:clone_opt = ['--origin', 'origin']
    if get(g:, 'plug_shallow', 1)
        call extend(s:clone_opt, ['--depth', '1'])
        if plug#git_version_requirement(1, 7, 10)
            call add(s:clone_opt, '--no-single-branch')
        endif
    endif

    if has('win32unix') || has('wsl')
        call extend(s:clone_opt, ['-c', 'core.eol=lf', '-c', 'core.autocrlf=input'])
    endif

    let s:submodule_opt = plug#git_version_requirement(2, 8) ? ' --jobs='.threads : ''

    call plug#update_vim()
    while use_job && sync
        sleep 50m
        if s:update.fin
            break
        endif
    endwhile
endfunction

function! plug#log4(name, msg)
    call setline(4, printf('- %s (%s)', a:msg, a:name))
    redraw
endfunction

function! plug#update_finish()
    if exists('s:git_terminal_prompt')
        let $GIT_TERMINAL_PROMPT = s:git_terminal_prompt
    endif
    if plug#switch_in()
        call append(3, '- Updating ...') | 4
        for [name, spec] in items(filter(copy(s:update.all), 'index(s:update.errors, v:key) < 0 && (s:update.force || s:update.pull || has_key(s:update.new, v:key))'))
            let [pos, _] = plug#logpos(name)
            if !pos
                continue
            endif
            let out = ''
            let error = 0
            if has_key(spec, 'commit')
                call plug#log4(name, 'Checking out '.spec.commit)
                let [out, error] = plug#checkout(spec)
            elseif has_key(spec, 'tag')
                let tag = spec.tag
                if tag =~ '\*'
                    let tags = plug#lines(plug#system('git tag --list '.plug#shellescape(tag).' --sort -version:refname 2>&1', spec.dir))
                    if !v:shell_error && !empty(tags)
                        let tag = tags[0]
                        call plug#log4(name, printf('Latest tag for %s -> %s', spec.tag, tag))
                        call append(3, '')
                    endif
                endif
                call plug#log4(name, 'Checking out '.tag)
                let out = plug#system('git checkout -q '.plug#shellescape(tag).' -- 2>&1', spec.dir)
                let error = v:shell_error
            elseif !empty(plug#git_origin_branch(spec))
                let branch = plug#git_origin_branch(spec)
                let current = plug#git_local_branch(spec.dir)
                if branch !=# current
                    call plug#log4(name, 'Switching to '.branch)
                    let out = plug#system('git checkout -q '.plug#shellescape(branch).' -- 2>&1', spec.dir)
                    let error = v:shell_error
                endif
            endif
            if !error && filereadable(spec.dir.'/.gitmodules') &&
                        \ (s:update.force || has_key(s:update.new, name) || plug#is_updated(spec.dir))
                call plug#log4(name, 'Updating submodules. This may take a while.')
                let out .= plug#bang('git submodule update --init --recursive'.s:submodule_opt.' 2>&1', spec.dir)
                let error = v:shell_error
            endif
            let msg = plug#format_message(error ? 'x': '-', name, out)
            if error
                call add(s:update.errors, name)
                call plug#regress_bar()
                silent execute pos 'd _'
                call append(4, msg) | 4
            elseif !empty(out)
                call setline(pos, msg[0])
            endif
            redraw
        endfor
        silent 4 d _
        try
            call plug#do(s:update.pull, s:update.force, filter(copy(s:update.all), 'index(s:update.errors, v:key) < 0 && has_key(v:val, "do")'))
        catch
            call plug#warn('echom', v:exception)
            call plug#warn('echo', '')
            return
        endtry
        call plug#finish(s:update.pull)
        call setline(1, 'Updated. Elapsed time: ' . split(reltimestr(reltime(s:update.start)))[0] . ' sec.')
        call plug#switch_out('normal! gg')
    endif
endfunction

function! plug#mark_aborted(name, message)
    let attrs = { 'running': 0, 'error': 1, 'abort': 1, 'lines': [a:message] }
    let s:jobs[a:name] = extend(get(s:jobs, a:name, {}), attrs)
endfunction

function! plug#job_abort(cancel)
    if (!s:nvim && !s:vim8) || !exists('s:jobs')
        return
    endif

    for [name, j] in items(s:jobs)
        if s:nvim
            silent! call jobstop(j.jobid)
        elseif s:vim8
            silent! call job_stop(j.jobid)
        endif
        if j.new
            call plug#rm_rf(g:plugs[name].dir)
        endif
        if a:cancel
            call plug#mark_aborted(name, 'Aborted')
        endif
    endfor

    if a:cancel
        for todo in values(s:update.todo)
            let todo.abort = 1
        endfor
    else
        let s:jobs = {}
    endif
endfunction

function! plug#last_non_empty_line(lines)
    let len = len(a:lines)
    for idx in range(len)
        let line = a:lines[len-idx-1]
        if !empty(line)
            return line
        endif
    endfor
    return ''
endfunction

function! plug#job_out_cb(self, data) abort
    let self = a:self
    let data = remove(self.lines, -1) . a:data
    let lines = map(split(data, "\n", 1), 'split(v:val, "\r", 1)[-1]')
    call extend(self.lines, lines)
    " To reduce the number of buffer updates
    let self.tick = get(self, 'tick', -1) + 1
    if !self.running || self.tick % len(s:jobs) == 0
        let bullet = self.running ? (self.new ? '+' : '*') : (self.error ? 'x' : '-')
        let result = self.error ? join(self.lines, "\n") : plug#last_non_empty_line(self.lines)
        call plug#log(bullet, self.name, result)
    endif
endfunction

function! plug#job_exit_cb(self, data) abort
    let a:self.running = 0
    let a:self.error = a:data != 0
    call plug#reap(a:self.name)
    call plug#tick()
endfunction

function! plug#job_cb(fn, job, ch, data)
    if !plug#plug_window_exists() " plug window closed
        return plug#job_abort(0)
    endif
    call call(a:fn, [a:job, a:data])
endfunction

function! plug#nvim_cb(job_id, data, event) dict abort
    return (a:event == 'stdout' || a:event == 'stderr') ?
                \ plug#job_cb('plug#job_out_cb',  self, 0, join(a:data, "\n")) :
                \ plug#job_cb('plug#job_exit_cb', self, 0, a:data)
endfunction

function! plug#spawn(name, cmd, opts)
    let job = { 'name': a:name, 'running': 1, 'error': 0, 'lines': [''],
                \ 'new': get(a:opts, 'new', 0) }
    let s:jobs[a:name] = job

    if s:nvim
        if has_key(a:opts, 'dir')
            let job.cwd = a:opts.dir
        endif
        let argv = a:cmd
        call extend(job, {
                    \ 'on_stdout': function('plug#nvim_cb'),
                    \ 'on_stderr': function('plug#nvim_cb'),
                    \ 'on_exit':   function('plug#nvim_cb'),
                    \ })
        let jid = plug#plug_call('jobstart', argv, job)
        if jid > 0
            let job.jobid = jid
        else
            let job.running = 0
            let job.error   = 1
            let job.lines   = [jid < 0 ? argv[0].' is not executable' :
                        \ 'Invalid arguments (or job table is full)']
        endif
    elseif s:vim8
        let cmd = join(map(copy(a:cmd), 'plug#shellescape(v:val, {"script": 0})'))
        if has_key(a:opts, 'dir')
            let cmd = plug#with_cd(cmd, a:opts.dir, 0)
        endif
        let argv = s:is_win ? ['cmd', '/s', '/c', '"'.cmd.'"'] : ['sh', '-c', cmd]
        let jid = job_start(s:is_win ? join(argv, ' ') : argv, {
                    \ 'out_cb':   function('plug#job_cb', ['plug#job_out_cb',  job]),
                    \ 'err_cb':   function('plug#job_cb', ['plug#job_out_cb',  job]),
                    \ 'exit_cb':  function('plug#job_cb', ['plug#job_exit_cb', job]),
                    \ 'err_mode': 'raw',
                    \ 'out_mode': 'raw'
                    \})
        if job_status(jid) == 'run'
            let job.jobid = jid
        else
            let job.running = 0
            let job.error   = 1
            let job.lines   = ['Failed to start job']
        endif
    else
        let job.lines = plug#lines(call('plug#system', has_key(a:opts, 'dir') ? [a:cmd, a:opts.dir] : [a:cmd]))
        let job.error = v:shell_error != 0
        let job.running = 0
    endif
endfunction

function! plug#reap(name)
    let job = s:jobs[a:name]
    if job.error
        call add(s:update.errors, a:name)
    elseif get(job, 'new', 0)
        let s:update.new[a:name] = 1
    endif
    let s:update.bar .= job.error ? 'x' : '='

    let bullet = job.error ? 'x' : '-'
    let result = job.error ? join(job.lines, "\n") : plug#last_non_empty_line(job.lines)
    call plug#log(bullet, a:name, empty(result) ? 'OK' : result)
    call plug#bar()

    call remove(s:jobs, a:name)
endfunction

function! plug#bar()
    if plug#switch_in()
        let total = len(s:update.all)
        call setline(1, (s:update.pull ? 'Updating' : 'Installing').
                    \ ' plugins ('.len(s:update.bar).'/'.total.')')
        call plug#progress_bar(2, s:update.bar, total)
        call plug#switch_out()
    endif
endfunction

function! plug#logpos(name)
    let max = line('$')
    for i in range(4, max > 4 ? max : 4)
        if getline(i) =~# '^[-+x*] '.a:name.':'
            for j in range(i + 1, max > 5 ? max : 5)
                if getline(j) !~ '^ '
                    return [i, j - 1]
                endif
            endfor
            return [i, i]
        endif
    endfor
    return [0, 0]
endfunction

function! plug#log(bullet, name, lines)
    if plug#switch_in()
        let [b, e] = plug#logpos(a:name)
        if b > 0
            silent execute printf('%d,%d d _', b, e)
            if b > winheight('.')
                let b = 4
            endif
        else
            let b = 4
        endif
        " FIXME For some reason, nomodifiable is set after :d in vim8
        setlocal modifiable
        call append(b - 1, plug#format_message(a:bullet, a:name, a:lines))
        call plug#switch_out()
    endif
endfunction

function! plug#update_vim()
    let s:jobs = {}

    call plug#bar()
    call plug#tick()
endfunction

function! plug#tick()
    let pull = s:update.pull
    let prog = plug#progress_opt(s:nvim || s:vim8)
    while 1 " Without TCO, Vim stack is bound to explode
        if empty(s:update.todo)
            if empty(s:jobs) && !s:update.fin
                call plug#update_finish()
                let s:update.fin = 1
            endif
            return
        endif

        let name = keys(s:update.todo)[0]
        let spec = remove(s:update.todo, name)
        let new  = empty(globpath(spec.dir, '.git', 1))

        call plug#log(new ? '+' : '*', name, pull ? 'Updating ...' : 'Installing ...')
        redraw

        let has_tag = has_key(spec, 'tag')
        if !new
            let [error, _] = plug#git_validate(spec, 0)
            if empty(error)
                if pull
                    let cmd = plug#git_version_requirement(2) ? ['git', '-c', 'credential.helper=', 'fetch'] : ['git', 'fetch']
                    if has_tag && !empty(globpath(spec.dir, '.git/shallow'))
                        call extend(cmd, ['--depth', '99999999'])
                    endif
                    if !empty(prog)
                        call add(cmd, prog)
                    endif
                    call plug#spawn(name, cmd, { 'dir': spec.dir })
                else
                    let s:jobs[name] = { 'running': 0, 'lines': ['Already installed'], 'error': 0 }
                endif
            else
                let s:jobs[name] = { 'running': 0, 'lines': plug#lines(error), 'error': 1 }
            endif
        else
            let cmd = ['git', 'clone']
            if !has_tag
                call extend(cmd, s:clone_opt)
            endif
            if !empty(prog)
                call add(cmd, prog)
            endif
            let branch = plug#git_origin_branch(spec)
            if !empty(branch)
                call extend(cmd, ['-b', branch])
            endif
            call plug#spawn(name, extend(cmd, [spec.uri, plug#trim(spec.dir)]), { 'new': 1 })
        endif

        if !s:jobs[name].running
            call plug#reap(name)
        endif
        if len(s:jobs) >= s:update.threads
            break
        endif
    endwhile
endfunction

function! plug#shellesc_cmd(arg, script)
    let escaped = substitute('"'.a:arg.'"', '[&|<>()@^!"]', '^&', 'g')
    return substitute(escaped, '%', (a:script ? '%' : '^') . '&', 'g')
endfunction

function! plug#shellesc_ps1(arg)
    return "'".substitute(escape(a:arg, '\"'), "'", "''", 'g')."'"
endfunction

function! plug#shellesc_sh(arg)
    return "'".substitute(a:arg, "'", "'\\\\''", 'g')."'"
endfunction

" Escape the shell argument based on the shell.
" Vim and Neovim's shellescape() are insufficient.
" 1. shellslash determines whether to use single/double quotes.
"    Double-quote escaping is fragile for cmd.exe.
" 2. It does not work for powershell.
" 3. It does not work for *sh shells if the command is executed
"    via cmd.exe (ie. cmd.exe /c sh -c command command_args)
" 4. It does not support batchfile syntax.
"
" Accepts an optional dictionary with the following keys:
" - shell: same as Vim/Neovim 'shell' option.
"          If unset, fallback to 'cmd.exe' on Windows or 'sh'.
" - script: If truthy and shell is cmd.exe, escape for batchfile syntax.
function! plug#shellescape(arg, ...)
    if a:arg =~# '^[A-Za-z0-9_/:.-]\+$'
        return a:arg
    endif
    let opts = a:0 > 0 && type(a:1) == s:TYPE.dict ? a:1 : {}
    let shell = get(opts, 'shell', s:is_win ? 'cmd.exe' : 'sh')
    let script = get(opts, 'script', 1)
    if shell =~# 'cmd\(\.exe\)\?$'
        return plug#shellesc_cmd(a:arg, script)
    elseif plug#is_powershell(shell)
        return plug#shellesc_ps1(a:arg)
    endif
    return plug#shellesc_sh(a:arg)
endfunction

function! plug#glob_dir(path)
    return map(filter(plug#glob(a:path, '**'), 'isdirectory(v:val)'), 'plug#dirpath(v:val)')
endfunction

function! plug#progress_bar(line, bar, total)
    call setline(a:line, '[' . plug#lpad(a:bar, a:total) . ']')
endfunction

function! plug#compare_git_uri(a, b)
    " See `git help clone'
    " https:// [user@] github.com[:port] / junegunn/vim-plug [.git]
    "          [git@]  github.com[:port] : junegunn/vim-plug [.git]
    " file://                            / junegunn/vim-plug        [/]
    "                                    / junegunn/vim-plug        [/]
    let pat = '^\%(\w\+://\)\='.'\%([^@/]*@\)\='.'\([^:/]*\%(:[0-9]*\)\=\)'.'[:/]'.'\(.\{-}\)'.'\%(\.git\)\=/\?$'
    let ma = matchlist(a:a, pat)
    let mb = matchlist(a:b, pat)
    return ma[1:2] ==# mb[1:2]
endfunction

function! plug#format_message(bullet, name, message)
    if a:bullet != 'x'
        return [printf('%s %s: %s', a:bullet, a:name, plug#lastline(a:message))]
    else
        let lines = map(plug#lines(a:message), '"    ".v:val')
        return extend([printf('x %s:', a:name)], lines)
    endif
endfunction

function! plug#with_cd(cmd, dir, ...)
    let script = a:0 > 0 ? a:1 : 1
    let pwsh = plug#is_powershell(&shell)
    let cd = s:is_win && !pwsh ? 'cd /d' : 'cd'
    let sep = pwsh ? ';' : '&&'
    return printf('%s %s %s %s', cd, plug#shellescape(a:dir, {'script': script, 'shell': &shell}), sep, a:cmd)
endfunction

function! plug#system(cmd, ...)
    let batchfile = ''
    try
        let [sh, shellcmdflag, shrd] = plug#chsh(1)
        if type(a:cmd) == s:TYPE.list
            " Neovim's system() supports list argument to bypass the shell
            " but it cannot set the working directory for the command.
            " Assume that the command does not rely on the shell.
            if has('nvim') && a:0 == 0
                return system(a:cmd)
            endif
            let cmd = join(map(copy(a:cmd), 'plug#shellescape(v:val, {"shell": &shell, "script": 0})'))
            if plug#is_powershell(&shell)
                let cmd = '& ' . cmd
            endif
        else
            let cmd = a:cmd
        endif
        if a:0 > 0
            let cmd = plug#with_cd(cmd, a:1, type(a:cmd) != s:TYPE.list)
        endif
        if s:is_win && type(a:cmd) != s:TYPE.list
            let [batchfile, cmd] = plug#batchfile(cmd)
        endif
        return system(cmd)
    finally
        let [&shell, &shellcmdflag, &shellredir] = [sh, shellcmdflag, shrd]
        if s:is_win && filereadable(batchfile)
            call delete(batchfile)
        endif
    endtry
endfunction

function! plug#system_chomp(...)
    let ret = call('plug#system', a:000)
    return v:shell_error ? '' : substitute(ret, '\n$', '', '')
endfunction

function! plug#git_validate(spec, check_branch)
    let err = ''
    if isdirectory(a:spec.dir)
        let result = [plug#git_local_branch(a:spec.dir), plug#git_origin_url(a:spec.dir)]
        let remote = result[-1]
        if empty(remote)
            let err = join([remote, 'PlugClean required.'], "\n")
        elseif !plug#compare_git_uri(remote, a:spec.uri)
            let err = join(['Invalid URI: '.remote,
                        \ 'Expected:    '.a:spec.uri,
                        \ 'PlugClean required.'], "\n")
        elseif !a:check_branch
            return ['', 0]
        elseif has_key(a:spec, 'commit')
            let sha = plug#git_revision(a:spec.dir)
            if empty(sha)
                let err = join(add(result, 'PlugClean required.'), "\n")
            elseif !plug#hash_match(sha, a:spec.commit)
                let err = join([printf('Invalid HEAD (expected: %s, actual: %s)',
                            \ a:spec.commit[:6], sha[:6]),
                            \ 'PlugUpdate required.'], "\n")
            endif
        elseif has_key(a:spec, 'tag')
            let tag = plug#system_chomp('git describe --exact-match --tags HEAD 2>&1', a:spec.dir)
            if a:spec.tag !=# tag && a:spec.tag !~ '\*'
                let err = printf('Invalid tag: %s (expected: %s). Try PlugUpdate.',
                            \ (empty(tag) ? 'N/A' : tag), a:spec.tag)
            endif
        elseif a:check_branch
            let current_branch = result[0]
            let origin_branch = plug#git_origin_branch(a:spec)
            if origin_branch !=# current_branch
                let err = printf('Invalid branch: %s (expected: %s). Try PlugUpdate.',
                            \ current_branch, origin_branch)
            endif
            if empty(err)
                let ahead_behind = split(plug#lastline(plug#system([
                            \ 'git', 'rev-list', '--count', '--left-right',
                            \ printf('HEAD...origin/%s', origin_branch)
                            \ ], a:spec.dir)), '\t')
                if v:shell_error || len(ahead_behind) != 2
                    let err = "Failed to compare with the origin. The default branch might have changed.\nPlugClean required."
                else
                    let [ahead, behind] = ahead_behind
                    if ahead && behind
                        " Only mention PlugClean if diverged, otherwise it's likely to be
                        " pushable (and probably not that messed up).
                        let err = printf(
                                    \ "Diverged from origin/%s (%d commit(s) ahead and %d commit(s) behind!\n"
                                    \ .'Backup local changes and run PlugClean and PlugUpdate to reinstall it.', origin_branch, ahead, behind)
                    elseif ahead
                        let err = printf("Ahead of origin/%s by %d commit(s).\n"
                                    \ .'Cannot update until local changes are pushed.',
                                    \ origin_branch, ahead)
                    endif
                endif
            endif
        endif
    else
        let err = 'Not found'
    endif
    return [err, err =~# 'PlugClean']
endfunction

function! plug#rm_rf(dir)
    if isdirectory(a:dir)
        return plug#system(s:is_win
                    \ ? 'rmdir /S /Q '.plug#shellescape(a:dir)
                    \ : ['rm', '-rf', a:dir])
    endif
endfunction

function! plug#clean(force)
    call plug#prepare()
    call append(0, 'Searching for invalid plugins in '.g:plug_home)
    call append(1, '')

    " List of valid directories
    let dirs = []
    let errs = {}
    let [cnt, total] = [0, len(g:plugs)]
    for [name, spec] in items(g:plugs)
        if !plug#is_managed(name) || get(spec, 'frozen', 0)
            call add(dirs, spec.dir)
        else
            let [err, clean] = plug#git_validate(spec, 1)
            if clean
                let errs[spec.dir] = plug#lines(err)[0]
            else
                call add(dirs, spec.dir)
            endif
        endif
        let cnt += 1
        call plug#progress_bar(2, repeat('=', cnt), total)
        normal! 2G
        redraw
    endfor

    let allowed = {}
    for dir in dirs
        let allowed[plug#dirpath(plug#plug_fnamemodify(dir, ':h:h'))] = 1
        let allowed[dir] = 1
        for child in plug#glob_dir(dir)
            let allowed[child] = 1
        endfor
    endfor

    let todo = []
    let found = sort(plug#glob_dir(g:plug_home))
    while !empty(found)
        let f = remove(found, 0)
        if !has_key(allowed, f) && isdirectory(f)
            call add(todo, f)
            call append(line('$'), '- ' . f)
            if has_key(errs, f)
                call append(line('$'), '    ' . errs[f])
            endif
            let found = filter(found, 'stridx(v:val, f) != 0')
        endif
    endwhile

    redraw
    if empty(todo)
        call append(line('$'), 'Already clean.')
    else
        let s:clean_count = 0
        call append(3, ['Directories to delete:', ''])
        redraw!
        if a:force || plug#ask_no_interrupt('Delete all directories?')
            call plug#delete([6, line('$')], 1)
        else
            call setline(4, 'Cancelled.')
            nnoremap <silent> <buffer> d :set opfunc=plug#delete_op<cr>g@
            nmap     <silent> <buffer> dd d_
            xnoremap <silent> <buffer> d :<c-u>call plug#delete_op(visualmode(), 1)<cr>
            echo 'Delete the lines (d{motion}) to delete the corresponding directories'
        endif
    endif
    setlocal nomodifiable
endfunction

function! plug#delete_op(type, ...)
    call plug#delete(a:0 ? [line("'<"), line("'>")] : [line("'["), line("']")], 0)
endfunction

function! plug#delete(range, force)
    let [l1, l2] = a:range
    let force = a:force
    let err_count = 0
    while l1 <= l2
        let line = getline(l1)
        if line =~ '^- ' && isdirectory(line[2:])
            execute l1
            redraw!
            let answer = force ? 1 : plug#ask('Delete '.line[2:].'?', 1)
            let force = force || answer > 1
            if answer
                let err = plug#rm_rf(line[2:])
                setlocal modifiable
                if empty(err)
                    call setline(l1, '~'.line[1:])
                    let s:clean_count += 1
                else
                    delete _
                    call append(l1 - 1, plug#format_message('x', line[1:], err))
                    let l2 += len(plug#lines(err))
                    let err_count += 1
                endif
                let msg = printf('Removed %d directories.', s:clean_count)
                if err_count > 0
                    let msg .= printf(' Failed to remove %d directories.', err_count)
                endif
                call setline(4, msg)
                setlocal nomodifiable
            endif
        endif
        let l1 += 1
    endwhile
endfunction

function! plug#upgrade()
    echo 'Downloading the latest version of vim-plug'
    redraw
    let tmp = plug#plug_tempname()
    let new = tmp . '/plug.vim'

    try
        let out = plug#system(['git', 'clone', '--depth', '1', s:plug_src, tmp])
        if v:shell_error
            return plug#err('Error upgrading vim-plug: '. out)
        endif

        if readfile(s:me) ==# readfile(new)
            echo 'vim-plug is already up-to-date'
            return 0
        else
            call rename(s:me, s:me . '.old')
            call rename(new, s:me)
            unlet g:loaded_plug
            echo 'vim-plug has been upgraded'
            return 1
        endif
    finally
        silent! call plug#rm_rf(tmp)
    endtry
endfunction

function! plug#upgrade_specs()
    for spec in values(g:plugs)
        let spec.frozen = get(spec, 'frozen', 0)
    endfor
endfunction

function! plug#status()
    call plug#prepare()
    call append(0, 'Checking plugins')
    call append(1, '')

    let ecnt = 0
    let unloaded = 0
    let [cnt, total] = [0, len(g:plugs)]
    for [name, spec] in items(g:plugs)
        let is_dir = isdirectory(spec.dir)
        if has_key(spec, 'uri')
            if is_dir
                let [err, _] = plug#git_validate(spec, 1)
                let [valid, msg] = [empty(err), empty(err) ? 'OK' : err]
            else
                let [valid, msg] = [0, 'Not found. Try PlugInstall.']
            endif
        else
            if is_dir
                let [valid, msg] = [1, 'OK']
            else
                let [valid, msg] = [0, 'Not found.']
            endif
        endif
        let cnt += 1
        let ecnt += !valid
        " `s:loaded` entry can be missing if PlugUpgraded
        if is_dir && get(s:loaded, name, -1) == 0
            let unloaded = 1
            let msg .= ' (not loaded)'
        endif
        call plug#progress_bar(2, repeat('=', cnt), total)
        call append(3, plug#format_message(valid ? '-' : 'x', name, msg))
        normal! 2G
        redraw
    endfor
    call setline(1, 'Finished. '.ecnt.' error(s).')
    normal! gg
    setlocal nomodifiable
    if unloaded
        echo "Press 'L' on each line to load plugin, or 'U' to update"
        nnoremap <silent> <buffer> L :call plug#status_load(line('.'))<cr>
        xnoremap <silent> <buffer> L :call plug#status_load(line('.'))<cr>
    endif
endfunction

function! plug#extract_name(str, prefix, suffix)
    return matchstr(a:str, '^'.a:prefix.' \zs[^:]\+\ze:.*'.a:suffix.'$')
endfunction

function! plug#status_load(lnum)
    let line = getline(a:lnum)
    let name = plug#extract_name(line, '-', '(not loaded)')
    if !empty(name)
        call plug#load(name)
        setlocal modifiable
        call setline(a:lnum, substitute(line, ' (not loaded)$', '', ''))
        setlocal nomodifiable
    endif
endfunction

function! plug#status_update() range
    let lines = getline(a:firstline, a:lastline)
    let names = filter(map(lines, 'plug#extract_name(v:val, "[x-]", "")'), '!empty(v:val)')
    if !empty(names)
        echo
        execute 'PlugUpdate' join(names)
    endif
endfunction

function! plug#is_preview_window_open()
    silent! wincmd P
    if &previewwindow
        wincmd p
        return 1
    endif
endfunction

function! plug#find_name(lnum)
    for lnum in reverse(range(1, a:lnum))
        let line = getline(lnum)
        if empty(line)
            return ''
        endif
        let name = plug#extract_name(line, '-', '')
        if !empty(name)
            return name
        endif
    endfor
    return ''
endfunction

function! plug#preview_commit()
    if b:plug_preview < 0
        let b:plug_preview = !plug#is_preview_window_open()
    endif

    let sha = matchstr(getline('.'), '^  \X*\zs[0-9a-f]\{7,9}')
    if empty(sha)
        let name = matchstr(getline('.'), '^- \zs[^:]*\ze:$')
        if empty(name)
            return
        endif
        let title = 'HEAD@{1}..'
        let command = 'git diff --no-color HEAD@{1}'
    else
        let title = sha
        let command = 'git show --no-color --pretty=medium '.sha
        let name = plug#find_name(line('.'))
    endif

    if empty(name) || !has_key(g:plugs, name) || !isdirectory(g:plugs[name].dir)
        return
    endif

    if exists('g:plug_pwindow') && !plug#is_preview_window_open()
        execute g:plug_pwindow
        execute 'e' title
    else
        execute 'pedit' title
        wincmd P
    endif
    setlocal previewwindow filetype=git buftype=nofile bufhidden=wipe nobuflisted modifiable
    let batchfile = ''
    try
        let [sh, shellcmdflag, shrd] = plug#chsh(1)
        let cmd = 'cd '.plug#shellescape(g:plugs[name].dir).' && '.command
        if s:is_win
            let [batchfile, cmd] = plug#batchfile(cmd)
        endif
        execute 'silent %!' cmd
    finally
        let [&shell, &shellcmdflag, &shellredir] = [sh, shellcmdflag, shrd]
        if s:is_win && filereadable(batchfile)
            call delete(batchfile)
        endif
    endtry
    setlocal nomodifiable
    nnoremap <silent> <buffer> q :q<cr>
    wincmd p
endfunction

function! plug#section(flags)
    call search('\(^[x-] \)\@<=[^:]\+:', a:flags)
endfunction

function! plug#format_git_log(line)
    let indent = '  '
    let tokens = split(a:line, nr2char(1))
    if len(tokens) != 5
        return indent.substitute(a:line, '\s*$', '', '')
    endif
    let [graph, sha, refs, subject, date] = tokens
    let tag = matchstr(refs, 'tag: [^,)]\+')
    let tag = empty(tag) ? ' ' : ' ('.tag.') '
    return printf('%s%s%s%s%s (%s)', indent, graph, sha, tag, subject, date)
endfunction

function! plug#append_ul(lnum, text)
    call append(a:lnum, ['', a:text, repeat('-', len(a:text))])
endfunction

function! plug#diff()
    call plug#prepare()
    call append(0, ['Collecting changes ...', ''])
    let cnts = [0, 0]
    let bar = ''
    let total = filter(copy(g:plugs), 'plug#is_managed(v:key) && isdirectory(v:val.dir)')
    call plug#progress_bar(2, bar, len(total))
    for origin in [1, 0]
        let plugs = reverse(sort(items(filter(copy(total), (origin ? '' : '!').'(has_key(v:val, "commit") || has_key(v:val, "tag"))'))))
        if empty(plugs)
            continue
        endif
        call plug#append_ul(2, origin ? 'Pending updates:' : 'Last update:')
        for [k, v] in plugs
            let branch = plug#git_origin_branch(v)
            if len(branch)
                let range = origin ? '..origin/'.branch : 'HEAD@{1}..'
                let cmd = ['git', 'log', '--graph', '--color=never']
                if plug#git_version_requirement(2, 10, 0)
                    call add(cmd, '--no-show-signature')
                endif
                call extend(cmd, ['--pretty=format:%x01%h%x01%d%x01%s%x01%cr', range])
                if has_key(v, 'rtp')
                    call extend(cmd, ['--', v.rtp])
                endif
                let diff = plug#system_chomp(cmd, v.dir)
                if !empty(diff)
                    let ref = has_key(v, 'tag') ? (' (tag: '.v.tag.')') : has_key(v, 'commit') ? (' '.v.commit) : ''
                    call append(5, extend(['', '- '.k.':'.ref], map(plug#lines(diff), 'plug#format_git_log(v:val)')))
                    let cnts[origin] += 1
                endif
            endif
            let bar .= '='
            call plug#progress_bar(2, bar, len(total))
            normal! 2G
            redraw
        endfor
        if !cnts[origin]
            call append(5, ['', 'N/A'])
        endif
    endfor
    call setline(1, printf('%d plugin(s) updated.', cnts[0])
                \ . (cnts[1] ? printf(' %d plugin(s) have pending updates.', cnts[1]) : ''))

    if cnts[0] || cnts[1]
        nnoremap <silent> <buffer> <plug>(plug-preview) :silent! call plug#preview_commit()<cr>
        if empty(maparg("\<cr>", 'n'))
            nmap <buffer> <cr> <plug>(plug-preview)
        endif
        if empty(maparg('o', 'n'))
            nmap <buffer> o <plug>(plug-preview)
        endif
    endif
    if cnts[0]
        nnoremap <silent> <buffer> X :call plug#revert()<cr>
        echo "Press 'X' on each block to revert the update"
    endif
    normal! gg
    setlocal nomodifiable
endfunction

function! plug#revert()
    if search('^Pending updates', 'bnW')
        return
    endif

    let name = plug#find_name(line('.'))
    if empty(name) || !has_key(g:plugs, name) ||
                \ input(printf('Revert the update of %s? (y/N) ', name)) !~? '^y'
        return
    endif

    call plug#system('git reset --hard HEAD@{1} && git checkout '.plug#shellescape(g:plugs[name].branch).' --', g:plugs[name].dir)
    setlocal modifiable
    normal! "_dap
    setlocal nomodifiable
    echo 'Reverted'
endfunction

function! plug#snapshot(force, ...) abort
    call plug#prepare()
    setf vim
    call append(0, ['" Generated by vim-plug',
                \ '" '.strftime("%c"),
                \ '" :source this file in vim to restore the snapshot',
                \ '" or execute: vim -S snapshot.vim',
                \ '', '', 'PlugUpdate!'])

    let anchor = line('$') - 3
    let names = sort(keys(filter(copy(g:plugs),
                \'has_key(v:val, "uri") && isdirectory(v:val.dir)')))
    for name in reverse(names)
        let sha = has_key(g:plugs[name], 'commit') ? g:plugs[name].commit : plug#git_revision(g:plugs[name].dir)
        if !empty(sha)
            call append(anchor, printf("silent! let g:plugs['%s'].commit = '%s'", name, sha))
            redraw
        endif
    endfor

    if a:0 > 0
        let fn = plug#plug_expand(a:1)
        if filereadable(fn) && !(a:force || plug#ask(a:1.' already exists. Overwrite?'))
            return
        endif
        call writefile(getline(1, '$'), fn)
        echo 'Saved as '.a:1
        silent execute 'e' plug#esc(fn)
        setf vim
    endif
endfunction

function! plug#split_rtp()
    return split(&rtp, '\\\@<!,')
endfunction

let s:first_rtp = plug#escrtp(get(plug#split_rtp(), 0, ''))
let s:last_rtp  = plug#escrtp(get(plug#split_rtp(), -1, ''))

if exists('g:plugs')
    let g:plugs_order = get(g:, 'plugs_order', keys(g:plugs))
    call plug#upgrade_specs()
    call plug#define_commands()
endif

let &cpo = s:cpo_save
unlet s:cpo_save
