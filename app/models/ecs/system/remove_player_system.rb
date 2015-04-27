require_relative "./system.rb"
require_relative "./game_over_system.rb"

=begin
	The RemovePlayerSystem is used to remove players from the game. If the
	player no longer has a command bunker, the player has lost. All its 
	remaining units are removed
=end
class RemovePlayerSystem < System

  private

  # Determines whether a player is still alive (aka still has a command
  # bunker)
  #
  # Arguments
  #   entity_manager = the manager of entities
  #   player         = the player to check.
  #
  # Returns
  #   true if the player is still alive, false otherwise
  def self.is_alive?(entity_manager, player)	
    alive = false
    entity_manager.each_entity(PieceComponent) { |entity|
      piece_comp = entity_manager.get_components(entity, PieceComponent).first
      owner_comp = entity_manager.get_components(entity, OwnedComponent).first
      if piece_comp == PieceComponent.command_bunker and player == owner_comp.owner
        alive = true
      end
    }
    return alive
  end

  # Removes all of a player's units from the board.
  #
  # Arguments
  #   entity_manager = the manager of entities
  #   player         = the player whose army to remove
  #
  # Postcondition
  #   All the player's entities are removed from the board and the entity_manager
  def self.remove_army(entity_manager, player)
    entity_manager.each_entity(PieceComponent) { |entity|
      owner_comp = entity_manager.get_components(entity, OwnedComponent).first
      if player == owner_comp.owner
        MotionSystem.remove_piece(entity_manager, entity)
        entity_manager.delete entity
      end
    }	
  end

  public

  # This function removes a specific player from the game
  #
  # Arguments
  #  entity_manager = the manager of entities
  #  player         = the player to remove
  #
  # Returns
  #  an array of the form:
  #    [removed_player_info, turn_change_info, game_over_info]
  def self.remove_player(entity_manager, player)
    turn = entity_manager.get_entities_with_components(TurnComponent).first
    turn_comp = entity_manager[turn][TurnComponent].first

    current_player = turn_comp.current_turn()
    change_turn = false

    self.remove_army(entity_manager, player)
    turn_comp.players.delete player 
    if current_player == player
      current_player = turn_comp.next_turn()
      change_turn = true
    end

    result = ["remove_player", [player]]
    turn = change_turn ? ["turn", current_player] : nil
    return [result, turn, GameOverSystem.update(entity_manager)]
  end

  # This function checks whether the players are still alive and removes them
  # otherwise updating the turn appropriately.
  #
  # Arguments
  #  entity_manager = the manager of entities
  #
  # Returns
  #  an array of the form:
  #    [removed_player_info, turn_change_info, game_over_info]
  def self.update(entity_manager)
    players = entity_manager.get_entities_with_components(HumanComponent)
    players.concat entity_manager.get_entities_with_components(AIComponent)

    turn = entity_manager.get_entities_with_components(TurnComponent).first
    turn_comp = entity_manager[turn][TurnComponent].first
    
    original_player = turn_comp.current_turn()
    current_player  = turn_comp.current_turn()
    players_removed = []
    players.each { |player| 
      unless self.is_alive?(entity_manager, player)
        players_removed.push player

        self.remove_army(entity_manager, player)
        entity_manager.delete player 
        turn_comp.players.delete player 
        if current_player == player
          current_player = turn_comp.next_turn()
        end
      end
    }
    
    result = nil
    result = ["remove_player", players_removed] if !players_removed.empty?
    turn_change = nil
    turn_change = ["turn", current_player] if original_player != current_player
    return [result, turn_change, GameOverSystem.update(entity_manager)]
  end
end
