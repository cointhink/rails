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

  test "create" do
#    post :create
#    assert_response :redirect
#    assert session[:logged_in_user_id]
  end
end
