extends Area3D

var DAMAGE_PER_SECOND = 50
var TICK_RATE = 0.2

var mana_cost_per_second = 20

var can_damage = true

func _ready():
	pass # Replace with function body.

func _process(delta):
	pass

func get_mana_cost():
	return mana_cost_per_second * TICK_RATE

func action(caster):
	if caster.mana >= get_mana_cost():
		if can_damage:
			caster.mana -= get_mana_cost()
			for body in get_overlapping_bodies():
				if body.is_in_group('enemy'):
					if body.has_method('take_damage'):
						body.take_damage(DAMAGE_PER_SECOND * TICK_RATE)
			can_damage = false
			$TickRate.start(TICK_RATE)
			$Fire.emitting = true
			$FireSpell.emitting = false

func _on_tick_rate_timeout():
	can_damage = true
	$Fire.emitting = false
	$FireSpell.emitting = true
