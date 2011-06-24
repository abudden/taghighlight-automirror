from optparse import Values
from languages import Languages
from utilities import AttributeDict

config = AttributeDict()

def SetInitialOptions(new_options):
    global config
    option_dict = vars(new_options)
    for key in option_dict:
        config[key] = option_dict[key]

def LoadLanguages():
    global config
    config['language_handler'] = Languages(config)

    full_language_list = config['language_handler'].GetAllLanguages()
    if len(config['languages']) == 0:
        # Include all languages
        config['language_list'] = full_language_list
    else:
        config['language_list'] = [i for i in full_language_list if i in config['languages']]
