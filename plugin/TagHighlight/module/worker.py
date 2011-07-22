from __future__ import print_function
import sys
import os

def RunWithOptions(options):
    from .config import config, SetInitialOptions, LoadLanguages

    SetInitialOptions(options)

    if config['use_existing_tagfile'] and not os.path.exists(config['ctags_file']):
        config['use_existing_tagfile'] = False

    LoadLanguages()

    if config['print_config']:
        import pprint
        pprint.pprint(config)
        return

    if config['print_py_version']:
        print(sys.version)
        return

    from .ctags import GenerateTags, ParseTags
    from .generation import CreateTypesFile

    if not config['use_existing_tagfile']:
        GenerateTags(config)
    tag_db = ParseTags(config)

    for language in config['language_list']:
        if language in tag_db:
            CreateTypesFile(config, language, tag_db[language])
