require_relative "./system.rb"
#require_relative "./energy_system.rb"

=begin
	The TurnSystem is responsible for handling turn-related issues. It keeps
	track of which player's turn it is and executes the appropriate updates
    (e.g. replenshing entity energies) upon updating to the next turn.
=end
class TurnSystem < System

#===============================================================================
private
    
    # Gets current turn component from an entity manager.
    def self.turn_component(entity_manager)
        turn = entity_manager.get_entities_with_components(TurnComponent).first
        return turn[TurnComponent].first
    end

    # Gets the entity for the current player from an entity manager.
    def self.current_turn(entity_manager)
        return self.turn_component(entity_manager).current_turn()
    end

    # Ends turn and gets the new current player from an entity manager.
    def self.next_turn(entity_manager)
        return self.turn_component(entity_manager).next_turn()
    end

#===============================================================================
public
    
    # Determines whether the entity belongs to the current turn's player.
    #
    # Arguments
    #   entity_manager = the manager of entities
    #   entity         = the entity whose owner will be checked
    # 
    # Returns
    #   true if the entity's owner is the current turn's player; false otherwise
    #
    def self.current_turn_entity?(entity_manager, entity)        
        turn = self.current_turn(entity_manager)
        return entity_manager[entity][OwnedComponent].first.owner == turn
    end

    # Generates each entity belonging to the current player.
    #
    # Arguments
    #   entity_manager = the manager of entities
    # 
    # Yields
    #   each entity whose owner is the current turn's player
    #
    def self.current_turn_entities_each(entity_manager)
        entity_manager.each_entity(OwnedComponent) { |entity|
            yield entity if self.current_turn_entity?(entity_manager, entity)
        }
    end

    # Gets an array of each entity belonging to the current player.
    #
    # Arguments
    #   entity_manager = the manager of entities
    # 
    # Returns
    #   array of entities whose owner is the current turn's player
    #
    def self.current_turn_entities(entity_manager)        
        entities = []
        self.current_turn_entities_each { |entity|
            entities << entity
        }
        return entities
    end

    # Updates to the next turn.
    #
    # Arguments
    #   entity_manager = the manager of entities
    # 
    # Returns
    #   an array of form ["turn", next_player] where next_player is the player
    #   whose turn it is after this method's call.
    #
    def self.update(entity_manager)
        #EnergySystem.reset_energy(entity_manager)
        return ["turn", self.next_turn(entity_manager)]
    end
end
