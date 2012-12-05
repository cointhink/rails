require 'test_helper'

class StageTest < ActiveSupport::TestCase
  def setup
    ask_market = Market.create(from_currency: 'usd', to_currency: 'btc',
                           fee_percentage: 0.5)
    bid_market = Market.create(from_currency: 'btc', to_currency: 'usd',
                           fee_percentage: 0.2)

    @stage = Stage.create({
      :balance_in => Balance.make_usd(21),
      :potential => Balance.make_usd(0.5)
      })
    buy_trade = @stage.trades.create({
      :balance_in => Balance.make_usd(20)
      })
    buy_trade.create_offer({
      price: 11, quantity: 3,
      market: ask_market, currency: 'usd'
      })
    sell1_trade = @stage.trades.create({
      :balance_in => Balance.make_btc(1.809090)
      })
    sell1_trade.create_offer({
      price: 12.5, quantity: 3.1,
      market: bid_market, currency: 'usd'
      })
  end

  test "buy" do
    buy = @stage.buy
    assert buy.balance_in.usd?
  end

  test "balance_in_calc" do
    balance = @stage.balance_in_calc
    assert_equal 20, balance.amount
  end

  test "profit_percentage" do
    percentage = @stage.profit_percentage
    assert_equal 2, percentage.floor
  end
end
