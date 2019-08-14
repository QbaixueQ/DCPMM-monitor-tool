# -*- coding: utf-8 -*-
from flask import Flask, render_template, request
from flask import jsonify

from dcpmmlib.memory_info import dcpmm_mode
from dcpmmlib.memory_info import dcpmm_capacity
from dcpmmlib.redis_info import get_current_info
from dcpmmlib.result_info import parse_result
from dcpmmlib.arg_info import stop_servers
from dcpmmlib.arg_info import run_tests

app = Flask(__name__)


@app.route('/')
def index():
    return render_template('index.html')


@app.route('/mode_info')
def load_mode():
    mode = jsonify(dcpmm_mode())
    return mode


@app.route('/memory_info')
def load_memory():
    memory = jsonify(dcpmm_capacity())
    return memory


@app.route('/redis_info')
def load_redis():
    redis = jsonify(get_current_info())
    return redis


@app.route('/result_info')
def load_results():
    results = jsonify(parse_result())
    return results


@app.route('/stop_server')
def stop_server():
    servers = jsonify(stop_servers())
    return servers


@app.route('/run_test')
def run_test():
    test = jsonify(run_tests())
    return test


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=3000)
