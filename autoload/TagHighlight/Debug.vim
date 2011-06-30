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
	let debug_level = TagHighlight#Option#GetOption('DebugLevel', 'Error')
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

function! TagHighlight#Debug#Print(str, level)
	let level_index = index(g:TagHighlight#Debug#DebugLevels, a:level)
	if level_index == -1
		level_index = index(g:TagHighlight#Debug#DebugLevels, 'Critical')
	endif
	if level_index <= TagHighlight#Debug#GetDebugLevel()
		echomsg a:str
	endif
endfunction
