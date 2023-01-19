#!/usr/bin/env python3

import random
import argparse

minw, maxw = 1e-6, 1
def generate_undirectedWeightedConnectedGraph(n, m):
    assert m >= n - 1 and m <= n*(n - 1)/2

    nodes = list(range(0, n))
    A = [{} for j in range(n)]

    def add_random_edges(m):
        n_edges = 0
        for _ in range(m):
            i, j = random.sample(nodes, 2)
            if j not in A[i] and i not in A[j]:
                # w = random.uniform(minw, maxw)
                A[i][j] = 1 #w
                n_edges += 1
        return n_edges

    def mst():
        S, T = set(nodes), set()

        curr = random.sample(S, 1).pop()

        T.add(curr)
        S.remove(curr)
        while S:
            new = random.sample(nodes, 1).pop()
            if new not in T:
                # w = random.uniform(minw, maxw)
                A[curr][new] = 1 #w
                T.add(new)
                S.remove(new)
            curr = new

    mst()
    n_edges = add_random_edges(m - n + 1)
    return A, n_edges + n - 1

def writeToFile(n, m, A, fname):
    with open(fname, 'w') as f:
        print(n, m, file=f)
        for i in range(n):
            for j in sorted(A[i]):
                print(i + 1, j + 1, A[i][j], file = f)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(
            description=
            'Generate positive weighted undirected connected graph')

    parser.add_argument(
            'size',
            type=int,
            help='Number of vertices in the graph')

    parser.add_argument(
            '--sparsity',
            type=str,
            help='Sparseness of graph',
            nargs='?',
            choices=['dense', 'sparse'])

    parser.add_argument(
            '--output',
            type=str,
            help='Output file name',
            default='g$size.inp')

    args = parser.parse_args()

    n = args.size
    if args.sparsity == 'sparse':
        m = int(n * random.uniform(1, 10))
    else:
        m = random.randint(n - 1, n*(n - 1)//2)

    A, m = generate_undirectedWeightedConnectedGraph(n, m)

    ofname = args.output
    if ofname == 'g$size.inp':
        ofname = 'g' + str(n) + '.inp'

    writeToFile(n, m, A, ofname)
