require 'test_helper'

class BalanceTest < ActiveSupport::TestCase
  test "make_usd" do
    balance = Balance.make_usd(10)
    assert_equal 10, balance.amount
    assert_equal 'usd', balance.currency
  end

  test "make_btc" do
    balance = Balance.make_btc(8)
    assert_equal 8, balance.amount
    assert_equal 'btc', balance.currency
  end

  test "multiplication" do
    balance = Balance.make_btc(8)
    answer = balance * 2
    assert_equal 16, answer.amount
    assert_equal 'btc', answer.currency
  end

  test "division" do
    balance = Balance.make_btc(8)
    answer = balance / 2
    assert_equal 4, answer.amount
    assert_equal 'btc', answer.currency
  end
end
