" Tag Highlighter:
"   Author:  A. S. Budden <abudden _at_ gmail _dot_ com>
"   Date:    01/07/2011
"   Version: 1
" Copyright: Copyright (C) 2010 A. S. Budden
"            Permission is hereby granted to use and distribute this code,
"            with or without modifications, provided that this copyright
"            notice is copied with it. Like anything else that's free,
"            ReadTypes.vim is provided *as is* and comes with no
"            warranty of any kind, either expressed or implied. By using
"            this plugin, you agree that in no event will the copyright
"            holder be liable for any damages resulting from the use
"            of this software.

" ---------------------------------------------------------------------
try
	if &cp || (exists('g:loaded_TagHLReadTypes') && (g:plugin_development_mode != 1))
		throw "Already loaded"
	endif
catch
	finish
endtry
let g:loaded_TagHLReadTypes = 1

function! TagHighlight#ReadTypes#ReadTypesAutoDetect()
	let extension = expand('%:e')
	" echomsg "Reading types for extension " . extension
	for key in keys(g:TagHighlightSettings['ExtensionLookup'])
		let regex = '^'.key.'$'
		if extension =~ regex
			call TagHighlight#ReadTypes#ReadTypes(g:TagHighlightSettings['ExtensionLookup'][key])
		endif
	endfor
endfunction

function! TagHighlight#ReadTypes#ReadTypes(suffix)
	let savedView = winsaveview()

	let file = '<afile>'
	if len(expand(file)) == 0
		let file = '%'
	endif

	" echomsg "Reading types of suffix " . a:suffix . " for file " . file

	if TagHighlight#Option#GetOption('DisableTypeParsing', 0) == 1
		call TagHighlight#Debug#Print("Type file parsing disabled", 'Status')
		return
	endif

	let skiplist = TagHighlight#Option#GetOption('ParsingSkipList', [])
	if len(skiplist) > 0
		let basename = expand(file . ':p:t')
		let fullname = expand(file . ':p')
		if index(skiplist, basename) != -1
			call TagHighlight#Debug#Print("Skipping file due to basename match", 'Status')
			return
		endif
		if index(skiplist, fullname) != -1
			call TagHighlight#Debug#Print("Skipping file due to fullname match", 'Status')
			return
		endif
	endif

	call TagHighlight#Debug#Print("Searching for types file", 'Status')

	" Clear any existing syntax entries
	for group in g:TagHighlightSettings['AllTypes']
		exe 'syn clear' group
	endfor
	
	let type_files = TagHighlight#ReadTypes#FindTypeFiles(a:suffix)
	for fname in type_files
		exe 'so' fname
	endfor

	" Restore the view
	call winrestview(savedView)
endfunction

function! TagHighlight#ReadTypes#FindTypeFiles(suffix)
	" TODO: Initial implementation only supports current directory
	let results = []
	let filename = TagHighlight#Option#GetOption('TypesFilePrefix',"types") . '_' .
				\ a:suffix .
				\ '.vim'
	if filereadable(filename)
		let results += [filename]
	endif
	return results
endfunction
