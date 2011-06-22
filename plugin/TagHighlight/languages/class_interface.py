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

    def GetParameters(self):
        raise NotImplementedError

    def KindsToSkip(self):
        raise NotImplementedError

    def GetCTagsOptions(self):
        raise NotImplementedError

    def GetCTagsLanguageName(self):
        raise NotImplementedError

    @staticmethod
    def GetFriendlyLanguageName():
        raise NotImplementedError
