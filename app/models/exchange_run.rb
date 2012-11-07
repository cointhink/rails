class ExchangeRun < ActiveRecord::Base
  belongs_to :snapshot
  belongs_to :exchange
  belongs_to :depth_run

  attr_accessible :snapshot, :exchange, :depth_run, :duration_ms, :start_at
end
