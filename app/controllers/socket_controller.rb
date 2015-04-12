require_relative '../models/ecs/Game.rb'
require_relative '../helpers/sessions_helper.rb'

class SocketController < WebsocketRails::BaseController
  @@game ||= Hash.new

  def self.init_game(users, game_id)
    manager, start_json = Game.init_game(users)
    @@game[game_id] = { :manager => manager, :start_json => start_json }
  end

  def rpc
    # TODO
    method_name = message['action']
    method_params = message['arguments']

    req_id = current_user.id
    game_id = current_user.game

    # Should separate initialization call to backend from that to frontend,
    # since we only need to call it once on backend, but multiple times on
    # frontend.
    if method_name == 'init_game'
        response = @@game[game_id][:start_json]
    elsif Game.respond_to? method_name      
        manager = @@game[game_id][:manager]
        method_params.unshift manager
        method_params.unshift req_id
        
        response = Game.public_send(method_name, *method_params)
        p response
    end

    # # the front end expects to response to be an array, if it's not though,
    # # that's fine, it just needs to be sent as one regardless, hence this:
    response = [response] unless response.kind_of?(Array)
    
    # if method_name == 'init_game'
    #   response = [
    #               {
    #                 action: "revealUnit",
    #                 arguments: [{
    #                               id: 1,
    #                               type: 'infantry',
    #                               x: 5,
    #                               y: 5,
    #                               player: 'test',
    #                               stats: {
    #                                 health: {
    #                                   current: 10,
    #                                   max: 10
    #                                 },
    #                                 energy: {
    #                                   current: 7,
    #                                   max: 10
    #                                 },
    #                                 range: {
    #                                   attack: 10
    #                                 }
    #                               }
    #                             }]
    #               },
    #               {
    #                 action: "updateUnitsHealth",
    #                 arguments: [[
    #                              {
    #                                id: 1,
    #                                newHealth: 4
    #                              }
    #                             ]]
    #               }
                  
    #              ]
    # elsif method_name == "get_unit_actions"
    #   response = [
    #               {
    #                 action: "showUnitActions",
    #                 arguments: [["ranged", "melee", "move"]]
    #               }
    #              ]
    # end

    p method_name

    if response
      send_message :rpc, {
        :sequence => response
      }
    end
  end
end
