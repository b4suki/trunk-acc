require 'test_helper'

class Accounting::SaleBalancesControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:accounting_sale_balances)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_sale_balance
    assert_difference('Accounting::SaleBalance.count') do
      post :create, :sale_balance => { }
    end

    assert_redirected_to sale_balance_path(assigns(:sale_balance))
  end

  def test_should_show_sale_balance
    get :show, :id => accounting_sale_balances(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => accounting_sale_balances(:one).id
    assert_response :success
  end

  def test_should_update_sale_balance
    put :update, :id => accounting_sale_balances(:one).id, :sale_balance => { }
    assert_redirected_to sale_balance_path(assigns(:sale_balance))
  end

  def test_should_destroy_sale_balance
    assert_difference('Accounting::SaleBalance.count', -1) do
      delete :destroy, :id => accounting_sale_balances(:one).id
    end

    assert_redirected_to accounting_sale_balances_path
  end
end
