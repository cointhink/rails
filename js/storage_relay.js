var zmq = require('zmq'),
    sock = zmq.socket('rep');
var r = require('rethinkdb'),
    redis = require('redis').createClient()


r.connect({host:'localhost', port:28015, db:'cointhink'},
  function(err, conn) {
  sock.bindSync('tcp://172.16.42.1:3003');
  console.log('storage relay on 3003')

  sock.on('message', function(data){
    try {
      var message = JSON.parse(data)
      var payload = message.payload
      var fullname = message.username+"/"+message.scriptname

      r.table('scripts').get(fullname).run(conn, function(err, doc){
        if(err){
          console.log(err)
          respond({"status":"dberr"})
        } else {
          if(doc){
            if(doc.key == message.key){
              var storage = doc.storage
              if(payload.action == 'get'){
                var value = storage[payload.key]
                console.log(fullname+' get '+payload.key+' '+value)
                respond({"status":"ok", "payload":value})
              }
              if(payload.action == 'set'){
                console.log(fullname+' set '+payload.key+' '+payload.value)
                storage[payload.key] = payload.value
                r.table('scripts').get(fullname).update({storage:storage}).run(conn, function(status){
                  respond({"status":"ok", "payload":status})
                })
              }
              if(payload.action == 'load'){
                console.log(fullname+' load storage '+JSON.stringify(storage))
                respond({"status":"ok", "payload":storage})
              }
              if(payload.action == 'store'){
                console.log(fullname+' store storage '+JSON.stringify(payload.storage))
                r.table('scripts').get(fullname).update({storage:payload.storage}).run(conn, function(status){
                  respond({"status":"ok", "payload":status})
                })
              }
              if(payload.action == 'trade'){
                console.log(fullname+' trade '+payload.exchange+' '+payload.market+' '+payload.buysell)
                var hashname = payload.exchange.toLowerCase()+"-ticker-"+
                               payload.market.toUpperCase()+
                               payload.currency.toUpperCase()
                redis.hgetall(hashname, function(err,ticker){
                  var response = trade(payload, doc.inventory, ticker)
                  if(response.status == 'ok'){
                    r.table('scripts').get(fullname)('trades').
                    prepend(response.payload.trade).run(conn, function(err){
                      if(err) console.log(err)
                      r.table('scripts').get(fullname).
                      update({inventory:doc.inventory}).run(conn, function(err){
                        if(err) console.log(err)
                        var trade_msg = "["+payload.exchange+"] "+payload.buysell+" "+payload.quantity+payload.market+"@"+payload.amount+payload.currency
                        r.table('signals').insert({name:fullname,
                                                   time:(new Date()).toISOString(),
                                                   type:payload.action,
                                                   msg:trade_msg}).run(conn, function(err){if(err)console.log(err)})
                        respond(response)
                      })
                    })
                  } else {
                    respond(response)
                  }
                })
              }
            } else {
              console.log(fullname+" bad key!")
              respond({"status":"badkey"})
            }
          } else {
            console.log(fullname+" empty doc!")
            respond({"status":"nodoc"})
          }
        }
      })
    } catch (ex) {
      console.log(ex+' ignoring "'+data+'"')
      respond({"status":"garbled"})
    }
  })

  function respond(payload){
    console.dir(payload)
    sock.send(JSON.stringify(payload))
  }

  //trade('mtgox','btc',4,'buy','usd',92)
  //trade('mtgox','btc',4,'sell','usd',97)
  function trade(payload, inventory, ticker){
    var result // return value
    var ticker_age_sec = ((new Date()) - new Date(ticker.now))/1000
    if(ticker_age_sec < 120){
      var price_diff_ratio = (Math.abs(payload.amount - ticker.value))/ticker.value
      if(price_diff_ratio <= 0.01){
        if(payload.buysell == 'buy') {
          var on_hand = inventory[payload.currency]
          if(on_hand){
            var price = (payload.amount * payload.quantity)
            if(on_hand >= price) {
                inventory[payload.currency] -= price
                result = {"status":"ok", payload: {trade:payload, inventory:inventory}}
            } else {
              result = {"status":"err", payload:""+on_hand+payload.currency+" is in sufficient for "+price}
            }
          } else {
            result = {"status":"err", payload:"no "+payload.currency+" in inventory"}
          }
        } else if (payload.buysell == 'sell') {
          var on_hand = inventory[payload.market]
          if(on_hand){
            if(on_hand >= payload.quantity){
              inventory[payload.market] -= payload.quantity
              result = {"status":"ok", payload: {trade:payload, inventory:inventory}}
            } else {
              result = {"status":"err", payload:""+on_hand+payload.market+" is in sufficient for "+payload.quantity}
            }
          } else {
            result = {"status":"err", payload:"no "+payload.market+" in inventory"}
          }
        }
      } else {
        result = {"status":"err", payload:"price of "+payload.amount+" is more than 1% away from exchange "+payload.exchange+" price "+ticker.value}
      }
    } else {
      result = {"status":"err", payload:"exchange "+payload.exchange+" price too old ("+age+" secs) validate this try. please try again."}
    }

    return result
  }

})
