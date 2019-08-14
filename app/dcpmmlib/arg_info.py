import os

def stop_servers():
    os.popen("pkill -9 redis");
    return "succes"

def run_tests():
    path="test_script/run_test.sh 2lm socket rdb"
    os.system(path);
    return "succes"
