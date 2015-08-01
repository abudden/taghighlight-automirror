" Tag Highlighter:
"   Author:  A. S. Budden <abudden _at_ gmail _dot_ com>
" Copyright: Copyright (C) 2013 A. S. Budden
"            Permission is hereby granted to use and distribute this code,
"            with or without modifications, provided that this copyright
"            notice is copied with it. Like anything else that's free,
"            the TagHighlight plugin is provided *as is* and comes with no
"            warranty of any kind, either expressed or implied. By using
"            this plugin, you agree that in no event will the copyright
"            holder be liable for any damages resulting from the use
"            of this software.

" ---------------------------------------------------------------------

try
	if &cp || v:version < 700 || (exists('g:loaded_TagHLBufferEntry') && (g:plugin_development_mode != 1))
		throw "Already loaded"
	endif
catch
	finish
endtry
let g:loaded_TagHLBufferEntry = 1

function! TagHighlight#BufferEntry#AutoSource()
	let searchresult = TagHighlight#Find#LocateFile('AUTOSOURCE', '')
	if searchresult['Found'] == 1 && searchresult['Exists'] == 1
		exe 'source' searchresult['FullPath']
	endif
endfunction

function! TagHighlight#BufferEntry#BufEnter(filename)
	if ! exists('b:TagHighlightPrivate')
		let b:TagHighlightPrivate = {}
	endif
	if ! has_key(b:TagHighlightPrivate, 'ReadTypesCompleted')
		" In case it hasn't already been run, run the extension
		" checker.
		call TagHighlight#ReadTypes#ReadTypesByExtension()
	endif

	if TagHighlight#Option#GetOption('EnableCscope')
		call TagHighlight#Cscope#BufEnter()
	endif

	if TagHighlight#Option#GetOption('AutoSource')
		call TagHighlight#BufferEntry#AutoSource()
	endif

	call TagHighlight#BufferEntry#SetupVars()

	let b:TagHighlightPrivate['BufEnterInitialised'] = 1
endfunction

function! TagHighlight#BufferEntry#BufLeave(filename)
	if ! exists('b:TagHighlightPrivate')
		let b:TagHighlightPrivate = {}
	endif

	if TagHighlight#Option#GetOption('EnableCscope')
		call TagHighlight#Cscope#BufLeave()
	endif

	call TagHighlight#BufferEntry#ResetVars()

	let b:TagHighlightPrivate['BufLeaveInitialised'] = 1
endfunction

function! TagHighlight#BufferEntry#SetupVars()
	let custom_globals = TagHighlight#Option#GetOption('CustomGlobals')
	let custom_settings = TagHighlight#Option#GetOption('CustomSettings')

	let custom_vars = {}
	for var in keys(custom_globals)
		let custom_vars['g:'.var] = custom_globals[var]
	endfor
	for var in keys(custom_settings)
		let custom_vars['&'.var] = custom_settings[var]
	endfor

	let s:saved_state = {}
	for var in keys(custom_vars)
		if exists(var)
			let s:saved_state[var] = eval(var)
		else
			let s:saved_state[var] = 'DOES NOT EXIST'
		endif
		exe 'let' var '= custom_vars[var]'
	endfor
endfunction

function! TagHighlight#BufferEntry#ResetVars()
	if ! exists('s:saved_state')
		return
	endif

	for var in keys(s:saved_state)
		if s:saved_state[var] == 'DOES NOT EXIST'
			exe 'unlet' var
		else
			exe 'let' var '= s:saved_state[var]'
		endif
	endfor
endfunction
