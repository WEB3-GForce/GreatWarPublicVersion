class SocketController < WebsocketRails::BaseController
  def test
    WebsocketRails[:messages].trigger(:rpc, {action: "revealFog", arguments: [2, 3]})
  end
end
