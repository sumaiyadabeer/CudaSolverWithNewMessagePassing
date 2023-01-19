import argparse
import math 
 
# Initialize parser
parser = argparse.ArgumentParser()
 
# Adding optional argument
parser.add_argument("-f", "--filename", help = "Output Filename")
parser.add_argument("-n", "--nodes", help = "Total Nodes")
parser.add_argument("-t", "--type", help = "Type of graph {star, line, mesh, complete }")
 
# Read arguments from command line
args = parser.parse_args()
 
if args.nodes:
    n = int(args.nodes)
    print("Displaying Output as: % s" % args.nodes)

file1 = open(args.filename, 'w')
edges=0
if args.type == "star":
    print("Design star graph")
    for i in range(2,n+1):
        edges = edges + 1 
        file1.write(str(i)+"\t 1\n")


if args.type == "line":
    print("Design line graph")
    for i in range(1,n):
        edges = edges + 1
        file1.write(str(i)+"\t"+str(i+1)+"\n")


if args.type == "cycle":
    print("Design cycle graph")
    for i in range(1,n):
        edges = edges + 1
        file1.write(str(i)+"\t"+str(i+1)+"\n")
    file1.write("1"+"\t"+str(n)+"\n")
    


if args.type == "mesh":
    print("Design mesh graph")
    length = int(math.sqrt(n))
    for i in range(1,n+1):
        if i%length:
            if i+1<=n:
                edges = edges + 1
                file1.write(str(i)+"\t"+str(i+1)+"\n")
            if i+length<=n:
                edges = edges + 1
                file1.write(str(i)+"\t"+str(i+length)+"\n")
    for i in range(length,n+1,length):
        if (i+length)<=n:
            edges = edges + 1
            file1.write(str(i)+"\t"+str(i+length)+"\n")

if args.type == "complete":
    print("Design commplete graph")
    for i in range(1,n+1):
        for j in range(i+1,n+1):
            edges = edges + 1
            file1.write(str(i)+"\t"+str(j)+"\n")

assert (args.type == "complete" or args.type == "cycle" or args.type == "mesh" or args.type == "line" or args.type == "star")
file1.close()
file1 = open(args.filename, 'r+')
readcontent = file1.read() 
file1.seek(0, 0)
file1.write(args.nodes+"\t"+str(edges)+'\n')
file1.write(readcontent) 
file1.close()
