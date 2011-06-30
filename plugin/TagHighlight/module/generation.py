from __future__ import print_function
import os
from .utilities import GenerateValidKeywordRange, IsValidKeyword

vim_synkeyword_arguments = [
        'contains',
        'oneline',
        'fold',
        'display',
        'extend',
        'contained',
        'containedin',
        'nextgroup',
        'transparent',
        'skipwhite',
        'skipnl',
        'skipempty'
        ]


def CreateTypesFile(options, language, tags):
    tag_types = list(tags.keys())
    tag_types.sort()

    language_handler = options['language_handler'].GetLanguageHandler(language)

    if options['check_keywords']:
        iskeyword = GenerateValidKeywordRange(language_handler.GetIsKeyword())

    matchEntries = set()
    vimtypes_entries = []


    # TODO: This may be included elsewhere, but we'll leave it in for now
    typesUsedByLanguage = list(options['language_handler'].GetKindList(language).values())
    clear_string = 'silent! syn clear ' + " ".join(typesUsedByLanguage)

    vimtypes_entries = []
    vimtypes_entries.append(clear_string)

    # Get the priority list from the language handler
    priority = language_handler.Priority[:]
    # Reverse the priority such that highest priority
    # is last.
    priority.reverse()

    fullTypeList = sorted(tags.keys())
    # Reorder type list according to priority sort order
    allTypes = []
    for thisType in priority:
        if thisType in fullTypeList:
            allTypes.append(thisType)
            fullTypeList.remove(thisType)
    # Add the ones not specified in priority
    allTypes += fullTypeList

    for thisType in allTypes:
        keystarter = 'syn keyword ' + thisType
        keycommand = keystarter
        for keyword in tags[thisType]:
            if options['check_keywords']:
                # In here we should check that the keyword only matches
                # vim's \k parameter (which will be different for different
                # languages).  This is quite slow so is turned off by
                # default; however, it is useful for some things where the
                # default generated file contains a lot of rubbish.  It may
                # be worth optimising IsValidKeyword at some point.
                if not IsValidKeyword(keyword, iskeyword):
                    matchDone = False

                    patternCharacters = "/@#':"
                    charactersToEscape = '\\' + '~[]*.$^'

                    for patChar in patternCharacters:
                        if keyword.find(patChar) == -1:
                            escapedKeyword = keyword
                            for ch in charactersToEscape:
                                escapedKeyword = escapedKeyword.replace(ch, '\\' + ch)
                            if not options['skip_matches']:
                                matchEntries.add('syn match ' + thisType + ' ' + patChar + escapedKeyword + patChar)
                            matchDone = True
                            break

                    if not matchDone:
                        print("Skipping keyword '" + keyword + "'")

                    continue


            if keyword.lower() in vim_synkeyword_arguments:
                if not options['skip_vimkeywords']:
                    matchEntries.add('syn match ' + thisType + ' /' + keyword + '/')
                continue

            temp = keycommand + " " + keyword
            if len(temp) >= 512:
                vimtypes_entries.append(keycommand)
                keycommand = keystarter
            keycommand = keycommand + " " + keyword
        if keycommand != keystarter:
            vimtypes_entries.append(keycommand)

    # Sort the matches
    matchEntries = sorted(list(matchEntries))

    vimtypes_entries.append('')
    vimtypes_entries += matchEntries

    AddList = 'add='
    for thisType in allTypes:
        if thisType in typesUsedByLanguage:
            if AddList != 'add=':
                AddList += ','
            AddList += thisType

    if language in ['c',]:
        vimtypes_entries.append('')
        vimtypes_entries.append("if exists('b:hlrainbow') && !exists('g:nohlrainbow')")
        vimtypes_entries.append('\tsyn cluster cBracketGroup ' + AddList + LocalTagType)
        vimtypes_entries.append('\tsyn cluster cCppBracketGroup ' + AddList + LocalTagType)
        vimtypes_entries.append('\tsyn cluster cCurlyGroup ' + AddList + LocalTagType)
        vimtypes_entries.append('\tsyn cluster cParenGroup ' + AddList + LocalTagType)
        vimtypes_entries.append('\tsyn cluster cCppParenGroup ' + AddList + LocalTagType)
        vimtypes_entries.append('endif')
    if language in ['java',]:
        vimtypes_entries.append('')
        vimtypes_entries.append('syn cluster javaTop ' + AddList + LocalTagType)

    filename = os.path.join(options['type_file_location'],
            options['type_file_prefix'] + language_handler.GetSuffix() + '.vim')

    try:
        # Have to open in binary mode as we want to write with Unix line endings
        # The resulting file will then work with any Vim (Windows, Linux, Cygwin etc)
        fh = open(filename, 'wb')
    except IOError:
        sys.stderr.write("ERROR: Couldn't create {file}\n".format(file=outfile))
        sys.exit(1)

    try:
        for line in vimtypes_entries:
            fh.write(line.encode('ascii'))
            fh.write('\n'.encode('ascii'))
    except IOError:
        sys.stderr.write("ERROR: Couldn't write {file} contents\n".format(file=outfile))
        sys.exit(1)
    finally:
        fh.close()
