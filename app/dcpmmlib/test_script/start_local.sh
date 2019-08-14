numactl -m 0 taskset -c 0,48  ../pmem-redis/src/redis-server --port 9001 --maxmemory 3G  --nvm-maxcapacity 20G --nvm-dir /mnt/pmem0/ --nvm-threshold 64 --maxmemory-policy allkeys-lru --protected-mode no  --dir /home/temp --dbfilename 9001.rdb --bind 192.168.1.5  >/dev/null 2>&1  &
#starting redis server 2
numactl -m 0 taskset -c 1,49  ../pmem-redis/src/redis-server --port 9002 --maxmemory 3G  --nvm-maxcapacity 20G --nvm-dir /mnt/pmem0/ --nvm-threshold 64 --maxmemory-policy allkeys-lru --protected-mode no  --dir /home/temp --dbfilename 9002.rdb --bind 192.168.1.5  >/dev/null 2>&1  &
#starting redis server 3
numactl -m 0 taskset -c 2,50  ../pmem-redis/src/redis-server --port 9003 --maxmemory 3G  --nvm-maxcapacity 20G --nvm-dir /mnt/pmem0/ --nvm-threshold 64 --maxmemory-policy allkeys-lru --protected-mode no  --dir /home/temp --dbfilename 9003.rdb --bind 192.168.1.5  >/dev/null 2>&1  &
#starting redis server 4
numactl -m 0 taskset -c 3,51  ../pmem-redis/src/redis-server --port 9004 --maxmemory 3G  --nvm-maxcapacity 20G --nvm-dir /mnt/pmem0/ --nvm-threshold 64 --maxmemory-policy allkeys-lru --protected-mode no  --dir /home/temp --dbfilename 9004.rdb --bind 192.168.1.5  >/dev/null 2>&1  &
#starting redis server 5
numactl -m 0 taskset -c 4,52  ../pmem-redis/src/redis-server --port 9005 --maxmemory 3G  --nvm-maxcapacity 20G --nvm-dir /mnt/pmem0/ --nvm-threshold 64 --maxmemory-policy allkeys-lru --protected-mode no  --dir /home/temp --dbfilename 9005.rdb --bind 192.168.1.5  >/dev/null 2>&1  &
#starting redis server 6
numactl -m 0 taskset -c 5,53  ../pmem-redis/src/redis-server --port 9006 --maxmemory 3G  --nvm-maxcapacity 20G --nvm-dir /mnt/pmem0/ --nvm-threshold 64 --maxmemory-policy allkeys-lru --protected-mode no  --dir /home/temp --dbfilename 9006.rdb --bind 192.168.1.5  >/dev/null 2>&1  &
#starting redis server 7
numactl -m 0 taskset -c 6,54  ../pmem-redis/src/redis-server --port 9007 --maxmemory 3G  --nvm-maxcapacity 20G --nvm-dir /mnt/pmem0/ --nvm-threshold 64 --maxmemory-policy allkeys-lru --protected-mode no  --dir /home/temp --dbfilename 9007.rdb --bind 192.168.1.5  >/dev/null 2>&1  &
#starting redis server 8
numactl -m 0 taskset -c 7,55  ../pmem-redis/src/redis-server --port 9008 --maxmemory 3G  --nvm-maxcapacity 20G --nvm-dir /mnt/pmem0/ --nvm-threshold 64 --maxmemory-policy allkeys-lru --protected-mode no  --dir /home/temp --dbfilename 9008.rdb --bind 192.168.1.5  >/dev/null 2>&1  &
#starting redis server 9
numactl -m 0 taskset -c 8,56  ../pmem-redis/src/redis-server --port 9009 --maxmemory 3G  --nvm-maxcapacity 20G --nvm-dir /mnt/pmem0/ --nvm-threshold 64 --maxmemory-policy allkeys-lru --protected-mode no  --dir /home/temp --dbfilename 9009.rdb --bind 192.168.1.5  >/dev/null 2>&1  &
#starting redis server 10
numactl -m 0 taskset -c 9,57  ../pmem-redis/src/redis-server --port 9010 --maxmemory 3G  --nvm-maxcapacity 20G --nvm-dir /mnt/pmem0/ --nvm-threshold 64 --maxmemory-policy allkeys-lru --protected-mode no  --dir /home/temp --dbfilename 9010.rdb --bind 192.168.1.5  >/dev/null 2>&1  &
#starting redis server 11
numactl -m 0 taskset -c 10,58  ../pmem-redis/src/redis-server --port 9011 --maxmemory 3G  --nvm-maxcapacity 20G --nvm-dir /mnt/pmem0/ --nvm-threshold 64 --maxmemory-policy allkeys-lru --protected-mode no  --dir /home/temp --dbfilename 9011.rdb --bind 192.168.1.5  >/dev/null 2>&1  &
#starting redis server 12
numactl -m 0 taskset -c 11,59  ../pmem-redis/src/redis-server --port 9012 --maxmemory 3G  --nvm-maxcapacity 20G --nvm-dir /mnt/pmem0/ --nvm-threshold 64 --maxmemory-policy allkeys-lru --protected-mode no  --dir /home/temp --dbfilename 9012.rdb --bind 192.168.1.5  >/dev/null 2>&1  &
#starting redis server 13
numactl -m 0 taskset -c 12,60  ../pmem-redis/src/redis-server --port 9013 --maxmemory 3G  --nvm-maxcapacity 20G --nvm-dir /mnt/pmem0/ --nvm-threshold 64 --maxmemory-policy allkeys-lru --protected-mode no  --dir /home/temp --dbfilename 9013.rdb --bind 192.168.1.5  >/dev/null 2>&1  &
#starting redis server 14
numactl -m 0 taskset -c 13,61  ../pmem-redis/src/redis-server --port 9014 --maxmemory 3G  --nvm-maxcapacity 20G --nvm-dir /mnt/pmem0/ --nvm-threshold 64 --maxmemory-policy allkeys-lru --protected-mode no  --dir /home/temp --dbfilename 9014.rdb --bind 192.168.1.5  >/dev/null 2>&1  &
#starting redis server 15
numactl -m 0 taskset -c 14,62  ../pmem-redis/src/redis-server --port 9015 --maxmemory 3G  --nvm-maxcapacity 20G --nvm-dir /mnt/pmem0/ --nvm-threshold 64 --maxmemory-policy allkeys-lru --protected-mode no  --dir /home/temp --dbfilename 9015.rdb --bind 192.168.1.5  >/dev/null 2>&1  &
#starting redis server 16
numactl -m 0 taskset -c 15,63  ../pmem-redis/src/redis-server --port 9016 --maxmemory 3G  --nvm-maxcapacity 20G --nvm-dir /mnt/pmem0/ --nvm-threshold 64 --maxmemory-policy allkeys-lru --protected-mode no  --dir /home/temp --dbfilename 9016.rdb --bind 192.168.1.5  >/dev/null 2>&1  &
#starting redis server 17
numactl -m 0 taskset -c 16,64  ../pmem-redis/src/redis-server --port 9017 --maxmemory 3G  --nvm-maxcapacity 20G --nvm-dir /mnt/pmem0/ --nvm-threshold 64 --maxmemory-policy allkeys-lru --protected-mode no  --dir /home/temp --dbfilename 9017.rdb --bind 192.168.1.5  >/dev/null 2>&1  &
#starting redis server 18
numactl -m 0 taskset -c 17,65  ../pmem-redis/src/redis-server --port 9018 --maxmemory 3G  --nvm-maxcapacity 20G --nvm-dir /mnt/pmem0/ --nvm-threshold 64 --maxmemory-policy allkeys-lru --protected-mode no  --dir /home/temp --dbfilename 9018.rdb --bind 192.168.1.5  >/dev/null 2>&1  &
#starting redis server 19
numactl -m 0 taskset -c 18,66  ../pmem-redis/src/redis-server --port 9019 --maxmemory 3G  --nvm-maxcapacity 20G --nvm-dir /mnt/pmem0/ --nvm-threshold 64 --maxmemory-policy allkeys-lru --protected-mode no  --dir /home/temp --dbfilename 9019.rdb --bind 192.168.1.5  >/dev/null 2>&1  &
#starting redis server 20
numactl -m 0 taskset -c 19,67  ../pmem-redis/src/redis-server --port 9020 --maxmemory 3G  --nvm-maxcapacity 20G --nvm-dir /mnt/pmem0/ --nvm-threshold 64 --maxmemory-policy allkeys-lru --protected-mode no  --dir /home/temp --dbfilename 9020.rdb --bind 192.168.1.5  >/dev/null 2>&1  &
#starting redis server 21
numactl -m 0 taskset -c 20,68  ../pmem-redis/src/redis-server --port 9021 --maxmemory 3G  --nvm-maxcapacity 20G --nvm-dir /mnt/pmem0/ --nvm-threshold 64 --maxmemory-policy allkeys-lru --protected-mode no  --dir /home/temp --dbfilename 9021.rdb --bind 192.168.1.5  >/dev/null 2>&1  &
#starting redis server 22
numactl -m 0 taskset -c 21,69  ../pmem-redis/src/redis-server --port 9022 --maxmemory 3G  --nvm-maxcapacity 20G --nvm-dir /mnt/pmem0/ --nvm-threshold 64 --maxmemory-policy allkeys-lru --protected-mode no  --dir /home/temp --dbfilename 9022.rdb --bind 192.168.1.5  >/dev/null 2>&1  &
#starting redis server 23
numactl -m 0 taskset -c 22,70  ../pmem-redis/src/redis-server --port 9023 --maxmemory 3G  --nvm-maxcapacity 20G --nvm-dir /mnt/pmem0/ --nvm-threshold 64 --maxmemory-policy allkeys-lru --protected-mode no  --dir /home/temp --dbfilename 9023.rdb --bind 192.168.1.5  >/dev/null 2>&1  &
#starting redis server 24
numactl -m 0 taskset -c 23,71  ../pmem-redis/src/redis-server --port 9024 --maxmemory 3G  --nvm-maxcapacity 20G --nvm-dir /mnt/pmem0/ --nvm-threshold 64 --maxmemory-policy allkeys-lru --protected-mode no  --dir /home/temp --dbfilename 9024.rdb --bind 192.168.1.5  >/dev/null 2>&1  &
