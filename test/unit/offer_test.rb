require 'test_helper'

class OfferTest < ActiveSupport::TestCase
  test "price and quantity" do
    offer = setup_valid_offer(price: 12.5, quantity: 3.1)
    assert_equal 12.5, offer.price
    assert_equal 3.1, offer.quantity
  end

  test "balance" do
    offer = setup_valid_offer(price: 12.5, quantity: 3.1)
    balance = offer.balance
    assert_equal 12.5, balance.amount
    assert_equal 'btc', balance.currency
  end

  test "market_fee" do
    offer = setup_valid_offer
    assert_equal 0.005, offer.market_fee
  end

  test "balance_with_fee" do
    offer = setup_valid_offer
    balance = offer.balance_with_fee
    assert_in_delta 12.43, balance.amount, 0.01
    assert_equal 'btc', balance.currency
  end

  def setup_valid_offer(params = {})
    market = Market.create(from_currency: 'usd', to_currency: 'btc',
                           fee_percentage: 0.5)
    depth_run = market.depth_runs.create
    params = {price: 12.5, quantity: 3.1}.merge(params)

    depth_run.offers.create(params)
  end
end
