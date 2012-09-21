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
  for(var datum in data) {
    dset.push({label: data[datum][0]+" bid",
               data: data[datum][1]})
    dset.push({label: data[datum][0]+" ask",
               data: data[datum][2]})
  }

  console.log(dset)
  $.plot($("#chart"), dset, options);
}