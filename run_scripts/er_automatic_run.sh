for prob_of_edge in 01 05 10 15 20 25 30 35 40 45 50 55 60 65 70 75 
do
    echo ${prob_of_edge}
    for size in 16000
    do 
        echo ${size}
        rm stat
        ./main data/${prob_of_edge}/ER_0.${prob_of_edge}_${size}.txt data/${prob_of_edge}/ER_0.${prob_of_edge}_${size}.out > stat
        cat stat >> data/${prob_of_edge}/ER_0.${prob_of_edge}_${size}.out
    done 
done
