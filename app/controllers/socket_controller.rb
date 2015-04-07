require_relative '../models/ecs/Game'

class SocketController < WebsocketRails::BaseController
  def init_game
    # entity_manager, start_json = Game.init_game
    send_message :rpc, {sequence: [
				{action: "revealFog", arguments: [
					[{x: 4, y: 4}, {x: 5, y: 4}]
				]}, 
				{action: "test", arguments: ["goodbye"]}
			]}
  end
end
