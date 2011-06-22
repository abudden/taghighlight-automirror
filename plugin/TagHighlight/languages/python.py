from class_interface import LanguageClassInterface

class Language(LanguageClassInterface):
    def __init__(self, options):
        self.options = options

    def GetParameters(self):
        params = {
                'iskeyword': '@,48-57,_,192-255',
                'suffix': 'py',
                'name': 'python',
                'extensions': r'pyw?',
                }
        return params

    def KindsToSkip(self):
        return []

    def GetCTagsOptions(self):
        return []

    def GetCTagsLanguageName(self):
        return 'python'

    @staticmethod
    def GetFriendlyLanguageName():
        return 'python'
