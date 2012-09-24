function setup(data) {
  console.log('setup')

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
  for(var market_id in data) {
    dset.push({label: data[market_id][0]+" ask",
               data: data[market_id][2]})
    dset.push({label: data[market_id][0]+" bid",
               data: data[market_id][1]})
  }

  console.log(dset)
  $.plot($("#chart"), dset, options);
}