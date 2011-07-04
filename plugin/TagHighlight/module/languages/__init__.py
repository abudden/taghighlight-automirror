import os
from ..config import config

class Languages():
    registry = {}

    def __init__(self, options):
        self.options = options
        self.kinds = None

        # Import language specific modules: this will make them be parsed
        # and will add to the registry
        import os
        import sys

        # Get the list of languages.  For pyinstaller variants, this is from a module
        # generated at compile time.  For script runs, this is done by parsing the
        # list of files in the languages directory and loading everything except
        # this file and class_interface.py
        if hasattr(sys, "frozen"):
            import all_languages
            mod_list = all_languages.languages
        else:
            mod_dir = os.path.dirname(__file__)
            mod_list = ['module.languages.' + i[:-3] for i in os.listdir(mod_dir) if i not in ['__init__.py','class_interface.py'] and i[-3:] == '.py']

        for module in mod_list:
            mod_import_name = module
            __import__(mod_import_name)
            mod = sys.modules[mod_import_name]

            class_name = 'Language'
            if class_name not in dir(mod):
                try:
                    if len(mod.__all__) == 1:
                        class_name = mod.__all__[0]
                except AttributeError:
                    raise NotImplementedError("Missing class (either call it Language or make it the only thing in __all__) for module {module}".format(module=mod_import_name))

            mod_class = getattr(mod, class_name)
            self.registry[mod_class.GetFriendlyLanguageName()] = \
                    mod_class(options)

    def GetAllLanguages(self):
        return list(self.registry.keys())

    def GetAllLanguageHandlers(self):
        return list(self.registry.values())

    def GetLanguageHandler(self, name):
        return self.registry[name]

    def GenerateExtensionTable(self):
        results = {}
        for handler in list(self.registry.values()):
            extensions = handler.GetVimMatcher()
            suffix = handler.GetSuffix()
            results[extensions] = suffix
        return results

    def GenerateFullKindList(self):
        self.LoadKindList()
        kinds = set()
        for language in list(self.kinds.keys()):
            kinds |= set(self.kinds[language].values())
        return sorted(list(kinds))

    def GetKindList(self, language=None):
        """Explicit list of kinds exported from ctags help."""
        if self.kinds is None:
            kind_file = os.path.join(config['data_directory'], 'kinds.txt')
            fh = open(kind_file, 'r')
            self.kinds = {}
            language_key = None
            for line in fh:
                if line[0] not in [' ','\t']:
                    if line.strip().endswith(':'):
                        language_key = line.strip()[:-1]
                else:
                    parts = line.strip().split(':')
                    if len(parts) == 2 and language_key is not None:
                        if language_key not in self.kinds:
                            self.kinds[language_key] = {}
                        self.kinds[language_key]['ctags_'+parts[0]] = parts[1]
            fh.close()

        if language is None:
            return self.kinds
        elif language in self.kinds:
            return self.kinds[language]
        else:
            return None

