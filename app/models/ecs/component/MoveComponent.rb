require_relative "./component.rb"

=begin
    A Move Component specifies a sequence of (adjacent) positions,
    each an object containing row and col attributes.
=end
class MoveComponent < Component

    attr_accessor(:positions)

    def initialize(positions)
        @positions = positions
    end
    
    def to_s
        return "Moves: #{@positions}"
    end
end
