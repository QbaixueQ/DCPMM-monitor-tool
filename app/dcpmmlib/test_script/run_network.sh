#!/bin/bash

pkill -9 redis-server
pkill -9 redis-benchmark

export redis_path='../pmem-redis/src'
export replication_server_type='master'
export dimm_mode=$1   # 1lm 2lm AD numa_node
export run_mode=$2    #socket,replication, network
export title=$3       #volatile , rdb , aof_always , aof_everysec , pba 

if [ "${run_mode}"x = "replication"x ]; then
    title='rdb'
fi

export network_bandwidth='25G'

export slave_redis_path='/home/sean/redis/pmem-redis/src'
export slave_dir_path='/home/temp'
export MASTER_HOST="192.168.1.5"
export SLAVE_HOST="192.168.1.4"

#---------------------------------------------------------------


max_memory=15          # max memory per instance on socket0
nvm_max_capacity=20   # max AEP capacity per instance on socket0
nvm_threshold=64

data_size=(4096)
#data_size=(128 256 512 1024 2048 4096 16384)
redis_instance=(24)
result_path='./result'
dir_path='/home/temp'

server_socket_bind=0
benchmark_socket_bind=1

key_range=12000000
request_num=12000000

#--------------------------------------------------------------------------------------------------------------------

rdb='disable'
aof='disable'
aof_type='always'  #always & everysec
pba='disable'


if [ "${dimm_mode}"x = "1lm"x ] || [ "${dimm_mode}"x = "2lm"x ] || [ "${dimm_mode}"x = "AD"x ] || [ "${dimm_mode}"x = "numa_node"x ] ; then
    echo "**********start test ************ "
else
    echo "**********please input args: dimm_mode,title , run_model************ "
    echo "1.dimm_mode should be equle: 1lm ,2lm , AD , numa_node "
    #echo "2.title should be equle : volatile , rdb , aof_always , aof_everysec , pba "
    #echo "3.run_mode should be equle : socket , network , replication "
    exit 1
fi


export test_title=''


if [ "$title"x = "volatile"x ]; then
    rdb='disable'
    aof='disable'
    aof_type='always'  #always & everysec
    pba='disable'

elif [ "$title"x = "rdb"x ]; then
    rdb='enable'
    aof='disable'
    aof_type='always'  #always & everysec
    pba='disable'

elif [ "$title"x = "aof_always"x ]; then
    rdb='disable'
    aof='enable'
    aof_type='always'  #always & everysec
    pba='disable'

elif [ "$title"x = "aof_everysec"x ]; then
    rdb='disable'
    aof='enable'
    aof_type='everysec'  #always & everysec
    pba='disable'

elif [ "$title"x = "pba"x ]; then
    rdb='disable'
    aof='enable'
    aof_type='always'  #always & everysec
    pba='enable'

else
    echo "**********please input args: dimm_mode,title , run_model************ "
    #echo "1.dimm_mode should be equle: 1lm ,2lm , AD , numa_node "
    #echo "2.run_mode should be equle : socket , network , replication "
    echo "2.title should be equle : volatile , rdb , aof_always , aof_everysec , pba "
    exit 1
fi

if [ "${run_mode}"x = "socket"x ]; then
    test_title="${dimm_mode}_${run_model}_${title}"
elif [ "${run_mode}"x = "replication"x ]; then
    test_title="${dimm_mode}_${run_mode}${network_bandwidth}" 
elif [ "${run_mode}"x = "network"x ]; then
    test_title="${dimm_mode}_${run_mode}${network_bandwidth}_${title}"
else
    echo "**********please input args: dimm_mode,title , run_model************ "
    #echo "1.dimm_mode should be equle: 1lm ,2lm , AD , numa_node "
    echo "2.run_mode should be equle : socket , network , replication "
    #echo "3.title should be equle : volatile , rdb , aof_always , aof_everysec , pba "
    exit 1
fi


#socket----------------------------------------------------------------------------
if [ "${run_mode}"x = "socket"x ]; then
MASTER_HOST=127.0.0.1
for datasize in ${data_size[@]}
do
    for instance in ${redis_instance[@]}
    do 

        if [ "${dimm_mode}"x = "1lm"x ] || [ "${dimm_mode}"x = "2lm"x ] ; then
           
            if [ "${dimm_mode}"x = "1lm"x ] && [ "${datasize}"x = "16384"x  ]; then
                max_memory=2
                key_range=120000
                request_num=120000
            fi
            ./server_ddr.sh $redis_path $instance $server_socket_bind $dir_path $dimm_mode $rdb $aof $aof_type $max_memory
        
        elif [ "${dimm_mode}"x = 'AD'x ] || [ "${dimm_mode}"x = "numa_node"x ]; then
            ./server_aep.sh $redis_path $instance $server_socket_bind $dir_path $dimm_mode $rdb $aof $aof_type $pba $max_memory $nvm_max_capacity $nvm_threshold
        
        else
           echo "dimm mode should be: 1lm,2lm,AD,numa_mode"
           exit 1
        fi

        sleep 5

        #./benchmark.sh $redis_path $instance $datasize $test_title $result_path $benchmark_socket_bind $dir_path $dimm_mode $MASTER_HOST $key_range $request_num
     
    done
done
fi


#replication----------------------------------------------------------
if [ "${run_mode}"x = "replication"x ]; then

for datasize in ${data_size[@]}
do
    for instance in ${redis_instance[@]}
    do
        if [ "${dimm_mode}"x = "1lm"x ] || [ "${dimm_mode}"x = "2lm"x ] ; then
            if [ "${dimm_mode}"x = "1lm"x ] && [ "${datasize}"x = "16384"x  ]; then
                max_memory=2
                key_range=120000
                request_num=120000
            fi


            ./server_replication_ddr.sh $redis_path $instance $server_socket_bind $dir_path $dimm_mode $rdb $aof $aof_type $max_memory $replication_server_type $MASTER_HOST $SLAVE_HOST $slave_redis_path $slave_dir_path

        elif [ "${dimm_mode}"x = 'AD'x ] || [ "${dimm_mode}"x = "numa_node"x ]; then
            #./server_replication_aep.sh $redis_path $instance $server_socket_bind $dir_path $dimm_mode $rdb $aof $aof_type $pba $max_memory $nvm_max_capacity $nvm_threshold $replication_server_type $MASTER_HOST $SLAVE_HOST $slave_redis_path $slave_dir_path
           ./start_local.sh
           sleep 10
           ./start_ssh.sh
        else
           echo "dimm mode should be: 1lm,2lm,AD,numa_mode"
           exit 1
        fi

        sleep 5
        #./benchmark.sh $redis_path $instance $datasize $test_title $result_path $benchmark_socket_bind $dir_path $dimm_mode $MASTER_HOST $key_range $request_num

        sleep 10
        #ssh ${SLAVE_HOST} pkill -9 redis-server

   done
done

fi

if [ "${run_mode}"x = "network"x ]; then
MASTER_HOST='192.168.1.5'

    if [ "${dimm_mode}"x = "1lm"x ] || [ "${dimm_mode}"x = "2lm"x ] ; then      
                
        echo ./server_ddr.sh $redis_path $instance $server_socket_bind $dir_path $dimm_mode $rdb $aof $aof_type $max_memory $MASTER_HOST
        ./server_network_ddr.sh $redis_path 24 $server_socket_bind $dir_path $dimm_mode $rdb $aof $aof_type $max_memory $MASTER_HOST

    elif [ "${dimm_mode}"x = 'AD'x ] || [ "${dimm_mode}"x = "numa_node"x ]; then
        ./server_network_aep.sh $redis_path 24 $server_socket_bind $dir_path $dimm_mode $rdb $aof $aof_type $pba $max_memory $nvm_max_capacity $nvm_threshold $MASTER_HOST

    else
        echo "dimm mode should be: 1lm,2lm,AD,numa_mode"
        exit 1
    fi
fi

#pkill -9 redis

echo -e "\e[36m******************************************************\e[0m"
echo -e "\e[36m--------Test cases are all complete!------------------\e[3m"
echo -e "\e[36m******************************************************\e[0m"



