require 'test_helper'

class SalesControllerTest < ActionController::TestCase
  setup do
    @sale = sales(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:sales)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create sale" do
    assert_difference('Sale.count') do
      post :create, sale: { card_id: @sale.card_id, gift_id: @sale.gift_id, giver_id: @sale.giver_id, provider_id: @sale.provider_id, request_string: @sale.request_string, response_string: @sale.response_string, revenue: @sale.revenue, status: @sale.status, transaction_id: @sale.transaction_id }
    end

    assert_redirected_to sale_path(assigns(:sale))
  end

  test "should show sale" do
    get :show, id: @sale
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @sale
    assert_response :success
  end

  test "should update sale" do
    put :update, id: @sale, sale: { card_id: @sale.card_id, gift_id: @sale.gift_id, giver_id: @sale.giver_id, provider_id: @sale.provider_id, request_string: @sale.request_string, response_string: @sale.response_string, revenue: @sale.revenue, status: @sale.status, transaction_id: @sale.transaction_id }
    assert_redirected_to sale_path(assigns(:sale))
  end

  test "should destroy sale" do
    assert_difference('Sale.count', -1) do
      delete :destroy, id: @sale
    end

    assert_redirected_to sales_path
  end
end
