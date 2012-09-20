function setup(d1, d2) {
  console.log('setup')
  console.log(d1)
  console.log(d2)

  var options = {
    series: {
        lines: { show: true },
        points: { show: true }
    }
  };

  $.plot($("#chart"), [
      { label: "d1",  data: [d1]},
      { label: "d2",  data: [d2]}
  ], options);
}