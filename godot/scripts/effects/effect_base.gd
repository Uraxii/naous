@abstract
class_name EffectBase extends Resource

## An "effect" is anything that may alter some other entity. It may be comprised of one or more parts and may have varying conditions or steps to fully apply.
## Example Effects:
# 1. Damage target
# 2. Heal target
# 3. Apply camera affect (eg. change FoV, apply fishbowl effect)
# 4. Apply debuff to target (eg. poison, slow)
# 5. Spawn projectile

## From there, an entity can trigger or activate its effects as it sees fit.
## Example Usage:
# 1. An area-of-effect spell that damages nearby enemies. May be modified to add a poison effect to damaged enemies.
# 2. An area-of-effect spell that heals nearby allies.
# 3. A sword that does basic "slash" damage.
# 4. A magic wand that spawns and launches projectiles that have their own effect that deals ice damage and applies an slowing debuff.


## Override with child classes
@abstract
func apply_effect_to_entity(entity: Entity) -> void
