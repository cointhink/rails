# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

@slider_setup = ->
  @exchanges = {}
  $('ul.exchanges li').each (idx,el)->
    exg = spans_to_json(el)
    dust.render 'exchange-button', exg, (err,out)->
      if err
        console.log(err)
      else
        $(el).replaceWith(out)    
    exchanges[exg['name']] = exg
  $('ul.exchanges li').click(exg_toggle)

spans_to_json = (el)->
  record = {}
  $("span", el).each (idx,el)->
    j = $(el)
    record[j.attr('key')] = j.html()
  record

exg_toggle = (event) ->
  el = $(event.target)
  name = el.attr('name')
  exchange = exchanges[name]
  exchange.active = !exchange.active
  if exchange.active
    el.addClass('btn-success')
  if !exchange.active
    el.removeClass('btn-success')
