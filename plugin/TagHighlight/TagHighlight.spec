# -*- mode: python -*-
# Work out what language files are needed
a = Analysis([os.path.join(HOMEPATH,'support\\_mountzlib.py'), os.path.join(HOMEPATH,'support\\useUnicode.py'), 'TagHighlight.py'],
        pathex=['.'])
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
        name='Compiled/Win32')

# vim: ft=python
