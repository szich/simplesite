require File.dirname(__FILE__) + '/../test_helper'
require 'my_account_controller'

# Re-raise errors caught by the controller.
class MyAccountController; def rescue_action(e) raise e end; end

class MyAccountControllerTest < Test::Unit::TestCase
  def setup
    @controller = MyAccountController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
