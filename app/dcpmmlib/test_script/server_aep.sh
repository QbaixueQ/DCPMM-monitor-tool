#!/bin/bash

pkill redis-server

export REDIS_PATH=$1
export REDIS_NUM=$2
export BIND_SOCKET=$3
export DIR_PATH=$4
export test_model=$5

export rdb=$6
export aof=$7
export aof_type=$8
export pba=$9
export max_memory=${10}G
export nvm_max_capacity=${11}G
export nvm_threshold=${12}

'''
export Zset_max_ziplist_entries=(512 2000 512)
# export Zset_max_ziplist_value=(64 2000 2000)
export Zset_max_ziplist_entries=512
export Zset_max_ziplist_value=64
while getopts e:v: OPT;do
    case $OPT in
        e)
            export Zset_max_ziplist_entries=$OPTARG
            ;;
        v)
            export Zset_max_ziplist_value=$OPTARG  # print_trashed_file is a function
            ;;
    esac
done
echo -e "\e[33mZset_max_ziplist_entries is $Zset_max_ziplist_entries\e[0m"
echo -e "\e[33mZset_max_ziplist_value is $Zset_max_ziplist_value\e[0m"
'''


if [ `ls /dev/pmem*|wc -l` -ne 2 ]; then
    echo "please check AD mode"
    exit 1
fi
if [ `mount|egrep "pmem0|pmem1"|wc -l` -ne 2 ]; then
    mount -o dax /dev/pmem0 /mnt/pmem0
    mount -o dax /dev/pmem1 /mnt/pmem1
fi


pkill -9 redis-server
pkill -9 redis-benchmark
pkill -9 redis-benchmakr-seq

mkdir -p ${DIR_PATH}

rm -rf  ${DIR_PATH}/*.rdb
rm -rf  ${DIR_PATH}/*.aof
rm -rf /mnt/pmem${BIND_SOCKET}/*AEP
rm -rf /mnt/pmem${BIND_SOCKET}/*.ag


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

#--------------------------start servers------------------------------------------------------
for (( instances=1; instances <= $REDIS_NUM; instances++ ))
do
    port=$((9000 + ${instances}))
    core_config=$((${LOCAL_THREAD}+${instances}-1)),$((${REMOTE_THREAD} + ${instances}-1))

    echo -e "\e[33mstarting redis server $instances\e[0m"


    #disable rdb & disable aof
    if [ "$rdb"x = "disable"x ] && [ "$aof"x = "disable"x ]; then
    echo -e "\e[33mnumactl -m ${BIND_SOCKET} taskset -c $core_config  $REDIS_PATH/redis-server --port ${port} --maxmemory ${max_memory} --nvm-maxcapacity ${nvm_max_capacity}  --nvm-dir /mnt/pmem${BIND_SOCKET}/ --nvm-threshold ${nvm_threshold} --maxmemory-policy allkeys-lru --save "" --appendonly no >/dev/null 2>&1  &\e[0m"
    numactl -m ${BIND_SOCKET} taskset -c $core_config  $REDIS_PATH/redis-server --port ${port} --maxmemory ${max_memory} --nvm-maxcapacity ${nvm_max_capacity} --nvm-dir /mnt/pmem${BIND_SOCKET}/ --nvm-threshold ${nvm_threshold} --maxmemory-policy allkeys-lru --save "" --appendonly no >/dev/null 2>&1  &
    fi

    #enable rdb & disable aof
    if [ "$rdb"x = "enable"x ] && [ "$aof"x = "disable"x ]; then
    echo -e "\e[33mnumactl -m ${BIND_SOCKET} taskset -c $core_config  $REDIS_PATH/redis-server --port ${port} --maxmemory ${max_memory}  --nvm-maxcapacity ${nvm_max_capacity} --nvm-dir /mnt/pmem${BIND_SOCKET}/ --nvm-threshold ${nvm_threshold} --maxmemory-policy allkeys-lru --dir ${DIR_PATH} --dbfilename ${port}.rdb --save 60 10000  >/dev/null 2>&1  &\e[0m"
    numactl -m ${BIND_SOCKET} taskset -c $core_config  $REDIS_PATH/redis-server --port ${port} --maxmemory ${max_memory} --nvm-maxcapacity ${nvm_max_capacity} --nvm-dir /mnt/pmem${BIND_SOCKET}/ --nvm-threshold ${nvm_threshold} --maxmemory-policy allkeys-lru --dir ${DIR_PATH} --dbfilename ${port}.rdb --save 60 10000  >/dev/null 2>&1  &
    fi

    #disable rdb & enable aof & appendfsync everysec & pba disable
    if [ "$rdb"x = "disable"x ] && [ "$aof"x = "enable"x ] && [ "$aof_type"x = "everysec"x ] && [ "$pba"x = "disable"x ]; then
     echo -e "\e[33mnumactl -m ${BIND_SOCKET} taskset -c $core_config  $REDIS_PATH/redis-server --port ${port} --maxmemory ${max_memory} --nvm-maxcapacity ${nvm_max_capacity} --nvm-dir /mnt/pmem${BIND_SOCKET}/ --nvm-threshold ${nvm_threshold} --maxmemory-policy allkeys-lru --dir ${DIR_PATH} --appendfilename ${port}.aof --appendonly yes --appendfsync everysec --pointer-based-aof yes  >/dev/null 2>&1  &\e[0m"
    numactl -m ${BIND_SOCKET} taskset -c $core_config  $REDIS_PATH/redis-server --port ${port} --maxmemory ${max_memory} --nvm-maxcapacity ${nvm_max_capacity} --nvm-dir /mnt/pmem${BIND_SOCKET}/ --nvm-threshold ${nvm_threshold} --maxmemory-policy allkeys-lru --dir ${DIR_PATH} --appendfilename ${port}.aof --appendonly yes --appendfsync everysec --pointer-based-aof yes  >/dev/null 2>&1  & 
    fi

    #disable rdb & enable aof & appendfsync always & pba disable
    if [ "$rdb"x = "disable"x ] && [ "$aof"x = "enable"x ] && [ "$aof_type"x = "always"x ] && [ "$pba"x = "disable"x ]; then
    echo -e "\e[33mnumactl -m ${BIND_SOCKET} taskset -c $core_config  $REDIS_PATH/redis-server --port ${port} --maxmemory ${max_memory} --nvm-maxcapacity ${nvm_max_capacity} --nvm-dir /mnt/pmem${BIND_SOCKET}/ --nvm-threshold ${nvm_threshold} --maxmemory-policy allkeys-lru --dir ${DIR_PATH} --appendfilename ${port}.aof --appendonly yes --appendfsync always --pointer-based-aof yes  >/dev/null 2>&1  &\e[0m"
    numactl -m ${BIND_SOCKET} taskset -c $core_config  $REDIS_PATH/redis-server --port ${port} --maxmemory ${max_memory} --nvm-maxcapacity ${nvm_max_capacity} --nvm-dir /mnt/pmem${BIND_SOCKET}/ --nvm-threshold ${nvm_threshold} --maxmemory-policy allkeys-lru --dir ${DIR_PATH} --appendfilename ${port}.aof --appendonly yes --appendfsync always --pointer-based-aof yes  >/dev/null 2>&1  &
    fi   

    #disable rdb & enable aof & appendfsync everysec & pba enable
    if [ "$rdb"x = "disable"x ] && [ "$aof"x = "enable"x ] && [ "$aof_type"x = "everysec"x ] && [ "$pba"x = "enable"x ]; then
    echo -e "\e[33mnumactl -m ${BIND_SOCKET} taskset -c $core_config  $REDIS_PATH/redis-server --port ${port} --maxmemory ${max_memory} --nvm-maxcapacity ${nvm_max_capacity} --nvm-dir /mnt/pmem${BIND_SOCKET}/ --nvm-threshold ${nvm_threshold} --maxmemory-policy allkeys-lru --dir ${DIR_PATH} --appendfilename ${port}.aof --appendonly yes --appendfsync everysec --pointer-based-aof yes  >/dev/null 2>&1  &\e[0m"
    numactl -m ${BIND_SOCKET} taskset -c $core_config  $REDIS_PATH/redis-server --port ${port} --maxmemory ${max_memory} --nvm-maxcapacity ${nvm_max_capacity} --nvm-dir /mnt/pmem${BIND_SOCKET}/ --nvm-threshold ${nvm_threshold} --maxmemory-policy allkeys-lru --dir ${DIR_PATH} --appendfilename ${port}.aof --appendonly yes --appendfsync everysec --pointer-based-aof yes  >/dev/null 2>&1  &
    fi

    #disable rdb & enable aof & appendfsync always & pba enable
    if [ "$rdb"x = "disable"x ] && [ "$aof"x = "enable"x ] && [ "$aof_type"x = "always"x ] && [ "$pba"x = "enable"x ]; then
    echo -e "\e[33mnumactl -m ${BIND_SOCKET} taskset -c $core_config  $REDIS_PATH/redis-server --port ${port} --maxmemory ${max_memory} --nvm-maxcapacity ${nvm_max_capacity} --nvm-dir /mnt/pmem${BIND_SOCKET}/ --nvm-threshold ${nvm_threshold} --maxmemory-policy allkeys-lru --dir ${DIR_PATH} --appendfilename ${port}.aof --appendonly yes --appendfsync always --pointer-based-aof yes  >/dev/null 2>&1  &\e[0m"
    numactl -m ${BIND_SOCKET} taskset -c $core_config  $REDIS_PATH/redis-server --port ${port} --maxmemory ${max_memory} --nvm-maxcapacity ${nvm_max_capacity} --nvm-dir /mnt/pmem${BIND_SOCKET}/ --nvm-threshold ${nvm_threshold} --maxmemory-policy allkeys-lru --dir ${DIR_PATH} --appendfilename ${port}.aof --appendonly yes --appendfsync always --pointer-based-aof yes  >/dev/null 2>&1  &
    fi
done
