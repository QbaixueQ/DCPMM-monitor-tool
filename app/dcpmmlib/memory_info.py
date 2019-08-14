import os
from system_info import numa_node_number


def dcpmm_mode():
    mode = os.popen("ipmctl show -region|tr -d '\n'").read()
    if mode == "There are no Regions defined in the system.":
        return "2LM"
    else:
        x = mode.split("|")
        ad_mode = x[7].replace(' ', '')
        node_number = numa_node_number()
        pmem = os.popen("df -hl|grep pmem0").read()
        if ad_mode == "AppDirect":
            if node_number == '2' and pmem != "":
                return "AD_Mode"
            elif node_number == '4':
                return "Numa_Node"
        else:
            return "1LM"


def dcpmm_mode1():
    return "AD_Mode"


def dcpmm_capacity():
    mode = dcpmm_mode()
    if mode == "2LM" or mode == "1LM":
        memory = memory_mode_capacity()
        return memory
    else:
        if mode == "AD_Mode":
            ad = ad_mode_capacity()
            return ad
        elif mode == "Numa_Node":
            numa = numa_node_capacity()
            return numa
        else:
            lm = memory_mode_capacity()
            return lm


def memory_mode_capacity():
    node_number = numa_node_number()
    node_size = []
    node_free = []
    node_used = []
    for index in range(0, int(node_number)):
        node_size.append(float(os.popen("numactl -H|grep 'node " + str(index) +
                                        " size'|awk -F ':' '{print $2'}|tr -d '[:space:]'").read().split("MB")[0]))
        node_free.append(float(os.popen("numactl -H|grep 'node " + str(index) +
                                        " free'|awk -F ':' '{print $2'}|tr -d '[:space:]'").read().split("MB")[0]))
        node_used.append(
            ((node_size[index]-node_free[index])/node_size[index])*100.0)
    return node_size, node_free, node_used


def ad_mode_capacity():
    node_number = numa_node_number()
    node_size = []
    node_free = []
    node_used = []
    for index in range(0, int(node_number)):
        node_size.append(float(os.popen("numactl -H|grep 'node " + str(index) +
                                        " size'|awk -F ':' '{print $2'}|tr -d '[:space:]'").read().split("MB")[0]))
        node_size.append(float(os.popen("df -hl|grep '/dev/pmem" + str(index) +
                                        "'|awk -F ' ' '{print $2'}|tr -d '\n'").read().split("G")[0])*1024)
        node_free.append(float(os.popen("numactl -H|grep 'node " + str(index) +
                                        " free'|awk -F ':' '{print $2'}|tr -d '[:space:]'").read().split("MB")[0]))
        node_free.append(float(os.popen("df -hl|grep '/dev/pmem" + str(index) +
                                        "'|awk -F ' ' '{print $4'}|tr -d '\n'").read().split("G")[0])*1024)
    for index in range(0, 4):
        node_used.append(
            ((node_size[index]-node_free[index])/node_size[index])*100.0)
   # print(node_size,node_free,node_used);
    return node_size, node_free, node_used


def numa_node_capacity():
    node_number = numa_node_number()
    node_size = []
    node_free = []
    node_used = []
    for index in range(0, int(node_number)):
        node_size.append(float(os.popen("numactl -H|grep 'node " + str(index) +
                                        " size'|awk -F ':' '{print $2'}|tr -d '[:space:]'").read().split("MB")[0]))
        node_free.append(float(os.popen("numactl -H|grep 'node " + str(index) +
                                        " free'|awk -F ':' '{print $2'}|tr -d '[:space:]'").read().split("MB")[0]))
        node_used.append(
            ((node_size[index]-node_free[index])/node_size[index])*100.0)
    return node_size, node_free, node_used


if __name__ == "__main__":
    dcpmm_mode()
    dcpmm_capacity()
