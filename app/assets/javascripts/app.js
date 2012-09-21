function setup(data) {
  console.log('setup')

  var options = {
    series: {
        lines: { show: true },
        points: { show: true },
    },
    xaxis: { mode: 'time',
             timeformat: "%m/%d %I%p",
             tickSize: [1, "hour"]}
  };

  var dset = []
  for(var market_id in data) {
    dset.push({label: data[market_id][0]+" ask",
               data: data[market_id][2]})
    dset.push({label: data[market_id][0]+" bid",
               data: data[market_id][1]})
  }

  var plusdiffs = []
  var minusdiffs = []
  for(var mdata in data[0][2]) {
    var point = data[0][2][mdata]
    var other_point = data[1][2][mdata]
    var diff = point[1]-other_point[1]
    if(diff > 0) {
      plusdiffs.push([point[0], diff])
    } else {
      minusdiffs.push([point[0], diff])
    }
  }
  dset.push({label: 'mtgox yes', data: plusdiffs, yaxis: 2})
  dset.push({label: 'bitstamp yes', data: minusdiffs, yaxis: 2})

  console.log(dset)
  $.plot($("#chart"), dset, options);
}