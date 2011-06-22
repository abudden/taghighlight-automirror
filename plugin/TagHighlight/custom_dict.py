class CustomDict(dict):
    """Customised version of a dictionary that allows access by attribute."""
    def __getattr__(self, name):
        return self[name]

    def __setattr__(self, name, value):
        self[name] = value
