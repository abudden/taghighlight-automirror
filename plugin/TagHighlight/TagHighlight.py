#!/usr/bin/env python
#  Author:  A. S. Budden

from __future__ import print_function
import sys

def main():
    from module.cmd import ProcessCommandLine
    from module.config import config

#    ProcessConfig()
    # This loads options and creates the config object
    ProcessCommandLine()

    if config['print_py_version']:
        print(sys.version)
        return

    print_then_exit = False

    if config['list_all_tagnames']:
        from module.languages import Languages
        print("TAGNAMES;" + ",".join(Languages.GenerateFullKindList()))
        print_then_exit = True

    if config['generate_extension_lookup']:
        extension_table = config['language_handler'].GenerateExtensionTable()
        print("EXTENSIONS;" + ",".join("{key}:{value}".format(key=k, value=v) for (k, v) in extension_table.items()))
        print_then_exit = True

    if print_then_exit:
        return

    from module.cscope import GenerateCScopeDBIfRequired
    from module.ctags import GenerateTags, ParseTags
    from module.generation import CreateTypesFile

    GenerateCScopeDBIfRequired(config)

    if not config['use_existing_tagfile']:
        GenerateTags(config)

    tag_db = ParseTags(config)

    for language in config['language_list']:
        if language in tag_db:
            CreateTypesFile(config, language, tag_db[language])

if __name__ == "__main__":
    main()
