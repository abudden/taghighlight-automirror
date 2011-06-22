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

