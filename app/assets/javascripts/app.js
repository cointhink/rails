function setup(data, percentages, strategies, strategy_ids) {

  var options = {
    series: {
        lines: { show: true },
        points: { show: true },
    },
    xaxis: { mode: 'time',
             timezone: 'browser',
             timeformat: "%m/%d %I%p",
             tickSize: [1, "hour"]},
    legend: { position: 'nw',
              container: '#legend'},
    yaxis: { tickFormatter: formatter},
    grid: {clickable: true}
  };

  var dset = []
  dset.push({label: "profit $",
             data: strategies,
             yaxis: 2,
             color: 'grey',
             bars: {show: false},
             lines: {show: false},
             points: {radius: 8}})

  dset.push({label: "profit %",
             data: percentages,
             yaxis: 3,
             color: 'grey',
             bars: {show: false, barWidth: 3},
             lines: {show: false},
             points: {radius: 5, fill: true, fillColor: 'grey'}})

  var color_index = 0;
  for(var market_id in data) {
    dset.push({label: data[market_id][0]+" ask",
               data: data[market_id][2],
               color: color_index,
               points: {radius: 5}})
    dset.push({label: data[market_id][0]+" bid",
               data: data[market_id][1],
               color: color_index,
               })
    color_index = color_index + 1;
  }

  $.plot($("#chart"), dset, options);
  $("#chart").bind('plotclick', function(e,p,i){strategyClick(e,p,i,strategy_ids)})
}

function chart_setup(data) {

  var options = {
    series: {
        lines: { show: true },
        points: { show: true },
    },
  };

  var dset = []
  for(var id in data) {
    dset.push({label: data[id][0],
               data: data[id][1],
               })
  }

  console.log(dset)
  $.plot($("#chart"), dset, options);
}

function strategyClick(event, point, item, strategy_ids) {
      console.log(item.dataIndex);
      console.log(item.seriesIndex);
      if(item.seriesIndex == 0) {
        window.location = "/strategies/"+strategy_ids[item.dataIndex]
      }
}

function formatter(val, axis) {
  if(axis.n == 1)
    return "$"+val.toFixed(2);
  if(axis.n == 2)
    return "$"+val.toFixed(2);
  if(axis.n == 3)
    return val.toFixed(2)+"%";
}
