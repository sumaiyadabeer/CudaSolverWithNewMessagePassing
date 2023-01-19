#!/usr/bin/env python3
from __future__ import print_function
import sys
#import numpy as np


def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)

def readOutputFile1(ofname):
    with open(ofname) as f:
        content = [x.strip() for x in f.readlines()]

        x, y = [], []
        x.append(np.array([float(i) for i in content[0].split()]))
        y.append(1)
        #for j in range(1, len(content), 2):
        #    y.append(float(content[j - 1].split()[0]))
        #    x.append(np.array([float(i) for i in content[j].split()]))
        return zip(x, y)

def readOutputFile(ofname):
    with open(ofname) as f:
        content = [x.strip() for x in f.readlines()]

        x = np.array([float(i) for i in content[0].split()])
        return x

if __name__ == "__main__":
    print(sys.version)
    ofname = sys.argv[1]
    afname = sys.argv[2]

    x = readOutputFile(afname)

    x -= np.min(x)
    for x_hat, y in readOutputFile1(ofname):
        x_hat -= np.min(x_hat)

        diff = np.absolute(x - x_hat)
        err = np.linalg.norm(diff)/np.linalg.norm(x)
        eprint(y, err, file=sys.stderr)
