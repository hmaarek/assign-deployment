require 'test_helper'

class NetRacksControllerTest < ActionController::TestCase
  setup do
    @net_rack = net_racks(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:net_racks)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create net_rack" do
    assert_difference('NetRack.count') do
      post :create, net_rack: { location_id: @net_rack.location_id, name: @net_rack.name, size: @net_rack.size }
    end

    assert_redirected_to net_rack_path(assigns(:net_rack))
  end

  test "should show net_rack" do
    get :show, id: @net_rack
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @net_rack
    assert_response :success
  end

  test "should update net_rack" do
    patch :update, id: @net_rack, net_rack: { location_id: @net_rack.location_id, name: @net_rack.name, size: @net_rack.size }
    assert_redirected_to net_rack_path(assigns(:net_rack))
  end

  test "should destroy net_rack" do
    assert_difference('NetRack.count', -1) do
      delete :destroy, id: @net_rack
    end

    assert_redirected_to net_racks_path
  end
end
