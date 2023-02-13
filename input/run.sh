#! /bin/bash
# usage : bash run.sh cycle 8
no_of_nodes=$2
type_of_graph=$1 # no space: otherwise it will treat this as an argument
type_of_expander=margulis #margulis chordal_cycle paley
start_index=1

frac_of_source_in_b=0.25
# let sink_index=$2/2   #$2-1 : end
source_index=0

# echo "sink at" $sink_index


if [ $type_of_graph == expander ]
then 
python3 expander_generation.py -n $no_of_nodes -t paley -f generated_graph_converted
else 
    if [ $type_of_graph == random ]
    then 
        # random graph Generation 
        # usage: generate_random_graph.py [-h] [--sparsity [{dense,sparse}]]  #no sparsity means dense graph
        #                             [--output OUTPUT]
        #                             size
        python3 generate_random_graph.py $no_of_nodes --output generated_graph 
        # the intent is to execute the command that follows the && only if the first command is successful. 
    else
        python3 generate_graph.py -n $no_of_nodes -t $type_of_graph -f generated_graph 
    fi 
    python3 convert_csr.py -f generated_graph -i $start_index 
fi
python3 genb.py $no_of_nodes --fsources $frac_of_source_in_b && #--sink_index $sink_index --source_index $source_index
cat generated_graph_converted b$no_of_nodes.inp > ../generated_input.txt
echo "see the input file: generated_input.txt for $type_of_graph Graph of $no_of_nodes nodes in parent folder"
rm generated_graph generated_graph_converted b$no_of_nodes.inp

