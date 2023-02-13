#usage :  bash run.sh outputfilename
# cd input
# bash run.sh cycle 8
# cd ..
rm main
make
# python3 util/solve.py generated_input.txt
./main 2>&1 | tee $1  #tee is used to print the command in console
# echo -n "x_solve.py: " >> $1
# cat generated_answer.txt >> $1
# echo "" >> $1
cat generated_input.txt >> $1   
mv $1 exec_stats/
# rm generated_answer.txt   
python3 util/visualize.py -f exec_stats/$1
echo exec_stats/$1 >> .gitignore 

