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
let s:opt_prefix = 'TagHL'

function! TagHighlight#Option#GetOption(name, default)
	let opt = a:default

	" Option priority (highest first):
	" * buffer dictionary,
	" * buffer variable,
	" * global dictionary,
	" * global variable
	" TODO: Make g:TagHighlightSettings exist in plugin/ so that
	" we don't have to do exists() on this all the time
	if exists('g:TagHighlightSettings') && has_key(g:TagHighlightSettings, a:name)
		let opt = g:TagHighlightSettings[a:name]
	elseif exists('g:' . s:opt_prefix . a:name)
		exe 'let opt = g:' . s:opt_prefix . a:name
	endif
	if exists('b:TagHighlightSettings') && has_key(b:TagHighlightSettings, a:name)
		let opt = b:TagHighlightSettings[a:name]
	elseif exists('b:' . s:opt_prefix . a:name)
		exe 'let opt = b:' . s:opt_prefix . a:name
	endif
	return opt
endfunction

