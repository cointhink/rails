require 'test_helper'

class ScriptsControllerTest < ActionController::TestCase

  test "start" do
    user = User.new({username:'jill'})
    login(user)
    script = MiniTest::Mock.new
    script.expect :start!, nil
    script.expect :user, user
    Script.stub :find, script do
      post :start, {scriptname:"average", username:"jill"}
      assert_nil flash[:error]
      assert_redirected_to :action => :lastrun
    end
  end

  def login(user)
    # setup a backdoor
    def @controller.mock_user(user)
      @mock_user = user
    end
    @controller.mock_user(user)
    # use the backdoor
    def @controller.auth
      log_in(@mock_user)
    end
  end
end
