import numpy as np
import pyamg

import matplotlib
matplotlib.use('Agg') # set the backend before importing pyplot
import matplotlib.pyplot as plt 
import argparse

import scipy
import time


def Admat_frm_CSR(row_ptr, col_off, values):
    N = len(row_ptr)-1
    A = [0]*(N*N)
    for i in range(0,len(row_ptr)-1):
        degree = row_ptr[i+1]-row_ptr[i]
        A[(N*i)+i] = degree
#         print(N,i, N*i)
        for j in range(row_ptr[i],row_ptr[i+1]):
#             print(i,j)
            A[(col_off[j])+N*(i)]= -values[j];


    A=np.asarray(A)
    A = A.reshape(N, N).T 
    return A

def read_graph(filename):
    
    file1 = open(filename, 'r')
    Lines = file1.readlines()
    file1.close()

    node_edge = Lines[0]
    node_edge = node_edge.split()
    node_edge = [int(i) for i in node_edge]
    
    row_ptr = Lines[1]
    row_ptr = row_ptr.split()
    row_ptr = [int(i) for i in row_ptr]
    
    col_off = Lines[2]
    col_off = col_off.split()
    col_off = [int(i) for i in col_off]
    
    values = Lines[3]
    values = values.split()
    values = [float(i) for i in values]
    
    b = Lines[4]
    b = b.split()
    b = [int(i) for i in b]
    
    
    return node_edge, row_ptr, col_off, values, b

def make_two_scatter_plot(input_list1, input_list2, title, path_to_save, x_title, y_title, color ):
    plt.scatter(list(range(0, len(input_list1))), input_list1, c = "red", label="Lsolve")
    plt.scatter(list(range(0, len(input_list2))), input_list2, c = "blue", label="pyamg")
 
    # To show the plot
    plt.legend()
    plt.xlabel(x_title)
    plt.ylabel(y_title)
    plt.title(title)
    plt.savefig(path_to_save+title+".png")
    plt.close() 


def make_scatter_plot(input_list, title, path_to_save, x_title, y_title, color ):
    plt.scatter(list(range(0, len(input_list))), input_list, c = color)
 
    # To show the plot
    plt.xlabel(x_title)
    plt.ylabel(y_title)
    plt.title(title)
    plt.savefig(path_to_save+title+".png")
    plt.close() 



#take input as an argumnt p  n 

# Initialize parser
parser = argparse.ArgumentParser()
 
# Adding optional argument
parser.add_argument("-f", "--folder", help = "Name of input folder and probability of an edge present in G")
parser.add_argument("-n", "--node", help = "number of nodes in G")
 
# Read arguments from command line
args = parser.parse_args()


folder = args.folder
nodes = args.node

#calculate beta input and result file
prob = "0."+ folder 
input_file = "data/"+folder+"/ER_"+prob+"_"+nodes+".txt"
result_file = "data/"+folder+"/ER_"+prob+"_"+nodes+".out"
stat_file = "data/"+folder+"/ER_"+prob+"_"+nodes+"_stat.txt"
path_to_save_plots = "data/"+folder+"/"
# print(stat_file)
# print(path_to_save_plots)

# read last line and extract beta

text_file = open(stat_file, "r")
#read whole file to a string
lines = text_file.read()
lines = lines.split("\n")
line_index = -1
while(len(lines[line_index]) == 0):
    line_index = line_index - 1


# print(lines[line_index].split())
beta = float(lines[line_index].split()[-4])
# print(beta)
# quit()

print("Reading graph from input file")

node_edge, row_ptr, col_off, values, b = read_graph(input_file)
dimension = len(row_ptr)-1
sink_index = [i for i in range(0, len(b)) if b[i] < 0]
assert(len(sink_index)==1) #to make sure only one element is negative 
sink_index = sink_index[0]


Admat_frm_CSR(row_ptr, col_off, values)
b= np.array(b)
print("creating Admat_frm_CSR")
a = scipy.sparse.csr_matrix(Admat_frm_CSR(row_ptr, col_off, values))

# convert RHS from b to \betaJ
# beta = 0.25
b_sink = b[-1]

b_new = (b*beta)/(-b_sink)
b_new[-1] # should be -beta
# Error calculation of Lsolve
x_lsolve = np.loadtxt(result_file,  max_rows=node_edge[0], skiprows=0, dtype='double')
# print(x_lsolve)
# x_lsolve = x_lsolve/100
#residual of Lsolve

residual_lsolve =  b_new - a * x_lsolve
residual_lsolve = residual_lsolve[:-1]

#call scatter plot here:residual_lsolve
make_scatter_plot(residual_lsolve, "Residual_Lsolve_"+nodes, path_to_save_plots, "Node", "Residual", "red" )


# plt.scatter(list(range(0, len(list(residual_lsolve)))), list(residual_lsolve), c = "red")
#  # To show the plot
# plt.xlabel("node")
# plt.ylabel("residual")
# plt.title("Residual in Lsolve")
print("\n")
print("Details: Lsolve ")
print("--------------------")

print("The residual norm is {}".format(np.linalg.norm(residual_lsolve)))  # compute norm of residual vector
print("The relative residual norm is {}".format(np.linalg.norm(residual_lsolve)/np.linalg.norm(b_new)))  # compute norm of residual vector

print("startng Pyamg")
# PYAMG
t_ = time.time()

# ------------------------------------------------------------------
# Step 2: setup up the system using pyamg.gallery
# ------------------------------------------------------------------
n = dimension
X, Y = np.meshgrid(np.linspace(0, 1, n), np.linspace(0, 1, n))
stencil = pyamg.gallery.diffusion_stencil_2d(type='FE', epsilon=0.001, theta=np.pi / 3)

a = scipy.sparse.csr_matrix(Admat_frm_CSR(row_ptr, col_off, values))
# b = np.array(b)

res1 = []
ml = pyamg.smoothed_aggregation_solver(a)
x = ml.solve(b_new, tol=100, residuals=res1)  # solve Ax=b to a tolerance of 1e-2
#Your code here
print('Time in Pyamg function', time.time() - t_)
x_sink_0 = x - x[sink_index]


# make_two_scatter_plot: x_sink_0 x_lsolve
make_two_scatter_plot(x_lsolve, x_sink_0, "solution(x)_"+nodes, path_to_save_plots, "Nodes", "x", "red" )

# plt.scatter(list(range(0, len(list(x_sink_0)))), list(x_sink_0), c = "blue", label="pyamg")
# plt.scatter(list(range(0, len(list(x_lsolve)))), list(x_lsolve), c = "red", label = "Lsolve")
# # To show the plot
# plt.legend()
# plt.xlabel("x")
# plt.ylabel("node")
# plt.title("x in Lx=b")


#residual Pyamg
residual = b_new - a * x_sink_0
# residual = residual[:-1]


#call scatter plot here:residual_lsolve
make_scatter_plot(residual, "Residual_Pyamg_"+nodes, path_to_save_plots, "Node", "Residual", "blue" )


# plt.scatter(list(range(0, len(list(residual)))), list(residual), c = "blue")
# # To show the plot
# plt.xlabel("node")
# plt.ylabel("residual")
# plt.title("Residual in pyamg")
print("\n")
print("Details: Default AMG")
print("--------------------")
print(ml)                                 



# print hierarchy information

print("The residual norm is {}".format(np.linalg.norm(residual)))  # compute norm of residual vector

print("The relative residual norm is {}".format(np.linalg.norm(residual)/np.linalg.norm(b_new)))  # compute norm of residual vector
print("\n")
print("The Multigrid Hierarchy")
print("-----------------------")
for l in range(len(ml.levels)):
    An = ml.levels[l].A.shape[0]
    Am = ml.levels[l].A.shape[1]
    if l == (len(ml.levels)-1):
        print(f"A_{l}: {An:>10}x{Am:<10}")
    else:
        Pn = ml.levels[l].P.shape[0]
        Pm = ml.levels[l].P.shape[1]
        print(f"A_{l}: {An:>10}x{Am:<10}   P_{l}: {Pn:>10}x{Pm:<10}")


