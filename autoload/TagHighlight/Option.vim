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

function! TagHighlight#Option#LoadOptions()
	if has_key(g:TagHighlightPrivate, 'PluginOptions')
		return
	endif

	let g:TagHighlightPrivate['PluginOptions'] = []
	let options = TagHighlight#LoadDataFile#LoadDataFile('options.txt')

	for option_dest in keys(options)
		if has_key(options[option_dest], 'VimOptionMap')
			let option = deepcopy(options[option_dest])
			let option['Destination'] = option_dest
			let g:TagHighlightPrivate['PluginOptions'] += [option]
		endif
	endfor
endfunction

function! TagHighlight#Option#GetOption(name)
	" Check we've loaded the options
	call TagHighlight#Option#LoadOptions()

	" Check this option exists
	let found = 0
	for option in g:TagHighlightPrivate['PluginOptions']
		if option['VimOptionMap'] == a:name
			let found = 1
			break
		endif
	endfor
	if ! found
		throw "Unrecognised option:" .a:name
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

	if ! exists('opt')
		" We haven't found it, return the default
		let default = option['Default']
		if option['Type'] == 'list'
			let opt = []
			if type(default) == type('')
				if default == '[]' || default == ''
					let parsed_default = []
				else
					let parsed_default = [default]
				endif
			else
				let parsed_default = default
			endif
			for part in parsed_default
				if part =~ '^OPT(\k\+)$'
					let value_name = part[4:len(part)-2]
					let opt += [TagHighlight#Option#GetOption(value_name)]
				else
					let opt += [part]
				endif
			endfor
		elseif option['Type'] == 'bool'
			if default == 'True'
				let opt = 1
			elseif default == 'False'
				let opt = 0
			else
				throw "Unrecognised bool value"
			endif
		elseif option['Type'] == 'string'
			if default =~ '^OPT(\k\+)$'
				let value_name = default[4:len(default)-2]
				let opt = TagHighlight#Option#GetOption(value_name)
			else
				let opt = default
			endif
		endif
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
