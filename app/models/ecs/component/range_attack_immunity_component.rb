require_relative "./component.rb"

=begin
	The RangeAttackImmunityComponent grants entities invulnerability to
	range attacks. For example, the command bunker entity has the
	RangeAttackImmunityComponent, which means that an opponent can not easily
	win the game by using artillery against the bunker. The opponent must
	use melee attacks to capture the bunker.
=end
class RangeAttackImmunityComponent < Component
end
