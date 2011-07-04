from __future__ import print_function

import os
import optparse

from .config import SetInitialOptions, LoadLanguages
from .options import AllOptions
from . import revision

def ProcessCommandLine():
    parser = optparse.OptionParser(version=("Tag Highlight Types File Creator (revision %%prog) {0}".format(revision)))

    required = ['CommandLineSwitches','Type','Default','Destination','Help']
    for option in AllOptions:
        for key in required:
            if key not in option:
                # TODO: Should be a critical debug error
                print("Missing field for option:",repr(option))
                return
        if option['Type'] == 'bool':
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
            if option['Type'] == 'string':
                action='store'
            elif option['Type'] == 'list':
                action='append'
            else:
                raise Exception('Unrecognised option type: ' + Option('Type'))
            parser.add_option(*option['CommandLineSwitches'],
                    action=action,
                    default=option['Default'],
                    type=optparse_type,
                    dest=option['Destination'],
                    help=option['Help'])

    options, remainder = parser.parse_args()

    return vars(options)
