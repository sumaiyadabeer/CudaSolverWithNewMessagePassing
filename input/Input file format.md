# Input file format
## _Input generation and conversion in DRW-Lsolve_



This part is developed using python but in future cpp could be used for better speed. Files used are listed below.

- generate_graph.py
- convert_csr.py
- gen_b.py
## Features

- #### generate_graph.py: 
   - **Arguments:** 
_Output Filename_ "-f",
_Total Nodes_ "-n", 
_Type of graph {star, line, mesh, complete }_"-t", 
- #### convert_csr.py
  - **Arguments:** _Input Filename_ "-f", 
_Index start from 0/1_  "--index",
- #### gen_b.py :
  - **Arguments:**  'size', 
-**Optional argumnets:** 
_Fraction of sources_ '--fsources' (default=0.1), 
_Output File name_ '--output',(default='b$size.inp')





## Usage

usage of these script is given in following example
```sh
python3 generate_graph.py -n 10 -t line -f line.txt
```
output file (line.txt) will be like this
| 10 |9 | Number of **Nodes** annd **Edges**|
| ------ | ------ | ------ |
| 1	| 2 | Edge list
| 2	| 3
| 3	| 4
| 4	| 5
| 5	| 6
| 6	| 7
| 7	| 8
| 8	| 9
| 9	| 10


```sh
python3 convert_csr.py -f line.txt -i 1
```
output file (line_converted.txt) will be like this
| 10 9 | Number of **Nodes** annd **Edges**|
| ------ | ------ |
| 0	1	3	5	7	9	11	13	15	17	18	| Row Pointer
|1	0	2	1	3	2	4	3	5	4	6	5	7	6	8	7	9	8	| Column offset

```sh
 python3 genb.py 10 --fsources 0.9
```
output file (b_10.inp) will be like this


|1 1 1 1 1 1 1 -9 1 1 |
| ----|
 
 At last we concatenate the file using bash command _cat_

```sh
cat line_converted.txt b10.inp > input.txt
```
Finally the input file will look like this:
|10	9| Number of **Nodes** annd **Edges** |
| --- | -----|
|0	1	3	5	7	9	11	13	15	17	18	|Row Pointer|
|1	0	2	1	3	2	4	3	5	4	6	5	7	6	8	7	9	8| Column Offset|	
|1 1 1 1 1 1 1 -9 1 1 | b Values

> Note: `--Alert` this file will be updtaed from time to time
  