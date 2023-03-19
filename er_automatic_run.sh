for prob_of_edge in 21 11 
do
    echo ${prob_of_edge}
    for size in 2016 4000 6016 8000 10016 12000 14016 16000
    do 
        echo ${size}
        rm stat
        ./main data/${prob_of_edge}/ER_0.${prob_of_edge}_${size}.txt data/${prob_of_edge}/ER_0.${prob_of_edge}_${size}.out > stat
        cat stat >> data/${prob_of_edge}/ER_0.${prob_of_edge}_${size}.out
    done 
done
