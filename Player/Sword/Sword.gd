extends Area3D

const DAMAGE = 20

func _ready():
	$AnimationPlayer.play("Idle")

func action():
	if not $AnimationPlayer.get_current_animation() in ['swing', 'swing_back']:
		$AnimationPlayer.play("swing")
		$AnimationPlayer.queue("swing_back")

func _process(_delta):
	#print($CollisionShape.disabled)
	pass

func _on_body_entered(body):
	if body.is_in_group('enemy'):
		if body.has_method('take_damage'):
			body.take_damage(DAMAGE)

func _on_animation_player_animation_finished(anim_name):
	if anim_name == 'swing_back':
		$AnimationPlayer.play("Idle")
