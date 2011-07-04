from .config import config
import os

AllOptions = []

def LoadOptionSpecification():
    options_file = os.path.join(config['data_directory'], 'options.txt')
    global AllOptions
    fh = open(options_file, 'r')
    entry = None
    dest = None
    ListKeys = ['CommandLineSwitches']
    RequiredKeys = ['CommandLineSwitches', 'Type', 'Default', 'Help']
    for line in fh:
        if line.strip().endswith(':') and line[0] not in [' ','\t',':','#']:
            dest = line.strip()[:-1]
            if entry is not None:
                AllOptions.append(entry)
            entry = {}
            entry['Destination'] = dest
        elif dest is not None and line.startswith('\t') and ':' in line:
            parts = line.strip().split(':', 1)
            key = parts[0]
            value = parts[1]
            if key in ListKeys:
                value = value.split(',')
            entry[key] = value

    if entry is not None:
        AllOptions.append(entry)

    for entry in AllOptions:
        for key in RequiredKeys:
            if key not in entry:
                raise Exception("Missing option {key} in option {dest}".format(key=key,dest=entry['Destination']))
        if entry['Type'] == bool:
            if entry['Default'] == 'True':
                entry['Default'] = True
            else:
                entry['Default'] = False
        elif entry['Type'] == list:
            if entry['Default'] == '[]':
                entry['Default'] = []
            else:
                entry['Default'] = entry['Default'].split(',')

LoadOptionSpecification()
