import os


def numa_node_number():
    node_number = os.popen(
        "lscpu|grep 'NUMA node(s):'|awk -F ':' '{print $2'}|tr -d '[:space:]'").read()
    return node_number


def socket_number():
    socket_number = os.popen(
        "lscpu|grep 'Socket(s):'|awk -F ':' '{print $2'}|tr -d '[:space:]'").read()
    return socket_number


if __name__ == "__main__":
    numa_node_number()
    socket_number()
