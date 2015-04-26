require 'test_helper'

class GamasControllerTest < ActionController::TestCase
  setup do
    @gama = gamas(:one)
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

  test "should create game" do
    assert_difference('Game.count') do
      post :create, gama: { done: @gama.done, pending: @gama.pending }
    end

    assert_redirected_to gama_path(assigns(:gama))
  end

  test "should show game" do
    get :show, id: @gama
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @gama
    assert_response :success
  end

  test "should update game" do
    patch :update, id: @gama, gama: { done: @gama.done, pending: @gama.pending }
    assert_redirected_to game_path(assigns(:gama))
  end

  test "should destroy game" do
    assert_difference('Game.count', -1) do
      delete :destroy, id: @gama
    end

    assert_redirected_to gamas_path
  end
end
