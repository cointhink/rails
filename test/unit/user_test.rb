require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @user_attrs = {username:"defaultbob",
                   email:"bob@bob",
                   password:"password"}
    @user = User.safe_create(@user_attrs)
    assert @user.valid?, @user.errors.inspect
  end

  test "username format" do
    @bad_attrs = {username:"badactor-#",
                   email:"bad@bad",
                   password:"password"}
    assert_raise ActiveRecord::RecordInvalid do
      User.safe_create(@bad_attrs)
    end
  end

end
