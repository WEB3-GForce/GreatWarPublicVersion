require_relative "./component.rb"

=begin
	  The PieceComponent identifies an entity as an army unit or a piece
	  on the board that a player can control. It also contains a type
	  attribute that identifies which type of unit it is.
	  
	  Since there are only a limited number of types of units, the
	  class is structured the same as the TerrainComponent. The initialize
	  function is private while static class instance variables are
	  provided for the different types.
=end
class PieceComponent < Component

	attr_reader :type

private
	# Initializes a new UnitComponent object
	#
	# Arguments
	#   type = the type of unit the piece is
	#
	# Postcondtion
	#   The UnitComponent object is properly initialized
	def initialize(type)
		@type = type
	end

public

	# These are the static unit objects. If a UnitComponent is needed,
	# these should be used. Since they are static, DO NOT MODIFY THESE
	# OUTSIDE THIS FILE.
	@infantry       = PieceComponent.new(:infantry)
	@machine_gun    = PieceComponent.new(:machine_gun)
	@artillery      = PieceComponent.new(:artillery)
	@command_bunker = PieceComponent.new(:command_bunker)

	# Getter methods for the class instance variables
	def self.infantry       ; @infantry    ; end
	def self.machine_gun    ; @machine_gun ; end
	def self.artillery      ; @artillery   ; end
	def self.command_bunker ; @command_bunker   ; end

  	# Returns a string representation of the component 
	def to_s
		"Unit Type: #{@type}"
	end
  
end

