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
	" Initial very simple implementation
endfunction

" Old implementation:
func! UpdateTypesFile(recurse, skiptags)
	let s:vrc = globpath(&rtp, "mktypes.py")

	call s:Debug_Print(g:DBG_Status, "Starting UpdateTypesFile revision " . s:CTagsHighlighterVersion)

	if type(s:vrc) == type("")
		let mktypes_py_file = s:vrc
	elseif type(s:vrc) == type([])
		let mktypes_py_file = s:vrc[0]
	endif

	let sysroot = 'python ' . shellescape(mktypes_py_file)
	let syscmd = ''

	let ctags_option = s:GetOption('TypesFileCtagsExecutable', '')
	if ctags_option == ''
		" Option not set: search for 'ctags' in the path
		let ctags_path = s:FindExePath('ctags')
		let syscmd .= ' --ctags-dir=' . ctags_path
	elseif ctags_option =~ '[\\/]'
		" Option set and includes '/' or '\': must be explicit
		" path to named executable: just pass to mktypes
		let syscmd .= ' --ctags-executable=' . ctags_option
	else
		" Option set but doesn't include path separator: search
		" in the path
		let ctags_path = s:FindExePath(ctags_option)
		let syscmd .= ' --ctags-path=' . ctags_path
		let syscmd .= ' --ctags-executable=' . ctags_option
	endif
	
	if exists('b:TypesFileRecurse')
		if b:TypesFileRecurse == 1
			let syscmd .= ' -r'
		endif
	else
		if a:recurse == 1
			let syscmd .= ' -r'
		endif
	endif

	if exists('b:TypesFileLanguages')
		for lang in b:TypesFileLanguages
			let syscmd .= ' --include-language=' . lang
		endfor
	endif

	let TypesFileIncludeSynMatches = s:GetOption('TypesFileIncludeSynMatches', 0)
	if TypesFileIncludeSynMatches == 1
		let syscmd .= ' --include-invalid-keywords-as-matches'
	endif

	let TypeFileSkipVimKeywords = s:GetOption('TypesFileSkipVimKeywords', 0)
	if TypeFileSkipVimKeywords == 1
		let syscmd .= ' --exclude-vim-keywords'
	endif

	let TypesFileIncludeLocals = s:GetOption('TypesFileIncludeLocals', 1)
	if TypesFileIncludeLocals == 1
		let syscmd .= ' --include-locals'
	endif

	let TypesFileDoNotGenerateTags = s:GetOption('TypesFileDoNotGenerateTags', 0)
	if TypesFileDoNotGenerateTags == 1
		let syscmd .= ' --use-existing-tagfile'
	elseif a:skiptags == 1
		let syscmd .= ' --use-existing-tagfile'
	endif

	let syscmd .= ' --ctags-file ' . s:GetOption('TypesCTagsFile', 'tags')
	let syscmd .= ' --types-prefix ' . s:GetOption('TypesPrefix', 'types')

	let CheckForCScopeFiles = s:GetOption('CheckForCScopeFiles', 0)
	if CheckForCScopeFiles == 1
		if cscope_connection()
			" Kill all existing cscope connections so that the database can be
			" rebuilt.  Because we run cscope in the background (from python)
			" we can't just re-add the cscope database as it might not have
			" finished yet.  Otherwise, we'd parse the output of 'cs show'
			" and re-add the database at the end of the function.
			cs kill -1
		endif
		let syscmd .= ' --build-cscopedb-if-cscope-file-exists'
		let syscmd .= ' --cscope-dir=' 
		let cscope_path = s:FindExePath('extra_source/cscope_win/cscope')
		let syscmd .= cscope_path
	endif

	let sysoutput = system(sysroot . syscmd) 
	echo sysroot . syscmd
	if sysoutput =~ 'python.*is not recognized as an internal or external command'
		let sysroot = g:VIMFILESDIR . '/extra_source/mktypes/dist/mktypes.exe'
		let sysoutput = sysoutput . "\nUsing compiled mktypes\n" . system(sysroot . syscmd)
	endif

	echo sysoutput

	if g:CTagsHighlighterDebug >= g:DBG_None
		echomsg sysoutput
		messages
	endif

	" There should be a try catch endtry
	" above, with the fall-back using the
	" exe on windows or the full system('python') etc
	" on Linux

endfunc
