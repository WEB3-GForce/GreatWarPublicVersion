require_relative "Component.rb"

=begin
    This class is used to specific a componenet's position on the board.
    The board system is responsible for ensuring that the position is valid
    on the board.
=end
class DamageComponent < Component

    attr_accessor(:amount)

    def initialize(amount)
        @amount = amount
    end
    
    def to_s
        return "Damage: #{@amount}"
    end
end