require 'test_helper'

class GamasJoin < ActionDispatch::IntegrationTest
  setup do
    @gama = gamas(:one)
    log_in_as(users(:david))
  end

  test "create game, attempt to join another" do
    get "/gamas/new"

    assert_difference 'Gama.count', 1 do
      post_via_redirect gamas_path, gama: { name:  "Example Game"}
    end
    assert_template 'static_pages/play'

  end


end
