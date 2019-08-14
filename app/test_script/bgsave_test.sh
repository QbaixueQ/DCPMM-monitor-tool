#!/bin/bash

pkill -9 redis-server
pkill -9 redis-benchmark
pkill -9 redis-benchmakr-seq
#--------------------------------------------------------------------------------------
export REDIS_PATH='../pmem-redis/src/'
export DIR_PATH='/home/temp'
export max_memory=30G
export port=3000

export nvm_max_capacity=20G


#clean----------------------------------------------------------------------------------

mkdir -p ${DIR_PATH}

rm -rf  ${DIR_PATH}/*.rdb
rm -rf  ${DIR_PATH}/*.aof
rm -rf  ${DIR_PATH}/*.ag

#----start server----------------
echo ""
echo "stap1: start a redis server"
echo ""

echo numactl -m 0 $REDIS_PATH/redis-server --port ${port} --maxmemory ${max_memory} --nvm-maxcapacity ${nvm_max_capacity}  --nvm-dir /mnt/pmem0/ --nvm-threshold 64 --maxmemory-policy allkeys-lru --dir ${DIR_PATH} --dbfilename ${port}.rdb
numactl -m 0 ${REDIS_PATH}/redis-server --port ${port} --maxmemory ${max_memory} --maxmemory-policy allkeys-lru --dir ${DIR_PATH} --dbfilename ${port}.rdb &

sleep 5
echo ""
echo "stap2: set some data to db"
echo ""

echo numactl -m 1 ${REDIS_PATH}/redis-benchmark -p ${port} -t set -n 100000000 -r 10000000 -d 1024
numactl -m 1 ${REDIS_PATH}/redis-benchmark -p ${port} -t set -n 100000 -r 100000 -d 1024 >/dev/null &

while [ $(ps -ef | grep -c redis-benchmark) -gt 1 ];do
      echo -e "\e[36mWaiting $(($(ps -ef | grep -c redis-benchmark)-1)) benchmark finish... \e[0m"
      sleep 5
done

echo ""
echo "stap2: start bgsave and meanwhile insert some different keys"
echo ""
numactl -m 0 $REDIS_PATH/redis-cli -p ${port} bgsave 
numactl -m 0 $REDIS_PATH/redis-cli -p ${port} set food value

for (( i=1; i<=10 ; i++ ))
do
   key='food_'${i}
   value='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
   echo "insert key  "$key 
   numactl -m 0 $REDIS_PATH/redis-cli -p ${port} set key value
done

while [ ! -f ${DIR_PATH}/${port}.rdb ];do
      echo -e "\e[36mWaiting bgsave...... \e[0m"
      sleep 2
done

sleep 5
echo ""
echo "stap3: kill redis server , then restart the server and reload rdb file"
echo ""
pkill -9 redis
sleep 5

echo ""
echo numactl -m 0 $REDIS_PATH/redis-server --port ${port} --maxmemory ${max_memory} --nvm-maxcapacity ${nvm_max_capacity}  --nvm-dir /mnt/pmem0/ --nvm-threshold 64 --maxmemory-policy allkeys-lru --dir ${DIR_PATH} --dbfilename ${port}.rdb >/dev/null 2>&1 &

numactl -m 0 $REDIS_PATH/redis-server --port ${port} --maxmemory ${max_memory} --maxmemory-policy allkeys-lru --dir ${DIR_PATH} --dbfilename ${port}.rdb >/dev/null 2>&1 &

sleep 5

echo ""
echo "stap4: check are the new keys in the db (expect not in db , value equal null)"
echo ""

for (( i=1; i<=10 ; i++ ))
do
   key='food_'${i}
   values=`numactl -m 0 $REDIS_PATH/redis-cli -p ${port} get ${key}`
   echo "get key "$key"  value="$values  
done












