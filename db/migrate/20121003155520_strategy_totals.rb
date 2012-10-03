class StrategyTotals < ActiveRecord::Migration
  def up
    add_column :strategies, :balance_in_id, :integer
    add_column :strategies, :balance_out_id, :integer
    add_column :strategies, :potential_id, :integer

    puts "Calculating #{Strategy.all.count} strategy totals"
    Strategy.all.each do |strategy|
      strategy.balance_in = strategy.balance_in_calc
      strategy.balance_out = strategy.balance_out_calc
      strategy.potential = strategy.potential_calc
      strategy.save
    end
  end
end
