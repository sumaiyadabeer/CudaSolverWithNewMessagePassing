#usage :  bash run.sh outputfilename
# cd input
# bash run.sh cycle 8
# cd ..
# cd ..
timestamp=$(date +%T)
# $1+=$timestamp
filename="${1}_${timestamp}"
# echo $tyme
rm main
make
# python3 util/solve.py generated_input.txt
# ./main 2>&1 | tee $1  #tee is used to print the command in console
# echo -n "x_solve.py: " >> $1
# cat generated_answer.txt >> $1
# echo "" >> $1
nsys profile -o $filename$size --force-overwrite true main 2>&1 | tee $filename
mv $filename$size.qdrep  exec_stats/profiler/
echo exec_stats/profiler/$filename$size.qdrep >> .gitignore 

cat generated_input.txt >> $filename   
mv $filename exec_stats/
# rm generated_answer.txt   
python3 util/visualize.py -f exec_stats/$filename
echo exec_stats/$filename >> .gitignore 

