extends KinematicBody2D

export(NodePath) var SpawnPoint

const UP = Vector2(0,-1)
const ACCELERATION = 30
const GRAVITY = 10
const WALK_SPEED = 70
const RUN_SPEED = 120
const JUMP_HEIGTH = -250
const DEATH_HEIGTH = 190

var isFallingToDeath = false
var motion = Vector2()

func _ready():
	$".".position = get_node(SpawnPoint).position

func _physics_process(delta):
	var friction = false
	
	if $".".position.y < DEATH_HEIGTH:
		motion.y += GRAVITY
	else:
		motion.y = 0
		isFallingToDeath = true
	
	if Input.is_key_pressed(KEY_D):
		if Input.is_key_pressed(KEY_L):
			motion.x = min(motion.x + ACCELERATION, RUN_SPEED)
		else: 
			motion.x = min(motion.x + ACCELERATION, WALK_SPEED)
		$Sprite.flip_h = false
		$Sprite.play("Run")
	
	elif Input.is_key_pressed(KEY_A):
		if Input.is_key_pressed(KEY_L):
			motion.x = max(motion.x - ACCELERATION, -RUN_SPEED)
		else: 
			motion.x = max(motion.x - ACCELERATION, -WALK_SPEED)
		$Sprite.flip_h = true
		$Sprite.play("Run")
	else:
		friction = true
		$Sprite.play("Idle")

	if is_on_floor():
		if Input.is_key_pressed(KEY_SPACE):
			motion.y = JUMP_HEIGTH
		if friction == true:
			motion.x = lerp(motion.x, 0, 0.2)
	else:
		if motion.y < 0:
			$Sprite.play("Jump")
		else:
			if isFallingToDeath == false:
				$Sprite.play("Fall")
			else:
				$Sprite.play("Hurt")
				$Sprite.modulate = Color(1,0.3,0.3,0.8)
		if friction == true:
			motion.x = lerp(motion.x, 0, 0.05)

	motion = move_and_slide(motion, UP)
