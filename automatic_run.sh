# Usage: bash automatic_run.sh type size1 size2 ...
# $1 is type rest is sizes

for size in $*
do
  if [[ $size == $1 ]]
	then
		# echo "Number skipp!" $size $1
		continue
	fi
    rm generated_input.txt
    cd input
    bash run.sh $1 $size
    cd ..
    bash run.sh $1$size
done