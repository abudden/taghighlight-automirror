" Tag Highlighter:
"   Author:  A. S. Budden <abudden _at_ gmail _dot_ com>
"   Date:    01/07/2011
"   Version: 1
" Copyright: Copyright (C) 2010 A. S. Budden
"            Permission is hereby granted to use and distribute this code,
"            with or without modifications, provided that this copyright
"            notice is copied with it. Like anything else that's free,
"            TagHighlight.vim is provided *as is* and comes with no
"            warranty of any kind, either expressed or implied. By using
"            this plugin, you agree that in no event will the copyright
"            holder be liable for any damages resulting from the use
"            of this software.

" ---------------------------------------------------------------------
try
	if &cp || (exists('g:loaded_TagHighlight') && (g:plugin_development_mode != 1))
		throw "Already loaded"
	endif
catch
	finish
endtry
let g:loaded_TagHighlight = 1

"let old_versions = globpath(&rtp, 'plugin/ctags_highlighting.vim')
"if len(old_versions) > 0
"	echoerr "Legacy ctags highlighter found.  This highlighter is"
"				\ "intended to replace ctags_highlighter.  See the"
"				\ "user documentation in doc/TagHighlight.txt for"
"				\ "more information."
"	finish
"endif

if ! exists('g:TagHighlightSettings')
	let g:TagHighlightSettings = {}
endif

let g:TagHighlightPrivate = {}

let s:plugin_paths = split(globpath(&rtp, 'plugin/TagHighlight/TagHighlight.py'), '\n')
if len(s:plugin_paths) == 1
	let g:TagHighlightPrivate['PluginPath'] = fnamemodify(s:plugin_paths[0], ':p:h')
elseif len(s:plugin_paths) == 0
	echoerr "Cannot find TagHighlight.py"
else
	echoerr "Multiple plugin installs found: something has gone wrong!"
endif

" Update types & tags - called with a ! recurses
command! -bang -bar UpdateTypesFile 
			\ silent call TagHighlight#Generation#UpdateTypesFile(<bang>0, 0) | 
			\ let s:SavedTabNr = tabpagenr() |
			\ let s:SavedWinNr = winnr() |
			\ silent tabdo windo call TagHighlight#ReadTypes#ReadTypesAutoDetect() |
			\ silent exe 'tabn ' . s:SavedTabNr |
			\ silent exe s:SavedWinNr . "wincmd w"

command! -bang -bar UpdateTypesFileOnly 
			\ silent call TagHighlight#Generation#UpdateTypesFile(<bang>0, 1) | 
			\ let s:SavedTabNr = tabpagenr() |
			\ let s:SavedWinNr = winnr() |
			\ silent tabdo windo call TagHighlight#ReadTypes#ReadTypesAutoDetect() |
			\ silent exe 'tabn ' . s:SavedTabNr |
			\ silent exe s:SavedWinNr . "wincmd w"

function! s:LoadLanguages()
	" This loads the language data files.
	let language_files = split(glob(g:TagHighlightPrivate['PluginPath'] . '/data/languages/*.txt'), '\n')
	let g:TagHighlightPrivate['ExtensionLookup'] = {}
	let g:TagHighlightPrivate['SpecialSyntaxHandlers'] = {}
	for language_file in language_files
		let entries = TagHighlight#LoadDataFile#LoadFile(language_file)
		if has_key(entries, 'VimExtensionMatcher') && has_key(entries, 'Suffix')
			let g:TagHighlightPrivate['ExtensionLookup'][entries['VimExtensionMatcher']] = entries['Suffix']
		else
			echoerr "Could not load language from file " . language_file
		endif
		if has_key(entries, 'SpecialSyntaxHandlers')
			if type(entries['SpecialSyntaxHandlers']) == type([])
				let handlers = entries['SpecialSyntaxHandlers']
			else
				let handlers = [entries['SpecialSyntaxHandlers']]
			endif
			let g:TagHighlightPrivate['SpecialSyntaxHandlers'][entries['Suffix']] = handlers
		endif
	endfor
endfunction

function! s:LoadKinds()
	" Load the list of kinds (ignoring ctags information) into
	" Vim.  This is used to make the default links
	let g:TagHighlightPrivate['Kinds'] = TagHighlight#LoadDataFile#LoadDataFile('kinds.txt')
	" Use a dictionary to get all unique entries
	let tag_names_dict = {}
	for entry in keys(g:TagHighlightPrivate['Kinds'])
		for key in keys(g:TagHighlightPrivate['Kinds'][entry])
			let tag_names_dict[g:TagHighlightPrivate['Kinds'][entry][key]] = ""
		endfor
	endfor
	let g:TagHighlightPrivate['AllTypes'] = sort(keys(tag_names_dict))
endfunction

call s:LoadLanguages()
call s:LoadKinds()

for tagname in g:TagHighlightPrivate['AllTypes']
	let simplename = substitute(tagname, '^CTags', '', '')
	exe 'hi default link' tagname simplename
	" Highlight everything as a keyword by default
	exe 'hi default link' simplename 'Keyword'
endfor

autocmd BufRead,BufNewFile * call TagHighlight#ReadTypes#ReadTypesAutoDetect()
command! ReadTypes call TagHighlight#ReadTypes#ReadTypesAutoDetect()
