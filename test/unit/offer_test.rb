require 'test_helper'

class OfferTest < ActiveSupport::TestCase
  test "price and quantity" do
    offer = setup_valid_offer(price: 12.5, quantity: 3.1)
    assert_equal 12.5, offer.price
    assert_equal 3.1, offer.quantity
  end

  test "rate" do
    offer = setup_valid_offer(price: 12.5, quantity: 3.1)
    rate = offer.rate('usd')
    assert_equal 12.5, rate.amount
    assert_equal 'usd', rate.currency
  end

  def setup_valid_offer(params = {})
    market = Market.create(from_currency: 'usd', to_currency: 'btc',
                           fee_percentage: 0.5)
    depth_run = market.depth_runs.create
    params = {price: 12.5, quantity: 3.1, market: market, currency: 'usd'}.merge(params)

    depth_run.offers.create(params)
  end
end
