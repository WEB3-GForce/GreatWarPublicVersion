require_relative "./component.rb"

=begin
    The SpriteComponent is used to identify what sprite is used by an identity.
=end
class SpriteComponent < Component
  
  attr_reader(:id)
  
  # Initializes a new SpriteComponent object
  #
  # Arguments
  #   id = the unique identifier
  #
  def initialize(id)
    @id      = id
  end
  
  # Returns a string representation of the component  
  def to_s
    "[Sprite ID: #{@id}]"
  end
end