require 'test_helper'

class Accounting::BankBalancesControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:accounting_bank_balances)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_bank_balance
    assert_difference('Accounting::BankBalance.count') do
      post :create, :bank_balance => { }
    end

    assert_redirected_to bank_balance_path(assigns(:bank_balance))
  end

  def test_should_show_bank_balance
    get :show, :id => accounting_bank_balances(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => accounting_bank_balances(:one).id
    assert_response :success
  end

  def test_should_update_bank_balance
    put :update, :id => accounting_bank_balances(:one).id, :bank_balance => { }
    assert_redirected_to bank_balance_path(assigns(:bank_balance))
  end

  def test_should_destroy_bank_balance
    assert_difference('Accounting::BankBalance.count', -1) do
      delete :destroy, :id => accounting_bank_balances(:one).id
    end

    assert_redirected_to accounting_bank_balances_path
  end
end
