require 'test_helper'

class SessionFlowsTest < ActionDispatch::IntegrationTest
  def setup
  end

  test "signup good" do
    user = {:username => "person",
            :email => "my@email",
            :password => "letmein"}

    assert_difference('User.where({username:'+user[:username].to_json+'}).count') do
      get "/session/signup"
      post "/session/create", user.merge({:email => user[:email]})
    end
    assert_redirected_to '/'
  end

  test "signup missing password" do
    user = {:username => "person",
            :email => "my@email",
            :password => ""}

    assert_no_difference('User.where({username:'+user[:username].to_json+'}).count') do
      get "/session/signup"
      post "/session/create", user.merge({:email => user[:email]})
    end
    assert_redirected_to url_for({action: "signup", email:user[:email], username: user[:username]})
  end

end