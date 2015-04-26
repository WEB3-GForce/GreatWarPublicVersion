require_relative "./component.rb"

=begin
    The UserIdComponent is used to uniquely identify player entities. It also
    contains other important info like which faction the entity belongs to.
=end
class UserIdComponent < Component
  
    attr_reader(:id, :faction)

    # Initializes a new UserIdComponent object
    #
    # Arguments
    #   id = the unique identifier
    #   faction = which faction the entity belongs to (typically a color like
    #             red, blue, etc.)
    #
    # Postcondtion
    #   The UserIdComponent object is properly initialized
    def initialize(id, faction)
        @id      = id
        @faction = faction
    end

    # Returns a string representation of the component  
    def to_s
        "[User ID: #{@id}, Faction: #{@faction}]"
    end
end

