require 'test_helper'

class DashControllerTest < ActionController::TestCase

  test "html" do
    get :chart, {pair: "btcusd"}
    assert_response :success
  end

  test "json" do
    get :chart, {pair: "btcusd", :format => :json}
    assert_response :success
    response_hash = JSON.parse(@response.body)
  end
end
