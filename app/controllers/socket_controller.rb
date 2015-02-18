class SocketController < WebsocketRails::BaseController
  before_action { controller_store[:usernames] ||= {} }

  def chat_message
    # perform application setup here
    name = controller_store[:usernames][client_id]
    WebsocketRails[:messages].trigger(:new, "#{name}: #{message["text"]}")
  end

  def set_name
    controller_store[:usernames][client_id] = message["name"]
  end
end
