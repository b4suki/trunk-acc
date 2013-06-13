require 'test_helper'

class Accounting::SaleDebitCreditsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:accounting_sale_debit_credits)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_sale_debit_credit
    assert_difference('Accounting::SaleDebitCredit.count') do
      post :create, :sale_debit_credit => { }
    end

    assert_redirected_to sale_debit_credit_path(assigns(:sale_debit_credit))
  end

  def test_should_show_sale_debit_credit
    get :show, :id => accounting_sale_debit_credits(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => accounting_sale_debit_credits(:one).id
    assert_response :success
  end

  def test_should_update_sale_debit_credit
    put :update, :id => accounting_sale_debit_credits(:one).id, :sale_debit_credit => { }
    assert_redirected_to sale_debit_credit_path(assigns(:sale_debit_credit))
  end

  def test_should_destroy_sale_debit_credit
    assert_difference('Accounting::SaleDebitCredit.count', -1) do
      delete :destroy, :id => accounting_sale_debit_credits(:one).id
    end

    assert_redirected_to accounting_sale_debit_credits_path
  end
end
