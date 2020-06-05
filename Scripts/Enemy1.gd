extends KinematicBody2D

const UP = Vector2(0,-1)
const ACCELERATION = 30
const GRAVITY = 10
const FALL_MAX = 300
const WALK_SPEED = 70
const DEATH_HEIGTH = 190

var motion = Vector2()
var isDead = false
var isGoingToRight = false
var movementDirectionIsChangable = true

func _ready():
	$Sprite.modulate = Color(0,0,0,1)

func _physics_process(delta):
	var friction = false
	if $".".position.y < DEATH_HEIGTH:
		if motion.y < FALL_MAX:
			motion.y += GRAVITY
	else:
		motion.y = 0
		isDead = true
		
	if !$RayCast_Floor.is_colliding() && movementDirectionIsChangable:
		ChangeMovementDirection()
		
	if isGoingToRight:
		motion.x = min(motion.x + ACCELERATION, WALK_SPEED)
		$RayCast_Floor.position.x = 10
		$Sprite.flip_h = false
		$Sprite.play("Run")
	elif !isGoingToRight:
		motion.x = max(motion.x - ACCELERATION, -WALK_SPEED)
		$RayCast_Floor.position.x = -10
		$Sprite.flip_h = true
		$Sprite.play("Run")
	else:
		friction = true
		$Sprite.play("Idle")
			
	if is_on_floor():
		if friction == true:
			motion.x = lerp(motion.x, 0, 0.2)
	else:
		if motion.y >= 0:
			$Sprite.play("Fall")
		if friction == true:
			motion.x = lerp(motion.x, 0, 0.05)
		
	motion = move_and_slide(motion, UP)

func Death():
	$Sprite.play("Hurt")
	$Sprite.modulate = Color(1,0.3,0.3,0.8)
	
func ChangeMovementDirection():
	movementDirectionIsChangable = false
	var changeMovementDirection = Timer.new()
	changeMovementDirection.set_wait_time(1)
	changeMovementDirection.set_one_shot(true)
	changeMovementDirection.connect("timeout",self,"setMovementChangable") 
	add_child(changeMovementDirection)
	changeMovementDirection.start()
	
	if isGoingToRight:
			isGoingToRight = false
	else: 
		isGoingToRight = true
		
func setMovementChangable():
	movementDirectionIsChangable = true


func _on_Area2D_Head_body_entered(body):
	if body.is_in_group("player"):
		body.jump()
		queue_free()
	pass # Replace with function body.
