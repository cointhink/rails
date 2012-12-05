require 'test_helper'

class StageTest < ActiveSupport::TestCase
  def setup
    ask_market = Market.create(from_currency: 'usd', to_currency: 'btc',
                           fee_percentage: 0.5)
    depth_run = ask_market.depth_runs.create
    @stage = Stage.create
    trade = @stage.trades.create({
      :balance_in => Balance.make_usd(20)
      })
    trade.create_offer({
      price: 12.5, quantity: 3.1,
      market: ask_market, currency: 'usd'
      })
  end

  test "buy" do
    buy = @stage.buy
    assert buy.balance_in.usd?
  end
end
