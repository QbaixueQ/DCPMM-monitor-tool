#!/bin/bash

export REDIS_PATH=$1
export REDIS_NUM=$2
export DATA_SIZE=$3        #-d
export TEST_TITLE=$4
export RESULT_PATH=$5
export BIND_SOCKET=$6
export DIR_PATH=$7
export TEST_MODEL=$8
export host=$9
export KEY_RANGE=${10}  #-r
export REQ_NUM=${11}     #-n

export Workloads=(set get)

declare -A Empty_Workloads
#Empty_Workloads=([get]="set" [lpop]="lpush" [hdel]="hset" [spop]="sadd" [zrem]="zadd")
Empty_Workloads=([get]="set")

mkdir -p $RESULT_PATH
mkdir -p $RESULT_PATH/log
rm -f $RESULT_PATH/log/*.csv -f > /dev/null   ##delete log/*.csv
mkdir -p $RESULT_PATH/report_collect 


#-----------------collect data--------------------------------------------------------------
Collect_Date()  ###generate ${workload}.csv in ${REDIS_PATH}/log/
{
    ##ex. cd /root/redis-4.0.0-volatile/log/set
    cd $RESULT_PATH/log/$1 >/dev/null
    #export max_latency_0=0
    export sum_latency_99=0
    export avg_latency_99=0
    export instance_number=$2
    export sum_tps=0

    export sum_nvm=0
    export sum_memory=0

    echo "$1,,,," >> ../$1.csv
    echo "latency_0,tps,used_memory,used_nvm," >> ../$1.csv
    for i in `seq 1 $2`
    do
        latency_0=`cat $2_${i}.log|grep -x '99.*'|head -n 1|awk '{print $3}'`
        tps=`cat $2_${i}.log|grep 'requests per second'|awk '{print $1}'`
        latency_99=`awk 'BEGIN{printf "%.2f\n",'$latency_0'/'100'}'`

        used_nvm=`cat $2_${i}.nvm|grep  'used_nvm'|awk -F ":" '{print $2'}|tr -d '[:space:]'`
        used_memory=`cat $2_${i}.memory|grep  'used_memory'|awk -F ":" '{print $2'}|tr -d '[:space:]'`
        #used_nvm=`echo "sclare=2;${used_nvm}/1024/1024/1024" | bc` 
        #used_memory=`echo "sclare=2;${used_memory}/1024/1024/1024" | bc`

        #echo $used_nvm

        if [ "$latency_0" == "" ]||[ "$tps" == "" ];then echo -e "\e[31m$1 $2_${i} is empty\e[0m";exit 1;fi
        echo "$latency_99,$tps,$used_memory,$used_nvm" >> ../$1.csv
        #[ `awk -v v1=$latency_99 -v v2=$max_latency_0 'BEGIN{print(v1>v2)?"0":"1"}'` == "0" ] && export max_latency_0=$latency_99
        sum_latency_99=`awk -v v1=$sum_latency_99 -v v2=$latency_99 'BEGIN {printf "%0.2f",(v1+v2)}'`
        sum_tps=`awk -v v1=$sum_tps -v v2=$tps 'BEGIN {printf "%0.2f",(v1+v2)}'`

        sum_nvm=`awk -v v1=$sum_nvm -v v2=$used_nvm 'BEGIN {printf "%d",(v1+v2)}'`
        sum_memory=`awk -v v1=$sum_memory -v v2=$used_memory 'BEGIN {printf "%d",(v1+v2)}'`

    done
    avg_latency_99=`awk 'BEGIN{printf "%.2f\n",'$sum_latency_99'/'$instance_number'}'`
    #echo "$max_latency_0,$sum_tps,,," >> ../$1.csv
    echo "avg_latency_99,sum_tps,sum_memory,sum_nvm," >> ../$1.csv
    echo "$avg_latency_99,$sum_tps,$sum_memory,$sum_nvm," >> ../$1.csv
    sleep 3
    cd - >/dev/null
}

#---------------------------check cpu configuration------------------------------------------
THREADS=`lscpu |grep "Thread(s) per core:"|awk -F ":" '{print $2'}|tr -d '[:space:]'`
CORES=`lscpu |grep "Core(s) per socket:"|awk -F ":" '{print $2'}|tr -d '[:space:]'`
if [ "$THREADS" == "1" ]; then
  echo "hyperthread is disabled, please enable it before doing the test."
  exit 1
fi

LOCAL_THREAD=`lscpu |grep "NUMA node${BIND_SOCKET} CPU(s):"| awk '{print $(NF)}'|awk -F ',' '{print $1}'|awk -F '-' '{print $1}'`
if  [ $REDIS_NUM -gt $CORES ]; then
    echo "You're running too many Redis servers! Each Redis server need 2 CPU threads."
    exit 1
fi
REMOTE_THREAD=$(($LOCAL_THREAD + $CORES*2))

#wating benchmark finish------------------------------------------------------
    while [ $(ps -ef | grep -c redis-benchmark) -gt 1 ];do
        echo -e "\e[36mWaiting $(($(ps -ef | grep -c redis-benchmark)-1)) benchmark finish... \e[0m"
        sleep 5
    done

#--------------------------start servers------------------------------------------------------
#for workload in lpush #zadd set
for workload in `echo ${Workloads[*]}`
do
    mkdir -p $RESULT_PATH/log/${workload}

    #--------------------------- flushall -----------------------------------------------------------
    for (( instances=1; instances <= $REDIS_NUM; instances++ ))
    do
        port=$((9000 + ${instances}))
        core_config=$((${LOCAL_THREAD}+${instances}-1)),$((${REMOTE_THREAD} + ${instances}-1))
        echo -e  "\e[34mnumactl -m ${BIND_SOCKET} taskset -c $core_config ${REDIS_PATH}/redis-cli -h $host -p ${port} flushall &\e[0m"
        numactl -m ${BIND_SOCKET} taskset -c $core_config ${REDIS_PATH}/redis-cli -h $host -p ${port} flushall >/dev/null  &
    done    

    #--------------------------For get operation, fill the dataset firstly------------------------------
    if [ "${workload}"x = "get"x ]; then
      fill_command="set"
      for (( instances=1; instances <= $REDIS_NUM; instances++ ))
      do
          port=$((9000 + ${instances}))
          core_config=$((${LOCAL_THREAD}+${instances}-1)),$((${REMOTE_THREAD} + ${instances}-1))
          echo -e  "\e[37;35m$workload starting redis client $instances\e[0m"
          echo -e "\e[35m[$workload]=>numactl -m ${BIND_SOCKET} taskset -c $core_config ${REDIS_PATH}/redis-benchmark -h $host   -p ${port} -r ${KEY_RANGE} -n ${KEY_RANGE} -d $DATA_SIZE -t ${fill_command} $Field_Range  &\e[0m"
          numactl -m ${BIND_SOCKET} taskset -c $core_config ${REDIS_PATH}/redis-benchmark -h $host -p ${port} -r ${KEY_RANGE} -n ${REQ_NUM} -d $DATA_SIZE -t ${workload} ${Field_Range} >/dev/null  &
      done
    fi

    #--------------------------Waiting benchmark finish------------------------------------------------------
    while [ $(ps -ef | grep -c redis-benchmark) -gt 1 ];do
        echo -e "\e[36mWaiting $(($(ps -ef | grep -c redis-benchmark)-1)) benchmark finish... \e[0m"
        sleep 5
    done
    
    #--------------------------start testing------------------------------------------------------
    for (( instances=1; instances <= $REDIS_NUM; instances++ ))
    do
        port=$((9000 + ${instances}))
        core_config=$((${LOCAL_THREAD}+${instances}-1)),$((${REMOTE_THREAD} + ${instances}-1))
        echo -e  "\e[37;35m$workload starting redis client $instances\e[0m"
        echo -e "\e[35m[$workload]=>numactl -m ${BIND_SOCKET} taskset -c $core_config ${REDIS_PATH}/redis-benchmark -h $host  -p ${port} -r ${KEY_RANGE} -n ${REQ_NUM} -d $DATA_SIZE -t ${workload} $Field_Range > ./result/log/${workload}/${REDIS_NUM}_$instances.log  &\e[0m"
        numactl -m ${BIND_SOCKET} taskset -c $core_config ${REDIS_PATH}/redis-benchmark -h $host -p ${port} -r ${KEY_RANGE} -n ${REQ_NUM} -d $DATA_SIZE -t ${workload} ${Field_Range} > ./result/log/${workload}/${REDIS_NUM}_$instances.log  &
    done
    #--------------------------Waiting benchmark finish------------------------------------------------------
    while [ $(ps -ef | grep -c redis-benchmark) -gt 1 ];do
        echo -e "\e[36mWaiting $(($(ps -ef | grep -c redis-benchmark)-1)) benchmark finish... \e[0m"
        sleep 5
    done
    
    
    #--------------------------Collect the result------------------------------------------------------  
    #Collect_Date $workload $REDIS_NUM


   #--------------------------------------------------------------------------------------------
   for (( instances=1; instances <= $REDIS_NUM; instances++ ))
   do
       port=$((9000 + ${instances}))
       ${REDIS_PATH}/redis-cli -h $host -p $port info memory|grep used_nvm: > ${RESULT_PATH}/log/${workload}/${REDIS_NUM}_${instances}.nvm
       ${REDIS_PATH}/redis-cli -h $host -p $port info memory|grep used_memory: > ${RESULT_PATH}/log/${workload}/${REDIS_NUM}_${instances}.memory
   done

    #--------------------------Collect the result------------------------------------------------------
    Collect_Date $workload $REDIS_NUM



   #generate redis.csv and clean some temp file
   mkdir -p $RESULT_PATH/report/${TEST_TITLE}
   mkdir -p $RESULT_PATH/report/${TEST_TITLE}/$workload
   cd $RESULT_PATH/log >/dev/null
   paste *.csv > redis.csv
   ls *.csv|grep -v redis|xargs rm -f > /dev/null
   cd - >/dev/null

   cp $RESULT_PATH/log/redis.csv $RESULT_PATH/report/${TEST_TITLE}/${workload}/${workload}_${TEST_TITLE}_${REDIS_NUM}_${DATA_SIZE}.csv -rf
   cp $RESULT_PATH/report/${TEST_TITLE}/${workload}/${workload}_${TEST_TITLE}_${REDIS_NUM}_${DATA_SIZE}.csv $RESULT_PATH/report_collect/

   mkdir -p $RESULT_PATH/report/${TEST_TITLE}/${workload}/log_${workload}_${REDIS_NUM}_${DATA_SIZE}
   cp $RESULT_PATH/log/${workload}  $RESULT_PATH/report/${TEST_TITLE}/${workload}/log_${workload}_${REDIS_NUM}_${DATA_SIZE} -rf

done

pkill -9 redis









