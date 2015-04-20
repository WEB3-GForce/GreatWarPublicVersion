require_relative '../models/ecs/Game.rb'
require_relative '../helpers/sessions_helper.rb'

class SocketController < WebsocketRails::BaseController
  @@game ||= Hash.new

  def self.init_game(users, game_id)
    user_ids = []
    users.each { |record|
      user_ids << record.id
    }
    manager, start_json = Game.init_game(user_ids)
    @@game[game_id] = { :manager => manager, :start_json => start_json }
    p user_ids, game_id
    return true
  end

  def rpc
    # TODO
    method_name = message['action']
    method_params = message['arguments']

    req_id = current_user.id
    game_id = current_user.game

    p method_name

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
    end

    p response

    # # the front end expects to response to be an array, if it's not though,
    # # that's fine, it just needs to be sent as one regardless, hence this:
    response = [response] unless response.kind_of?(Array)

    if response
      public_calls = ['move_unit', 'attack', 'end_turn']
      if public_calls.include? method_name
        broadcast_message :rpc, {
            :sequence => response
        }
      else
        send_message :rpc, {
            :sequence => response
        }
      end
    end
  end
end
