require_relative "entity/EntityManager.rb"

=begin
	A Game represents a game instance the The Great War, with players, units, etc.
=end
class Game
	attr_reader :entity_manager :systems
	
	# Creates new entity manager and associated systems
	def initialize()
		@entity_manager = EntityManager.new
		@systems = [] # TODO add systems need for game
	end
	
	# Processes a request object
	def process(request)
		raise NotImplementedError
	end
end
