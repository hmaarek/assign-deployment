require 'test_helper'

class CustomersControllerTest < ActionController::TestCase
  test "should get mew" do
    get :mew
    assert_response :success
  end

end
