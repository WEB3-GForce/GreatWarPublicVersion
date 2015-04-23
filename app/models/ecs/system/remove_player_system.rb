require_relative "./system.rb"
require_relative "./game_over_system.rb"

=begin
	The RemovePlayerSystem is used to remove players from the game. If the
	player no longer has a command bunker, the player has lost. All its 
	remaining units are removed
=end
class RemovePlayerSystem < System

private

	def is_alive?(entity_manager, player)	
	    	alive = false
    		entity_manager.each_entity([PieceComponent]) { |entity|
    			piece_comp = entity_manager.get_components(entity, [PieceComponent]).first
    			owner_comp = entity_manager.get_components(entity, [OwnedComponent]).first
		       	if piece_comp.type == self.command_bunker and player == owner_comp.owner
		        	alive = true
		        end
    		}
    		return alive
    	end
    
	def remove_army(entity_manager, player)
     		entity_manager.each_entity([PieceComponent]) { |entity|
    			owner_comp = entity_manager.get_components(entity, [OwnedComponent]).first
    		       	if player == owner_comp.owner
    		        	entity_manager.delete entity
    		        end
    		}	
	end

public

    def self.remove_player(entity_manager, player)
    	players = entity_manager.get_entities_with_components([HumanComponent])
    	players.append entity_manager.get_entities_with_components([AIComponent])
        turn_comp = entity_manager.get_entities_with_components(TurnComponent).first
 
        current_player = turn_comp.current_turn()
        change_turn = false

        remove_army(entity_manager, player)
        entity_manager.delete player 
        turn_comp.players.delete player 
        if current_player == player
            current_player = turn_comp.next_turn(entity_manager)
            change_turn = true
        end

    	result = ["remove player", player]
    	turn = change_turn ? ["turn", current_player] : nil
    	return [result, turn, GameOverSystem.update(entity_manager)]
    end

    def self.update(entity_manager)
    	players = entity_manager.get_entities_with_components([HumanComponent])
    	players.append entity_manager.get_entities_with_components([AIComponent])
        turn_comp = entity_manager.get_entities_with_components(TurnComponent).first
 
        original_player = turn_comp.current_turn()
        current_player  = turn_comp.current_turn()
    	players_removed = []
    	players.each { |player| 
    		unless self.is_alive?(entity_manager, player)
    			players_removed.append player

      			remove_army(entity_manager, player)
    			entity_manager.delete player 
    			turn_comp.players.delete player 
    			if current_player == player
    				current_player = turn_comp.next_turn(entity_manager)
    			end
    		end
    	}
    	
    	result = nil
    	result = ["remove player", players_removed] if players_removed
    	turn_change = nil
    	turn_change = ["turn", current_player] if original_player != current_player
    	return [result, turn_change, GameOverSystem.update(entity_manager)]
    end
end
