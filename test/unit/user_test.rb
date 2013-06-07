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

  test "good username" do
    @bad_attrs = {username:"niceguy",
                   email:"nice@nice",
                   password:"password"}
    @user.apply_params(@bad_attrs)
    assert @user.valid?
  end

  test "bad username chars" do
    @bad_attrs = {username:"badactor-#",
                   email:"bad@bad",
                   password:"password"}
    @user.apply_params(@bad_attrs)
    @user.valid?
    assert_equal [:username], @user.errors.keys
  end

  test "good password" do
    @bad_attrs = {username:"gooduser",
                   email:"bad@bad",
                   password:"password1"}
    old_encrypted_password = @user.encrypted_password
    @user.apply_params(@bad_attrs)
    @user.valid?
    refute_equal old_encrypted_password, @user.encrypted_password
  end

  test "empty password" do
    @bad_attrs = {username:"gooduser",
                   email:"bad@bad",
                   password:""}
    @user.apply_params(@bad_attrs)
    @user.valid?
    assert_equal [:encrypted_password], @user.errors.keys
  end

end
