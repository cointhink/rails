require 'test_helper'

class SessionFlowsTest < ActionDispatch::IntegrationTest
  def setup
  end

  test "signup good" do
    user = {:username => "person",
             :password => "letmein"}

    assert_difference('User.where({username:'+user[:username].to_json+'}).count') do
      get "/session/signup"
      post "/session/create", user.merge({:email => "my@email"})
    end
    assert_redirected_to '/'
  end

  test "signup missing password" do
    user = {:username => "person",
             :password => ""}

    assert_no_difference('User.where({username:'+user[:username].to_json+'}).count') do
      get "/session/signup"
      post "/session/create", user.merge({:email => "my@email"})
    end
    assert_redirected_to '/'
  end

end