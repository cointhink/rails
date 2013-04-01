# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

@slider_setup = ->
  @exchanges = []
  $('ul.exchanges li').each (idx,el)->
      exg = spans_to_json(el)
      console.log(exg)
      dust.render('exchange-button', exg, (err,out)->
        if err
          console.log(err)
        else
          $(el).replaceWith(out)    
      )
      exchanges.push(exg)

spans_to_json = (el)->
  record = {}
  $("span", el).each (idx,el)->
                       j = $(el)
                       record[j.attr('key')] = j.html()
  record