" Tag Highlighter:
"   Author:  A. S. Budden <abudden _at_ gmail _dot_ com>
"   Date:    25/07/2011
"   Version: 1
" Copyright: Copyright (C) 2009-2011 A. S. Budden
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
	if &cp || (exists('g:loaded_TagHLLibraries') && (g:plugin_development_mode != 1))
		throw "Already loaded"
	endif
catch
	finish
endtry
let g:loaded_TagHLLibraries = 1

function! TagHighlight#Libraries#LoadLibraries()
	if has_key(g:TagHighlightPrivate,'Libraries')
		" Already loaded
		return
	endif

	let g:TagHighlightPrivate['LibraryPath'] = g:TagHighlightPrivate['PluginPath'] . '/standard_libraries'
	let g:TagHighlightPrivate['Libraries'] = {}
	let library_config_files = split(glob(g:TagHighlightPrivate['LibraryPath'] . '/*/library_types.txt'), '\n')

	let required_keys = ["LibraryName","TypesFiles","CheckMode","TypesSuffixes"]
	for library_config in library_config_files
		let skip = 0
		let library_details = TagHighlight#LoadDataFile#LoadFile(library_config)
		for key in required_keys
			if ! has_key(library_details, key)
				echomsg "Could not load library from " . library_config
				let skip = 1
				break
			endif
		endfor
		if skip
			continue
		endif
		" Config looks valid; check fields that should be lists are:
		let list_keys = ["TypesFiles","TypesSuffixes","MatchREs"]
		for key in list_keys
			if has_key(library_details,key) && type(library_details[key]) == type('')
				let value = library_details[key]
				unlet library_details[key]
				let library_details[key] = [value]
			endif
		endfor
		" Store the absolute path to the all types files
		let library_details['TypesFileFullPaths'] = []
		for types_file in library_details['TypesFiles']
			let library_details['TypesFileFullPaths'] += [fnamemodify(library_config, ':p:h') . '/' . types_file]
		endfor

		" Handle some defaults
		if ! has_key(library_details,'MatchREs')
			" Default matcher will never match on any file
			let library_details['MatchREs'] = ['.\%^']
		endif
		if ! has_key(library_details, 'CustomFunction')
			" Default custom function will always return 'Skip'
			let library_details['CustomFunction'] = 'TagHighlight#Libraries#NeverMatch'
		endif
		if ! has_key(library_details, 'MatchLines')
			" Just use a suitable default value
			let library_details['MatchLines'] = 30
		endif
		
		let g:TagHighlightPrivate['Libraries'][library_details['LibraryName']] = library_details
	endfor
endfunction

function! TagHighlight#Libraries#FindUserLibraries()
	" Open any explicitly configured libraries
	let user_library_dir = TagHighlight#Option#GetOption('UserLibraryDir')
	let user_libraries = TagHighlight#Option#GetOption('UserLibraries')

	let libraries_to_load = []

	for library in user_libraries
		" If it looks like an absolute path, just load it
		if (library[1] == ':' || library['0'] == '/') && filereadable(library)
			let libraries_to_load +=
						\ [{
						\     'Name': 'User Library',
						\     'Filename': fnamemodify(library, ':t'),
						\     'Path': fnamemodify(library, '%:p'),
						\ }]
		" Otherwise, try appending to the library dir
		elseif filereadable(user_library_dir . '/' . library)
			let library_path = user_library_dir . '/' . library
			let libraries_to_load +=
						\ [{
						\     'Name': 'User Library',
						\     'Filename': fnamemodify(library_path, ':t'),
						\     'Path': fnamemodify(library_path, '%:p'),
						\ }]
		else
			echomsg "Cannot load user library " . library
		endif
	endfor
	return libraries_to_load
endfunction

function! TagHighlight#Libraries#FindLibraryFiles(suffix)
	" Should only actually read the libraries once
	call TagHighlight#Libraries#LoadLibraries()

	let libraries_to_load = []
	let forced_standard_libraries = TagHighlight#Option#GetOption('ForcedStandardLibraries')

	if TagHighlight#Option#GetOption('DisableStandardLibraries')
		return []
	endif

	for library in values(g:TagHighlightPrivate['Libraries'])
		let load = 0
		if index(library['TypesSuffixes'], a:suffix) != -1
			" Suffix is in the list of acceptable ones
			if index(forced_standard_libraries, library['LibraryName']) != -1
				"echomsg "Library(".library['LibraryName']."): Forced"
				let load = 1
			elseif library['CheckMode'] == 'Always'
				"echomsg "Library(".library['LibraryName']."): Always"
				let load = 1
			elseif library['CheckMode'] == 'MatchStart'
				"echomsg "Library(".library['LibraryName']."): MatchStart"
				for matcher in library['MatchREs']
					call cursor(1,1)
					if search(matcher, 'nc',library['MatchLines'])
						"echomsg "Match!"
						let load = 1
						break
					endif
				endfor
			elseif library['CheckMode'] == 'MatchEnd'
				"echomsg "Library(".library['LibraryName']."): MatchEnd"
				for matcher in library['MatchREs']
					call cursor(1000000,1000000)
					if search(matcher, 'ncb', library['MatchLines'])
						"echomsg "Match!"
						let load = 1
						break
					endif
				endfor
			elseif library['CheckMode'] == 'Custom'
				"echomsg "Library(".library['LibraryName']."): Custom (".library['CustomFunction'].")"
				" The hope is that this won't really ever be used, but
				" call the function and check that it returns the right
				" kind of thing (takes suffix as parameter)
				exe 'let result = ' . library['CustomFunction'] . '(' . a:suffix . ')'
				if result == 'Load'
					let load = 1
				elseif result == 'Skip'
					" Pass
				else
					echoerr "Misconfigured library: custom function has invalid return value"
				endif
			endif
		endif
		if load
			for full_path in library['TypesFileFullPaths']
				let libraries_to_load += 
							\ [{
							\     'Name': library['LibraryName'],
							\     'Filename': fnamemodify(full_path, ':t'),
							\     'Path': full_path,
							\ }]
			endfor
		else
			"echomsg "No match:" . library['LibraryName']
		endif
	endfor

	return libraries_to_load
endfunction

function! TagHighlight#Libraries#NeverMatch()
	return 'Skip'
endfunction
