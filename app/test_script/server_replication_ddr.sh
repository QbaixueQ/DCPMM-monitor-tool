#!/bin/bash

pkill -9 redis-server
pkill -9 redis-benchmark
pkill -9 redis-benchmakr-seq

ssh ${slave_ip} pkill -9 redis-server
ssh ${slave_ip} pkill -9 redis-benchmark
ssh ${slave_ip} pkill -9 redis-benchmakr-seq

#--------------------------------------------------------------------------------------
export REDIS_PATH=$1
export REDIS_NUM=$2
export BIND_SOCKET=$3
export DIR_PATH=$4
export test_model=$5

export rdb=$6
export aof=$7
export aof_type=$8

export max_memory=${9}G
export repliction_server_type=${10}

export master_ip=${11}
export slave_ip=${12}
export SLAVE_REDIS_PATH=${13}
export SLAVE_DIR_PATH=${14}

#clean----------------------------------------------------------------------------------
mkdir -p ${SLAVE_DIR_PATH}

rm -rf  ${DIR_PATH}/*.rdb
rm -rf  ${DIR_PATH}/*.aof
rm -rf  ${DIR_PATH}/*.ag

ssh ${slave_ip} mkdir -p ${SLAVE_DIR_PATH}
ssh ${slave_ip} rm -rf   ${SLAVE_DIR_PATH}/*.rdb
ssh ${slave_ip} rm -rf   ${SLAVE_DIR_PATH}/*.aof
ssh ${slave_ip} rm -rf   ${SLAVE_DIR_PATH}/*.ag

#check cpu configuration---------------------------------------------------------------
THREADS=`lscpu |grep "Thread(s) per core:"|awk -F ":" '{print $2'}|tr -d '[:space:]'`
CORES=`lscpu |grep "Core(s) per socket:"|awk -F ":" '{print $2'}|tr -d '[:space:]'`
if [ "$THREADS" == "1" ]; then
  echo "hyperthread is disabled, please enable it before doing the test."
  exit 1
fi

echo ${BIND_SOCKET}

LOCAL_THREAD=`lscpu |grep "NUMA node${BIND_SOCKET} CPU(s):"| awk '{print $(NF)}'|awk -F ',' '{print $1}'|awk -F '-' '{print $1}'`



if  [ $REDIS_NUM -gt $CORES ]; then
    echo "You're running too many Redis servers! Each Redis server need 2 CPU threads."
    exit 1
fi
REMOTE_THREAD=$(($LOCAL_THREAD + $CORES*2))

#--------------------------start master servers--------------------------------------------------------------------

for (( instances=1; instances <= $REDIS_NUM; instances++ ))
do
    port=$((9000 + ${instances}))
    core_config=$((${LOCAL_THREAD}+${instances}-1)),$((${REMOTE_THREAD} + ${instances}-1))

    echo -e "\e[33mstarting redis master server $instances\e[0m"

    echo -e "\e[33mnumactl -m ${BIND_SOCKET} taskset -c $core_config $REDIS_PATH/redis-server --port ${port} --maxmemory ${max_memory} --maxmemory-policy allkeys-lru --protected-mode no --dir ${DIR_PATH} --dbfilename ${port}.rdb --bind ${master_ip}  >/dev/null 2>&1 &\e[0m"

    numactl -m ${BIND_SOCKET} taskset -c $core_config $REDIS_PATH/redis-server --port ${port} --maxmemory ${max_memory} --maxmemory-policy allkeys-lru --protected-mode no --dir ${DIR_PATH} --dbfilename ${port}.rdb --bind ${master_ip} >/dev/null 2>&1 &

done
#-----------------------------------------------------------------------------------------------------------------
sleep 15
#--------------------------start slave servers---------------------------------------------------------------------

for (( instances=1; instances <= $REDIS_NUM; instances++ ))
do
    port=$((9000 + ${instances}))
    core_config=$((${LOCAL_THREAD}+${instances}-1)),$((${REMOTE_THREAD} + ${instances}-1))

    echo -e "\e[33mstarting redis slave server $instances\e[0m"

    echo -e "\e[33mssh ${slave_ip} numactl -m ${BIND_SOCKET} taskset -c $core_config $SLAVE_REDIS_PATH/redis-server --port ${port} --maxmemory ${max_memory} --maxmemory-policy allkeys-lru --protected-mode no --dir ${SLAVE_DIR_PATH} --dbfilename ${port}.rdb --bind ${slave_ip} --slaveof ${master_ip} ${port}  >/dev/null 2>&1 &\e[0m"
    
    ssh ${slave_ip} numactl -m ${BIND_SOCKET} taskset -c $core_config $SLAVE_REDIS_PATH/redis-server --port ${port} --maxmemory ${max_memory} --maxmemory-policy allkeys-lru --protected-mode no --dir ${SLAVE_DIR_PATH} --dbfilename ${port}.rdb --bind ${master_ip} --bind ${slave_ip} --slaveof ${master_ip} ${port} >/dev/null 2>&1 &

done


