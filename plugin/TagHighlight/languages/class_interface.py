class LanguageClassInterface():
    def __init__(self, options):
        self.options = options

    def GetParameters(self):
        raise NotImplementedError

    def GetCTagsOptions(self):
        raise NotImplementedError

    def GetCTagsLanguageName(self):
        raise NotImplementedError

    @staticmethod
    def GetFriendlyLanguageName():
        raise NotImplementedError
