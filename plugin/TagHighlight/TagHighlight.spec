# -*- mode: python -*-
# Work out what language files are needed
language_files = ['module.languages.' + i[:-3] for i in
        os.listdir('module/languages')
        if i not in ['__init__.py', 'class_interface.py'] and
        i[-3:] == '.py']
# Create a directory for hooks (if it doesn't exist already)
try:
    os.mkdir('./hooks')
except OSError:
    pass
# Create a hook for the languages module
fh = open('./hooks/hook-module.languages.py', 'w')
fh.write("hiddenimports = %s\n" % str(language_files))
fh.close()
# Create an empty hook for the top level module (saveas a warning)
fh = open('./hooks/hook-module.py', 'w')
fh.close()
# Create a module holding the list of languages
fh = open('./module/languages/all_languages.py', 'w')
fh.write("languages = %s\n" % str(language_files))
fh.close()

a = Analysis([os.path.join(HOMEPATH,'support\\_mountzlib.py'), os.path.join(HOMEPATH,'support\\useUnicode.py'), 'TagHighlight.py'],
        pathex=['.'],
        hookspath=['./hooks'])
pyz = PYZ(a.pure)
exe = EXE(pyz,
        a.scripts,
        exclude_binaries=1,
        name=os.path.join('build/', 'TagHighlight.exe'),
        debug=False,
        strip=False,
        upx=True,
        console=True )
coll = COLLECT( exe,
        a.binaries,
        a.zipfiles,
        a.datas,
        strip=False,
        upx=True,
        name='Win32Compiled')

# Remove the generated files

os.remove('./hooks/hook-module.languages.py')
os.remove('./hooks/hook-module.py')
os.remove('./hooks/hook-module.languages.pyc')
os.remove('./hooks/hook-module.pyc')
if len(os.listdir('./hooks')) == 0:
    os.rmdir('./hooks')
os.remove('./module/languages/all_languages.py')
os.remove('./module/languages/all_languages.pyc')

# vim: ft=python
