" Tag Highlighter:
"   Author:  A. S. Budden <abudden _at_ gmail _dot_ com>
"   Date:    05/07/2011
"   Version: 1
" Copyright: Copyright (C) 2011 A. S. Budden
"            Permission is hereby granted to use and distribute this code,
"            with or without modifications, provided that this copyright
"            notice is copied with it. Like anything else that's free,
"            Find.vim is provided *as is* and comes with no
"            warranty of any kind, either expressed or implied. By using
"            this plugin, you agree that in no event will the copyright
"            holder be liable for any damages resulting from the use
"            of this software.

" ---------------------------------------------------------------------
try
	if &cp || (exists('g:loaded_TagHLFind') && (g:plugin_development_mode != 1))
		throw "Already loaded"
	endif
catch
	finish
endtry
let g:loaded_TagHLFind = 1

" Tools for finding files.  When generating the tags and types file, we need
" to decide where to place it.  If the user has configured the mode in which
" everything is based on the current directory (which works well with the
" project plugin), the current directory is what we use.  If the user wants to
" search up for a tags file, we can look for an existing tags file and stop
" when we find one, starting either from the current directory or source
" directory.  If we don't, either use the current directory or the source file
" directory (configuration).
"
" It should also be possible to place the tags file in a remote location and
" use either the current directory, source directory or explicitly set
" directory for the base of the scan.

" Option structure:
"
" [gb]:TagHighlightSettings:
"	DefaultDirModePriority:[Explicit,UpFromCurrent,UpFromFile,CurrentExplicit,FileExplicit]
"	TagFileDirModePriority:["Default"] or as above
"	TypesFileDirModePriority:As tag file
"	ConfigFileDirModePriority:As tag file
"	DirModeSearchWildcard:'' (look for tags file) or something specific (*.uvopt)?
"
" Explicit Locations:
"
"  [gb]:TagHighlightSettings:
"    TagFileDirectory:str (NONE)
"    CtagsOutputFile:str (tags)
"    TypesFileDirectory:str (NONE)
"    TypesPrefix:str (types)
"    ProjectConfigFileName:str (taghl_config.txt)
"    ProjectConfigFileDirectory:str (NONE)

function! TagHighlight#Find#LocateFile(which, suffix)
	" a:which is 'TAGS', 'TYPES', 'CONFIG'
	let default_priority = TagHighlight#Option#GetOption('DefaultDirModePriority',
				\ ["Explicit","UpFromCurrent","UpFromFile","CurrentExplicit","FileExplicit"])
	let search_wildcard = TagHighlight#Option#GetOption('DirModeSearchWildcard', '')

	let file = '<afile>'
	if len(expand(file)) == 0
		let file = '%'
	endif

	if a:which == 'TAGS'
		" Suffix is ignored here
		let filename = TagHighlight#Option#GetOption('CtagsOutputFile','tags')
		let search_priority = TagHighlight#Option#GetOption('TagFileDirModePriority',
					\ ['Default'])
		let explicit_location = TagHighlight#Option#GetOption('TagFileDirectory', 'NONE')
	elseif a:which == 'TYPES'
		let filename = TagHighlight#Option#GetOption('TypesFilePrefix','types') . '_' .
					\ a:suffix . '.vim'
		let search_priority = TagHighlight#Option#GetOption('TypesFileDirModePriority',
					\ ['Default'])
		let explicit_location = TagHighlight#Option#GetOption('TypesFileDirectory', 'NONE')
	elseif a:which == 'CONFIG'
		let filename = TagHighlight#Option#GetOption('ProjectConfigFileName', 'taghl_config.txt')
		let search_priority = TagHighlight#Option#GetOption('ConfigFileDirModePriority',
					\ ['Default'])
		let explicit_location = TagHighlight#Option#GetOption('ProjectConfigFileDirectory', 'NONE')
	else
		throw "Unrecognised file"
	endif

	let search_wildcard = TagHighlight#Option#GetOption('DirModeSearchWildcard',
				\ TagHighlight#Option#GetOption('CtagsOutputFile','tags'))

	if search_priority[0] == 'Default'
		let search_priority = default_priority
	endif

	" Ensure there's no trailing slash on 'explicit location'
	if explicit_location[len(explicit_location)-1] == '/'
		let explicit_location = explicit_location[:len(explicit_location)-2]
	endif

	" Result contains 'Found','FullPath','Directory','Filename','Exists']
	let result = {'Found': 0}

	for search_mode in search_priority
		if search_mode == 'Explicit' && explicit_location != 'NONE'
			" Use explicit location, overriding everything else
			let result['Directory'] = explicit_location
			let result['Filename'] = filename
		elseif search_mode == 'UpFromCurrent'
			" Start in the current directory and search up
			let new_dir = fnamemodify('.',':p:h')
			let dir = ''
			while new_dir != dir
				let dir = new_dir
				if len(glob(dir . '/' . search_wildcard)) > 0
					let result['Directory'] = dir
					let result['Filename'] = filename
					break
				endif
				let new_dir = fnamemodify(dir, ':h')
			endwhile
		elseif search_mode == 'UpFromFile'
			" Start in the directory containing the current file and search up
			let new_dir = fnamemodify(file,':p:h')
			let dir = ''
			while new_dir != dir
				let dir = new_dir
				if len(glob(dir . '/' . search_wildcard)) > 0
					let result['Directory'] = dir
					let result['Filename'] = filename
					break
				endif
				let new_dir = fnamemodify(dir, ':h')
			endwhile
		elseif search_mode == 'CurrentExplicit'
			let result['Directory'] = fnamemodify(file,':p:h')
			let result['Filename'] = filename
		elseif search_mode == 'FileExplicit'
			let result['Directory'] = fnamemodify(file,':p:h')
			let result['Filename'] = filename
		endif
		if has_key(result, 'Directory')
			let result['FullPath'] = result['Directory'] . '/' . result['Filename']
			let result['Found'] = 1
			if filereadable(result['FullPath'])
				let result['Exists'] = 1
			else
				let result['Exists'] = 0
			endif
			break
		endif
	endfor

	return result
endfunction
