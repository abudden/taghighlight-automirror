#!/usr/bin/env python
#  Author:  A. S. Budden
## Date::   24th June 2011       ##
## RevTag:: r472                 ##

revision = "## RevTag:: r472 ##".strip('# ').replace('RevTag::', 'revision')

def main():
    from cmd import ProcessCommandLine
    from config import config

#    ProcessConfig()
    # This loads options and creates the config object
    ProcessCommandLine()

    print_then_exit = False

    if config['list_all_tagnames']:
        from languages import Languages
        print "TAGNAMES;" + ",".join(Languages.GenerateFullKindList())
        print_then_exit = True

    if config['generate_extension_lookup']:
        extension_table = config['language_handler'].GenerateExtensionTable()
        print "EXTENSIONS;" + ",".join("%s:%s" % (k, v) for (k, v) in extension_table.items())
        print_then_exit = True

    if print_then_exit:
        return

    from cscope import GenerateCScopeDBIfRequired
    from ctags import GenerateTags, ParseTags
    from generation import CreateTypesFile

    GenerateCScopeDBIfRequired(config)

    if not config['use_existing_tagfile']:
        GenerateTags(config)

    tag_db = ParseTags(config)

    for language in config['language_list']:
        if language in tag_db:
            CreateTypesFile(config, language, tag_db[language])

if __name__ == "__main__":
    main()
