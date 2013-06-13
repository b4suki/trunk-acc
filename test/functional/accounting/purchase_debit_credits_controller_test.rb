require 'test_helper'

class Accounting::PurchaseDebitCreditsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:accounting_purchase_debit_credits)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_purchase_debit_credit
    assert_difference('Accounting::PurchaseDebitCredit.count') do
      post :create, :purchase_debit_credit => { }
    end

    assert_redirected_to purchase_debit_credit_path(assigns(:purchase_debit_credit))
  end

  def test_should_show_purchase_debit_credit
    get :show, :id => accounting_purchase_debit_credits(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => accounting_purchase_debit_credits(:one).id
    assert_response :success
  end

  def test_should_update_purchase_debit_credit
    put :update, :id => accounting_purchase_debit_credits(:one).id, :purchase_debit_credit => { }
    assert_redirected_to purchase_debit_credit_path(assigns(:purchase_debit_credit))
  end

  def test_should_destroy_purchase_debit_credit
    assert_difference('Accounting::PurchaseDebitCredit.count', -1) do
      delete :destroy, :id => accounting_purchase_debit_credits(:one).id
    end

    assert_redirected_to accounting_purchase_debit_credits_path
  end
end
