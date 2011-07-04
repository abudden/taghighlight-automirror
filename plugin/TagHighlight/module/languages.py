import os
import glob

from ..config import config

class Languages():
    registry = {}

    def __init__(self, options):
        self.options = options
        self.kinds = None

        # Import language specific modules: this will make them be parsed
        # and will add to the registry
        defaults_file = os.path.join(config['data_directory'], 'language_defaults.txt')
        self.defaults = self.ReadConfigFile(defaults_file)

        language_dir = os.path.join(config['data_directory'],'languages')
        for language_file in glob.glob(os.path.join(language_dir, '*.txt')):
            language_file = os.path.join(language_dir, language_file)
            language_dict = self.ReadConfigFile(language_file)
            language_dict['Filename'] = language_file
            language_dict = self.VerifyLanguage(language_dict)
            self.registry[language_dict['FriendlyName']] = language_dict

    def ReadConfigFile(self, filename):
        result = {}
        fh = open(filename, 'r')
        list_entries = ['SkipList','Priority']
        key = None
        for line in fh:
            if line.strip().endswith(':') and line[0] not in [' ','\t',':','#']:
                key = line.strip()[:-1]
                result[key] = []
            elif key is not None and line.startswith('\t'):
                result[key] += [line.strip()]
            elif ':' in line and line[0] not in [' ','\t',':','#']:
                # End of the previous list, so reset key
                key = None
                parts = line.strip().split(':',1)
                if parts[0] in list_entries:
                    if ',' in parts[1]:
                        result[parts[0]] = parts[1].split(',')
                    else:
                        result[parts[0]] = [parts[1]]
                else:
                    result[parts[0]] = parts[1]
        fh.close()
        return result

    def VerifyLanguage(self, language_dict):
        required_keys = [
                'FriendlyName',
                'CTagsName',
                'PythonExtensionMatcher',
                'VimExtensionMatcher',
                'Suffix',
                'SkipList',
                'IsKeyword',
                'Priority',
                ]
        for key in required_keys:
            if key not in language_dict:
                if key in self.defaults:
                    language_dict[key] = self.defaults[key]
                else:
                    raise Exception("Language data from file {filename} is " \
                            "missing required key {key} (no default " \
                            "available).".format(filename=language_dict['Filename'],
                                key=key))
        return language_dict

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
                if line[0] not in [' ','\t',':','#']:
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

