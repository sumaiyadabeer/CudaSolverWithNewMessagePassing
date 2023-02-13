#!/usr/bin/env python3

import random
import argparse

def generate_b(n, nsinks, sink_index, source_index):
    b = [0]*n

    for i in random.sample(range(n), nsinks):
        b[i] = 1
    b[-1] = -sum(b)

#     b[sink_index] = -1
#     b[source_index] = 1
    
    flag=0
    while(flag == 0):
            random_index = random.randrange(len(b))
            if (b[random_index] == 0):
            	b[random_index] = -sum(b)
            	flag=1
    return b

def writeToFile(b, fname):
    with open(fname, 'w') as f:
        for i in b:
            print(i, end='\t',file=f)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(
            description=
            'Generate RHS of Lx=b')

    parser.add_argument(
            'size',
            type=int,
            help='Number of vertices')

    parser.add_argument(
            '--fsources',
            type=float,
            help='Fraction of source',
            default=0.1)


    parser.add_argument(
            '--output',
            type=str,
            help='Output file name',
            default='b$size.inp')

    parser.add_argument(
            '--sink_index',
            type=int,
            help='Position of sink')
            
    parser.add_argument(
            '--source_index',
            type=int,
            help='Position of source')

    args = parser.parse_args()

    n = args.size
    b = generate_b(n, int(n*args.fsources), args.sink_index, args.source_index)
   

    ofname = args.output
    if ofname == 'b$size.inp':
        ofname = 'b' + str(n) + '.inp'

    writeToFile(b, ofname)
