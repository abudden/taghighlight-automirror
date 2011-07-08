from __future__ import print_function

import os
import optparse

from .config import SetInitialOptions, LoadLanguages
from .options import AllOptions
from . import revision

def ProcessCommandLine():
    parser = optparse.OptionParser(version=("Tag Highlight Types File Creator (revision %%prog) {0}".format(revision)))

    for dest in AllOptions.keys():
        if AllOptions[dest]['Type'] == 'bool':
            if AllOptions[dest]['Default'] == True:
                action = 'store_false'
            else:
                action = 'store_true'
            parser.add_option(*AllOptions[dest]['CommandLineSwitches'],
                    action=action,
                    default=AllOptions[dest]['Default'],
                    dest=dest,
                    help=AllOptions[dest]['Help'])
        else:
            optparse_type='string'
            if AllOptions[dest]['Type'] == 'string':
                action='store'
            elif AllOptions[dest]['Type'] == 'list':
                action='append'
            else:
                raise Exception('Unrecognised option type: ' + AllOptions[dest]['Type'])
            parser.add_option(*AllOptions[dest]['CommandLineSwitches'],
                    action=action,
                    default=AllOptions[dest]['Default'],
                    type=optparse_type,
                    dest=dest,
                    help=AllOptions[dest]['Help'])

    options, remainder = parser.parse_args()

    return vars(options)
