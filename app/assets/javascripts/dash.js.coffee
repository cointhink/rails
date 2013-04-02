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
  $('ul.exchanges li').click(exg_toggle)
  @chart = chart_setup()

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
    
@chart_freshen = ->
  chart.selectAll("rect")
       .data(data)
       .enter().append("rect")
       .attr("y", (data, idx) -> 
                 return idx * 25 )
       .attr("width", (data, idx)->
                 data*10 )
       .attr("height", 20)

