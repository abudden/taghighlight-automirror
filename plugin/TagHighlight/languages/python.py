from class_interface import LanguageClassInterface

class Language(LanguageClassInterface):
    def __init__(self, options):
        self.options = options

    def GetExtensions(self):
        return r'pyw?'

    def GetSuffix(self):
        return 'py'

    def KindsToSkip(self):
        return []

    def GetCTagsOptions(self):
        return []

    def GetCTagsLanguageName(self):
        return 'python'

    @staticmethod
    def GetFriendlyLanguageName():
        return 'python'
