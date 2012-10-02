class DepthRun < ActiveRecord::Base
  belongs_to :market
  has_many :offers
  # attr_accessible :title, :body

  def self.all_offers(markets)
    run_ids = markets.map{|market| market.depth_runs.last.id}
    Offer.where("depth_run_id in (?)", run_ids)
  end
end
