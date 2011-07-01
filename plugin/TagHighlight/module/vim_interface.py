from .options import AllOptions

import vim

def GetAllOptions():
    vim_commands = [
            'unlet! g:pyinterface_result',
            'let g:pyinterface_result = []',
            ]
    for c in vim_commands:
        vim.command(c)

    for option in AllOptions:
        vim.command('let g:pyinterface_result += [{}]')
        for key, value in option.items():
            if isinstance(value, list) or isinstance(value, str):
                # Format should be compatible:
                vim_value = repr(value)
            elif isinstance(value, bool):
                vim_value = "'True'" if value else "'False'"
            elif value is None:
                vim_value = "'None'"
            else:
                print repr(key), repr(value)
                raise Exception("Unrecognised option type")
            vim.command('let g:pyinterface_result[-1]["{key}"] = {vim_value}'.format(key=key,vim_value=vim_value))
