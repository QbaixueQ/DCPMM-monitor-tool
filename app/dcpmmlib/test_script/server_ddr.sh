#!/bin/bash

pkill -9 redis-server
pkill -9 redis-benchmark
pkill -9 redis-benchmakr-seq
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

#clean----------------------------------------------------------------------------------
mkdir -p ${DIR_PATH}

rm -rf  ${DIR_PATH}/*.rdb
rm -rf  ${DIR_PATH}/*.aof
rm -rf  ${DIR_PATH}/*.ag

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

#--------------------------start servers------------------------------------------------------
for (( instances=1; instances <= $REDIS_NUM; instances++ ))
do
    port=$((9000 + ${instances}))
    core_config=$((${LOCAL_THREAD}+${instances}-1)),$((${REMOTE_THREAD} + ${instances}-1))

    echo -e "\e[33mstarting redis server $instances\e[0m"

    
    #disable rdb & disable aof
    if [ "$rdb"x = "disable"x ] && [ "$aof"x = "disable"x ]; then
    echo -e "\e[33mnumactl -m ${BIND_SOCKET} taskset -c $core_config $REDIS_PATH/redis-server --port ${port} --maxmemory ${max_memory} --maxmemory-policy allkeys-lru --save "" --appendonly no  >/dev/null 2>&1  &\e[0m"
    numactl -m ${BIND_SOCKET} taskset -c $core_config $REDIS_PATH/redis-server --port ${port} --maxmemory ${max_memory} --maxmemory-policy allkeys-lru --save "" --appendonly no  >/dev/null 2>&1  &
    fi

    #enable rdb & disable aof
    if [ "$rdb"x = "enable"x ] && [ "$aof"x = "disable"x ]; then
    echo -e "\e[33mnumactl -m ${BIND_SOCKET} taskset -c $core_config $REDIS_PATH/redis-server --port ${port} --maxmemory ${max_memory} --maxmemory-policy allkeys-lru --dir ${DIR_PATH} --dbfilename ${port}.rdb --save 60 10000 >/dev/null 2>&1 &\e[0m"
    numactl -m ${BIND_SOCKET} taskset -c $core_config $REDIS_PATH/redis-server --port ${port} --maxmemory ${max_memory} --maxmemory-policy allkeys-lru --dir ${DIR_PATH} --dbfilename ${port}.rdb --save 60 10000 >/dev/null 2>&1 &
    fi

    #disable rdb & enable aof & appendfsync everysec
    if [ "$rdb"x = "disable"x ] && [ "$aof"x = "enable"x ] && [ "$aof_type"x = "everysec"x ]; then
    echo -e "\e[33mnumactl -m ${BIND_SOCKET} taskset -c $core_config $REDIS_PATH/redis-server --port ${port} --maxmemory ${max_memory} --maxmemory-policy allkeys-lru --dir ${DIR_PATH} --save '' --appendonly yes --appendfsync everysec --appendfilename ${port}.aof  >/dev/null 2>&1 &\e[0m"
    numactl -m ${BIND_SOCKET} taskset -c $core_config $REDIS_PATH/redis-server --port ${port} --maxmemory ${max_memory} --maxmemory-policy allkeys-lru --dir ${DIR_PATH} --save '' --appendonly yes --appendfsync everysec --appendfilename ${port}.aof >/dev/null 2>&1 &
    fi

   #disable rdb & enable aof & appendfsync always
   if [ "$rdb"x = "disable"x ] &&  [ "$aof"x = "enable"x ]  && [ "$aof_type"x = "always"x ]; then
   echo -e "\e[33mnumactl -m ${BIND_SOCKET} taskset -c $core_config $REDIS_PATH/redis-server --port ${port} --maxmemory ${max_memory} --maxmemory-policy allkeys-lru --dir ${DIR_PATH} --save '' --appendonly yes --appendfsync always --appendfilename ${port}.aof  >/dev/null 2>&1 &\e[0m"
   numactl -m ${BIND_SOCKET} taskset -c $core_config $REDIS_PATH/redis-server --port ${port} --maxmemory ${max_memory} --maxmemory-policy allkeys-lru --dir ${DIR_PATH} --save '' --appendonly yes --appendfsync always --appendfilename ${port}.aof  >/dev/null 2>&1 &
   fi

done
