require_relative '../models/ecs/Game.rb'
require_relative '../helpers/sessions_helper.rb'

class SocketController < WebsocketRails::BaseController
  def self.user_joined(user, new_user)
    WebsocketRails[user.channel].trigger("userJoined", {name: new_user.name})
  end

  def self.init_game(users, game_id)
    manager = Game.init_game(users, Rails.root.join('app', 'assets', 'json', 'demo.json'))
    Game.save(game_id, manager)
    Game.store(game_id, manager)

    Game.get_user_channels(manager).each do |channel|
      WebsocketRails[channel].trigger :initGame, {}
    end
  end

  def self.leave_game(user)
    manager = Game.get(user.gama_id)
    response = Game.leave_game(user.id, manager)
    Game.get_user_channels(manager).each do |channel|
      WebsocketRails[channel].trigger :rpc, {
        :sequence => response
      }
    end
  end

  def get_channel
    send_message :setChannel, {channel: current_user.channel, name: current_user.name}
  end

  def get_game
    unless Game.get(current_user.gama_id).nil?
      WebsocketRails[current_user.channel].trigger :initGame, {}
    end
  end

  def rpc
    method_name = message['action']
    method_params = message['arguments']

    req_id = current_user.id
    game_id = current_user.gama_id

    p method_name

    manager = Game.get(game_id)
    if method_name == 'init_game'
      response = Game.get_game_state(req_id, manager)
    elsif Game.respond_to? method_name
      method_params.unshift manager
      method_params.unshift req_id

      response = Game.public_send(method_name, *method_params)
    end

    Game.save(game_id, manager)
    if method_name == 'end_turn'
      Game.store(game_id, manager) # probably only want to store after a turn ends
    end

    response.each do |action|
      if action["action"] == "gameOver"
        current_user.gama.gameover
      end
    end

    p response

    # # the front end expects to response to be an array, if it's not though,
    # # that's fine, it just needs to be sent as one regardless, hence this:
    response = [response] unless response.kind_of?(Array)

    if response
      public_calls = ['move_unit', 'attack', 'end_turn', 'leave_game', 'make_trench']
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
