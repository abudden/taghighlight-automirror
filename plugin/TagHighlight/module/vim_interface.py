from .options import AllOptions

import vim
from .languages import Languages
from .config import config, LoadLanguages

def GetConfiguration():
    vim_commands = [
            'unlet! g:taghl_available_options',
            'unlet! g:taghl_extension_lookup',
            'unlet! g:taghl_tagnames',
            'let g:taghl_available_options = []',
            'let g:taghl_tagnames = []',
            'let g:taghl_extension_lookup = {}',
            ]
    for c in vim_commands:
        vim.command(c)

    for option in AllOptions:
        vim.command('let g:taghl_available_options += [{}]')
        for key, value in option.items():
            if isinstance(value, list) or isinstance(value, str):
                # Format should be compatible:
                vim_value = repr(value)
            elif isinstance(value, bool) or value is None:
                vim_value = "'"+str(value)+"'"
            else:
                print repr(key), repr(value)
                raise Exception("Unrecognised option type")
            vim.command('let g:taghl_available_options[-1]["{key}"] = {vim_value}'.format(key=key,vim_value=vim_value))

    for kind in Languages.GenerateFullKindList():
        vim.command('let g:taghl_tagnames += ["{kind}"]'.format(kind=kind))

    LoadLanguages()
    for key, value in config['language_handler'].GenerateExtensionTable().items():
        vim.command("let g:taghl_extension_lookup['{key}'] = '{value}'".format(key=key,value=value))
