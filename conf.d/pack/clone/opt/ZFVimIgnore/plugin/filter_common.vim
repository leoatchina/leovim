
if !get(g:, 'ZFIgnore_filter_common', 1)
    finish
endif

" some werid thing would happen if:
" * cwd or cwd's parent is ignored
" * `~` or user directory is ignored
" * special patterns: `.` `*`
" * vim's rtp is ignored

function! ZFIgnore_filter_common(ignore, option)
    let ret = {
                \   'file_filters' : [],
                \   'dir_filters' : [],
                \ }
    let filterMap = {}

    if get(a:option, 'filter_spec', 1)
        let filterMap['~'] = 1
        let filterMap['.'] = 1
        let filterMap['..'] = 1
        let filterMap['*'] = 1
        let filterMap['**'] = 1
    endif

    if get(a:option, 'filter_HOME', 1)
        for item in split(substitute($HOME, '\\', '/', 'g'), '/')
            let filterMap[item] = 1
        endfor
    endif

    if get(a:option, 'filter_cwd', 1)
        for item in split(substitute(getcwd(), '\\', '/', 'g'), '/')
            let filterMap[item] = 1
        endfor
    endif

    if get(a:option, 'filter_rtp', 1)
        for rtp in split(&rtp, ',')
            for item in split(substitute(rtp, '\\', '/', 'g'), '/')
                let filterMap[item] = 1
            endfor
        endfor
    endif

    let filter = keys(filterMap)
    for type in ['file', 'dir']
        let i = len(a:ignore[type]) - 1
        while i >= 0
            let filterIndex = s:checkFilter(filter, a:ignore[type][i])
            if filterIndex >= 0
                let pattern = remove(a:ignore[type], i)
                call add(a:ignore[type . '_filtered'], pattern)
                call add(ret[type . '_filters'], filter[filterIndex])
            elseif match(a:ignore[type][i], '\(^\|,\)\*\+,\|,\*\+\($\|,\)') >= 0 " (^|,)\*+,|,\*+($|,)
                " filter out:
                "   xxx,*,yyy
                "   xxx,*
                "   *,yyy
                " to prevent result to `aaa,xxx,*,yyy,bbb` for wildignore
                " typically for typo of `xxx.*` to `xxx,*`
                let pattern = remove(a:ignore[type], i)
                call add(a:ignore[type . '_filtered'], pattern)
                call add(ret[type . '_filters'], '(^|,)\*+,|,\*+($|,)')
            endif
            let i -= 1
        endwhile
    endfor
    return ret
endfunction

if !exists('g:ZFIgnoreFilter')
    let g:ZFIgnoreFilter = {}
endif
if !exists("g:ZFIgnoreFilter['ZFIgnore_filter_common']")
    if !exists('g:ZFIgnoreOptionDefault')
        let g:ZFIgnoreOptionDefault = {}
    endif
    if !exists("g:ZFIgnoreOptionDefault['filter_spec']")
        let g:ZFIgnoreOptionDefault['filter_spec'] = 1
    endif
    if !exists("g:ZFIgnoreOptionDefault['filter_HOME']")
        let g:ZFIgnoreOptionDefault['filter_HOME'] = 1
    endif
    if !exists("g:ZFIgnoreOptionDefault['filter_cwd']")
        let g:ZFIgnoreOptionDefault['filter_cwd'] = 1
    endif
    if !exists("g:ZFIgnoreOptionDefault['filter_rtp']")
        let g:ZFIgnoreOptionDefault['filter_rtp'] = 0
    endif

    let g:ZFIgnoreFilter['ZFIgnore_filter_common'] = function('ZFIgnore_filter_common')
endif

function! s:checkFilter(filter, pattern)
    let pattern = ZFIgnorePatternToRegexp(a:pattern)
    if empty(pattern)
        return -1
    endif
    let pattern = '\c' . pattern
    let i = 0
    let iEnd = len(a:filter)
    while i < iEnd
        if match(a:filter[i], pattern) >= 0
            return i
        endif
        let i += 1
    endwhile
    return -1
endfunction

