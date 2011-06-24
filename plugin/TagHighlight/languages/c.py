from class_interface import LanguageClassInterface

class Language(LanguageClassInterface):
    def __init__(self, options):
        self.options = options

    def GetExtensions(self):
        return r'(c|cc|cpp|h|hpp|cxx|hxx)'

    def GetSuffix(self):
        return 'c'

    def KindsToSkip(self):
        return ['ctags_p']

    def GetCTagsOptions(self):
        result = []
        if self.options.include_locals:
            result.append('--c-kinds=+l')
        return result

    def GetCTagsLanguageName(self):
        return 'c'

    @staticmethod
    def GetFriendlyLanguageName():
        return 'c'
