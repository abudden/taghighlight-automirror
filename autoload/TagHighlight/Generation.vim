" Tag Highlighter:
"   Author:  A. S. Budden <abudden _at_ gmail _dot_ com>
"   Date:    01/07/2011
"   Version: 1
" Copyright: Copyright (C) 2010 A. S. Budden
"            Permission is hereby granted to use and distribute this code,
"            with or without modifications, provided that this copyright
"            notice is copied with it. Like anything else that's free,
"            Generation.vim is provided *as is* and comes with no
"            warranty of any kind, either expressed or implied. By using
"            this plugin, you agree that in no event will the copyright
"            holder be liable for any damages resulting from the use
"            of this software.

" ---------------------------------------------------------------------
try
	if &cp || (exists('g:loaded_TagHLGeneration') && (g:plugin_development_mode != 1))
		throw "Already loaded"
	endif
catch
	finish
endtry
let g:loaded_TagHLGeneration = 1

function! TagHighlight#Generation#UpdateTypesFile(recurse, skiptags)
	call TagHighlight#Option#LoadOptionFileIfPresent()
	" Initial very simple implementation
	
	" Call any PreUpdate hooks
	let hooks = TagHighlight#Option#GetOption('Hooks')
	if has_key(hooks, 'PreUpdate')
		for preupdate_hook in hooks['PreUpdate']
			exe 'call' preupdate_hook . '()'
		endfor
	endif
	
	" Start with a copy of the settings so that we can tweak things
	let RunOptions = TagHighlight#Option#CopyOptions()
	if a:recurse
		let RunOptions['Recurse'] = 1
	endif
	if a:skiptags
		let RunOptions['DoNotGenerateTags'] = 1
	endif

	" Most simple options are automatic.  The options below are
	" handled manually.
	
	" Find the ctags path
	let ctags_option = TagHighlight#Option#GetOption('CtagsExecutable')
	if ctags_option == 'None'
		" Option not set: search for 'ctags' in the path
		let RunOptions['CtagsExeFull'] = TagHighlight#RunPythonScript#FindExeInPath('ctags')
	elseif ctags_option =~ '[\\/]'
		" Option set and includes '/' or '\': must be explicit
		" path to named executable: just pass to mktypes
		let RunOptions['CtagsExeFull'] = ctags_option
	else
		" Option set but doesn't include path separator: search
		" in the path
		let RunOptions['CtagsExeFull'] = TagHighlight#RunPythonScript#FindExePath(ctags_option)
	endif

	let tag_file_info = TagHighlight#Find#LocateFile('TAGS', '')
	if tag_file_info['Found'] == 1
		let RunOptions['CtagsFileLocation'] = tag_file_info['Directory']
	endif

	let types_file_info = TagHighlight#Find#LocateFile('TYPES', '*')
	if types_file_info['Found'] == 1
		let RunOptions['TypesFileLocation'] = types_file_info['Directory']
	endif
	
	call TagHighlight#RunPythonScript#RunGenerator(RunOptions)

	if has_key(hooks, 'PostUpdate')
		for postupdate_hook in hooks['PostUpdate']
			exe 'call' postupdate_hook . '()'
		endfor
	endif
endfunction
