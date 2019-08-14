import redis
import os


def get_current_info():
    ports = []
    redis_infos = []
    instance = os.popen("ps -ef|grep redis").readlines()
    for line in instance:
        x = line.split("redis-server *:")
        if(len(x) > 1):
            ports.append((x[1].split("\n"))[0])
    for port_num in ports:
        port_info = []
        r = redis.Redis(host='localhost', port=port_num, decode_responses=True)
        redis_info = r.info()
        for key in redis_info:
            if key == 'instantaneous_ops_per_sec':
                ops_sec = redis_info['instantaneous_ops_per_sec']
                port_info.append(ops_sec)
            if key == 'used_memory':
                used_memory = redis_info['used_memory']
                port_info.append(used_memory)
        redis_infos.append(port_info)
    return redis_infos


if __name__ == "__main__":
    get_current_info()
