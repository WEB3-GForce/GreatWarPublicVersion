require_relative "./component.rb"

=begin
	TerrainComponent is a major component for the board. It denotes what
	type of terrain will appear on the board. For example, a
	TerrainComponent of type river would appear on the board as a river
	whereas a mountain terrain would appear as a mountain.
	
	For this game, TerrainComponent objects will be static. One river will
	not differ substantially from another. Hence, the initialization
	function is made private and objects representing the different types of
	terrain are provided as class instance variables. Developers wishing to
	include TerrainComponent's to entities should simply include the class
	variables provided.
	
	Note: it is preferred to use class instance variables over class
	variables. See the following article for more info:

	http://4thmouse.com/index.php/2011/03/20/why-class-variables-in-ruby-are-a-bad-idea/
=end
class TerrainComponent < Component

  attr_reader  :type

  private
  # Initializes a new TerrainComponent object
  #
  # Arguments
  #   type = the type of terrain (river, mountain, etc.)
  #
  # Postcondtion
  #   The TerrainComponent object is properly initialized
  def initialize(type)
    @type = type
  end

  public
  # These are the static terrain objects. If a TerrainComponent is needed,
  # these should be used. Since they are static, DO NOT MODIFY THESE
  # OUTSIDE THIS FILE.
  @flatland = TerrainComponent.new(:flatland)
  @mountain = TerrainComponent.new(:mountain)
  @hill     = TerrainComponent.new(:hill)
  @trench   = TerrainComponent.new(:trench)
  @river    = TerrainComponent.new(:river)

  # Getter methods for the class variables
  def self.flatland ; @flatland ; end
  def self.mountain ; @mountain ; end
  def self.hill     ; @hill     ; end
  def self.trench   ; @trench   ; end
  def self.river    ; @river    ; end

  # Default to_string method
  def to_s
    return "Terrain: " + @type.to_s
  end
end


