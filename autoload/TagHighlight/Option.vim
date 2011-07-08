" Tag Highlighter:
"   Author:  A. S. Budden <abudden _at_ gmail _dot_ com>
"   Date:    29/06/2011
"   Version: 1
" Copyright: Copyright (C) 2010 A. S. Budden
"            Permission is hereby granted to use and distribute this code,
"            with or without modifications, provided that this copyright
"            notice is copied with it. Like anything else that's free,
"            <+$FILENAME$>.vim is provided *as is* and comes with no
"            warranty of any kind, either expressed or implied. By using
"            this plugin, you agree that in no event will the copyright
"            holder be liable for any damages resulting from the use
"            of this software.

" ---------------------------------------------------------------------
try
	if &cp || (exists('g:loaded_TagHLOption') && (g:plugin_development_mode != 1))
		throw "Already loaded"
	endif
catch
	finish
endtry
let g:loaded_TagHLOption = 1

" TODO: Options should be customisable per project (following the same method
" as looking for tags/types... look for options file).

let s:log_defaults = 1
let g:TagHighlightOptionDefaults = {}

function! TagHighlight#Option#GetOption(name, default)
	let opt = a:default

	if s:log_defaults
		if has_key(g:TagHighlightOptionDefaults, a:name)
			if g:TagHighlightOptionDefaults[a:name] != a:default
				echoerr "Different defaults proposed for option " . a:name . ": " . string(a:default) . " != " . string(g:TagHighlightOptionDefaults[a:name])
			endif
		else
			let g:TagHighlightOptionDefaults[a:name] = a:default
		endif
	endif

	" Option priority (highest first):
	" * buffer dictionary,
	" * global dictionary,
	if has_key(g:TagHighlightSettings, a:name)
		let opt = g:TagHighlightSettings[a:name]
	endif
	if exists('b:TagHighlightSettings') && has_key(b:TagHighlightSettings, a:name)
		let opt = b:TagHighlightSettings[a:name]
	endif
	return opt
endfunction

function! TagHighlight#Option#CopyOptions()
	let result = {}
	for key in keys(g:TagHighlightSettings)
		if type(g:TagHighlightSettings[key]) == type([])
			let result[key] = g:TagHighlightSettings[key][:]
		elseif type(g:TagHighlightSettings[key]) == type({})
			let result[key] = deepcopy(g:TagHighlightSettings[key])
		else
			let result[key] = g:TagHighlightSettings[key]
		endif
	endfor
	if exists('b:TagHighlightSettings')
		for key in keys(b:TagHighlightSettings)
			if type(b:TagHighlightSettings[key]) == type([])
				let result[key] = b:TagHighlightSettings[key][:]
			elseif type(b:TagHighlightSettings[key]) == type({})
				let result[key] = deepcopy(b:TagHighlightSettings[key])
			else
				let result[key] = b:TagHighlightSettings[key]
			endif
		endfor
	endif

	return result
endfunction
