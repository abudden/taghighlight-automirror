import sys
import os

from optparse import Values
from .utilities import AttributeDict

config = AttributeDict()

if hasattr(sys, 'frozen'):
    # Compiled variant, executable should be in
    # plugin/TagHighlight/Compiled/Win32, so data
    # is in ../../data relative to executable
    config['data_directory'] = os.path.abspath(
            os.path.join(os.path.dirname(sys.executable),
            '../../data'))
else:
    # Script variant: this file in
    # plugin/TagHighlight/module, so data is in
    # ../data relative to this file
    config['data_directory'] = os.path.abspath(
            os.path.join(os.path.dirname(__file__),
            '../data'))

def SetInitialOptions(new_options):
    global config
    option_dict = vars(new_options)
    for key in option_dict:
        config[key] = option_dict[key]

def LoadLanguages():
    global config
    if 'language_handler' in config:
        return
    from .languages import Languages
    config['language_handler'] = Languages(config)

    full_language_list = config['language_handler'].GetAllLanguages()
    if len(config['languages']) == 0:
        # Include all languages
        config['language_list'] = full_language_list
    else:
        config['language_list'] = [i for i in full_language_list if i in config['languages']]
