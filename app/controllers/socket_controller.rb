require_relative '../models/ecs/Game.rb'

class SocketController < WebsocketRails::BaseController
  @@game = Hash.new

  def rpc
    # TODO
    p message
    
    method_name = message['action']
    method_params = message['arguments']

    req_id = 0
    game_id = 0

    # Should separate initialization call to backend from that to frontend,
    # since we only need to call it once on backend, but multiple times on
    # frontend.
    if method_name == 'init_game'
        em, response = Game.init_game(*method_params)

        @@game[game_id] = em if !em.nil?

    elsif obj.respond_to? method_name
        manager = @@game[game_id]
        method_params.unshift manager
        method_params.unshift req_id
        response = Game.public_send(method_name.to_sym, *method_params)
    end
    
    p response

    send_message :rpc, {
      sequence => response
    }
  end
end
