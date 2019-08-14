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

export Workloads=(set)

declare -A Empty_Workloads
#Empty_Workloads=([get]="set" [lpop]="lpush" [hdel]="hset" [spop]="sadd" [zrem]="zadd")
Empty_Workloads=([get]="set")

mkdir -p $RESULT_PATH
mkdir -p $RESULT_PATH/log
rm -f $RESULT_PATH/log/*.csv -f > /dev/null   ##delete log/*.csv
mkdir -p $RESULT_PATH/report_collect 


#-----------------collect data--------------------------------------------------------------

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
    while [ $(ps -ef | grep -c redis-benchmark) -gt 23 ];do
        var=`numactl -H | grep "node 0 free" |awk -F ":" '{print $2'}|tr -d '[:space:]'`
        memory_used=${var%MB*}
        let memory_used=${memory_used}/1024
        echo $memory_used
        if (( $memory_used < 5)); then
          echo $memory_used
          echo "exit benchmark"
          break 3
        fi
        echo -e "\e[36mWaiting $(($(ps -ef | grep -c redis-benchmark)-1)) benchmark finish... \e[0m"
        sleep 5
    done
done

   

















