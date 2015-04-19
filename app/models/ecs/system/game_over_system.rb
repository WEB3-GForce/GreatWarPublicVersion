require_relative "./system.rb"

=begin
    The TurnSystem is responsible for handling turn-related issues. It keeps
    track of which player's turn it is and executes the appropriate updates
    (e.g. replenshing entity energies) upon updating to the next turn.
=end
class GameOverSystem < System

    # Checks whether the game is over.
    #
    # Arguments
    #   entity_manager = the manager of entities
    # 
    # Returns
    #   an array of form ["game_over", boolean] where boolean is id of the
    #   player who won, else nil.
    #
    def self.update(entity_manager)
        players = entity_manager.get_entities_with_components(UserIdComponent)
        return (players.size <= 1) ? ["game_over", players[0]] : nil
    end
end