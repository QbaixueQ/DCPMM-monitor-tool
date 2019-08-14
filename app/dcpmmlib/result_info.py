import os
import csv
import pprint

# DATADIR="../test_script/result/report_collect"
DATADIR = "test_script/result/report_collect"
DATAFILE = "set_AD__aof_always_24_1024.csv"


def parse_result():
    datafile = os.path.join(DATADIR, DATAFILE)
    data = [[], [], [], []]
    ave_data = []
    latency_0 = []
    tps = []
    used_memory = []
    used_nvm = []
    with open(datafile, "r") as f:
        if(f != None):
            data_type = f.readline()  # set
            reader = csv.DictReader(f)
            for row in reader:
                latency_0.append(row["latency_0"])
                tps.append(row["tps"])
                used_memory.append(row["used_memory"])
                used_nvm.append(row["used_nvm"])
            ave_data = [latency_0.pop(), tps.pop(), used_memory.pop(),
                        used_nvm.pop()]  # average data
            latency_0.pop()
            tps.pop()
            used_memory.pop()
            used_nvm.pop()
            # the value of first instance
            data[0].append(round(float(latency_0[0]), 2))
            data[1].append(round(float(tps[0]), 2))
            data[2].append(round(float(used_memory[0])/1024/1024, 2))
            data[3].append(round(float(used_nvm[0])/1024/1024, 2))
            for i in range(1, len(latency_0)):
                data[0].append(round(float(latency_0[i]), 2))
                data[1].append(round(float(tps[i])+data[1][i-1], 2))
                data[2].append(
                    round(float(used_memory[i])/1024/1024+data[2][i-1], 2))
                data[3].append(
                    round(float(used_nvm[i])/1024/1024+data[3][i-1], 2))
    return data


if __name__ == "__main__":
    parse_result()
