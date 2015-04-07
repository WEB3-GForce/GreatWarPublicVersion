require_relative '../models/ecs/Game'

class SocketController < WebsocketRails::BaseController
  def init_game
    # entity_manager, start_json = Game.init_game
    send_message :rpc, {sequence: [{action: "testAnim", arguments: []}, {action: "moveUnit", arguments: [1, {x: 10, y: 10}]}]}
  end
end
