var cointhink=require("cointhink")

cointhink.db.load(function(storage){
  cointhink.exchange('mtgox', function(ticker){
    cointhink.log('mtgox ticker reads: '+ticker.last.value)
  })
})