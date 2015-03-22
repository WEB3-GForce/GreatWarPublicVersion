class SocketController < WebsocketRails::BaseController
  before_action { controller_store[:usernames] ||= {} }

  def chat_message
    # perform application setup here
    name = controller_store[:usernames][client_id]
    WebsocketRails[:messages].trigger(:new, "#{name}: #{message["text"]}")
  end

  def set_name
    # controller_store[:usernames][client_id] = message["name"]

    trigger_success({ tiles: [[1, 2, 3], [4, 5, 6], [7, 8, 9]] })
  end
end
