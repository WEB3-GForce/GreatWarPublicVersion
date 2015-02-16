class SocketController < WebsocketRails::BaseController
  def test_session
    # perform application setup here
    p 'hello'
    controller_store[:message_count] = 0
  end
end