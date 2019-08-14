pkill -9 redis

numactl -m 0 taskset -c 0,48 ./redis-server --port 6037 --maxmemory 90G --maxmemory-policy allkeys-lru  --dir /home/temp --save 60 100000 

numactl -m 0 taskset -c 0,48 ./redis-server --port 6038 --maxmemory 90G --maxmemory-policy allkeys-lru  --dir /home/temp --save 60 100000 

numactl -m 0 taskset -c 0,48 ./redis-server --port 6039 --maxmemory 90G --maxmemory-policy allkeys-lru  --dir /home/temp --save 60 100000 

numactl -m 1 taskset 24,72 ./redis-benchmark -p 6037 -t set -n 10000000 -r 10000000 -d 15026

numactl -m 1 taskset 24,72 ./redis-benchmark -p 6038 -t set -n 10000000 -r 10000000 -d 15026

numactl -m 1 taskset 24,72 ./redis-benchmark -p 6039 -t set -n 10000000 -r 10000000 -d 15026

