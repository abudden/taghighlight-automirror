" Tag Highlighter:
"   Author:  A. S. Budden <abudden _at_ gmail _dot_ com>
"   Date:    02/08/2011
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
	if &cp || (exists('g:loaded_TagHLDebug') && (g:plugin_development_mode != 1))
		throw "Already loaded"
	endif
catch
	finish
endtry
let g:loaded_TagHLDebug = 1

let TagHighlight#Debug#DebugLevels = [
			\ "None",
			\ "Critical",
			\ "Error",
			\ "Warning",
			\ "Status",
			\ "Information",
			\ ]

function! TagHighlight#Debug#GetDebugLevel()
	try
		let debug_level = TagHighlight#Option#GetOption('DebugLevel')
	catch /Unrecognised option/
		" Probably loading the option file, so no debug level available
		" yet, so assume 'Information'
		let debug_level = 'Information'
	endtry
	let debug_num = index(g:TagHighlight#Debug#DebugLevels, debug_level)
	if debug_num != -1
		return debug_num
	else
		return index(g:TagHighlight#Debug#DebugLevels, 'Error')
	endif
endfunction

function! TagHighlight#Debug#GetDebugLevelName()
	let debug_level_num = TagHighlight#Debug#GetDebugLevel()
	return g:TagHighlight#Debug#DebugLevels[debug_level_num]
endfunction

function! TagHighlight#Debug#DebugUpdateTypesFile(filename)
	" Update the types file with debugging turned on
	if a:filename ==? 'None'
		" Force case to be correct
		let debug_file = 'None'
	else
		let debug_file = a:filename
	endif

	let g:TagHighlightSettings['DebugFile'] = debug_file
	let g:TagHighlightSettings['DebugLevel'] = 'Information'

	call TagHighlight#Generation#UpdateTypesFile(1, 0)
	let s:SavedTabNr = tabpagenr()
	let s:SavedWinNr = winnr()
	tabdo windo call TagHighlight#ReadTypes#ReadTypesAutoDetect()
	exe 'tabn' s:SavedTabNr
	exe s:SavedWinNr . "wincmd w"
endfunction
