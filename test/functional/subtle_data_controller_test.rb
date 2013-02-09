require 'test_helper'

class SubtleDataControllerTest < ActionController::TestCase
  setup do
    @subtle_datum = subtle_data(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:subtle_data)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create subtle_datum" do
    assert_difference('SubtleDatum.count') do
      post :create, subtle_datum: {  }
    end

    assert_redirected_to subtle_datum_path(assigns(:subtle_datum))
  end

  test "should show subtle_datum" do
    get :show, id: @subtle_datum
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @subtle_datum
    assert_response :success
  end

  test "should update subtle_datum" do
    put :update, id: @subtle_datum, subtle_datum: {  }
    assert_redirected_to subtle_datum_path(assigns(:subtle_datum))
  end

  test "should destroy subtle_datum" do
    assert_difference('SubtleDatum.count', -1) do
      delete :destroy, id: @subtle_datum
    end

    assert_redirected_to subtle_data_path
  end
end
