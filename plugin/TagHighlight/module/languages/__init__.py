class Languages():
    registry = {}

    def __init__(self, options):
        self.options = options

        # Import language specific modules: this will make them be parsed
        # and will add to the registry
        import os
        import sys

        for module in os.listdir(os.path.dirname(__file__)):
            if module in ['__init__.py', 'class_interface.py'] or module[-3:] != '.py':
                continue

            mod_import_name = 'module.languages.' + module[:-3]
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

    @staticmethod
    def GenerateFullKindList():
        all_kinds = Languages.GetKindList()
        kinds = set()
        for language in list(all_kinds.keys()):
            kinds |= set(all_kinds[language].values())
        return sorted(list(kinds))

    @staticmethod
    def GetKindList(language=None):
        """Explicit list of kinds exported from ctags help."""
        LanguageKinds = {}
        LanguageKinds['asm'] = \
        {
            'ctags_d': 'CTagsDefinedName',
            'ctags_l': 'CTagsLabel',
            'ctags_m': 'CTagsMacro',
            'ctags_t': 'CTagsType',
        }
        LanguageKinds['asp'] = \
        {
            'ctags_c': 'CTagsConstant',
            'ctags_f': 'CTagsFunction',
            'ctags_s': 'CTagsSubroutine',
            'ctags_v': 'CTagsVariable',
        }
        LanguageKinds['awk'] = \
        {
            'ctags_f': 'CTagsFunction',
        }
        LanguageKinds['basic'] = \
        {
            'ctags_c': 'CTagsConstant',
            'ctags_f': 'CTagsFunction',
            'ctags_l': 'CTagsLabel',
            'ctags_t': 'CTagsType',
            'ctags_v': 'CTagsVariable',
            'ctags_g': 'CTagsEnumeration',
        }
        LanguageKinds['beta'] = \
        {
            'ctags_f': 'CTagsFragment',
            'ctags_p': 'CTagsPattern',
            'ctags_s': 'CTagsSlot',
            'ctags_v': 'CTagsVirtualPattern',
        }
        LanguageKinds['c'] = \
        {
            'ctags_c': 'CTagsClass',
            'ctags_d': 'CTagsDefinedName',
            'ctags_e': 'CTagsEnumerationValue',
            'ctags_f': 'CTagsFunction',
            'ctags_g': 'CTagsEnumeratorName',
            'ctags_k': 'CTagsConstant',
            'ctags_l': 'CTagsLocalVariable',
            'ctags_m': 'CTagsMember',
            'ctags_n': 'CTagsNamespace',
            'ctags_p': 'CTagsFunction',
            'ctags_s': 'CTagsStructure',
            'ctags_t': 'CTagsType',
            'ctags_u': 'CTagsUnion',
            'ctags_v': 'CTagsGlobalVariable',
            'ctags_x': 'CTagsExtern',
            'ctags_F': 'CTagsFile',
        }
        LanguageKinds['c++'] = \
        {
            'ctags_c': 'CTagsClass',
            'ctags_d': 'CTagsDefinedName',
            'ctags_e': 'CTagsEnumerationValue',
            'ctags_f': 'CTagsFunction',
            'ctags_g': 'CTagsEnumerationName',
            'ctags_k': 'CTagsConstant',
            'ctags_l': 'CTagsLocalVariable',
            'ctags_m': 'CTagsMember',
            'ctags_n': 'CTagsNamespace',
            'ctags_p': 'CTagsFunction',
            'ctags_s': 'CTagsStructure',
            'ctags_t': 'CTagsType',
            'ctags_u': 'CTagsUnion',
            'ctags_v': 'CTagsGlobalVariable',
            'ctags_x': 'CTagsExtern',
            'ctags_F': 'CTagsFile',
        }
        LanguageKinds['c#'] = \
        {
            'ctags_c': 'CTagsClass',
            'ctags_d': 'CTagsDefinedName',
            'ctags_e': 'CTagsEnumerationValue',
            'ctags_E': 'CTagsEvent',
            'ctags_f': 'CTagsField',
            'ctags_g': 'CTagsEnumerationName',
            'ctags_i': 'CTagsInterface',
            'ctags_l': 'CTagsLocalVariable',
            'ctags_m': 'CTagsMethod',
            'ctags_n': 'CTagsNamespace',
            'ctags_p': 'CTagsProperty',
            'ctags_s': 'CTagsStructure',
            'ctags_t': 'CTagsType',
        }
        LanguageKinds['cobol'] = \
        {
            'ctags_d': 'CTagsData',
            'ctags_f': 'CTagsFileDescription',
            'ctags_g': 'CTagsGroupItem',
            'ctags_p': 'CTagsParagraph',
            'ctags_P': 'CTagsProgram',
            'ctags_s': 'CTagsSection',
        }
        LanguageKinds['eiffel'] = \
        {
            'ctags_c': 'CTagsClass',
            'ctags_f': 'CTagsFeature',
            'ctags_l': 'CTagsEntity',
        }
        LanguageKinds['erlang'] = \
        {
            'ctags_d': 'CTagsDefinedName',
            'ctags_f': 'CTagsFunction',
            'ctags_m': 'CTagsModule',
            'ctags_r': 'CTagsRecord',
        }
        LanguageKinds['fortran'] = \
        {
            'ctags_b': 'CTagsBlockData',
            'ctags_c': 'CTagsCommonBlocks',
            'ctags_e': 'CTagsEntryPoint',
            'ctags_f': 'CTagsFunction',
            'ctags_i': 'CTagsInterfaceComponent',
            'ctags_k': 'CTagsTypeComponent',
            'ctags_l': 'CTagsLabel',
            'ctags_L': 'CTagsLocalVariable',
            'ctags_m': 'CTagsModule',
            'ctags_n': 'CTagsNamelist',
            'ctags_p': 'CTagsProgram',
            'ctags_s': 'CTagsSubroutine',
            'ctags_t': 'CTagsType',
            'ctags_v': 'CTagsGlobalVariable',
        }
        LanguageKinds['html'] = \
        {
            'ctags_a': 'CTagsAnchor',
            'ctags_f': 'CTagsFunction',
        }
        LanguageKinds['java'] = \
        {
            'ctags_c': 'CTagsClass',
            'ctags_e': 'CTagsEnumerationValue',
            'ctags_f': 'CTagsField',
            'ctags_g': 'CTagsEnumeratorName',
            'ctags_i': 'CTagsInterface',
            'ctags_l': 'CTagsLocalVariable',
            'ctags_m': 'CTagsMethod',
            'ctags_p': 'CTagsPackage',
        }
        LanguageKinds['javascript'] = \
        {
            'ctags_f': 'CTagsFunction',
            'ctags_c': 'CTagsClass',
            'ctags_m': 'CTagsMethod',
            'ctags_p': 'CTagsProperty',
            'ctags_v': 'CTagsGlobalVariable',
        }
        LanguageKinds['lisp'] = \
        {
            'ctags_f': 'CTagsFunction',
        }
        LanguageKinds['lua'] = \
        {
            'ctags_f': 'CTagsFunction',
        }
        LanguageKinds['make'] = \
        {
            'ctags_m': 'CTagsFunction',
        }
        LanguageKinds['pascal'] = \
        {
            'ctags_f': 'CTagsFunction',
            'ctags_p': 'CTagsFunction',
        }
        LanguageKinds['perl'] = \
        {
            'ctags_c': 'CTagsGlobalConstant',
            'ctags_f': 'CTagsFormat',
            'ctags_l': 'CTagsLabel',
            'ctags_p': 'CTagsPackage',
            'ctags_s': 'CTagsFunction',
            'ctags_d': 'CTagsFunction',
        }
        LanguageKinds['php'] = \
        {
            'ctags_c': 'CTagsClass',
            'ctags_i': 'CTagsInterface',
            'ctags_d': 'CTagsGlobalConstant',
            'ctags_f': 'CTagsFunction',
            'ctags_v': 'CTagsGlobalVariable',
            'ctags_j': 'CTagsFunction',
        }
        LanguageKinds['python'] = \
        {
            'ctags_c': 'CTagsClass',
            'ctags_f': 'CTagsFunction',
            'ctags_i': 'CTagsImport',
            'ctags_m': 'CTagsMember',
            'ctags_v': 'CTagsGlobalVariable',
        }
        LanguageKinds['rexx'] = \
        {
            'ctags_s': 'CTagsFunction',
        }
        LanguageKinds['ruby'] = \
        {
            'ctags_c': 'CTagsClass',
            'ctags_f': 'CTagsMethod',
            'ctags_m': 'CTagsModule',
            'ctags_F': 'CTagsSingleton',
        }
        LanguageKinds['scheme'] = \
        {
            'ctags_f': 'CTagsFunction',
            'ctags_s': 'CTagsSet',
        }
        LanguageKinds['sh'] = \
        {
            'ctags_f': 'CTagsFunction',
            'ctags_F': 'CTagsFile',
        }
        LanguageKinds['slang'] = \
        {
            'ctags_f': 'CTagsFunction',
            'ctags_n': 'CTagsNamespace',
        }
        LanguageKinds['sml'] = \
        {
            'ctags_e': 'CTagsException',
            'ctags_f': 'CTagsFunction',
            'ctags_c': 'CTagsFunctionObject',
            'ctags_s': 'CTagsSignature',
            'ctags_r': 'CTagsStructure',
            'ctags_t': 'CTagsType',
            'ctags_v': 'CTagsGlobalVariable',
        }
        LanguageKinds['sql'] = \
        {
            'ctags_c': 'CTagsCursor',
            'ctags_d': 'CTagsFunction',
            'ctags_f': 'CTagsFunction',
            'ctags_F': 'CTagsField',
            'ctags_l': 'CTagsLocalVariable',
            'ctags_L': 'CTagsLabel',
            'ctags_P': 'CTagsPackage',
            'ctags_p': 'CTagsFunction',
            'ctags_r': 'CTagsRecord',
            'ctags_s': 'CTagsType',
            'ctags_t': 'CTagsTable',
            'ctags_T': 'CTagsTrigger',
            'ctags_v': 'CTagsGlobalVariable',
            'ctags_i': 'CTagsIndex',
            'ctags_e': 'CTagsEvent',
            'ctags_U': 'CTagsPublication',
            'ctags_R': 'CTagsService',
            'ctags_D': 'CTagsDomain',
            'ctags_V': 'CTagsView',
            'ctags_n': 'CTagsSynonym',
        }
        LanguageKinds['tcl'] = \
        {
            'ctags_c': 'CTagsClass',
            'ctags_m': 'CTagsMethod',
            'ctags_p': 'CTagsFunction',
        }
        LanguageKinds['vera'] = \
        {
            'ctags_c': 'CTagsClass',
            'ctags_d': 'CTagsDefinedName',
            'ctags_e': 'CTagsEnumerationValue',
            'ctags_f': 'CTagsFunction',
            'ctags_g': 'CTagsEnumeratorName',
            'ctags_l': 'CTagsLocalVariable',
            'ctags_m': 'CTagsMember',
            'ctags_p': 'CTagsProgram',
            'ctags_P': 'CTagsFunction',
            'ctags_t': 'CTagsTask',
            'ctags_T': 'CTagsType',
            'ctags_v': 'CTagsGlobalVariable',
            'ctags_x': 'CTagsExtern',
        }
        LanguageKinds['verilog'] = \
        {
            'ctags_c': 'CTagsGlobalConstant',
            'ctags_e': 'CTagsEvent',
            'ctags_f': 'CTagsFunction',
            'ctags_m': 'CTagsModule',
            'ctags_n': 'CTagsNetType',
            'ctags_p': 'CTagsPort',
            'ctags_r': 'CTagsRegisterType',
            'ctags_t': 'CTagsTask',
        }
        LanguageKinds['vhdl'] = \
        {
            'ctags_c': 'CTagsGlobalConstant',
            'ctags_t': 'CTagsType',
            'ctags_T': 'CTagsTypeComponent',
            'ctags_r': 'CTagsRecord',
            'ctags_e': 'CTagsEntity',
            'ctags_C': 'CTagsComponent',
            'ctags_d': 'CTagsPrototype',
            'ctags_f': 'CTagsFunction',
            'ctags_p': 'CTagsFunction',
            'ctags_P': 'CTagsPackage',
            'ctags_l': 'CTagsLocalVariable',
        }
        LanguageKinds['vim'] = \
        {
            'ctags_a': 'CTagsAutoCommand',
            'ctags_c': 'CTagsCommand',
            'ctags_f': 'CTagsFunction',
            'ctags_m': 'CTagsMap',
            'ctags_v': 'CTagsGlobalVariable',
        }
        LanguageKinds['yacc'] = \
        {
            'ctags_l': 'CTagsLabel',
        }

        if language is None:
            return LanguageKinds
        elif language in LanguageKinds:
            return LanguageKinds[language]
        else:
            return None

