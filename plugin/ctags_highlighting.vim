" ctags_highlighting
"   Author: A. S. Budden
"   Date:   29 Aug 2008
"   Version: 1

if &cp || exists("g:loaded_ctags_highlighting")
	finish
endif
let g:loaded_ctags_highlighting = 1

if !exists('g:VIMFILESDIR')
	if has("unix")
		let g:VIMFILESDIR = $HOME . "/.vim/"
	endif

	if has("win32")
		let g:VIMFILESDIR = $VIM . "/vimfiles/"
	endif
endif

" These should only be included if editing a wx or qt file
" They should also be updated to include all functions etc, not just
" typedefs
let g:wxTypesFile = g:VIMFILESDIR . "types_wx.vim"
let g:qtTypesFile = g:VIMFILESDIR . "types_qt4.vim"
let g:wxPyTypesFile = g:VIMFILESDIR . "types_wxpy.vim"

" These should only be included if editing a wx or qt file
let g:wxTagsFile = g:VIMFILESDIR . 'tags_wx'
let g:qtTagsFile = g:VIMFILESDIR . 'tags_qt4'
let g:wxPyTagsFile = g:VIMFILESDIR . 'tags_wxpy'

" Update types & tags - called with a ! recurses
command! -bang UpdateTypesFile call UpdateTypesFile(<bang>0)

" load the types_*.vim highlighting file, if it exists
autocmd BufRead,BufNewFile *.[ch]   call ReadTypes('c')
autocmd BufRead,BufNewFile *.[ch]pp call ReadTypes('c')
autocmd BufRead,BufNewFile *.py     call ReadTypes('py')
autocmd BufRead,BufNewFile *.pyw    call ReadTypes('py')
autocmd BufRead,BufNewFile *.rb     call ReadTypes('ruby')
autocmd BufRead,BufNewFile *.vhd*   call ReadTypes('vhdl')

function! ReadTypes(suffix)
	let fname = expand('<afile>:p:h') . '/types_' . a:suffix . '.vim'
	if filereadable(fname)
		exe 'so ' . fname
	endif
	let fname = expand('<afile>:p:h:h') . '/types_' . a:suffix . '.vim'
	if filereadable(fname)
		exe 'so ' . fname
	endif
	let fname = 'types_' . a:suffix . '.vim'
	if filereadable(fname)
		exe 'so ' . fname
	endif

	" Open default source files
	if index(['cpp', 'h', 'hpp'], expand('<afile>:e')) != -1
		" This is a C++ source file
		if search('^\s*#include\s\+<wx/', 'nc', 30)
			if filereadable(g:wxTypesFile)
				execute 'so ' . g:wxTypesFile
			endif
			execute 'setlocal tags+=' . g:wxTagsFile
		endif

		if search('^\s*#include\s\+<q', 'nc', 30)
			if filereadable(g:qtTypesFile)
				execute 'so ' . g:qtTypesFile
			endif
			execute 'setlocal tags+=' . g:qtTagsFile
		endif
	elseif index['py', 'pyw'], (expand('<afile>:e')) != -1
		" This is a python source file

		if search('^\s*import\s\+wx', 'nc', 30)
			if filereadable(g:wxPyTypesFile)
				execute 'so ' . g:wxPyTypesFile
			endif
			execute 'setlocal tags+=' . g:wxPyTagsFile
		endif
	endif
endfunction


func! UpdateTypesFile(recurse)
	let s:vrc = globpath(&rtp, "mktypes.py")

	if type(s:vrc) == type("")
		let mktypes_py_file = s:vrc
	elseif type(s:vrc) == type([])
		let mktypes_py_file = s:vrc[0]
	endif

	let sysroot = 'python ' . mktypes_py_file
	let syscmd = ' --ctags-dir='

	if has("win32")
		let path = substitute($PATH, ';', ',', 'g')
		let ctags_exe_list = split(globpath(path, 'ctags.exe'))
		if len(ctags_exe_list) > 0
			let ctags_exe = ctags_exe_list[0]
		else
			let ctags_exe = ''
		endif

		" If ctags is not in the path, look for it in vimfiles/
		if !filereadable(ctags_exe)
			let ctags_exe = split(globpath(&rtp, "ctags.exe"))[0]
		endif

		if filereadable(ctags_exe)
			let ctags_path = escape(fnamemodify(ctags_exe, ':p:h'),' \')
		else
			throw "Cannot find ctags"
		endif
	else
		let path = substitute($PATH, ':', ',', 'g')
		if has("win32unix")
			let ctags_exe = split(globpath(path, 'ctags.exe'))[0]
		else
			let ctags_exe = split(globpath(path, 'ctags'))[0]
		endif
		if filereadable(ctags_exe)
			let ctags_path = fnamemodify(ctags_exe, ':p:h')
		else
			throw "Cannot find ctags"
		endif
	endif

	let syscmd .= ctags_path
	
	if a:recurse == 1
		let syscmd .= ' -r'
	endif

	let syscmd .= ' --check-keywords'

	let sysoutput = system(sysroot . syscmd) 
	if sysoutput =~ 'python.*is not recognized as an internal or external command'
		let sysroot = g:VIMFILESDIR . 'extra_source/mktypes/dist/mktypes.exe'
		let sysoutput = sysoutput . "\nUsing compiled mktypes\n" . system(sysroot . syscmd)
	endif

	echo sysoutput



	" There should be a try catch endtry
	" above, with the fall-back using the
	" exe on windows or the full system('python') etc
	" on Linux

endfunc

