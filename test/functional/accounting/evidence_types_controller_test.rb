require 'test_helper'

class Accounting::EvidenceTypesControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:accounting_evidence_types)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_evidence_type
    assert_difference('Accounting::EvidenceType.count') do
      post :create, :evidence_type => { }
    end

    assert_redirected_to evidence_type_path(assigns(:evidence_type))
  end

  def test_should_show_evidence_type
    get :show, :id => accounting_evidence_types(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => accounting_evidence_types(:one).id
    assert_response :success
  end

  def test_should_update_evidence_type
    put :update, :id => accounting_evidence_types(:one).id, :evidence_type => { }
    assert_redirected_to evidence_type_path(assigns(:evidence_type))
  end

  def test_should_destroy_evidence_type
    assert_difference('Accounting::EvidenceType.count', -1) do
      delete :destroy, :id => accounting_evidence_types(:one).id
    end

    assert_redirected_to accounting_evidence_types_path
  end
end
