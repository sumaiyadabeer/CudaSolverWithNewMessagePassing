import itertools
import argparse	
import networkx as nx
import math


# Initialize parser
parser = argparse.ArgumentParser()
 
# Adding optional argument
parser.add_argument("-f", "--filename", help = "Output Filename")
parser.add_argument("-n", "--nodes", help = "Total Nodes")
parser.add_argument("-p", "--prob", help = "Prob of an edge being selected")
 
# Read arguments from command line
args = parser.parse_args()  

if args.nodes:
    n = int(args.nodes)
else:
    print("Enter number of nodes")
    exit(1) 

if args.prob:
    p = float(args.prob)
    if (p<0 or p>1):
        print("Please enter valid prob ranges")
        exit(1)
else:
    print("Enter probability")
    exit(1) 
# print(n)

is_connected = False
iteration = 0
while( (not is_connected) and iteration < 10):
    # if not create the graph in loop with print
    iteration = iteration + 1
    print( "." , end=" ")
    #create graph
    G = nx.fast_gnp_random_graph(n, p, seed=None, directed=False)
    #chk if connected
    is_connected = nx.is_connected(G)

 
if ((not is_connected)):
    print("\n connected graph is not generated in ", iteration, " iterations")
    exit(1)
	
adj = nx.adjacency_matrix(G)
#print(adj)
#print(list(adj.__dict__))

indptr = list(adj.__dict__['indptr'])
indices = list(adj.__dict__['indices'])
data = list(adj.__dict__['data'])

file1 = open(args.filename, 'w')

file1.write(str(n)+"\t"+str(len(data))+"\n")

for i in indptr:
	file1.write(str(i)+"\t")
file1.write("\n")

for i in indices:
	file1.write(str(i)+"\t")
file1.write("\n")

for i in data:
	file1.write(str(i)+"\t")
file1.write("\n")

file1.close()