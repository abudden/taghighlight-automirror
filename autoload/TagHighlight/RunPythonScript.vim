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

let s:python_variant = 'None'

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

function! TagHighlight#RunPythonScript#RunGenerator(options)
	" Will only actually load the options once
	call TagHighlight#RunPythonScript#LoadScriptOptions()

	if s:python_variant == 'None'
		call TagHighlight#RunPythonScript#FindPython()
	endif

	if index(["if_pyth","if_pyth3"], s:python_variant) != -1
		let add_to_py_path = substitute(g:TagHighlightSettings['PluginPath'], '\\', '/','g')
		let PY = s:python_cmd[0]
		exe PY 'import sys'
		exe PY 'sys.path = ["'.add_to_py_path.'"] + sys.path'
		exe PY 'from module.utilities import TagHighlightOptionDict' 
		exe PY 'from module.worker import RunWithOptions'
		exe PY 'options = TagHighlightOptionDict()'
		" We're using the custom interpreter: create an options object
		for option in g:TagHighlightSettings['ScriptOptions']
			if has_key(option, 'VimOptionMap') && has_key(a:options, option['VimOptionMap'])
				" We can handle this one automatically
				let pyoption = 'options["'.option['Destination'].'"]'
				if option['Type'] == 'bool'
					if a:options[option['VimOptionMap']]
						exe PY pyoption '= True'
					else
						exe PY pyoption '= False'
					endif
				elseif option['Type'] == 'string'
					exe PY pyoption '= """'.a:options[option['VimOptionMap']].'"""'
				elseif option['Type'] == 'list'
					exe PY pyoption '= []'
					for entry in a:options[option['VimOptionMap']]
						exe PY pyoption '+= ["""' . entry . '"""]'
					endfor
				endif
			endif
		endfor
		exe PY 'RunWithOptions(options)'
	elseif index(["python","compiled"], s:python_variant) != -1
		let args = s:python_cmd[:]
		" We're calling the script externally, build a list of arguments
		for option in g:TagHighlightSettings['ScriptOptions']
			if has_key(option, 'VimOptionMap') && has_key(a:options, option['VimOptionMap'])
				" We can handle this one automatically
				if option['Type'] == 'bool'
					if ((a:options[option['VimOptionMap']] && option['Default'] == 'False')
								\ || ( ! a:options[option['VimOptionMap']] && option['Default'] == 'True'))
						let args += [option['CommandLineSwitches']]
					endif
				elseif option['Type'] == 'string'
					let args += [option['CommandLineSwitches'] . '=' . a:options[option['VimOptionMap']]]
				elseif option['Type'] == 'list'
					for entry in a:options[option['VimOptionMap']]
						let args += [option['CommandLineSwitches'] . '=' . entry]
					endfor
				endif
			endif
		endfor
		let sysoutput = system(join(args, " "))
	else
		throw "Tag highlighter: invalid or not implemented python variant"
	endif
endfunction

function! TagHighlight#RunPythonScript#FindExeInPath(file)
	let full_file = a:file
	if has("win32") || has("win32unix")
		if a:file !~ '.exe$'
			let full_file = a:file . '.exe.'
		endif
	endif
	let short_file = fnamemodify(full_file, ':p:t')
	let file_exe_list = split(globpath(s:GetPath(), short_file), '\n')
	
	if len(file_exe_list) > 0 && executable(file_exe_list[0])
		let file_exe = file_exe_list[0]
	else
		return 'None'
	endif
	let file_exe = substitute(file_exe, '\\', '/', 'g')
	return file_exe
endfunction

function! TagHighlight#RunPythonScript#LoadScriptOptions()
	if has_key(g:TagHighlightSettings, 'ScriptOptions')
		return
	endif

	let g:TagHighlightSettings['ScriptOptions'] = []
	let entries = readfile(g:TagHighlightSettings['PluginPath'] . '/data/options.txt')
	
	let dest = ''
	let option = {}
	for entry in entries
		if entry[len(entry)-1] == ':'
			if dest != ''
				let g:TagHighlightSettings['ScriptOptions'] += [deepcopy(option)]
				let option = {}
			endif
			let dest = entry[:len(entry)-2]
			let option['Destination'] = dest
			echo "Dest:".dest
		elseif dest != '' && entry[0] == "\t" && stridx(entry, ':') != -1
			let parts = split(entry[1:], ':')
			if parts[0] == 'CommandLineSwitches' && stridx(parts[1], ',') != -1
				" Only take the first option for the command line switches
				let parts[1] = split(parts[1], ',')[0]
			endif
			let option[parts[0]] = parts[1]
			echo "Option:".parts[0]."=".parts[1]
		endif
	endfor
	if dest != ''
		let g:TagHighlightSettings['ScriptOptions'] += [option]
	endif
endfunction


function! TagHighlight#RunPythonScript#GetPythonVersion()
	" Assumes that python path is set correctly
	if s:python_variant == 'if_pyth3'
		py3 import sys
		py3 vim.command('let g:taghl_getpythonversion = "{0}"'.format(sys.version))
		let pyversion = g:taghl_getpythonversion
		unlet g:taghl_getpythonversion
	elseif s:python_variant == 'if_pyth'
		py import sys
		py vim.command('let g:taghl_getpythonversion = "%s"' % sys.version)
		let pyversion = g:taghl_getpythonversion
		unlet g:taghl_getpythonversion
	elseif s:python_variant == 'python'
		let syscmd = shellescape(s:python_path) . " --version"
		let pyversion = system(syscmd)
	elseif s:python_variant == 'compiled'
		let syscmd = shellescape(s:highlighter_path) . " --pyversion"
		let pyversion = system(syscmd)
	else
		let pyversion = 'ERROR'
	endif
	return pyversion
endfunction

function! TagHighlight#RunPythonScript#FindPython()
	let s:python_variant = 'None'
	let forced_variant = TagHighlight#Option#GetOption('ForcedPythonVariant', 'None')
	" Supported variants
	let supported_variants = ['if_pyth3', 'if_pyth', 'python', 'compiled']
	" Priority of those variants (default is that specified above)
	let variant_priority = TagHighlight#Option#GetOption('PythonVariantPriority',
				\ supported_variants)

	" Make sure that the user specified variant is supported
	if index(supported_variants, forced_variant) == -1
		let forced_variant = 'None'
	endif

	" Make sure that all variants in the priority list are supported
	call filter(variant_priority, 'index(supported_variants, v:val) != -1')

	" Try each variant in the priority list until we find one that works
	for variant in variant_priority
		if forced_variant == variant || forced_variant == 'None'
			if variant == 'if_pyth3' && has('python3')
				" Check whether the python 3 interface works
				let g:taghl_findpython_testvar = 0
				try
					py3 import vim
					py3 vim.command('let g:taghl_findpython_testvar = 1')
					if g:taghl_findpython_testvar != 1
						throw "Python doesn't seem to be working"
					endif
					unlet g:taghl_findpython_testvar
					let s:python_variant = 'if_pyth3'
					let s:python_cmd = ['py3']
				endtry
			elseif variant == 'if_pyth' && has('python')
				" Check whether the python 2 interface works
				let g:taghl_findpython_testvar = 0
				try
					py import vim
					py vim.command('let g:taghl_findpython_testvar = 1')
					if g:taghl_findpython_testvar != 1
						throw "Python doesn't seem to be working"
					endif
					unlet g:taghl_findpython_testvar
					let s:python_variant = 'if_pyth'
					let s:python_cmd = ['py']
				endtry
			elseif variant == 'python'
				" Try calling an external python
				
				" Has a specific path to python been set?
				let python_path = TagHighlight#Option#GetOption('PathToPython', 'None')
				if python_path != 'None' && executable(python_path)
					" We've found python, it's probably usable
					let s:python_variant = 'python'
					let s:python_path = python_path
					let s:python_cmd = [python_path, g:TagHighlightSettings['PluginPath'] . '/TagHighlight.py']
				else
					" See if it's in the path
					let python_path = TagHighlight#RunPythonScript#FindExeInPath('python')
					if python_path != 'None'
						let s:python_variant = 'python'
						let s:python_path = python_path
						let s:python_cmd = [python_path, g:TagHighlightSettings['PluginPath'] . '/TagHighlight.py']
					endif
				endif
			elseif variant == 'compiled'
				" See if there's a compiled executable version of the
				" highlighter
				if has("win32")
					let compiled_highlighter = split(globpath(&rtp, "plugin/TagHighlight/Compiled/Win32/TagHighlight.exe"), "\n")
					if len(compiled_highlighter) > 0  && executable(compiled_highlighter[0])
						let s:python_variant = 'compiled'
						let s:python_cmd = [compiled_highlighter[0]]
					endif
				endif
			endif
		endif
		
		if s:python_variant != 'None'
			" Found one!
			break
		endif
	endfor

	if s:python_variant != 'None'
		" Consider checking that it's valid
		if TagHighlight#Debug#GetDebugLevelName() == 'Information'
			let pyversion = TagHighlight#RunPythonScript#GetPythonVersion()
			call TagHighlight#Debug#Print("Python version reported as: " . pyversion,
						\ 'Information')
		endif
	else
		throw "Tag highlighter: could not find python or the compiled version of the highlighter."
	endif

	return s:python_variant
endfunction

