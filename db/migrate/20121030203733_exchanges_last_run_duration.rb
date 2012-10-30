class ExchangesLastRunDuration < ActiveRecord::Migration
  def change
    add_column :exchanges, :last_http_duration_ms, :integer
  end
end
