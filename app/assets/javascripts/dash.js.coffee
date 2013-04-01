# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

@slider_setup = ->
  console.log('slider setup')
  exchanges = []
  $('ul.exchanges li').each((idx,el)->
      exg = {}
      exg.name = $(el).attr('name')
      exchanges.push(exg)
  )
  console.log(exchanges)