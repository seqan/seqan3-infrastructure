import subprocess
import sys

def getopts(argv):
    opts = {}  # Empty dictionary to store key-value pairs.
    while argv:  # While there are arguments left to parse...
        if argv[0][0] == '-':  # Found a "-name value" pair.
            opts[argv[0]] = argv[1]  # Add key and value to the dictionary.
        argv = argv[1:]  # Reduce the argument list by copying it starting from index 1.
    return opts

if __name__ == '__main__':
    from sys import argv
    myargs = getopts(argv)
    process = subprocess.Popen([myargs.get("-e"), myargs.get("-i")], stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    cnt = 0
    for line in process.stdout:
        if "warning:" in line:
            cnt = cnt + 1
            print line

    if cnt != 0:
        print "Detected %d warnings!" % cnt
        sys.exit(1)

    sys.exit(0)
