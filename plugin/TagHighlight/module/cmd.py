import os
import optparse

from .config import SetInitialOptions, LoadLanguages
from .options import AllOptions
from . import revision

def ProcessCommandLine():
    parser = optparse.OptionParser(version=("Tag Highlight Types File Creator (revision %%prog) {0}".format(revision)))

    for option in AllOptions:
        if sorted(option.keys()) != sorted(['CommandLineSwitches','Type','Default','Destination','Help']):
            # TODO: Should be a critical debug error
            print "Missing field for option:",repr(option)
            return
        if option['Type'] == bool:
            if option['Default'] == True:
                action = 'store_false'
            else:
                action = 'store_true'
            parser.add_option(*option['CommandLineSwitches'],
                    action=action,
                    default=option['Default'],
                    dest=option['Destination'],
                    help=option['Help'])
        else:
            optparse_type='string'
            if option['Type'] == str:
                action='store'
            elif option['Type'] == list:
                action='append'
            parser.add_option(*option['CommandLineSwitches'],
                    action=action,
                    default=option['Default'],
                    type=optparse_type,
                    dest=option['Destination'],
                    help=option['Help'])

    options, remainder = parser.parse_args()

    if '/' in options.ctags_executable:
        options.ctags_exe_full = options.ctags_executable
    elif options.ctags_dir is not None:
        options.ctags_exe_full = os.path.join(options.ctags_dir, options.ctags_executable)
    else:
        options.ctags_exe_full = options.ctags_executable

    if options.cscope_dir is not None:
        options.cscope_exe_full = options.cscope_dir + '/' + 'cscope'

    if options.use_existing_tagfile and not os.path.exists(options.ctags_file):
        options.use_existing_tagfile = False

    SetInitialOptions(options)

    # Now create the config language object
    LoadLanguages()
