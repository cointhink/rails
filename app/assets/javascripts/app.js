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

  console.log(strategies)
  dset.push({label: "profit",
             data: strategies,
             yaxis: 2,
             color: 'grey',
             bars: {show: true},
             lines: {show: false}})

  $.plot($("#chart"), dset, options);
}