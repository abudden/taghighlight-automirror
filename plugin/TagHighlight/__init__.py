#!/usr/bin/env python
#  Author:  A. S. Budden
## Date::   6th May 2011         ##
## RevTag:: r461                 ##

revision = "## RevTag:: r461 ##".strip('# ').replace('RevTag::', 'revision')

def main():
    from cmd import ProcessCommandLine
    from config import config
    from cscope import GenerateCScopeDBIfRequired
    from ctags import GenerateTags, ParseTags
    from generation import CreateTypesFile

#    ProcessConfig()
    # This loads options and creates the config object
    ProcessCommandLine()

    GenerateCScopeDBIfRequired(config)

    if not config['use_existing_tagfile']:
        GenerateTags(config)

    tag_db = ParseTags(config)

    for language in config['language_list']:
        if language in tag_db:
            CreateTypesFile(config, language)

if __name__ == "__main__":
    main()
