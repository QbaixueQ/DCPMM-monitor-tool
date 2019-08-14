ssh 192.168.1.4  numactl -m 0 taskset -c 0,48  /home/sean/redis/pmem-redis/src/redis-server --port 9001 --maxmemory 3G  --nvm-maxcapacity 20G --nvm-dir /mnt/pmem0/ --nvm-threshold 64 --maxmemory-policy allkeys-lru --protected-mode no  --dir /home/temp --dbfilename 9001.rdb --bind 192.168.1.4 --slaveof 192.168.1.5 9001  >/dev/null 2>&1  &
#starting redis server 2
ssh 192.168.1.4  numactl -m 0 taskset -c 1,49  /home/sean/redis/pmem-redis/src/redis-server --port 9002 --maxmemory 3G  --nvm-maxcapacity 20G --nvm-dir /mnt/pmem0/ --nvm-threshold 64 --maxmemory-policy allkeys-lru --protected-mode no  --dir /home/temp --dbfilename 9002.rdb --bind 192.168.1.4 --slaveof 192.168.1.5 9002  >/dev/null 2>&1  &
#starting redis server 3
ssh 192.168.1.4  numactl -m 0 taskset -c 2,50  /home/sean/redis/pmem-redis/src/redis-server --port 9003 --maxmemory 3G  --nvm-maxcapacity 20G --nvm-dir /mnt/pmem0/ --nvm-threshold 64 --maxmemory-policy allkeys-lru --protected-mode no  --dir /home/temp --dbfilename 9003.rdb --bind 192.168.1.4 --slaveof 192.168.1.5 9003  >/dev/null 2>&1  &
#starting redis server 4
ssh 192.168.1.4  numactl -m 0 taskset -c 3,51  /home/sean/redis/pmem-redis/src/redis-server --port 9004 --maxmemory 3G  --nvm-maxcapacity 20G --nvm-dir /mnt/pmem0/ --nvm-threshold 64 --maxmemory-policy allkeys-lru --protected-mode no  --dir /home/temp --dbfilename 9004.rdb --bind 192.168.1.4 --slaveof 192.168.1.5 9004  >/dev/null 2>&1  &
#starting redis server 5
ssh 192.168.1.4  numactl -m 0 taskset -c 4,52  /home/sean/redis/pmem-redis/src/redis-server --port 9005 --maxmemory 3G  --nvm-maxcapacity 20G --nvm-dir /mnt/pmem0/ --nvm-threshold 64 --maxmemory-policy allkeys-lru --protected-mode no  --dir /home/temp --dbfilename 9005.rdb --bind 192.168.1.4 --slaveof 192.168.1.5 9005  >/dev/null 2>&1  &
#starting redis server 6
ssh 192.168.1.4  numactl -m 0 taskset -c 5,53  /home/sean/redis/pmem-redis/src/redis-server --port 9006 --maxmemory 3G  --nvm-maxcapacity 20G --nvm-dir /mnt/pmem0/ --nvm-threshold 64 --maxmemory-policy allkeys-lru --protected-mode no  --dir /home/temp --dbfilename 9006.rdb --bind 192.168.1.4 --slaveof 192.168.1.5 9006  >/dev/null 2>&1  &
#starting redis server 7
ssh 192.168.1.4  numactl -m 0 taskset -c 6,54  /home/sean/redis/pmem-redis/src/redis-server --port 9007 --maxmemory 3G  --nvm-maxcapacity 20G --nvm-dir /mnt/pmem0/ --nvm-threshold 64 --maxmemory-policy allkeys-lru --protected-mode no  --dir /home/temp --dbfilename 9007.rdb --bind 192.168.1.4 --slaveof 192.168.1.5 9007  >/dev/null 2>&1  &
#starting redis server 8
ssh 192.168.1.4  numactl -m 0 taskset -c 7,55  /home/sean/redis/pmem-redis/src/redis-server --port 9008 --maxmemory 3G  --nvm-maxcapacity 20G --nvm-dir /mnt/pmem0/ --nvm-threshold 64 --maxmemory-policy allkeys-lru --protected-mode no  --dir /home/temp --dbfilename 9008.rdb --bind 192.168.1.4 --slaveof 192.168.1.5 9008  >/dev/null 2>&1  &
#starting redis server 9
ssh 192.168.1.4  numactl -m 0 taskset -c 8,56  /home/sean/redis/pmem-redis/src/redis-server --port 9009 --maxmemory 3G  --nvm-maxcapacity 20G --nvm-dir /mnt/pmem0/ --nvm-threshold 64 --maxmemory-policy allkeys-lru --protected-mode no  --dir /home/temp --dbfilename 9009.rdb --bind 192.168.1.4 --slaveof 192.168.1.5 9009  >/dev/null 2>&1  &
#starting redis server 10
ssh 192.168.1.4  numactl -m 0 taskset -c 9,57  /home/sean/redis/pmem-redis/src/redis-server --port 9010 --maxmemory 3G  --nvm-maxcapacity 20G --nvm-dir /mnt/pmem0/ --nvm-threshold 64 --maxmemory-policy allkeys-lru --protected-mode no  --dir /home/temp --dbfilename 9010.rdb --bind 192.168.1.4 --slaveof 192.168.1.5 9010  >/dev/null 2>&1  &
#starting redis server 11
ssh 192.168.1.4  numactl -m 0 taskset -c 10,58  /home/sean/redis/pmem-redis/src/redis-server --port 9011 --maxmemory 3G  --nvm-maxcapacity 20G --nvm-dir /mnt/pmem0/ --nvm-threshold 64 --maxmemory-policy allkeys-lru --protected-mode no  --dir /home/temp --dbfilename 9011.rdb --bind 192.168.1.4 --slaveof 192.168.1.5 9011  >/dev/null 2>&1  &
#starting redis server 12
ssh 192.168.1.4  numactl -m 0 taskset -c 11,59  /home/sean/redis/pmem-redis/src/redis-server --port 9012 --maxmemory 3G  --nvm-maxcapacity 20G --nvm-dir /mnt/pmem0/ --nvm-threshold 64 --maxmemory-policy allkeys-lru --protected-mode no  --dir /home/temp --dbfilename 9012.rdb --bind 192.168.1.4 --slaveof 192.168.1.5 9012  >/dev/null 2>&1  &
#starting redis server 13
ssh 192.168.1.4  numactl -m 0 taskset -c 12,60  /home/sean/redis/pmem-redis/src/redis-server --port 9013 --maxmemory 3G  --nvm-maxcapacity 20G --nvm-dir /mnt/pmem0/ --nvm-threshold 64 --maxmemory-policy allkeys-lru --protected-mode no  --dir /home/temp --dbfilename 9013.rdb --bind 192.168.1.4 --slaveof 192.168.1.5 9013  >/dev/null 2>&1  &
#starting redis server 14
ssh 192.168.1.4  numactl -m 0 taskset -c 13,61  /home/sean/redis/pmem-redis/src/redis-server --port 9014 --maxmemory 3G  --nvm-maxcapacity 20G --nvm-dir /mnt/pmem0/ --nvm-threshold 64 --maxmemory-policy allkeys-lru --protected-mode no  --dir /home/temp --dbfilename 9014.rdb --bind 192.168.1.4 --slaveof 192.168.1.5 9014  >/dev/null 2>&1  &
#starting redis server 15
ssh 192.168.1.4  numactl -m 0 taskset -c 14,62  /home/sean/redis/pmem-redis/src/redis-server --port 9015 --maxmemory 3G  --nvm-maxcapacity 20G --nvm-dir /mnt/pmem0/ --nvm-threshold 64 --maxmemory-policy allkeys-lru --protected-mode no  --dir /home/temp --dbfilename 9015.rdb --bind 192.168.1.4 --slaveof 192.168.1.5 9015  >/dev/null 2>&1  &
#starting redis server 16
ssh 192.168.1.4  numactl -m 0 taskset -c 15,63  /home/sean/redis/pmem-redis/src/redis-server --port 9016 --maxmemory 3G  --nvm-maxcapacity 20G --nvm-dir /mnt/pmem0/ --nvm-threshold 64 --maxmemory-policy allkeys-lru --protected-mode no  --dir /home/temp --dbfilename 9016.rdb --bind 192.168.1.4 --slaveof 192.168.1.5 9016  >/dev/null 2>&1  &
#starting redis server 17
ssh 192.168.1.4  numactl -m 0 taskset -c 16,64  /home/sean/redis/pmem-redis/src/redis-server --port 9017 --maxmemory 3G  --nvm-maxcapacity 20G --nvm-dir /mnt/pmem0/ --nvm-threshold 64 --maxmemory-policy allkeys-lru --protected-mode no  --dir /home/temp --dbfilename 9017.rdb --bind 192.168.1.4 --slaveof 192.168.1.5 9017  >/dev/null 2>&1  &
#starting redis server 18
ssh 192.168.1.4  numactl -m 0 taskset -c 17,65  /home/sean/redis/pmem-redis/src/redis-server --port 9018 --maxmemory 3G  --nvm-maxcapacity 20G --nvm-dir /mnt/pmem0/ --nvm-threshold 64 --maxmemory-policy allkeys-lru --protected-mode no  --dir /home/temp --dbfilename 9018.rdb --bind 192.168.1.4 --slaveof 192.168.1.5 9018  >/dev/null 2>&1  &
#starting redis server 19
ssh 192.168.1.4  numactl -m 0 taskset -c 18,66  /home/sean/redis/pmem-redis/src/redis-server --port 9019 --maxmemory 3G  --nvm-maxcapacity 20G --nvm-dir /mnt/pmem0/ --nvm-threshold 64 --maxmemory-policy allkeys-lru --protected-mode no  --dir /home/temp --dbfilename 9019.rdb --bind 192.168.1.4 --slaveof 192.168.1.5 9019  >/dev/null 2>&1  &
#starting redis server 20
ssh 192.168.1.4  numactl -m 0 taskset -c 19,67  /home/sean/redis/pmem-redis/src/redis-server --port 9020 --maxmemory 3G  --nvm-maxcapacity 20G --nvm-dir /mnt/pmem0/ --nvm-threshold 64 --maxmemory-policy allkeys-lru --protected-mode no  --dir /home/temp --dbfilename 9020.rdb --bind 192.168.1.4 --slaveof 192.168.1.5 9020  >/dev/null 2>&1  &
#starting redis server 21
ssh 192.168.1.4  numactl -m 0 taskset -c 20,68  /home/sean/redis/pmem-redis/src/redis-server --port 9021 --maxmemory 3G  --nvm-maxcapacity 20G --nvm-dir /mnt/pmem0/ --nvm-threshold 64 --maxmemory-policy allkeys-lru --protected-mode no  --dir /home/temp --dbfilename 9021.rdb --bind 192.168.1.4 --slaveof 192.168.1.5 9021  >/dev/null 2>&1  &
#starting redis server 22
ssh 192.168.1.4  numactl -m 0 taskset -c 21,69  /home/sean/redis/pmem-redis/src/redis-server --port 9022 --maxmemory 3G  --nvm-maxcapacity 20G --nvm-dir /mnt/pmem0/ --nvm-threshold 64 --maxmemory-policy allkeys-lru --protected-mode no  --dir /home/temp --dbfilename 9022.rdb --bind 192.168.1.4 --slaveof 192.168.1.5 9022  >/dev/null 2>&1  &
#starting redis server 23
ssh 192.168.1.4  numactl -m 0 taskset -c 22,70  /home/sean/redis/pmem-redis/src/redis-server --port 9023 --maxmemory 3G  --nvm-maxcapacity 20G --nvm-dir /mnt/pmem0/ --nvm-threshold 64 --maxmemory-policy allkeys-lru --protected-mode no  --dir /home/temp --dbfilename 9023.rdb --bind 192.168.1.4 --slaveof 192.168.1.5 9023  >/dev/null 2>&1  &
#starting redis server 24
ssh 192.168.1.4  numactl -m 0 taskset -c 23,71  /home/sean/redis/pmem-redis/src/redis-server --port 9024 --maxmemory 3G  --nvm-maxcapacity 20G --nvm-dir /mnt/pmem0/ --nvm-threshold 64 --maxmemory-policy allkeys-lru --protected-mode no  --dir /home/temp --dbfilename 9024.rdb --bind 192.168.1.4 --slaveof 192.168.1.5 9024  >/dev/null 2>&1  &
