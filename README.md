# cuda solver
## Implementation of Parallel Laplacian Solver from the paper
[*A stochastic process on a network with connections to Laplacian systems of equations*](https://www.cambridge.org/core/journals/advances-in-applied-probability/article/abs/stochastic-process-on-a-network-with-connections-to-laplacian-systems-of-equations/BFC44A295068B74529DBCF81CDEEDB55)
## **How to run the project**
### Generate graph
```bash
cd input
# change run.sh -add arguments in this later  
bash run.sh
# chk for b values
```
### Run code and put the output in exec folder (compilation is not needed each time)
```bash
./main > exec_stat\topology_nodes_sources.txt
```

### Append the generated input for future references
```bash
cat generated_input.txt >> exec_stats/cycle_32_errorByBeta.txt
```
### Plot graphs
```bash
python3 util/visualize.py -f exec_stats/random32_0.1.txt
```


