require_relative '../models/ecs/Game.rb'

class SocketController < WebsocketRails::BaseController
  @@game ||= Hash.new

  def rpc
    # TODO
    method_name = message['action']
    method_params = message['arguments']

    # req_id = 0
    # game_id = 0

    # # Should separate initialization call to backend from that to frontend,
    # # since we only need to call it once on backend, but multiple times on
    # # frontend.
    # if method_name == 'init_game'
    #     em, response = Game.init_game(*method_params)

    #     @@game[game_id] = em if !em.nil?

    # elsif Game.respond_to? method_name      
    #     manager = @@game[game_id]
    #     method_params.unshift manager
    #     method_params.unshift req_id
        
    #     response = Game.public_send(method_name, *method_params)
    #     p response
    # end

    # # the front end expects to response to be an array, if it's not though,
    # # that's fine, it just needs to be sent as one regardless, hence this:
    # response = [response] unless response.kind_of?(Array)
    if method_name == 'init_game'
      response = [
                  {
                    action: "revealUnit",
                    arguments: [{
                                  id: 1,
                                  type: 'infantry',
                                  x: 5,
                                  y: 5,
                                  player: 'test',
                                  stats: {
                                    health: {
                                      current: 10,
                                      max: 10
                                    },
                                    energy: {
                                      current: 7,
                                      max: 10
                                    },
                                    range: {
                                      attack: 10
                                    }
                                  }
                                }]
                  }
                  
                 ]
    elsif method_name == "get_unit_actions"
      response = [
                  {
                    action: "showUnitActions",
                    arguments: [["ranged", "melee", "move"]]
                  }
                 ]
    end

    p method_name

    if response
      send_message :rpc, {
        :sequence => response
      }
    end
  end
end
