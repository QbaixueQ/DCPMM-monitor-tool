
#./run_test.sh 1lm socket aof_always

#while [ "1" = "1" ]
#do
#  ./run_test.sh 1lm socket aof_always
#done

./run_test.sh 1lm socket rdb

while [ "1" = "1" ]
do
  ./run_test.sh 1lm socket rdb
done


