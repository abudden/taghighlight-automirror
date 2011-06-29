" Tag Highlighter:
"   Author:  A. S. Budden <abudden _at_ gmail _dot_ com>
"   Date:    29/06/2011
"   Version: 1
" Copyright: Copyright (C) 2010 A. S. Budden
"            Permission is hereby granted to use and distribute this code,
"            with or without modifications, provided that this copyright
"            notice is copied with it. Like anything else that's free,
"            RunPythonScript.vim is provided *as is* and comes with no
"            warranty of any kind, either expressed or implied. By using
"            this plugin, you agree that in no event will the copyright
"            holder be liable for any damages resulting from the use
"            of this software.

" ---------------------------------------------------------------------
try
	if &cp || (exists('g:loaded_TagHLRunPythonScript') && (g:plugin_development_mode != 1))
		throw "Already loaded"
	endif
catch
	finish
endtry
let g:loaded_TagHLRunPythonScript = 1

" This script is responsible for finding a means of running the python app.
" If vim is compiled with python support (and we can run a simple test
" command), use that method.  If not, but python is in the path, use it to
" run the script.  If python is not in path, we'll have to rely on a compiled
" executable version.

function! s:GetPath()
	if has("win32")
		let path = substitute($PATH, '\\\?;', ',', 'g')
	else
		let path = substitute($PATH, ':', ',', 'g')
	endif
	return path
endfunction

function! s:FindExeInPath(file)
	if has("win32") || has("win32unix")
		if a:file =~ '.exe$'
			let full_file = a:file . '.exe.'
		endif
	endif
	let short_file = fnamemodify(a:file, ':p:t')
	let file_exe_list = split(globpath(s:GetPath(), short_file), '\n')
	
	if len(file_exe_list) > 0 && executable(file_exe_list[0])
		let file_exe = file_exe_list[0]
	else
		return 'None'
	endif
	let file_exe = substitute(file_exe, '\\', '/', 'g')
endfunction

function! TagHighlight#RunPythonScript#FindPython()
	let s:python_variant = 'None'
	" This script is written for python 2.x, so we check for that.
	if has('python')
		" Check that it works
		let g:taghl_findpython_testvar = 0
		try
			py import vim
			py import sys
			py vim.command('let g:taghl_findpython_testvar = 1')
			if g:taghl_findpython_testvar != 1
				throw "Python doesn't seem to be working"
			endif
			" Get the version of python
			if TagHighlight#Debug#GetDebugLevelName() == 'Information'
				py import sys
				py vim.command('let g:taghl_findpython_testvar = "%s"' % sys.version)
				call TagHighlight#Debug#Print("Python version reported as: " . g:taghl_findpython_testvar,
							\ 'Information')
			endif
			unlet g:taghl_findpython_testvar
			let s:python_variant = 'if_pyth'
		endtry
	endif

	if s:python_variant == 'None'
		" Has a specific path to python been set?
		let python_path = TagHighlight#Option#GetOption('PathToPython', 'None')
		if python_path != 'None' && executable(python_path)
			" We've found python, it's probably usable
			let s:python_variant = 'python'
			let s:python_path = python_path
		else
			" See if it's in the path
			let python_path = s:FindExeInPath('python')
			if python_path != 'None'
				let s:python_variant = 'python'
				let s:python_path = python_path
			endif
		endif
		
		if python_path != 'None'
			" Consider checking that it's valid
			if TagHighlight#Debug#GetDebugLevelName() == 'Information'
				let pyversion = TagHighlight#RunPythonScript#GetPythonVersion()
				TagHighlight#Debug#Print("Python version reported as: " . pyversion,
							\ 'Information')
			endif
		endif
	endif

	if s:python_variant == 'None'
		" Still haven't found it, see if we have a compiled version available
		if has("win32")
			let compiled_highlighter = split(globpath(&rtp, "plugin/TagHighlight/Win32Compiled/TagHighlight.exe"), "\n")
			if len(compiled_highlighter) > 0  && executable(compiled_highlighter[0])
				let s:python_variant = 'compiled'
				let s:highlighter_path = compiled_highlighter[0]
			endif
		endif
	endif

	if s:python_variant == 'None'
		throw "Tag highlighter: could not find python or the compiled version of the highlighter."
	endif

	return s:python_variant
endfunction

