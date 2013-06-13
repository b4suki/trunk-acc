require 'test_helper'

class TransItemStatusesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:trans_item_statuses)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create trans_item_status" do
    assert_difference('TransItemStatus.count') do
      post :create, :trans_item_status => { }
    end

    assert_redirected_to trans_item_status_path(assigns(:trans_item_status))
  end

  test "should show trans_item_status" do
    get :show, :id => trans_item_statuses(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => trans_item_statuses(:one).to_param
    assert_response :success
  end

  test "should update trans_item_status" do
    put :update, :id => trans_item_statuses(:one).to_param, :trans_item_status => { }
    assert_redirected_to trans_item_status_path(assigns(:trans_item_status))
  end

  test "should destroy trans_item_status" do
    assert_difference('TransItemStatus.count', -1) do
      delete :destroy, :id => trans_item_statuses(:one).to_param
    end

    assert_redirected_to trans_item_statuses_path
  end
end
