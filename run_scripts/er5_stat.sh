for size in 16000  #14016 12000 10016 8000 6016 4000 2016
do
    
    for prob_of_edge in 45 50 55 60 65 70 75 #05 10 15 20 25 30 35 40 45 50 55 60 65 70 75 
    do 
    echo ${prob_of_edge}
    echo ${size}
    ./main data/${prob_of_edge}/ER_0.${prob_of_edge}_${size}.txt data/${prob_of_edge}/ER_0.${prob_of_edge}_${size}.out > data/${prob_of_edge}/ER_0.${prob_of_edge}_${size}_stat.txt
    
    python3 util/ER_run_stat.py -n $size -f $prob_of_edge > temp_stat

    cat temp_stat >> data/${prob_of_edge}/ER_0.${prob_of_edge}_${size}_stat.txt
    rm temp_stat
    done 
done

