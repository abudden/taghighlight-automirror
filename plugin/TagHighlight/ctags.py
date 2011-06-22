import subprocess
import os
import re
import glob

field_processor = re.compile(
r'''
	^                 # Start of the line
	(?P<keyword>.*?)  # Capture the first field: everything up to the first tab
	\t                # Field separator: a tab character
	.*?               # Second field (uncaptured): everything up to the next tab
	\t                # Field separator: a tab character
	(?P<search>.*?)   # Any character at all, but as few as necessary (i.e. catch everything up to the ;")
	;"                # The end of the search specifier (see http://ctags.sourceforge.net/FORMAT)
	(?=\t)            # There MUST be a tab character after the ;", but we want to match it with zero width
	.*\t              # There can be other fields before "kind", so catch them here.
	                  # Also catch the tab character from the previous line as there MUST be a tab before the field
	(kind:)?          # This is the "kind" field; "kind:" is optional
	(?P<kind>\w)      # The kind is a single character: catch it
	(\t|$)            # It must be followed either by a tab or by the end of the line
	.*                # If it is followed by a tab, soak up the rest of the line; replace with the syntax keyword line
''', re.VERBOSE)


def GenerateTags(options):
    print "Generating Tags"

    args = GetCommandArgs(options)

    ctags_cmd = [options['ctags_exe_full']] + args
    print ctags_cmd

    #subprocess.call(" ".join(ctags_cmd), shell = (os.name != 'nt'))
    subprocess.call(ctags_cmd)

    tagFile = open(options['ctags_file'], 'r')
    tagLines = [line.strip() for line in tagFile]
    tagFile.close()

    # Also sort the file a bit better (tag, then kind, then filename)
    tagLines.sort(key=ctags_key)

    tagFile = open(options['ctags_file'], 'w')
    for line in tagLines:
        tagFile.write(line + "\n")
    tagFile.close()

def ParseTags(options):
    """Function to parse the tags file and generate a dictionary containing language keys.

    Each entry is a list of tags with all the required details.
    """
    return {}

def GetCommandArgs(options):
    args = []

    ctags_languages = [l.GetCTagsLanguageName() for l in options['language_handler'].GetAllLanguageHandlers()]
    if 'c' in ctags_languages:
        ctags_languages.append('c++')
    args += ["--languages=" + ",".join(ctags_languages)]

    if options['ctags_file']:
        args += ['-f', options['ctags_file']]

    if not options['include_docs']:
        args += ["--exclude=docs", "--exclude=Documentation"]

    for language_handler in options['language_handler'].GetAllLanguageHandlers():
        args += language_handler.GetCTagsOptions()

    # Must be last as it includes the file list:
    if options['recurse']:
        args += ['--recurse']
        args += ['.']
    else:
        args += glob.glob('*')

    return args

key_regexp = re.compile('^(?P<keyword>.*?)\t(?P<remainder>.*\t(?P<kind>[a-zA-Z])(?:\t|$).*)')

def ctags_key(ctags_line):
    match = key_regexp.match(ctags_line)
    if match is None:
        return ctags_line
    return match.group('keyword') + match.group('kind') + match.group('remainder')
