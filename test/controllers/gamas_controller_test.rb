require 'test_helper'

class GamasControllerTest < ActionController::TestCase
  setup do
    @gama = gamas(:one)
    log_in_as(users(:david))
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:gamas)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should join game" do

    assert_difference('@gama.users.count', 1) do
      put :join, id: @gama
      assert_redirected_to "/play"
    end
  end

  test "should create game" do
    assert_difference('Gama.count') do
      post :create, gama: { name: "example"}
    end

    assert_redirected_to "/play"
  end

  test "should show game" do
    get :show, id: @gama
    assert_response :success
  end


  test "should update game" do
    patch :update, id: @gama, gama: { name: "example1" }
    assert_redirected_to gama_path(assigns(:gama))
  end

  test "should destroy game" do
    assert_difference('Gama.count', -1) do
      delete :destroy, id: @gama
    end

    assert_redirected_to gamas_path
  end
end
