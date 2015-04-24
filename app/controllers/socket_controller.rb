require_relative '../models/ecs/Game.rb'
require_relative '../helpers/sessions_helper.rb'

class SocketController < WebsocketRails::BaseController
  @@game ||= Hash.new

  def self.user_joined(user, new_user)
    WebsocketRails[user.channel].trigger("userJoined", {name: new_user.name})
  end

  def self.gameover(gama_id)
    manager = @@game[gama_id][:manager]

    Game.get_user_channels(manager).each do |channel|
      WebsocketRails[channel].trigger :gameover, {}
    end
  end

  def self.init_game(users, game_id)
    manager, start_json = Game.init_game(users)
    @@game[game_id] = { :manager => manager, :start_json => start_json }

    Game.get_user_channels(manager).each do |channel|
      WebsocketRails[channel].trigger :initGame, {}
    end
  end
  
  def get_channel
    send_message :setChannel, {channel: current_user.channel, name: current_user.name}
  end
  
  def get_game
    if !@@game[current_user.gama_id].nil?
      WebsocketRails[current_user.channel].trigger :initGame, {}
    end
  end

  def rpc
    method_name = message['action']
    method_params = message['arguments']

    req_id = current_user.id
    game_id = current_user.gama_id

    p method_name

    manager = @@game[game_id][:manager]
    if method_name == 'init_game'
        response = Game.get_game_state(req_id, manager)
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
        Game.get_user_channels(manager).each do |channel|
          WebsocketRails[channel].trigger :rpc, {
            :sequence => response
          }
        end
      else
        WebsocketRails[current_user.channel].trigger :rpc, {
          :sequence => response
        }
      end
    end
  end
end
