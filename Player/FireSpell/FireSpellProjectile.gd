extends Area3D

var direction = Vector3.FORWARD
var speed = 30
var damage = 15
var ally
var pos

func _ready():
	global_position = pos

func _process(delta):
	global_position += direction * speed * delta

func _on_body_entered(body):
	if not body.is_in_group(ally):
		if body.has_method('take_damage'):
			body.take_damage(damage)
		queue_free()

func _on_expiration_timeout():
	queue_free()
