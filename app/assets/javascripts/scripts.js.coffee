# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(->
  $('.scripts-list #add').click((e) ->
    $('.scripts-list #add').hide()
    $('.scripts-list #fields').show()
    $('.scripts-list input[name="name"]').focus()
  )
  $('.scripts-list form').submit((e) ->
    console.log("posting")
    console.log(e)
    $.post('/scripts', {})
  )
)
