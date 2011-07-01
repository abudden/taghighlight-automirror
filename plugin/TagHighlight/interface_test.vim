let g:pymodule_path = globpath(&rtp, 'plugin/TagHighlight')
py import sys
py import vim
py mod_path = vim.eval('g:pymodule_path')
py sys.path += [mod_path]
py from module.vim_interface import GetAllOptions
py GetAllOptions()
