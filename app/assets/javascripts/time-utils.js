// fixup the timestamps with the browser's timezone
function time_fixups() {
  $('time').each(function(){
    var datetime = new XDate($(this).attr('datetime'))
    var formatted = datetime.toString($(this).attr('data-format'))
    $(this).html(formatted)
  })
  var timezone_name = (new XDate()).toString().slice(-4,-1) //hack to get the full timezone name
  $('.local_timezone').html(timezone_name)
}
