# Used for timing a function; from http://www.daniweb.com/code/snippet368.html
# decorator: put @print_timing before a function to time it.
import time
def print_timing(func):
    def wrapper(*arg):
        t1 = time.time()
        res = func(*arg)
        t2 = time.time()
        print '%s took %0.3f ms' % (func.func_name, (t2-t1)*1000.0)
        return res
    return wrapper

class AttributeDict(dict):
    """Customised version of a dictionary that allows access by attribute."""
    def __getattr__(self, name):
        return self[name]

    def __setattr__(self, name, value):
        self[name] = value

class ListDict(dict):
    """Customised version of a dictionary that auto-creates non-existent keys as lists."""
    def __getitem__(self, key):
        if key not in self:
            self[key] = []
        return super(ListDict, self).__getitem__(key)

    def __setitem__(self, key, value):
        if isinstance(value, list):
            super(ListDict, self).__setitem__(key, value)
        else:
            super(ListDict, self).__setitem__(key, [value])

if __name__ == "__main__":
    import pprint
    test_obj = ListDict()
    # Should be able to add an item to the list
    pprint.pprint(test_obj)
    test_obj['MyIndex'].append('Hello')
    test_obj['SetList'] = ['This', 'Is', 'A', 'List']
    test_obj['SetString'] = 'This is a string'
    # These should all be lists:
    pprint.pprint(test_obj)
