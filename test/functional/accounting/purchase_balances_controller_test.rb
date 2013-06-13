require 'test_helper'

class Accounting::PurchaseBalancesControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:accounting_purchase_balances)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_purchase_balance
    assert_difference('Accounting::PurchaseBalance.count') do
      post :create, :purchase_balance => { }
    end

    assert_redirected_to purchase_balance_path(assigns(:purchase_balance))
  end

  def test_should_show_purchase_balance
    get :show, :id => accounting_purchase_balances(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => accounting_purchase_balances(:one).id
    assert_response :success
  end

  def test_should_update_purchase_balance
    put :update, :id => accounting_purchase_balances(:one).id, :purchase_balance => { }
    assert_redirected_to purchase_balance_path(assigns(:purchase_balance))
  end

  def test_should_destroy_purchase_balance
    assert_difference('Accounting::PurchaseBalance.count', -1) do
      delete :destroy, :id => accounting_purchase_balances(:one).id
    end

    assert_redirected_to accounting_purchase_balances_path
  end
end
