class LanguageClassInterface():
    """Default priority: specified highest priority first.

    Can be overridden in specific language implementations.
    """
    Priority = [
            'CTagsNamespace', 'CTagsClass', 'CTagsDefinedName',
            'CTagsType', 'CTagsMethod', 'CTagsFunction',
            'CTagsEnumerationValue', 'CTagsEnumeratorName',
            'CTagsConstant', 'CTagsGlobalVariable',
            'CTagsUnion', 'CTagsProperty', 'CTagsMember',
            'CTagsStructure',
            ]

    def __init__(self, options):
        self.options = options

    def GetExtensions(self):
        raise NotImplementedError

    def GetSuffix(self):
        raise NotImplementedError

    def GetIsKeyword(self):
        return '@,48-57,_,192-255'

    def GetVimMatcher(self):
        python_matcher = self.GetExtensions()
        special_characters = '()|?+'
        vim_matcher = python_matcher
        for ch in special_characters:
            vim_matcher = vim_matcher.replace(ch, "\\" + ch)
        return vim_matcher

    def KindsToSkip(self):
        raise NotImplementedError

    def GetCTagsOptions(self):
        raise NotImplementedError

    def GetCTagsLanguageName(self):
        raise NotImplementedError

    @staticmethod
    def GetFriendlyLanguageName():
        raise NotImplementedError
