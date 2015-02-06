require "./Component.rb"

=begin
	This is the class to define the Terrain attribute of game entities.
	This inherits from Component class.

=end

class TerrainComponent < Component

   #cattr_reader @@flatland @@mountain @@trench @@river
   attr_reader  :type


private
	def initialize(type)
		@type = type
	end

public
	# These are the static class variables. These represent the four values that
	# a terrain can have as an attribute.
	@@flatland = TerrainComponent.new(:flatland)
	@@mountain = TerrainComponent.new(:mountain)
	@@trench = TerrainComponent.new(:trench)
	@@river = TerrainComponent.new(:river)

	# Default to_string method
    def to_s
    	return "Terrain: " + @type.to_s
    end

    # Getter methods
    def self.flatland ; @@flatland ; end

    def self.mountain ; @@mountain ; end

    def self.trench ; @@trench ; end

    def self.river ; @@river ; end

end

puts TerrainComponent.flatland


puts TerrainComponent.mountain

puts TerrainComponent.trench

puts TerrainComponent.river


puts TerrainComponent.flatland.type