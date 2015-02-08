require_relative "Component.rb"

class RangeAttackComponent < Component

	attr_reader(:min_range, :max_range, :attack)

	def initialize(min_range, max_range, attack)
		@min_range = 0
		@max_range = 0
		@attack    = 0
		self.min_range = min_range
		self.max_range = max_range
		self.attack    = attack
	end
	
	def attack=(attack)
		@attack = [0, attack].max
	end
	
	def min_range=(range)
		@min_range = [0, range].max
		@max_range = [@min_range, @max_range].max
	end
	
	def max_range=(range)
		@max_range = [0, range].max
		@min_range = [@min_range, @max_range].min
	end
	
	def to_s
		"Range Attack: [attack = #{@attack}, range = #{@min_range}-#{@max_range}]"
	end
end

#attack = RangeAttackComponent.new(5, 10, 20)
#attack2 = RangeAttackComponent.new(20, 10, 20)
#puts attack
#puts attack2
