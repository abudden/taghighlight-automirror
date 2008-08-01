#!/usr/bin/env python
import os
import optparse
import re
import fnmatch
import glob

field_processor = re.compile(
r'''
	^                # Start of the line
	(?P<keyword>.*?) # Capture the first field: everything up to the first tab
	\t               # Field separator: a tab character
	.*?              # Second field (uncaptured): everything up to the next tab
	\t               # Field separator: a tab character
	(.*?)            # Any character at all, but as few as necessary (i.e. catch everything up to the ;")
	;"               # The end of the search specifier (see http://ctags.sourceforge.net/FORMAT)
	(?=\t)           # There MUST be a tab character after the ;", but we want to match it with zero width
	.*\t             # There can be other fields before "kind", so catch them here.
			         # Also catch the tab character from the previous line as there MUST be a tab before the field
	(kind:)?         # This is the "kind" field; "kind:" is optional
	(?P<kind>\w)     # The kind is a single character: catch it
	(\t|$)           # It must be followed either by a tab or by the end of the line
	.*               # If it is followed by a tab, soak up the rest of the line; replace with the syntax keyword line
''', re.VERBOSE)

field_trim = re.compile(r'ctags_[pF]')
field_keyword = re.compile(r'syntax keyword (?P<kind>ctags_\w) (?P<keyword>.*)')

ctags_exe = 'ctags'

class GlobDirectoryWalker:
    # a forward iterator that traverses a directory tree

    def __init__(self, directory, pattern="*"):
        self.stack = [directory]
        self.pattern = pattern
        self.files = []
        self.index = 0

    def __getitem__(self, index):
        while 1:
            try:
                file = self.files[self.index]
                self.index = self.index + 1
            except IndexError:
                # pop next directory from stack
                self.directory = self.stack.pop()
                self.files = os.listdir(self.directory)
                self.index = 0
            else:
                # got a filename
                fullname = os.path.join(self.directory, file)
                if os.path.isdir(fullname) and not os.path.islink(fullname):
                    self.stack.append(fullname)
                if fnmatch.fnmatch(file, self.pattern):
                    return fullname

def GetCommandArgs(options):
	Configuration = {}
	if options.recurse:
		Configuration['CTAGS_OPTIONS'] = '--recurse'
		Configuration['CTAGS_FILES'] = ['.']
	else:
		Configuration['CTAGS_OPTIONS'] = ''
		Configuration['CTAGS_FILES'] = glob.glob('*')
	return Configuration

def CreateTagsFile(config):
	print "Generating Tags"
	ctags_cmd = '%s %s %s' % (ctags_exe, config['CTAGS_OPTIONS'], " ".join(config['CTAGS_FILES']))
	os.system(ctags_cmd)

def GetLanguageParameters(lang):
	params = {}
	if lang == 'c':
		params['language'] = 'c,c++,c#'
		params['suffix'] = 'c'
		params['inames'] = '*.[ch]*'
	elif lang == 'python':
		params['language'] = 'python'
		params['suffix'] = 'py'
		params['inames'] = '*.py'
	elif lang == 'ruby':
		params['language'] = 'ruby'
		params['suffix'] = 'ruby'
		params['inames'] = '*.rb'
	elif lang == 'vhdl':
		params['language'] = 'vhdl'
		params['suffix'] = 'vhdl'
		params['inames'] = '*.vhd*'
	else:
		raise AttributeError('Language not recognised %s' % lang)
	return params

def CreateTypesFile(config, Parameters):
	outfile = 'types_%s.vim' % Parameters['suffix']
	print "Generating " + outfile
	ctags_cmd = '%s %s --languages=%s -o- %s' % \
			(ctags_exe, config['CTAGS_OPTIONS'], Parameters['language'], " ".join(config['CTAGS_FILES']))
	p = os.popen(ctags_cmd, "r")

	ctags_entries = []
	while 1:
		line = p.readline()
		if not line:
			break
		vimmed_line = field_processor.sub(r'syntax keyword ctags_\g<kind> \g<keyword>', line.strip())

		if not field_trim.match(vimmed_line):
			ctags_entries.append(vimmed_line)
	
	# Essentially a uniq() function
	ctags_entries = dict.fromkeys(ctags_entries).keys()
	# Sort the list
	ctags_entries.sort()

	if len(ctags_entries) == 0:
		print "No tags found"
		return
	
	keywordDict = {}
	for line in ctags_entries:
		m = field_keyword.match(line)
		if m is not None:
			if not keywordDict.has_key(m.group('kind')):
				keywordDict[m.group('kind')] = []
			keywordDict[m.group('kind')].append(m.group('keyword'))
	
	vimtypes_entries = []
	for thisType in sorted(keywordDict.keys()):
		keystarter = "syntax keyword " + thisType
		keycommand = keystarter
		for keyword in keywordDict[thisType]:
			temp = keycommand + " " + keyword
			if len(temp) >= 512:
				vimtypes_entries.append(keycommand)
				keycommand = keystarter
			keycommand = keycommand + " " + keyword
		vimtypes_entries.append(keycommand)

	vimtypes_entries.append('')
	vimtypes_entries.append('" Class')
	vimtypes_entries.append('hi link ctags_c ClassName')
	vimtypes_entries.append('" Define')
	vimtypes_entries.append('hi link ctags_d DefinedName')
	vimtypes_entries.append('" Enumerator')
	vimtypes_entries.append('hi link ctags_e Enumerator')
	vimtypes_entries.append('" Function or method')
	vimtypes_entries.append('hi link ctags_f Function')
	vimtypes_entries.append('" Enumeration name')
	vimtypes_entries.append('hi link ctags_g EnumerationName')
	vimtypes_entries.append('" Member (of structure or class)')
	vimtypes_entries.append('hi link ctags_m Member')
	vimtypes_entries.append('" Structure Name')
	vimtypes_entries.append('hi link ctags_s Structure')
	vimtypes_entries.append('" Typedef')
	vimtypes_entries.append('hi link ctags_t Type')
	vimtypes_entries.append('" Union Name')
	vimtypes_entries.append('hi link ctags_u Union')
	vimtypes_entries.append('" Variable')
	vimtypes_entries.append('hi link ctags_v Variable')

	try:
		fh = open(outfile, 'wb')
	except IOError:
		sys.stderr.write("ERROR: Couldn't create %s\n" % (outfile))
		sys.exit(1)
	
	try:
		for line in vimtypes_entries:
			fh.write(line)
			fh.write('\n')
	except IOError:
		sys.stderr.write("ERROR: Couldn't write %s contents\n" % (outfile))
		sys.exit(1)
	finally:
		fh.close()


def CheckFilePresence(recurse, inames):
	if recurse:
		fileList = [fname for fname in GlobDirectoryWalker('.', inames)]
	else:
		fileList = glob.glob(inames)

	return (len(fileList) > 0)

def main():
	import optparse
	parser = optparse.OptionParser()
	parser.add_option('-r','-R','--recurse',
			action="store_true",
			default=False,
			dest="recurse",
			help="Recurse into subdirectories")
	parser.add_option('--ctags-dir',
			action='store',
			default='.',
			dest='ctags_dir',
			type='string',
			help='CTAGS Executable Directory')
	options, remainder = parser.parse_args()
	global ctags_exe
	ctags_exe = options.ctags_dir + '/' + 'ctags'

	Configuration = GetCommandArgs(options)
	CreateTagsFile(Configuration)

	for language in ['c', 'python', 'ruby', 'vhdl']:
		Parameters = GetLanguageParameters(language)
		if not CheckFilePresence(options.recurse, Parameters['inames']):
			continue
		CreateTypesFile(Configuration, Parameters)
	


if __name__ == "__main__":
	main()

