require_relative "./component.rb"

=begin
	  The OwnedComponent is used to denote that one entity owns another.
	  For example, an infantry entity might be owned by a player entity.
	  Hence, the OwnedComponent makes assigning units to armies and things
	  of this nature possible.
=end
class OwnedComponent < Component

  attr_accessor :owner

  # Initializes a new OwnedComponent object
  #
  # Arguments
  #   owner = the owner of the entity
  #
  # Postcondtion
  #   The OwnedComponent object is properly initialized
  def initialize(owner)
    @owner = owner
  end
  
  # Returns a string representation of the component 
  def to_s
    "Owner: #{@owner}"
  end
  
end

