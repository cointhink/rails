require 'test_helper'

class ScriptsControllerTest < ActionController::TestCase

  test "start" do
    login(User.new)
    post :start, {scriptname:"average", username:"jill"}
    assert_nil flash[:error]
    assert_redirected_to :action => :lastrun
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
