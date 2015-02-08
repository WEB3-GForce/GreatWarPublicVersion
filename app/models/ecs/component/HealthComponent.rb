require_relative "Component.rb"

=begin
	This class is used to notify the system that the given entity is AI-
	controlled.
=end
class HealthComponent < Component

	attr_reader(:max_health, :cur_health)

	def initialize(max_health, cur_health=max_health)
		@max_health = max_health
		@cur_health = cur_health
	end
	
	def cur_health=(health)
		@cur_health = [[health, 0].max, @max_health].min
	end
	
	def max_health=(health)
		diff = [health - @max_health, 0].max
		@max_health = [health, 0].max
		@cur_health = [@cur_health + diff, @max_health].min
	end
	
	def alive? ; health > 0 ; end
	
	def to_s ;"Health : #{@cur_health}/#{@max_health}" ; end
end

#test = HealthComponent.new(20, 10)
#test.cur_health *= 5
#test.cur_health += 10
#puts test
#health.cur_health = -100000000000000
