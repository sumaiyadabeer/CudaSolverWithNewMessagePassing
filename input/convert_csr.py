import argparse
from itertools import count
from re import L
# import igraph as ig
# from igraph import Graph

parser = argparse.ArgumentParser()
 
# Adding optional argument
parser.add_argument("-f", "--filename", help = "Input Filename")
parser.add_argument("-i", "--index", help = "Index start from 0/1")

 
# Read arguments from command line
args = parser.parse_args()

name=args.filename
file1 = open(name, 'r')
Lines = file1.readlines()
file1.close()

line = Lines[0]
l = line.split()

vertex = int(l[0])
edge = int(l[1])
# print(vertex)


edges={(0,0,0)}  # adding because empty list is not working

for line in Lines[1:]:
    l=line.split()
    edge_list=[]
    edge_list.append(int(l[0])-int(args.index))
    edge_list.append(int(l[1])-int(args.index))
    if(len(l)>2):
    	edge_list.append(float(l[2]))
    else:
    	edge_list.append(1)
    edges.add(tuple(edge_list)) # adding of a to b edge
    edges.add((edge_list[1], edge_list[0], edge_list[2])) # adding of b to a edge
    
edges.remove((0,0,0)) # removal of above dummy object
    


l = list(edges)
l.sort(key=lambda x: int(x[0]))
all_edges = l
# print(all_edges)

row_ptr = [0]
col_offset = []
values = []
prev_index = 0
counter = 0
for i in all_edges:
    col_offset.append(i[1])
    values.append(i[2])
    counter = counter + 1
    # print(i, prev_index)
    if i[0] != prev_index:
        row_ptr.append(counter-1)
        prev_index = i[0]
   
   

# print(row_ptr)
# print(col_offset)
# print(values)

# write no of nodes \t no of modified edges
file1 = open(name+'_converted', 'w')
file1.write(str(vertex)+"\t"+str(len(all_edges))+"\n")  # writing line 1

# write row_ptr \n
for i in row_ptr:    
    file1.write(str(i)+"\t")
file1.write(str(len(all_edges)))
file1.write("\n")


# write col_offset \n
for i in col_offset:    
    file1.write(str(i)+"\t")
file1.write("\n")

# write values \n
for i in values:    
    file1.write(str(i)+"\t")
file1.write("\n")

file1.close()

print(" Conversion is done successfully with filename " + name+'_converted')

## igraph drama ___________________________________> ignoring as it is taking much time
# g = Graph(edges)
# g.es['weight'] = weight
# print(g.summary(verbosity=0))
# print(g.vcount())
# print(g.ecount())

# name=name.split(".")[0]

# #from pprint import pprint
# #import inspect


# #print(inspect.getfullargspec(g.get_adjacency_sparse))
# r=[]
# A=g.get_adjacency_sparse(attribute='weight')
# AA=g.get_adjacency(attribute='weight')
# print(AA)
# file1 = open(name+'_converted.txt', 'w')
# file1.write(str(vertex)+"\t"+str(edge)+"\n")  #reading line 1



# for i in range(len(A.nonzero()[0])):
#     if i%1000==0:
#         print(i)
#     r.append(A.nonzero()[0][i])
#     file1.write(str(A.nonzero()[1][i])+"\t") #col_off
# #file1.close()
 

# #craete row ptr
# row_ptr=[]
# row_ptr.insert(0,g.ecount()*2)
# #next time do it with cpp vectors
# for i in range(g.vcount()-1,0,-1):
#     if i%1000==0:
#         print(i)   
#     try:
#         val=r.index(i)
#         row_ptr.insert(0,val)
#     except:
#         row_ptr.insert(0,val)

# row_ptr.insert(0,0)

# file1.write("\n")
# #file1 = open(name+'csr_rowptr.txt', 'w')
# for i in row_ptr:    
#     file1.write(str(i)+"\t")

# file1.close()

# #values
# values=[]
# for i in range(0,vertex):    
#     for j in range(row_ptr[i], row_ptr[i+1]):    
#     	values.append(AA[i][A.nonzero()[1][j]])	
    	
# print(values)

# file1 = open(name+'_converted.txt', 'r')
# Lines = file1.readlines()
# file1.close()
# file1 = open(name+'_converted.txt', 'w')
# temp = Lines[1]
# Lines[1] = Lines[2]+"\n"
# Lines[2] = temp
# for i in Lines:
#     file1.write(i)
# for i in values:    
#     file1.write(str(i)+"\t")
# file1.write("\n")
# file1.close()


# #print(row_ptr)
# # 2 in case of undirected
# #file1.writelines(s)

