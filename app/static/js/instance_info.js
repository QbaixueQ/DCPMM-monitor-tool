$(document).ready(function () {
    //GaugeMeter
    $(".GaugeMeter").gaugeMeter();

    //Format Code
    $("pre.Code").html(function (index, html) {
        return html.replace(/^(.*)$/mg, "<span class='Line'>$1</span>")
    });

    //Sticky Table Header
    var tables = $("table.StickyHeader");
    tables.each(function (i) {
        var table = tables[i];
        var theadClone = $(table).find("thead").clone(true);
        var stickyHeader = $("<div></div>").addClass("StickyHeader Hide");
        stickyHeader.append($("<table></table")).find("table").append(theadClone);
        $(table).after(stickyHeader);

        var tableHeight = $(table).height();
        var tableWidth = $(table).width() + Number($(table).css("padding-left").replace(/px/ig,
            "")) + Number($(table).css("padding-right").replace(/px/ig, "")) + Number($(
                table).css("border-left-width").replace(/px/ig, "")) + Number($(table).css(
                    "border-right-width").replace(/px/ig, ""));

        var headerCells = $(table).find("thead th");
        var headerCellHeight = $(headerCells[0]).height();
        var no_fixed_support = false;
        if (stickyHeader.css("position") == "Absolute") {
            no_fixed_support = true;
        }

        var stickyHeaderCells = stickyHeader.find("th");
        stickyHeader.css("width", "100%");

        var cellWidth = $(headerCells[0]).width() + 1;
        $(stickyHeaderCells[0]).attr("style", "width:" + cellWidth + "px !important");

        var cutoffTop = $(table).offset().top;
        var cutoffBottom = tableHeight + cutoffTop - headerCellHeight;

        $(window).scroll(function () {
            var currentPosition = $(window).scrollTop();
            if (currentPosition > cutoffTop && currentPosition < cutoffBottom) {
                stickyHeader.removeClass("Hide");
                if (no_fixed_support) {
                    stickyHeader.css("top", currentPosition + "px");
                }
            } else {
                stickyHeader.addClass("Hide");
            }
        });
    });

    const QPS_time = 5000;

    // $.ajax({
    //     url: "/mode_info",
    //     success: function (data) {
    //         document.getElementById("sys_mode").innerText = data;
    //     }
    // });

    function memory() {
        $.ajax({
            url: "/memory_info",
            success: function (data) {
                var memory_num = 0;
                // var mode = document.getElementById("sys_mode").innerText;
                var mode = "AD_Mode"
                if (mode == "AD_Mode" || mode == "Numa_Node") {
                    memory_num = 2;
                } else {
                    memory_num = 1;
                }
                if (mode == "Numa_Node") {
                    for (var i = 0; i < 4; i++) {
                        var flag = i;
                        var b = document.getElementById("PreviewGaugeMeter_" + i).getElementsByTagName("b");
                        if (flag == 1)
                            flag = 2;
                        if (flag == 2)
                            flag = 1;
                        b[1].innerText = "total:" + (data[0][flag] / 1024).toFixed(2) + "G"
                        b[2].innerText = "used:" + ((data[0][flag] - data[1][flag]) / 1024).toFixed(
                            2) + "G"
                        $("#PreviewGaugeMeter_" + i).gaugeMeter({
                            percent: data[2][flag]
                        });
                    }
                } else {
                    for (var i = 0; i < memory_num; i++) {
                        var b;
                        if (mode == "AD_Mode") {
                            b = document.getElementById("PreviewGaugeMeter_" + i).getElementsByTagName("b");
                            $("#PreviewGaugeMeter_" + i).gaugeMeter({
                                percent: data[2][i]
                            });
                        } else if (mode == "1LM") {
                            b = document.getElementById("PreviewGaugeMeter_1lm_" + i).getElementsByTagName("b");
                            $("#PreviewGaugeMeter_1lm_" + i).gaugeMeter({
                                percent: data[2][i]
                            });
                        } else if (mode == "2LM") {
                            b = document.getElementById("PreviewGaugeMeter_2lm_" + i).getElementsByTagName("b");
                            $("#PreviewGaugeMeter_2lm_" + i).gaugeMeter({
                                percent: data[2][i]
                            });
                        }
                        b[1].innerText = "total:" + (data[0][i] / 1024).toFixed(2) + "G"
                        b[2].innerText = "used:" + ((data[0][i] - data[1][i]) / 1024).toFixed(
                            2) + "G"
                        $("#PreviewGaugeMeter_" + i).gaugeMeter({
                            percent: data[2][i]
                        });
                    }
                }
            }
        });
    }

    setInterval(memory, 1000);


    function createdata() {
        var series = new Array();
        var seriesdata = new Array(),
            time = (new Date()).getTime(),
            i;

        for (i = -19; i <= 0; i += 1) {
            var data = [];
            var t = time + i * QPS_time;
            var instance = getredis();
            for (var j = 0; j < instance.length; j++) {
                data.push({
                    x: t,
                    y: instance[j][0]
                });
            }
            seriesdata.push(data);
        }
        var seriesdatas = JSON.parse(JSON.stringify(seriesdata)) //deep copy
        for (m = 0; m < seriesdatas[0].length; m++) {
            var instance_data = [];
            var temp = []
            for (var n = 0; n < seriesdatas.length; n++) {
                temp.push(seriesdatas[n][m]);
            }
            instance_data["name"] = "instance" + m;
            instance_data["data"] = temp;
            series.push(instance_data);
        }
        // return series;   
        if (series.length != 0) {
            return series;
        } else {
            return [{}];
        }
    }

    function getredis() {
        var redis_data;
        $.ajax({
            url: "/redis_info",
            async: false,
            success: function (data) {
                redis_data = data;
                return redis_data;
            }
        });
        return redis_data;
    }

    // qps_chart();

    var qps_chart_flag = false;
    var qps_interval = null;
    var hqps_interval = null;
    var qpsvalue = 0;
    qps_chart();
    instance_qps();

    function monitor_qps() {
        var redis_data;
        $.ajax({
            url: "/redis_info",
            async: false,
            success: function (data) {
                if (!qps_chart_flag && data.length != 0) {
                    qps_chart();
                    instance_qps();
                    qps_chart_flag = true;
                } else if (qps_chart_flag && data.length == 0) {
                    qpsvalue = 0;
                    qps_chart();
                    instance_qps();
                    qps_chart_flag = false;
                    document.getElementById("chart_qps").innerText = "";
                }
            }
        });
    }

    setInterval(monitor_qps, QPS_time);

    Highcharts.setOptions({
        global: {
            useUTC: false
        }
    });

    function qps_chart() {
        qps_chart_flag = true;
        clearInterval(qps_interval);

        Highcharts.chart('container', {
            chart: {
                type: 'line',
                backgroundColor: '#272B30',              
                animation: Highcharts.svg, // don't animate in old IE
                marginRight: 10,
                events: {
                    load: function () {
                        // set up the updating of the chart each second
                        var series = this.series;
                        var loadData = function () {
                            $.ajax({
                                url: "/redis_info",
                                async: false,
                                success: function (data) {                                  
                                    if (data.length != 0 && series.length != 0) {
                                        // qps_chart_flag=true;
                                        var qps = 0;
                                        var x = (new Date()).getTime();
                                        for (var k = 0; k < data.length; k++) {
                                            var lastTime = 0;
                                            if (series[k].data.length > 0) {
                                                lastTime = series[k].data[
                                                    series[k].data.length -
                                                    1].x
                                            }
                                            if (x > lastTime) {
                                                series[k].addPoint([x, data[k][
                                                    0]], true, true)
                                            }
                                            qps += data[k][0];
                                        }
                                        qpsvalue = (qps / data.length).toFixed(2);
                                        // document.getElementById("chart_qps").innerText = "average_qps: " + (qps / data.length).toFixed(2)+"\xa0\xa0\xa0"+ "instance_num: "+ data.length;
                                        document.getElementById("chart_qps").innerText = "instance_num: " + data.length;
                                    }
                                }
                            });
                        };
                        qps_interval = setInterval(loadData, QPS_time);
                    }
                }
            },
            credits: {
                enabled: false
            },

            time: {
                useUTC: false
            },

            title: {
                text: null
            },
            xAxis: {
                type: 'datetime',
                tickPixelInterval: 150,
                gridLineColor: '#373B40',
                gridLineWidth: 1,
                lineColor: '#373B40',
                labels: {
                    style: {
                        color: '#808080',
                        fontSize: '11px',
                    }
                }
            },
            yAxis: {
                title: {
                    text: 'QPS',
                    style: {
                        color: '#808080',
                        fontSize: '11px',
                    }
                },
                lineColor: '#373B40',
                lineWidth: 1,
                gridLineColor: '#373B40',
                plotLines: [{
                    value: 0,
                    width: 1,
                    color: '#808080'
                }],
                labels: {
                    style: {
                        color: '#808080',
                        fontSize: '11px',
                    }
                },
                tickPositioner: function () {
                    var positions = [],
                        tick = 0,
                        max = 0;
                    if (this.dataMax <= 1000) {                      
                        max = (Math.floor(this.dataMax / 100) + 1) * 100 + Math.ceil((Math
                            .floor(this.dataMax / 100) + 1) / 4) * 100;
                    } else if (this.dataMax > 1000 && this.dataMax <= 10000) {                      
                        max = (Math.floor(this.dataMax / 1000) + 1) * 1000 + Math.ceil((Math
                            .floor(this.dataMax / 1000) + 1) / 4) * 1000;
                    } else if (this.dataMax > 10000) {                      
                        max = (Math.floor(this.dataMax / 2000) + 1) * 2000 + Math.ceil((Math
                            .floor(this.dataMax / 2000) + 1) / 4) * 2000;
                    }
                    increment = Math.ceil(max / 5);
                    for (tick; tick <= max; tick += increment) {
                        positions.push(tick);
                    }
                    return positions;
                }
            },
            tooltip: {
                headerFormat: '<b>{series.name}</b><br/>',
                pointFormat: '{point.x:%Y-%m-%d %H:%M:%S}<br/>{point.y:.2f}'
            },
            legend: {
                enabled: true,
                itemStyle: {
                    color: '#808080',
                    fontSize: '11px',
                }
            },
            exporting: {
                enabled: false
            },
            series: createdata()
        });
    }

    function instance_qps() {
        clearInterval(hqps_interval);
        Highcharts.chart('instance_qps', {
            chart: {
                type: 'column',
                backgroundColor: '#272B30',
                events: {
                    load: function () {
                        var series = this.series[0];
                        var loadData = function () {
                            var data = [];
                            data.push(['average_qps', parseInt(qpsvalue)]);
                            series.setData(data);
                        }
                        hqps_interval = setInterval(loadData, QPS_time);
                    }
                },
            },
            credits: {
                enabled: false
            },
            exporting: {
                enabled: false
            },
            title: {
                text: null
            },
            xAxis: {
                type: 'category',
                gridLineColor: '#373B40',
                gridLineWidth: 1,
                lineColor: '#373B40',
                labels: {
                    style: {
                        color: '#808080',
                        fontSize: '15px',
                    }
                }
            },
            yAxis: {
                title: {
                    text: null
                },
                lineColor: '#373B40',
                lineWidth: 1,
                gridLineColor: '#373B40',
                plotLines: [{
                    value: 0,
                    width: 1,
                    color: '#808080'
                }],
                labels: {
                    style: {
                        color: '#808080',
                        fontSize: '12px',
                    }
                },
                tickPositioner: function () {
                    var positions = [],
                        tick = 0,
                        max = 0;
                    max = 70000
                    increment = Math.ceil(max / 5);
                    for (tick; tick <= max; tick += increment) {
                        positions.push(tick);
                    }
                    return positions;
                }

            },
            legend: {
                enabled: false
            },
            plotOptions: {
                series: {
                    borderWidth: 0,
                    dataLabels: {
                        enabled: true,
                        shadow: false
                        // format: '{point.y:.1f}%'
                    },

                }
            },
            series: [{
                name: "average_qps",
                colorByPoint: true,
                data: [{
                    name: "average_qps",
                    y: parseInt(qpsvalue),
                },]
            }],
        });

    }

    document.getElementById("show-log").onclick = function () {
        if (document.getElementById("log_result").style.visibility == "") {
            document.getElementById("log_result").style.visibility = "visible"
            document.getElementById("log_result").style.display = "block"
            result_latency();
            result_qps_memory();
        } else {
            document.getElementById("log_result").style.visibility = "hidden"
            document.getElementById("log_result").style.display = "none"
        }
    }

    function results_data() {
        var series = new Array();
        $.ajax({
            url: "/result_info",
            async: false,
            success: function (data) {
                if (data != null) {
                    var name = ["latency", "qps", "used_memory", "used_nvm"]
                    var type = ["column", "spline", "column", "column"]
                    for (var i = 0; i < data.length; i++) {
                        var temp = [];
                        temp["name"] = name[i];
                        temp["type"] = type[i];
                        temp["data"] = data[i];
                        if (i == 1) {
                            temp["yAxis"] = 1;
                        }
                        series.push(temp);
                    }
                }
            }
        });
        return series;
    }

    function result_latency() {
        var result_data = results_data()
        var cagname = new Array();
        for (var i = 0; i < result_data[0].data.length; i++) {
            cagname.push("instance" + i);
        }
        Highcharts.chart('result_latency', {
            chart: {
                type: 'column',
                backgroundColor: '#272B30'
            },
            title: {
                text: null
            },

            xAxis: {
                categories: cagname,
                crosshair: true
            },
            yAxis: {
                min: 0,
                title: {
                    text: 'latency'
                },
                lineColor: '#373B40',
                lineWidth: 1,
                gridLineColor: '#373B40',
                plotLines: [{
                    value: 0,
                    width: 1,
                    color: '#808080'
                }],
                labels: {
                    format: '{value} S',
                    style: {
                        color: '#808080',
                        fontSize: '11px',
                    }
                }
            },
            tooltip: {
                // head + 每个 point + footer 拼接成完整的 table
                headerFormat: '<span style="font-size:10px">{point.key}</span><table>',
                pointFormat: '<tr><td style="color:{series.color};padding:0">{series.name}: </td>' +
                    '<td style="padding:0"><b>{point.y:.1f} s</b></td></tr>',
                footerFormat: '</table>',
                shared: true,
                useHTML: true
            },
            plotOptions: {
                column: {
                    borderWidth: 0
                }
            },
            legend: {
                enabled: true,
                itemStyle: {
                    color: '#808080',
                    fontSize: '11px',
                }
            },
            exporting: {
                enabled: false
            },
            credits: {
                enabled: false
            },
            series: [result_data[0]]
        });
    }


    function result_qps_memory() {
        var result_data = results_data()
        var cagname = new Array();
        for (var i = 0; i < result_data[2].data.length; i++) {
            cagname.push("instance_num: " + (i + 1));
        }
        Highcharts.setOptions({
            colors: ['#66AA00', '#FE3912', '#7cb5ec']
        });
        Highcharts.chart('result_qps_mem', {
            chart: {
                zoomType: 'xy',
                backgroundColor: '#272B30',
            },
            title: {
                text: null
            },
            xAxis: {
                categories: cagname,
                crosshair: true
            },
            yAxis: [{
                min: 0,
                title: {
                    text: 'memory,nvm',
                },
                lineColor: '#373B40',
                lineWidth: 1,
                gridLineColor: '#373B40',
                plotLines: [{
                    value: 0,
                    width: 1,
                    color: '#808080'
                }],
                labels: {
                    format: '{value}G',
                    color: '#808080',
                    fontSize: '11px',
                }
            }, { // Secondary yAxis
                min: 0,
                title: {
                    text: 'QPS',
                },
                lineColor: '#373B40',
                lineWidth: 1,
                gridLineColor: '#373B40',
                plotLines: [{
                    value: 0,
                    width: 1,
                    color: '#808080'
                }],
                labels: {
                    format: '{value}',
                    color: '#808080',
                    fontSize: '11px',
                },
                opposite: true
            }],
            tooltip: {
                // head + 每个 point + footer 拼接成完整的 table
                headerFormat: '<span style="font-size:10px">{point.key}</span><table>',
                pointFormat: '<tr><td style="color:{series.color};padding:0">{series.name}: </td>' +
                    '<td style="padding:0"><b>{point.y:.1f}</b></td></tr>',
                footerFormat: '</table>',
                shared: true,
                useHTML: true
            },
            plotOptions: {
                column: {
                    borderWidth: 0
                }
            },
            legend: {
                enabled: true,
                itemStyle: {
                    color: '#808080',
                    fontSize: '11px',
                }
            },
            exporting: {
                enabled: false
            },
            credits: {
                enabled: false
            },
            series: [result_data[2], result_data[3], result_data[1]]
        });
    }


    //  document.getElementById("stop-server").onclick=function(){
    //   console.log(111)
    //   $.ajax({
    //        url: "/stop_server",
    //      async: false,
    //    success: function (data) {
    // alert(data)
    //  }
    //  });
    // }

    // document.getElementById("run-test").onclick=function(){
    //   $.ajax({
    //     url: "/run_test",
    //   async: false,
    // success: function (data) {
    //   alert(data)
    //  }
    //  });
    // }
});
