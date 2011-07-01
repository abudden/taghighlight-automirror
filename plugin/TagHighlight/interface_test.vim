if ! exists('g:plugin_development_mode')
	finish
endif
let g:pymodule_path = globpath(&rtp, 'plugin/TagHighlight')
py import sys
py import vim
py mod_path = vim.eval('g:pymodule_path')
py sys.path += [mod_path]
py import module.vim_interface
py module.vim_interface.GetConfiguration()
