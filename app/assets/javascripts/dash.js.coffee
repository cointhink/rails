# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

@slider_setup = ->
  @exchanges = {}
  $('ul.exchanges li').each (idx,el)->
    exg = html_to_obj(el)
    dust.render 'exchange-button', exg, (err,out)->
      if err
        console.log(err)
      else
        $(el).replaceWith(out)
    exchanges[exg['name']] = exg
  $('ul.exchanges li').click((event)-> exg_toggle(event); load())
  @chart = chart_setup()
  load()

html_to_obj = (el)->
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

chart_setup = ->
  @data = [1,2,3]
  d3.select("div.chart").append("svg")
    .attr("class", "chart")
    .attr("width", 420)
    .attr("height", 25 * data.length);

load = ->
  names = jQuery.map(exchanges, (idx,o)-> exchanges[o]["name"] if exchanges[o].active )
  json_rpc('arbitrage', {exchanges:names})

@chart_freshen = ->
  chart.selectAll("rect")
       .data(data)
       .enter().append("rect")
       .attr("x", (data, idx) ->
                 return idx * 25 )
       .attr("y", (data, idx) ->
                 75 - data*10)
       .attr("height", (data, idx)->
                 data*10 )
       .attr("width", 20)

json_rpc = (method, params) ->
  params.jsonrpc = "2.0"
  params.method = method
  url = "/api/v0/jsonrpc"
  console.log(params)
  $.ajax({type:"post", url:url, data:JSON.stringify(params), contentType:"application/json", success: json_done})

json_done = ->
