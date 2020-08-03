extends KinematicBody2D

export(NodePath) var SpawnPoint
export(NodePath) var EndPoint
export(NodePath) var LifebarNode
export var healthPoints = 3

const UP = Vector2(0,-1)
const ACCELERATION = 30
const GRAVITY = 10
const FALL_MAX = 300
const WALK_SPEED = 70
const RUN_SPEED = 120
const JUMP_HEIGTH = -280
const DEATH_HEIGTH = 190

var endpoint
var lifebar
var arrayLifebar
var friction
var isDead = false
var isHurt = false
var isInvincible = false
var levelIsOver = false
var motion = Vector2()

func _ready():
	$".".position = get_node(SpawnPoint).position
	endpoint = get_node(EndPoint).position
	lifebar = get_node(LifebarNode).find_node("Lifebar")
	arrayLifebar = [preload("res://Sprites/Player/Health/0hearts.png"),
		preload("res://Sprites/Player/Health/1hearts.png"),
		preload("res://Sprites/Player/Health/2hearts.png"),
		preload("res://Sprites/Player/Health/3hearts.png")
	]
	lifebar.set_texture(arrayLifebar[healthPoints])

func _physics_process(delta):
	friction = false
	
	if healthPoints <= 0:
		isDead = true

	if isDead == true:
		death()
		return

	if levelIsOver == true:
		levelEnd()
		return

	if $".".position.y < DEATH_HEIGTH:
		if motion.y < FALL_MAX:
			motion.y += GRAVITY
	else:
		motion.y = 0
		isDead = true

	if $".".position.x > endpoint.x - 50:
		levelIsOver = true
		
	if Input.is_key_pressed(KEY_D):
		if Input.is_key_pressed(KEY_L):
			walk("right", true)
		else: 
			walk("right", false)
		
	elif Input.is_key_pressed(KEY_A):
		if Input.is_key_pressed(KEY_L):
			walk("left", true)
		else: 
			walk("left", false)
	else:
		idle()
		
	if is_on_floor():
		if Input.is_key_pressed(KEY_SPACE):
			jump()
		if friction == true:
			motion.x = lerp(motion.x, 0, 0.2)
	else:
		if motion.y < 0:
			if isHurt == false:
				$Sprite.play("Jump")
		else:
			if isHurt == false:
				$Sprite.play("Fall")
		if friction == true:
			motion.x = lerp(motion.x, 0, 0.05)
			
	motion = move_and_slide(motion, UP)
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		for collisionGroup in collision.collider.get_groups():
			if collisionGroup == "Spikes":
				hurt()
				
func jump():
	motion.y = JUMP_HEIGTH
	
func walk(var direction, var isRunning):
	if (direction == "right"):
		if isRunning:
			motion.x = min(motion.x + ACCELERATION, RUN_SPEED)
		else:
			motion.x = min(motion.x + ACCELERATION, WALK_SPEED)
		$Sprite.flip_h = false
	else:
		if isRunning:
			motion.x = max(motion.x - ACCELERATION, -RUN_SPEED)
		else:
			motion.x = max(motion.x - ACCELERATION, -WALK_SPEED)
		$Sprite.flip_h = true
	
	if isHurt == false:
		$Sprite.play("Run")
		
func idle():
		friction = true
		if isInvincible == false:
			$Sprite.play("Idle")

func death():
	$Sprite.play("Hurt")
	$Sprite.modulate = Color(1,0.3,0.3,0.8)
	healthPoints = 0
	lifebar.set_texture(arrayLifebar[healthPoints])
	var resetLevelTimer = Timer.new()
	resetLevelTimer.set_wait_time(3)
	resetLevelTimer.set_one_shot(true)
	resetLevelTimer.connect("timeout",self,"resetLevel") 
	add_child(resetLevelTimer)
	resetLevelTimer.start()

func levelEnd():
	if motion.y < FALL_MAX:
		motion.y += GRAVITY
	if !is_on_floor():
		$Sprite.play("Fall")
		motion.x = 0
	else:
		$Sprite.play("Run")
		if $".".position.x > endpoint.x:
			$".".visible = false
			motion.x = 0
			var resetLevelTimer = Timer.new()
			resetLevelTimer.set_wait_time(3)
			resetLevelTimer.set_one_shot(true)
			resetLevelTimer.connect("timeout",self,"resetLevel") 
			add_child(resetLevelTimer)
			resetLevelTimer.start()
		else: 
			motion.x = WALK_SPEED
	motion = move_and_slide(motion, UP)

func hurt():
	if isInvincible == false:
		isInvincible = true
		isHurt = true
		$Sprite.play("Hurt")
		healthPoints = healthPoints - 1
		lifebar.set_texture(arrayLifebar[healthPoints])
		set_collision_layer_bit(0, false)
		var InvincibleTimer = Timer.new()
		InvincibleTimer.set_wait_time(2)
		InvincibleTimer.set_one_shot(true)
		InvincibleTimer.connect("timeout",self,"removeInvincibilityFrames") 
		add_child(InvincibleTimer)
		InvincibleTimer.start()
		var HurtTimer = Timer.new()
		HurtTimer.set_wait_time(1)
		HurtTimer.set_one_shot(true)
		HurtTimer.connect("timeout",self,"stopHurtAnimation") 
		add_child(HurtTimer)
		HurtTimer.start()

func stopHurtAnimation():
	isHurt = false

func removeInvincibilityFrames():
	isInvincible = false
	set_collision_layer_bit(0, true)

func resetLevel():
   get_tree().reload_current_scene()
