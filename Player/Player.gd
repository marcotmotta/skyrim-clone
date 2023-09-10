extends CharacterBody3D

var max_health = 100
var health

var max_mana = 100
var mana
var mana_regen_per_second = 3
var mana_can_regen = true
var mana_regen_delay = 1

var max_stamina = 100
var stamina
var stamina_cost_per_second = 15
var stamina_regen_per_second = 5
var stamina_can_regen = true
var stamina_regen_delay = 1

var SPEED = 3
var JUMP_SPEED = 10

var camera
var rotation_helper
var first_person = true

var MOUSE_SENSITIVITY = 0.05

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var SPRINT_MULTIPLIER = 2
var is_sprinting = false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	# Camera
	camera = $Rotation_Helper/Camera
	rotation_helper = $Rotation_Helper

	# Health
	health = max_health
	$CanvasLayer/Control/HealthBar.max_value = max_health
	$CanvasLayer/Control/HealthBar.value = health

	# Mana
	mana = max_mana
	$CanvasLayer/Control/ManaBar.max_value = max_mana
	$CanvasLayer/Control/ManaBar.value = mana

	# Stamina
	stamina = max_stamina
	$CanvasLayer/Control/StaminaBar.max_value = max_stamina
	$CanvasLayer/Control/StaminaBar.value = stamina

func _process(delta):
	# Health
	$CanvasLayer/Control/HealthBar.value = health

	# Mana
	if mana_can_regen:
		mana = min(mana + mana_regen_per_second * delta, max_mana)
	$CanvasLayer/Control/ManaBar.value = mana

	# Stamina
	if stamina_can_regen:
		stamina = min(stamina + stamina_regen_per_second * delta, max_stamina)
	$CanvasLayer/Control/StaminaBar.value = stamina

	# Action1 (can hold)
	if Input.is_action_pressed("action1"):
		if $Rotation_Helper/Slot1.get_child_count():
			$Rotation_Helper/Slot1.get_child(0).action()

	# Action2 (can hold)
	if Input.is_action_pressed("action2"):
		if $Rotation_Helper/Slot2.get_child_count():
			if $Rotation_Helper/Slot2.get_child(0).has_method('get_mana_cost'):
				if mana >= $Rotation_Helper/Slot2.get_child(0).get_mana_cost():
					mana_can_regen = false
					$ManaRegenDelay.start(mana_regen_delay)
					$Rotation_Helper/Slot2.get_child(0).action(self)
			else:
				$Rotation_Helper/Slot2.get_child(0).action(self)

func _physics_process(delta):
	var camera_transform = camera.get_global_transform()

	# Vertical Velocity
	if not is_on_floor(): # If in the air, fall towards the floor. Literally gravity
		velocity.y -= gravity * delta * 2
	elif Input.is_action_just_pressed("space"): # Jumping
			velocity.y = JUMP_SPEED

	var direction = Vector3.ZERO
	
	var input_dir = Input.get_vector("a", "d", "s", "w")
	direction += -camera_transform.basis.z.normalized() * input_dir.y
	direction += camera_transform.basis.x.normalized() * input_dir.x
	direction.y = 0

	if direction != Vector3.ZERO:
		direction = direction.normalized()

	# Ground Velocity
	velocity.x = direction.x * SPEED
	velocity.z = direction.z * SPEED

	# Sprinting
	if Input.is_action_pressed("lshift") and is_on_floor() and direction != Vector3.ZERO:
		if stamina >= 0:
			stamina_can_regen = false
			$StaminaRegenDelay.start(stamina_regen_delay)
			stamina -= stamina_cost_per_second * delta
			velocity.x *= SPRINT_MULTIPLIER
			velocity.z *= SPRINT_MULTIPLIER

	# Moving the Character
	move_and_slide()

func _input(event):
	# Mouse rotation
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotation_helper.rotate_x(deg_to_rad(event.relative.y * MOUSE_SENSITIVITY * -1))
		self.rotate_y(deg_to_rad(event.relative.x * MOUSE_SENSITIVITY * -1))

		var camera_rot = rotation_helper.rotation_degrees
		camera_rot.x = clamp(camera_rot.x, -70, 70)
		rotation_helper.rotation_degrees = camera_rot

	# Capturing/Freeing the cursor
	if Input.is_action_just_pressed("esc"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	# Third person
	if Input.is_action_just_pressed("f5"):
		if first_person:
			camera.position.y = 3
			camera.position.z = 4
			camera.rotation_degrees.x = -35
			first_person = false
		else:
			camera.position.y = 0.6
			camera.position.z = -0.3
			camera.rotation_degrees.x = 0
			first_person = true

func _on_mana_regen_delay_timeout():
	mana_can_regen = true

func _on_stamina_regen_delay_timeout():
	stamina_can_regen = true

func take_damage(amount):
	health -= amount
