require 'test_helper'

class Accounting::BankReconciliationsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:accounting_bank_reconciliations)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_bank_reconciliations
    assert_difference('Accounting::BankReconciliations.count') do
      post :create, :bank_reconciliations => { }
    end

    assert_redirected_to bank_reconciliations_path(assigns(:bank_reconciliations))
  end

  def test_should_show_bank_reconciliations
    get :show, :id => accounting_bank_reconciliations(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => accounting_bank_reconciliations(:one).id
    assert_response :success
  end

  def test_should_update_bank_reconciliations
    put :update, :id => accounting_bank_reconciliations(:one).id, :bank_reconciliations => { }
    assert_redirected_to bank_reconciliations_path(assigns(:bank_reconciliations))
  end

  def test_should_destroy_bank_reconciliations
    assert_difference('Accounting::BankReconciliations.count', -1) do
      delete :destroy, :id => accounting_bank_reconciliations(:one).id
    end

    assert_redirected_to accounting_bank_reconciliations_path
  end
end
