require_relative '../models/ecs/Game'

class SocketController < WebsocketRails::BaseController
  def init_game
    # entity_manager, start_json = Game.init_game
    send_message :rpc, {sequence: [{action: "testAnim", arguments: []}, {action: "test", arguments: ["goodbye"]}]}
  end
end
