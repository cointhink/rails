var zmq = require('zmq'),
    sock = zmq.socket('rep');
var r = require('rethinkdb'),
    redis = require('redis').createClient()


r.connect({host:'localhost', port:28015, db:'cointhink'},
  function(err, conn) {

  conn.addListener('error', function(e) {
    console.log("rethinkdb error: "+e)
  })

  conn.addListener('close', function() {
    console.log("rethinkdb closed")
  })

  redis.on("error", function (err) {
        console.log("Redis Error " + err);
  })

  sock.on('message', function(data){
    console.log("REQ: "+data)
    try {
      var message = JSON.parse(data)
      var payload = message.payload
      var fullname = message.username+"/"+message.scriptname

      console.log("rethink load called on "+fullname)
      r.table('scripts').get(fullname).run(conn, function(err, doc){
        if(err){
          console.log('rethink load error: '+err)
          respond({"status":"dberr"})
        } else {
          console.log(fullname+' rethink doc loaded')
          if(doc){
            if(doc.key == message.key){
              var storage = doc.storage
              if(payload.action == 'get'){
                var value = storage[payload.key]
                console.log(fullname+' get '+payload.key+' '+value)
                respond({"status":"ok", "payload":value})
              } else if(payload.action == 'set'){
                console.log(fullname+' set '+payload.key+' '+payload.value)
                storage[payload.key] = payload.value
                var update_hash = {}
                update_hash[payload.key] = payload.value
                r.table('scripts').get(fullname).
                  update({storage:update_hash}).run(conn, function(status){
                  console.log(fullname+' set '+payload.key+' '+payload.value+' = '+status)
                  respond({"status":"ok", "payload":status})
                })
              } else if(payload.action == 'load'){
                console.log(fullname+' load storage, returning '+JSON.stringify(storage))
                respond({"status":"ok", "payload":storage})
              } else if(payload.action == 'store'){
                console.log(fullname+' store storage '+JSON.stringify(payload.storage))
                if(typeof(payload.storage) == 'object'){
                  r.table('scripts').get(fullname).
                    update({storage:payload.storage}).run(conn, function(status){
                    console.log(fullname+' store storage result '+status)
                    respond({"status":"ok", "payload":status})
                  })
                } else {
                  respond({"status":"err", "msg":"storage must be an object"})
                }
              } else if(payload.action == 'trade'){
                console.log(fullname+' trade '+payload.exchange+' '+payload.market+' '+payload.buysell)
                var hashname = payload.exchange.toLowerCase()+"-ticker-"+
                               payload.market.toUpperCase()+
                               payload.currency.toUpperCase()
                redis.hgetall(hashname, function(err,ticker){
                  console.log('redis return '+JSON.stringify(ticker))
                  var response = trade(payload, doc.inventory, ticker)
                  if(response.status == 'ok'){
                    console.log("prepending trades with "+JSON.stringify(response.payload.trade))
                    r.table('scripts').get(fullname)('trades').
                    prepend(response.payload.trade).run(conn, function(err, trades){
                      console.log('prepend trades done. size '+trades.length)
                      if(err) { console.log('rethink prepend error: '+err) }
                      console.log('updating inventory with '+JSON.stringify(doc.inventory))
                      r.table('scripts').get(fullname).
                      update({inventory:doc.inventory}).run(conn, function(err){
                        console.log('update inventory done')
                        if(err) { console.log('rethink update inventory error: '+err) }
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
              } else {
                respond({"status":"err", "msg":"unknown action "+payload.action})
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
      console.log(ex+' bad JSON "'+data+'"')
      respond({"status":"garbled"})
    }

  })

  sock.connect('tcp://127.0.0.1:3004');
  console.log('storage relay connected to dealer on 3004')

  function respond(payload){
    var data = JSON.stringify(payload)
    console.log('REP: '+data)
    sock.send(data)
  }

  //trade('mtgox','btc',4,'buy','usd',92)
  //trade('mtgox','btc',4,'sell','usd',97)
  //payload: exchange, market, quantity, buysell, currency, amount, cb
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
                inventory[payload.market] += payload.quantity
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
              if(typeof(inventory[payload.currency]) == "undefined") {  inventory[payload.currency] = 0}
              inventory[payload.currency] += (payload.quantity * payload.amount)
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
      result = {"status":"err", payload:"exchange "+payload.exchange+" price too old ("+ticker_age_sec+" secs). please try again."}
    }

    return result
  }

})
