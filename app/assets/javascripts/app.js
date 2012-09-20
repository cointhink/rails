function setup(d1, d2) {
  console.log('setup')
  console.log(d1)
  console.log(d2)

  var options = {
    series: {
        lines: { show: true },
        points: { show: true },
    },
    xaxis: { mode: 'time',
             timeformat: "%m/%d %M:%H",
             tickSize: [1, "hour"]}
  };

  $.plot($("#chart"), [
      { label: "d1",  data: d1},
      { label: "d2",  data: d2}
  ], options);
}