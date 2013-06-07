module Routy
  private
  def routes_match_count(path)
    matching_routes = Rails.application.routes.routes.simulator.simulate(path)
    matching_routes.memos ? matching_routes.memos.size : 0
  end
end