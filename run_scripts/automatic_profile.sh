# Usage: bash automatic_run.sh type size1 size2 ...
# $1 is type rest is sizes
cd ..
for size in $*
do
  if [[ $size == $1 ]]
	then
		# echo "Number skipp!" $size $1
		continue
	fi
    rm generated_input.txt
    cd input
    bash profile_run.sh $1 $size
    cd ..
    bash profile_run.sh $1$size
    
done