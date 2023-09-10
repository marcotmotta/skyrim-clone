extends CharacterBody3D

const SPEED = 2

const MAX_HEALTH = 100
var health

var player
# var patrol_distance = 15
var patrol_direction
var idle_timer = 2
var patrol_timer = 3

var damage = 10

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

enum {
	IDLE,
	PATROL,
	RUN,
	ATTACK
}

var state = IDLE

var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()
	player = get_parent().get_node('Player')

	health = MAX_HEALTH

	setState(IDLE)

func _physics_process(delta):
	# Vertical Velocity
	# Must be here so the character falls even if its not moving horizontally
	if not is_on_floor(): # If in the air, fall towards the floor. Literally gravity
		velocity.y -= gravity * delta * 3
		move_and_slide()

	match state:
		IDLE:
			$WarriorModel/AnimationPlayer.play("Idle")
			pass
		PATROL:
			process_movement(patrol_direction)
			$WarriorModel/AnimationPlayer.play("Walk")
			#if check_patrol_distance() <= 2:
			#	setState(IDLE)
		RUN:
			process_movement((player.position - self.position).normalized())
			$WarriorModel/AnimationPlayer.play("Walk")
		ATTACK:
			$WarriorModel/AnimationPlayer.play("Attack")
			pass

func setState(new_state):
	# What to do when some state begin
	match new_state:
		IDLE:
			$IdleTimer.start(idle_timer)
		PATROL:
			patrol_direction = choose_patrol_direction()
			$PatrolTimer.start(patrol_timer)
		RUN:
			pass
		ATTACK:
			look_at(player.position, Vector3.UP)
	state = new_state

func is_in_state(current_state):
	return  state == current_state

func process_movement(direction):
	look_at(self.position + direction, Vector3.UP)

	# Ground Velocity
	velocity.x = direction.x * SPEED
	velocity.z = direction.z * SPEED

	move_and_slide()

func choose_patrol_direction():
	var new_point = Vector3()
	new_point.y = 0
	new_point.x = rng.randi_range(-1, 1)
	new_point.z = rng.randi_range(-1, 1)
	return new_point.normalized()

func check_patrol_distance():
	var pos = Vector3()
	pos.y = 0
	pos.x = self.position.x
	pos.z = self.position.z
	return pos.distance_to(patrol_direction)

func _on_idle_timer_timeout():
	if is_in_state(IDLE):
		setState(PATROL)

func _on_patrol_timer_timeout():
	if is_in_state(PATROL):
		setState(IDLE)

func _on_sight_range_body_entered(body):
	if body.is_in_group('player'):
		setState(RUN)

func _on_sight_range_body_exited(body):
	if body.is_in_group('player'):
		setState(IDLE)

func _on_attack_range_body_entered(body):
	if body.is_in_group('player'):
		setState(ATTACK)

func attack_area_entered(body):
	if body.is_in_group('player') and body.has_method('take_damage'):
		body.take_damage(damage)

func animation_finished(anim_name):
	if anim_name == "Attack":
		setState(IDLE)
		$SightRange/CollisionShape3D.disabled = true
		$SightRange/CollisionShape3D.disabled = false
		$AttackRange/CollisionShape3D.disabled = true
		$AttackRange/CollisionShape3D.disabled = false

func take_damage(amount):
	print(amount)
	health -= amount

	if health <= 0:
		die()

func die():
	queue_free()
