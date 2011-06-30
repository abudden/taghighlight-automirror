import os
import optparse

from .config import SetInitialOptions, LoadLanguages
from . import revision

def ProcessCommandLine():
    parser = optparse.OptionParser(version=("Tag Highlight Types File Creator (revision %%prog) {0}".format(revision)))
    parser.add_option('-r','-R','--recurse',
            action="store_true",
            default=False,
            dest="recurse",
            help="Recurse into subdirectories")
    parser.add_option('--ctags-file',
            action='store',
            default='tags',
            dest='ctags_file',
            help='CTAGS output filename')
    parser.add_option('--types-prefix',
            action='store',
            default='types',
            dest='types_prefix',
            help='Vim Types file prefix')
    parser.add_option('--ctags-dir',
            action='store',
            default=None,
            dest='ctags_dir',
            type='string',
            help='CTAGS Executable Directory')
    parser.add_option('--ctags-executable',
            action='store',
            default='ctags',
            dest='ctags_executable',
            type='string',
            help='Name of the CTAGS executable, with or without a full path')
    parser.add_option('--include-docs',
            action='store_true',
            default=False,
            dest='include_docs',
            help='Include docs or Documentation directory (stripped by default for speed)')
    parser.add_option('--do-not-check-keywords',
            action='store_false',
            default=True,
            dest='check_keywords',
            help="Do not check validity of keywords (for speed)")
    parser.add_option('--include-invalid-keywords-as-matches',
            action='store_false',
            default=True,
            dest='skip_matches',
            help='Include invalid keywords as regular expression matches (may slow it loading)')
    parser.add_option('--exclude-vim-keywords',
            action='store_true',
            default=False,
            dest='skip_vimkeywords',
            help="Don't include Vim keywords (they have to be matched with regular expression matches, which is slower)")
    parser.add_option('--do-not-analyse-constants',
            action='store_false',
            default=True,
            dest='parse_constants',
            help="Do not treat constants as separate entries")
    parser.add_option('--include-language',
            action='append',
            dest='languages',
            type='string',
            default=[],
            help='Only include specified languages')
    parser.add_option('--build-cscopedb',
            action='store_true',
            default=False,
            dest='build_cscopedb',
            help="Also build a cscope database")
    parser.add_option('--build-cscopedb-if-cscope-file-exists',
            action='store_true',
            default=False,
            dest='build_cscopedb_if_file_exists',
            help="Also build a cscope database if cscope.files exists")
    parser.add_option('--cscope-dir',
            action='store',
            default=None,
            dest='cscope_dir',
            type='string',
            help='CSCOPE Executable Directory')
    parser.add_option('--type-prefix',
            action='store',
            default='types_',
            dest='type_file_prefix',
            help='Specify the prefix for the generated types files')
    parser.add_option('--type-file-location',
            action='store',
            default='.',
            dest='type_file_location',
            help='Specify the location for the generated types files')
    parser.add_option('--include-locals',
            action='store_true',
            default=False,
            dest='include_locals',
            help='Include local variables in the database')
    parser.add_option('--use-existing-tagfile',
            action='store_true',
            default=False,
            dest='use_existing_tagfile',
            help="Do not generate tags if a tag file already exists")
    parser.add_option('--list-all-tagnames',
            action='store_true',
            default=False,
            dest='list_all_tagnames',
            help='Just print a list of all the tag names')
    parser.add_option('--generate-extension-lookup',
            action='store_true',
            default=False,
            dest='generate_extension_lookup',
            help='Just generate a table of extensions and file types')
    parser.add_option('--pyversion',
            action='store_true',
            default=False,
            dest='print_py_version',
            help='Just print the version of python')

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
