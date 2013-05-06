class ExchangeRun < ActiveRecord::Base
  belongs_to :snapshot
  belongs_to :exchange
  has_many :depth_runs, :dependent => :destroy

  attr_accessible :snapshot, :exchange, :duration_ms, :start_at
end
