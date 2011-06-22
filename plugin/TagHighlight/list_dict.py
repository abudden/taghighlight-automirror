class ListDict(dict):
    def __getitem__(self, key):
        if key not in self:
            self[key] = []
        return super(ListDict, self).__getitem__(key)

if __name__ == "__main__":
    test_obj = ListDict()
    # Should be able to add an item to the list
    import pprint
    pprint.pprint(test_obj)

    test_obj['MyIndex'].append('Hello')
    pprint.pprint(test_obj)
