require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @user_attrs = {username:"defaultbob",
                   email:"bob@bob",
                   password:"password"}
    @user = User.new
    @user.apply_params(@user_attrs)
    assert @user.valid?, @user.errors.inspect
  end

  test "username format" do
    @bad_attrs = {username:"badactor-#",
                   email:"bad@bad",
                   password:"password"}
    @user.apply_params(@bad_attrs)
    @user.valid?
    assert_equal [:username], @user.errors.keys
  end

end
