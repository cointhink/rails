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
    $.post('/scripts', {})
  )

  $('.scripts-edit a.url').click((e) ->
    e.preventDefault()
    $('.scripts-edit a.text').removeClass('selected-source')
    $('.scripts-edit a.url').addClass('selected-source')
    $('.scripts-edit input.url').show()
    $('.scripts-edit textarea').hide()
  )
  $('.scripts-edit a.text').click((e) ->
    e.preventDefault()
    $('.scripts-edit a.text').addClass('selected-source')
    $('.scripts-edit a.url').removeClass('selected-source')
    $('.scripts-edit input.url').hide()
    $('.scripts-edit textarea').show()
  )
)

this.scripts_edit_setup = (script, body) ->
  editor = ace.edit("editor");
  editor.setTheme("ace/theme/clouds");
  editor.getSession().setMode("ace/mode/javascript");
  editor.getSession().setUseSoftTabs(true);
  editor.getSession().setValue(body);
  $('form').submit((evt) ->
    $('textarea').val(editor.getSession().getValue())
  )
  editor.focus()
