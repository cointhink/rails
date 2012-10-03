function setup(data, strategies) {

  var options = {
    series: {
        lines: { show: true },
        points: { show: true },
    },
    xaxis: { mode: 'time',
             timeformat: "%m/%d %I%p",
             tickSize: [1, "hour"]},
    legend: { position: 'nw',
              container: '#legend'}
  };

  var dset = []
  dset.push({label: "potential",
             data: strategies,
             yaxis: 2,
             color: 'grey',
             bars: {show: false},
             lines: {show: false},
             points: {radius: 8}})

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