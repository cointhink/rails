require 'test_helper'

class SessionControllerTest < ActionController::TestCase
  test "lookup nothing" do
    get :lookup
    assert_redirected_to session_signup_path
  end

  test "lookup new user" do
    get :lookup, {:username => "newuser"}
    assert_redirected_to session_signup_path(:username => "newuser")
  end

  test "lookup existing user" do
    existing_user = User.new
    User.stub :where, [existing_user] do
      get :lookup, {:username => "existinguser"}
      assert_redirected_to session_login_path(:username => "existinguser")
    end
  end

  test "login user" do
    login_params = {:username => "existinguser",
                    :password => "password6"}
    user = Minitest::Mock.new
    user.expect :authentic?, true, [login_params[:password]]
    user_id = 110
    user.expect :id, user_id
    user.expect :username, login_params[:username]
    User.stub :where, [user] do
      post :create, login_params
      assert_redirected_to root_path
      assert_equal user_id, session[:logged_in_user_id]
    end
  end

  test "create new user" do
    User.stub :where, [] do
      User.stub :new, User.new do
        post :create, {:username => "newuser",
                       :password => "password6",
                       :email => "me@me"}
        assert_redirected_to root_path
        assert session[:logged_in_user_id]
      end
    end
  end

  test "create new user with route dupe username" do
    User.stub :where, [] do
      User.stub :new, User.new do
        post :create, {:username => "arbitrage",
                       :password => "password6",
                       :email => "me@me"}
        assert_redirected_to session_signup_path(:username => "arbitrage", :email => "me@me")
        assert_nil session[:logged_in_user_id]
      end
    end
  end

end
