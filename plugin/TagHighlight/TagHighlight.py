#!/usr/bin/env python
#  Author:  A. S. Budden

from __future__ import print_function
import sys

def main():
    from module.cmd import ProcessCommandLine
    from module.worker import RunWithOptions

    options = ProcessCommandLine()
    RunWithOptions(options)

if __name__ == "__main__":
    main()
