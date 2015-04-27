require_relative "./system.rb"

=begin
    The GameOverSystem determines whether the game is finished.
=end
class GameOverSystem < System

    # Checks whether the game is over.
    #
    # Arguments
    #   entity_manager = the manager of entities
    # 
    # Returns
    #   an array of the form ["game_over", id_of_player_who_won] if the game is over,
    #   nil otherwise.
    def self.update(entity_manager)
      turn = entity_manager.get_entities_with_components(TurnComponent).first
      players = entity_manager[turn][TurnComponent][0].players
      return (players.size <= 1) ? ["game_over", players[0]] : nil
    end
end
