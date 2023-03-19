from copy import error
import matplotlib
matplotlib.use('Agg') # set the backend before importing pyplot
import matplotlib.pyplot as plt # etc. etc.

#IN DRW compute1: 
"""line 2: packet comm
line 3: heading of eta 
line 4-n+3: eta info 
line n+4: eta_del_norm and eps Condition
line n+5: error"""

import argparse

# Initialize parser
parser = argparse.ArgumentParser()
 
# Adding optional argument
parser.add_argument("-f", "--input_file", help = "Name of input file")
 
# Read arguments from command line
args = parser.parse_args()

def find_line(lines, search_string, reverse):
    #this function takes lines and return the line number where search string is found 
    lines=lines.split("\n")
    num_of_lines = len(lines) 

    if reverse == False:
        my_range = range(0, num_of_lines)
    else:
        my_range = range(num_of_lines-1, -1, -1)
    # print(my_range)
    for i in my_range:
        # print(lines[i].strip(), search_string.strip())
        if(lines[i].strip() == search_string.strip()):
            # print("line is found at ", i)
            return i
            



def sample_multiple_lines(lines, start_string, end_string, result_list):
    #this function take takes a strat string and end string and gives list of float between them

    start_index = find_line(lines, start_string, True)+1
    # print(find_line(lines, start_string, True))
    # return
    end_index = find_line(lines, end_string, True)

    lines = lines.split("\n")

    for i in range(start_index, end_index):
        result_list.append(float(lines[i].strip().split()[-1]))



def sample_last_line_for_b(lines, result_list):
    # print(lines)
    lines = lines.split("\n")

    line = lines[-1] #-2 if last line is empty 
    # print(list(line))
    if len(line) < 2:
        line = lines[-2]
    for i in line.split():
        result_list.append(int(i))



def make_scatter_plot(input_list, filename, path_to_save, x_title, y_title, color ):
    plt.scatter(list(range(0, len(input_list))), input_list, c = color)
 
    # To show the plot
    plt.xlabel(x_title)
    plt.ylabel(y_title)
    plt.title(filename+"_"+x_title+"_"+y_title)
    plt.savefig(path_to_save+filename+"_"+x_title+"_"+y_title+".png")
    plt.close() 


def sample_error(lines, search_string, result_list):
    lines=lines.split("\n")
    num_of_lines = len(lines) 
 
    for i in range(0, num_of_lines):
        if(lines[i][0:len(search_string)] == search_string):
            # print("line is found at ", i, lines[i][len(search_string):] )
            result_list.append(float(lines[i][len(search_string):]))    

def sample_beta_iter(lines, search_string, iter, beta):
    lines=lines.split("\n")
    num_of_lines = len(lines) 
 
    for i in range(0, num_of_lines):
        if(lines[i][0:len(search_string)] == search_string):
            values = lines[i][len(search_string):].split()
            iter.append(int(values[0]))
            beta.append(float(values[-1]))
            # print("line is found at ", i, values[0], values[-1] )
            # result_list.append(float(lines[i][len(search_string):]))    


def make_multiple_line_plot(beta, iter, error, filename, path_to_save, x_title, y_title, plot_title):
    length =  len(beta)
    assert len(iter) == length
    # assert len(error) == length
    x_values = []
    y_values = []
    indices = []
    beta_values = sorted(list(set(beta)), reverse= True)
    print(beta_values)
    # print(beta_values)
    indices.insert(0,0)
    for i in range(1, len(iter)):
        # print(iter[i])
        if iter[i] == 0:
            indices.append(i-1)
            # print(iter[i], iter[i-1], i)
    # print(indices)
    # if (indices[0]!= 0):
        

    indices.append(len(iter)+1)

#plot for scatter
    for i in range(len(error)-1):
        plt.scatter(beta_values[i], error[i],label = str(beta_values[i]) )
    
#plot for line    
    # for i in range(len(indices)-1):
    #     plt.plot(iter[indices[i]+1:indices[i+1]-1], error[indices[i]+1:indices[i+1]-1],label = str(beta_values[i]) )
    

    plt.xlabel(x_title)
    plt.ylabel(y_title)
    plt.legend()
    plt.title(plot_title, fontsize = 5)
    # plt.savefig(path_to_save+filename+"_"+x_title+"_"+y_title+".eps",format='eps')
    plt.savefig(path_to_save+filename+"_"+x_title+"_"+y_title+".png", dpi=400)
    plt.close() 




def sample_etamax_time(lines):
    lines=lines.split("\n")
    num_of_lines = len(lines)
    eta = []
    tym = []
 
    for i in range(0, num_of_lines):
        if(lines[i][0:len("epoch: ")] == "epoch: "):
            values = lines[i][len("epoch: "):].split()
            eta.append(float(values[2]))
            tym.append(float(values[-2]))
            # print("line is found at ", i, values[2], values[-2] )
            # result_list.append(float(lines[i][len(search_string):]))    
    eta.append(eta[-1])
    time = sum(tym)
    tym.append(time)
    return str(list(zip(eta,tym)))







#open text file in read mode
text_file = open(args.input_file, "r")
 
#read whole file to a string
lines = text_file.read()

eta = []
x = []
# sample_multiple_lines(lines, start_string, end_string, result_list)
sample_multiple_lines(lines, "printing x", "printing x ends", x)
sample_multiple_lines(lines, "printing eta", "printing eta ends", eta)
# print(eta)

Lx_b = []
sample_multiple_lines(lines, "printing Lx-b", "printing Lx-b ends", Lx_b)
# print(Lx_b)

b = []
sample_last_line_for_b(lines, b)
# print(b)

make_scatter_plot(b, args.input_file.split("/")[-1].split(".")[0], "exec_stats/plots/" , "Node", "b", "cyan")
make_scatter_plot(Lx_b, args.input_file.split("/")[-1].split(".")[0], "exec_stats/plots/" , "Node", "Lx-b", "red")
make_scatter_plot(x, args.input_file.split("/")[-1].split(".")[0], "exec_stats/plots/" , "Node", "x", "blue")
make_scatter_plot(eta, args.input_file.split("/")[-1].split(".")[0], "exec_stats/plots/" , "Node", "eta", "blue")



#make plot for error
error = []
beta = []
iter = []
sample_error(lines, "Error is", error)
sample_beta_iter(lines, "In DRW compute iter: ", iter, beta)
# print(sample_etamax_time(lines))
make_multiple_line_plot(beta, iter, error, args.input_file.split("/")[-1].split(".")[0], "exec_stats/plots/" , "Iter", "Error", sample_etamax_time(lines))
print(sample_etamax_time(lines))
# print(iter, beta, error)