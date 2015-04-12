require_relative "./System.rb"

=begin
    The Kill System checks entities with health components, and removes
    ones that are no longer alive from the entity manager.
=end
class DamageSystem < System
    def self.update(entity_manager)
        entity_manager.each_entity(HealthComponent).each { |id, components|
            health = components[HealthComponent]
            entity_manager.delete(id) unless health.all? { |h| h.alive? }
        }
    end
end