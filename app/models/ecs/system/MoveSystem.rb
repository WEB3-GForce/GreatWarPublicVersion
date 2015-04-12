require_relative "./System.rb"

=begin
    The Move System checks entities with position, motion, and move
    components, and updates an entity's position as specified by its
    move components (so long as it has enough motion left).

    The system can process multiple move components per entity,
    but they should be in the order that they should be executed.
=end
class MoveSystem < System
    def self.update(entity_manager)
        entity_manager.each_entity(PositionComponent, MotionComponent,
                MoveComponent).each { |id, components|

            position = components[PositionComponent].first
            motion = components[MotionComponent].first

            components[MoveComponent].each { |move| 
                move.positions.each { |new_position|
                    cost = position.distance_to(new_position)

                    next if motion.cur_movement < cost

                    motion.cur_movement -= cost

                    position.row = new_position.row
                    position.col = new_position.col                    
                }
            }
        }
    end
end