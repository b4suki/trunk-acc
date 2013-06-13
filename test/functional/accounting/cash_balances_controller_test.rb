require 'test_helper'

class Accounting::CashBalancesControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:accounting_cash_balances)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_cash_balance
    assert_difference('Accounting::CashBalance.count') do
      post :create, :cash_balance => { }
    end

    assert_redirected_to cash_balance_path(assigns(:cash_balance))
  end

  def test_should_show_cash_balance
    get :show, :id => accounting_cash_balances(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => accounting_cash_balances(:one).id
    assert_response :success
  end

  def test_should_update_cash_balance
    put :update, :id => accounting_cash_balances(:one).id, :cash_balance => { }
    assert_redirected_to cash_balance_path(assigns(:cash_balance))
  end

  def test_should_destroy_cash_balance
    assert_difference('Accounting::CashBalance.count', -1) do
      delete :destroy, :id => accounting_cash_balances(:one).id
    end

    assert_redirected_to accounting_cash_balances_path
  end
end
