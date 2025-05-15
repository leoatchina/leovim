" cpp_tagfunc.vim: Sets up a cpp savvy tagfunc
" GetLatestVimScripts: 6124 1 :AutoInstall: cpptags.vmb

if exists("g:loaded_cpp_tagfunc")
  finish
endif
let g:loaded_cpp_tagfunc = 1

let s:save_cpo = &cpo
set cpo&vim

" Options:
" g:cpptag_logging        -> if 1 enables logging (default false)
" g:cpptag_file           -> if a valid file logs to it. Otherwise it logs to messages

if !exists('g:cpptag_logging')
    let g:cpptag_logging = 0
endif

function s:Log(lines)

    if !g:cpptag_logging
        return
    endif

    if exists('g:cpptag_file')
        " save the arguments in the log file
        let s:bufnr = bufadd(g:cpptag_file)
        call appendbufline(s:bufnr, '$', a:lines)
    else
        " save the arguments in the log file
        if type(a:lines) == v:t_list
            call foreach(a:lines, 'echomsg v:val')
        else
            echomsg a:lines
        endif
    endif

endfunction

function! cpptags#CppTagFunc(pattern, flags, info)

    call s:Log([
\            strftime("%c"),
\            "pattern: " . a:pattern,
\            "flags: " . a:flags,
\            "info: " . string(a:info)
\   ])

    if a:flags =~ 'r'
        call s:Log("regular expression: ordinary tag processing")
        let result = taglist(a:pattern)
        return result
    endif

    if a:flags =~ 'c' && a:info->has_key('buf_ffname')
        " retrieve cursor position
        call s:Log(string(getcurpos(bufwinid(a:info['buf_ffname']))))
    endif

    let search_pattern = a:pattern

    " if pattern matches a builtin operator take heed ctags generates an operator tag
    const operators = ['co_await', 'co_yield', 'co_return']
    for op in operators
        if search_pattern =~ '\<' .. op .. '\>' && search_pattern !~ 'operator\s\+' .. op
            let search_pattern = substitute(search_pattern, op, 'operator ' .. op, "")
            break
        endif
    endfor

    " try special processing
    const domain_pattern = '\(\%(\i\+\%(<.\{-}>\)\?::\)*\)'
    const pattern = '\%#=1\m' .. domain_pattern .. '\(\%(operator\s\+' ..
\                    domain_pattern .. '\)\?\i\+\)\(<.*>\)\?\((.*)\)\?'

    let s = matchlist(search_pattern, pattern)

    " auxiliary dict
    let elems = {
\       'match': s[0],
\       'domain': s[1],
\       'tagid': s[2],
\       'operator_domain': s[3],
\       'template': s[4],
\       'signature': s[5]
\   }

    " check if we are searching for an operator
    let elems['is_operator'] = elems['tagid'] =~ '^operator\>'

    call s:Log(elems)

    if empty(s) || empty(elems['tagid'])
        " doesn't match expected pattern
        call s:Log("unexpected pattern")
        let result = taglist(search_pattern)
    elseif elems['is_operator']
        " search operator for type independently from the operator domain
        let operator_pattern = elems['tagid']->substitute(
\           '^operator\s\+' .. domain_pattern, 'operator .*', "")
        let result = taglist(operator_pattern)
    else
        let result = taglist(elems['tagid'])
    endif

    " in absence of results or non-command case ignore processing
    if empty(result) || a:flags =~ '\%#=1\mc\|i\|r'
        call s:Log("ordinary tag processing")
        return result
    endif

    " filter by exact name, for operators is done already
    if !elems['is_operator']
        let exact_name_pattern = '\m\<' . elems['tagid'] . '$'
        let result = result->filter({idx, val -> val["name"]
\           =~ exact_name_pattern ? 1 : s:Log(string(val) .
\           " removed because name doesn't match: " . exact_name_pattern)})
    endif

    " filter by namespace or class
    if !empty(elems['domain'])
        " split domain and get last identifier (remove <⋯> because ctags doesn't provide hint)
        let id = split(elems['domain'], '::')[-1]
        " remove template specialization on classes (ctags cannot handle it)
        let id = id->substitute("<.*>","","")

        function! s:ClassFilter(idx, val) closure
            let keep = (a:val->has_key('namespace') && a:val['namespace'] =~ id)
\                      || (a:val->has_key('class') && a:val['class'] =~ id)
\                      || (a:val->has_key('struct') && a:val['struct'] =~ id)
            if !keep
                call s:Log(string(a:val) .. " removed because doesn't match namespace/class " .. id)
            endif

            return keep
        endfunction

        " filtering matchlist by class or namespace
        let result = result->filter(funcref("s:ClassFilter"))

        function! s:SortNamespace(item1, item2) closure
            let lastid = id .. "$"
            let l1 = a:item1->has_key('namespace') && a:item1['namespace'] =~ lastid ||
\                    a:item1->has_key('class') && a:item1['class'] =~ lastid
            let l2 = a:item2->has_key('namespace') && a:item2['namespace'] =~ lastid ||
\                    a:item2->has_key('class') && a:item2['class'] =~ lastid

            if l1 && l2
                return 0
            elseif !l1 && l2
                call s:Log("reorder " .. string(a:item1) .. " after " .. string(a:item2))
                return 1
            elseif l1 && !l2
                return -1
            else
                return 0
            endif

        endfunction

        " favour if id is the last namespace/class
        let result = result->sort(funcref("s:SortNamespace"))

    endif

    " filter by template spec
    if empty(elems['template'])
        " remove them with template specialization
        let result = result->filter({idx, val -> val->has_key('specialization') ?
\            s:Log(string(val) .. " removed because is a template specialization") : 1})

        function! s:SortTemplates(item1, item2)
            let t1 = a:item1->has_key('template')
            let t2 = a:item2->has_key('template')

            if t1 && t2
                return 0
            elseif t1 && !t2
                call s:Log("reorder " .. string(a:item1) .. " after " .. string(a:item2))
                return 1
            elseif !t1 && t2
                return -1
            else
                return 0
            endif

        endfunction

        " deprioritize template
        let result = result->sort(funcref("s:SortTemplates"))

    elseif elems['template'] == '<>'
        " use <> to choose template definitions over specialization
        let result = result->filter({idx, val -> val->has_key('template') && !val->has_key('specialization') ?
\            1 : s:Log(string(val) .. " removed because is not a plain template definition")})
    else
        " get param pattern from s3
        let param = elems['template']->substitute('^<\s*\(.*\)\s*>$','\1',"")->substitute('\s*,\s*','\\s*,\\s*',"")

        function! s:TemplateFilter(idx, val) closure
            let keep = (a:val->has_key('specialization') && a:val['specialization'] =~ param)
            if !keep
                call s:Log(string(a:val) .. " removed because doesn't match template specialization " .. param)
            endif

            return keep
        endfunction

        " filtering matchlist by specialization
        let result = result->filter(funcref("s:TemplateFilter"))
    endif

    " filter by signature
    if empty(elems['signature'])

        function! s:Priority(item)
            let p = 0
            let kind = a:item['kind']

            if kind =~ 'class'
                let p += 5
            elseif kind =~ 'struct'
                let p += 4
            elseif kind =~ 'union'
                let p += 3
            elseif kind =~ 'enum'
                let p += 2
            elseif kind !~ 'function\|prototype'
                let p += 1
            endif

            return p
        endfunction

        " prioritize structs, unions, ... over functions and prototypes
        let result = result->sort({ item1, item2 -> s:Priority(item2) - s:Priority(item1) })

    else
        " only methods and functions
        let result = result->filter({idx, val -> val['kind'] =~ 'function\|prototype' ?
\            1 : s:Log(string(val) .. " removed because is neither function nor method")})

        function! s:SortKinds(item1, item2)
            let f1 = a:item1['kind'] == 'function'
            let f2 = a:item2['kind'] == 'function'

            if f1 && f2
                return 0
            elseif !f1 && f2
                call s:Log("reorder " .. string(a:item1) .. " after " .. string(a:item2))
                return 1
            elseif f1 && !f2
                return -1
            else
                return 0
            endif

        endfunction

        " prioritize functions over prototypes
        let result = result->sort(funcref("s:SortKinds"))

        " get sign pattern from s4
        let sign = elems['signature']->substitute('^(\s*\(.*\)\s*)$','\1',"")->substitute('\s*,\s*','\\%(\\s\\+\\i*\\)\\=,\\s*',"")

        if empty(sign)

            function! s:SortEmpty(item1, item2)
                let e1 = a:item1['signature'] == '()'
                let e2 = a:item2['signature'] == '()'

                if e1 && e2
                    return 0
                elseif !e1 && e2
                    call s:Log("reorder " .. string(a:item1) .. " after " .. string(a:item2))
                    return 1
                elseif e1 && !e2
                    return -1
                else
                    return 0
                endif

            endfunction

            " prioritize empty signatures
            let result = result->sort(funcref("s:SortEmpty"))

        else
            function! s:SignatureFilter(idx, val) closure
                let keep = (a:val->has_key('signature') && a:val['signature'] =~ sign)
                if !keep
                    call s:Log(string(a:val) .. " removed because doesn't match signature " .. sign)
                endif

                return keep
            endfunction

            " filtering matchlist by signature
            let result = result->filter(funcref("s:SignatureFilter"))

        endif

    endif

    " filter by operator domain the operator cast
    if !empty(elems['operator_domain'])
        " split domain and get last identifier (remove <⋯> because ctags doesn't provide hint)
        let id = split(elems['operator_domain'], '::')[-1]
        " remove template specialization on classes (ctags cannot handle it)
        let id = id->substitute("<.*>","","")

        function! s:OperatorDomainFilter(idx, val) closure
            " extract operator domain from tag
            let res = matchlist(a:val['name'], 'operator\s\+\(\S*\)::')
            let keep = !empty(res[1]) && res[1] =~ id

            if !keep
                call s:Log(string(a:val) .. " removed because doesn't match operator domain " .. id)
            endif

            return keep
        endfunction

        " prioritize empty signatures
        let result = result->sort(funcref("s:OperatorDomainFilter"))

    endif

  return result
endfunc

let &cpo = s:save_cpo
unlet s:save_cpo
