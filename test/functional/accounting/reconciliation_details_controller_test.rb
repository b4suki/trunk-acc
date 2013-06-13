require 'test_helper'

class Accounting::ReconciliationDetailsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:accounting_reconciliation_details)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_reconciliation_detail
    assert_difference('Accounting::ReconciliationDetail.count') do
      post :create, :reconciliation_detail => { }
    end

    assert_redirected_to reconciliation_detail_path(assigns(:reconciliation_detail))
  end

  def test_should_show_reconciliation_detail
    get :show, :id => accounting_reconciliation_details(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => accounting_reconciliation_details(:one).id
    assert_response :success
  end

  def test_should_update_reconciliation_detail
    put :update, :id => accounting_reconciliation_details(:one).id, :reconciliation_detail => { }
    assert_redirected_to reconciliation_detail_path(assigns(:reconciliation_detail))
  end

  def test_should_destroy_reconciliation_detail
    assert_difference('Accounting::ReconciliationDetail.count', -1) do
      delete :destroy, :id => accounting_reconciliation_details(:one).id
    end

    assert_redirected_to accounting_reconciliation_details_path
  end
end
