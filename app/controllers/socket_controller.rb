require_relative '../models/ecs/Game'

class SocketController < WebsocketRails::BaseController

  @@game

  def rpc(method_name, method_params)
    # entity_manager, start_json = Game.init_game
    
    if obj.respond_to? method_name
      if method_name == 'init_game'
        em, response = Game.public_send(method_name.to_sym, method_params)
      else
        response = Game.public_send(method_name.to_sym, method_params) 
      end
    end

    @@game = em

    send_message :rpc, {
      sequence: response
   }
  end
end
