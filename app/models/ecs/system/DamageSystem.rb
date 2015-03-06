

class DamageSystem
    def self.update(entity_manager)
        entity_manager.each_entity(
                HealthComponent, DamageComponent).each { |id, components|
            health = components[HealthComponent].first
            damage = components[DamageComponent].first
            health.cur_health -= damage.amount
        }
    end
end