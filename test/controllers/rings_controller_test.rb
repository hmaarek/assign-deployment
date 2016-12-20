require 'test_helper'

class RingsControllerTest < ActionController::TestCase
  setup do
    @ring = rings(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:rings)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create ring" do
    assert_difference('Ring.count') do
      post :create, ring: { description: @ring.description, name: @ring.name }
    end

    assert_redirected_to ring_path(assigns(:ring))
  end

  test "should show ring" do
    get :show, id: @ring
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @ring
    assert_response :success
  end

  test "should update ring" do
    patch :update, id: @ring, ring: { description: @ring.description, name: @ring.name }
    assert_redirected_to ring_path(assigns(:ring))
  end

  test "should destroy ring" do
    assert_difference('Ring.count', -1) do
      delete :destroy, id: @ring
    end

    assert_redirected_to rings_path
  end
end
