// fixup the timestamps with the browser's timezone
function time_fixups() {
  $('time').each(function(){
    var datetime = new XDate($(this).attr('datetime'))
    var formatted = datetime.toString($(this).attr('data-format'))
    $(this).html(formatted)
  })
  var timezone_letters = (new XDate()).toString().match(/\(([A-Z]).*([A-Z]).*([A-Z]).*\)/)
  var timezone_name = timezone_letters[1]+timezone_letters[2]+timezone_letters[3] //hack to get the full timezone name
  $('.local_timezone').html(timezone_name)
}
