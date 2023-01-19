#!/usr/bin/env python3

import sys
import numpy as np

def readInputFile(ifname):
    with open(ifname) as f:
        content = [x.strip() for x in f.readlines()]

        n, m = [int(x) for x in content[0].split()]
        # print(n,m)
        A = [[0 for j in range(n)] for i in range(n)]

        row_ptr = [int(x) for x in content[1].split()]
        # print(row_ptr)
        col_offset = [int(x) for x in content[2].split()]
        values = [float(x) for x in content[3].split()]

        # print("row ptr: ", content[1])
        # print("col offset: ", content[2])
        # # print("values: ", content[3])
        # for(int i = row_ptr[index]; i<row_ptr[index+1]; i++){
		# L[(col_off[i])+n*(index)]= -values[i];

        for i in range(1,len(row_ptr)):
            # print(i-1, col_offset[row_ptr[i-1]: row_ptr[i]], values[row_ptr[i-1]: row_ptr[i]])
            for (j, k) in zip(col_offset[row_ptr[i-1]: row_ptr[i]], values[row_ptr[i-1]: row_ptr[i]]):
                A[i-1][j] = k
        b = [float(x) for x in content[4].split()]
        # print(A)
        return A, b

def computeSolutionLstsq(A, b):
    L = np.array(np.diag([sum(row) for row in A]) - np.array(A))
    b = np.array(b)

    x = np.linalg.lstsq(L, b, rcond = None)[0]
    assert np.allclose(np.dot(L, x), b)
    return x

def computeSolutionJacobi(A, b):
    # print(A)
    # print(b)    
    n = len(b)
    d = np.diag([sum(row) for row in A])
    # print(d)
    di = np.diag([1/sum(row) for row in A])
    # print(di)
    # A = [[A[i][j] for j in range(n)] for i in range(n)]
    A = np.array(A)
    b = np.array(b)
    x = np.array([1]*n)
    while 1:
        y = di.dot(A.dot(x) + b)
        print(".", end="")
        d = np.absolute(x - y)
        e = np.linalg.norm(d)/np.linalg.norm(x)
        if e < 1e-3: break
        x = y
    #scale the solution so the sink entry is zero
    sink_values = [abs(j) for (i,j) in enumerate(y) if y[i] < 0]
    # print(max(sink_values))

    #  = abs(loop if)
    x = x + float(max(sink_values))
    return x

def writeToFile(afname, x):
    n = len(x) #int(afname.split('.')[0])
    with open(afname, 'w') as f:
        for i in range(n):
            print(x[i], end = " " if i < n - 1 else '', file = f)

if __name__ == "__main__":
    ifname = sys.argv[1]

    A, b = readInputFile(ifname)
    #y = computeSolutionLstsq(A, b)
    y = computeSolutionJacobi(A, b)

    afname = ifname.replace('input', 'answer')
    writeToFile(afname, y)
