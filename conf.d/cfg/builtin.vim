vim9script
set autocomplete
set cpt=.^5,w^5,b^5,u^5
set cot=popup,longest
if exists('&pumborder')
	set pb=shadow
endif
set cpp=highlight:Normal

func SmartTab()
	if &cot !~ 'longest\|preinsert' || !exists("*preinserted") || !preinserted()
		return pumvisible() ? "\<c-n>" : "\<tab>"
	endif
	let info = complete_info()
	let items = info->has_key('matches') ? info.matches : info.items
	if items[0].word[:-2] =~ $'\C{info.preinserted_text}$'
		return "\<c-n>"
	endif
	let postfix = getline('.')->strpart(col('.') - 1)->matchstr('^\k\+')
	if items[0].word =~ $'\C{postfix}$'
		let hops = postfix->len() - info.preinserted_text->len()
		return "\<c-y>" . repeat("\<right>", hops)
	endif
	return "\<c-y>"
endfunc

inoremap <silent><expr> <tab> SmartTab()
inoremap <silent><expr> <s-tab> pumvisible() ? "\<c-p>" : "\<s-tab>"
inoremap <silent><expr> <PageDown> exists("*preinserted") && preinserted() ? "\<c-y>" : "\<PageDown>"

hi link PreInsert LineNr


set cpt+=FAbbrevCompletor
def! g:AbbrevCompletor(findstart: number, base: string): any
	if findstart > 0
		var prefix = getline('.')->strpart(0, col('.') - 1)->matchstr('\S\+$')
		if prefix->empty()
			return -2
		endif
		return col('.') - prefix->len() - 1
	endif
	var lines = execute('ia', 'silent!')
	if lines =~? gettext('No abbreviation found')
		return v:none  # Suppresses warning message
	endif
	var items = []
	for line in lines->split("\n")
		var m = line->matchlist('\v^i\s+\zs(\S+)\s+(.*)$')
		if m->len() > 2 && m[1]->stridx(base) == 0
			items->add({ word: m[1], menu: 'abbr', info: m[2], dup: 1 })
		endif
	endfor
	return items->empty() ? v:none : items
enddef
