require_relative "./component.rb"

=begin
    The UserIdComponent is used to uniquely identify player entities.
=end
class UserIdComponent < Component
  
    attr_reader(:id, :channel, :faction)

    # Initializes a new NameComponent object
    #
    # Arguments
    #   name = the name of the entity
    #
    # Postcondtion
    #   The NameComponent object is properly initialized
    def initialize(id, channel, faction)
        @id      = id
        @channel = channel
        @faction = faction
    end

    # Returns a string representation of the component  
    def to_s
        "User ID: #{@id}"
    end
end

