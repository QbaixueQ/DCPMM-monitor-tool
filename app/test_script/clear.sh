pkill -9 redis

rm -rf /home/temp/.rdb
rm -rf /home/temp/.aof

rm -rf /mnt/pmem0/*AEP
rm -rf /mnt/pmem0/*.ag

rm -rf /mnt/nvme0n1/.aof
rm -rf /mnt/nvme0n1/.ag
rm -rf /mnt/nvme0n1/.rdb


