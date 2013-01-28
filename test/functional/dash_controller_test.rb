require 'test_helper'

class DashControllerTest < ActionController::TestCase

  test "html" do
    get :chart
    assert_response :success
  end

  test "json" do
    get :chart, :format => :json
    assert_response :success
    response_hash = JSON.parse(@response.body)
  end
end
