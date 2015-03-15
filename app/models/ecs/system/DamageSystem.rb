require_relative "./System.rb"

=begin
    The Damage System checks entities with health and damage
    components, subtracting the damage represented by the damage
    components from an entity's health as represented by its
    health component.

    The system can process multiple damage components per entity,
    but it assumes an entity has only one health component.
=end
class DamageSystem < System
    def self.update(entity_manager)
        entity_manager.each_entity(
                HealthComponent, DamageComponent).each { |id, components|

            health = components[HealthComponent].first

            components[DamageComponent].each { |damage|
                health.cur_health -= damage.amount
            }
        }
    end
end