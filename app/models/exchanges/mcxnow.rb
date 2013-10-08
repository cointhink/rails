require "rexml/document"
class Exchanges::Mcxnow < Exchanges::Base
  def depth_poll(conn, from_currency, to_currency)
    # covers two markets, from/to and to/from
    url = "https://mcxnow.com/orders?cur=#{from_currency.upcase}"
    xml = REXML::Document.new(conn.get(url).body)
    depth = {'asks' => [], 'bids' => []}
    xml.elements['/doc/buy'].each do |bid|
      offer = price_quantity(bid)
      depth['bids'] << offer if offer
    end
    xml.elements['/doc/sell'].each do |ask|
      offer = price_quantity(ask)
      depth['asks'] << offer if offer
    end
    depth
  end

  private
  def price_quantity(doc)
    price_node = doc.elements['p']
    quantity_node = doc.elements['c1']
    if price_node && quantity_node
      [price_node.text.to_f, quantity_node.text.to_f]
    end
  end
end