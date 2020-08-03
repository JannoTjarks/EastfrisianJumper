extends KinematicBody2D

const UP = Vector2(0,-1)
const ACCELERATION = 30
const GRAVITY = 10
const FALL_MAX = 300
const WALK_SPEED = 70
const DEATH_HEIGTH = 190

var motion = Vector2()
var rayCastFloorOffset = 15
var rayCastWallOffset = 12
var isDead = false
var isGoingToRight = false
var movementDirectionIsChangable = true

func _physics_process(delta):	
	var friction = false
	if $".".position.y < DEATH_HEIGTH:
		if motion.y < FALL_MAX:
			motion.y += GRAVITY
	else:
		motion.y = 0
		isDead = true
		
	if (!$RayCast_Floor.is_colliding() || $RayCast_Wall.is_colliding()) && movementDirectionIsChangable:
		ChangeMovementDirection()
	
	$Sprite.play()
	
	if isGoingToRight:
		motion.x = min(motion.x + ACCELERATION, WALK_SPEED)
		$RayCast_Floor.position.x = rayCastFloorOffset
		$RayCast_Wall.position.x = rayCastWallOffset
		$RayCast_Wall.scale.x = 1
		$Sprite.flip_h = false
	elif !isGoingToRight:
		motion.x = max(motion.x - ACCELERATION, -WALK_SPEED)
		$RayCast_Floor.position.x = rayCastFloorOffset * -1
		$RayCast_Wall.position.x = rayCastWallOffset * -1
		$RayCast_Wall.scale.x = -1
		$Sprite.flip_h = true
	else:
		friction = true
			
	if is_on_floor():
		if friction == true:
			motion.x = lerp(motion.x, 0, 0.2)
		
	motion = move_and_slide(motion, UP)

func Death():
	$Sprite.modulate = Color(1,0.3,0.3,0.8)
	$Area2D_Body.monitoring = false
	var deathTimer = Timer.new()
	deathTimer.set_wait_time(0.1)
	deathTimer.set_one_shot(true)
	deathTimer.connect("timeout",self,"queue_free") 
	add_child(deathTimer)
	deathTimer.start()
	
func ChangeMovementDirection():
	movementDirectionIsChangable = false
	var changeMovementDirection = Timer.new()
	changeMovementDirection.set_wait_time(0.5)
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
	if body.get_collision_layer_bit(0):	
		Death()
		body.jump()

func _on_Area2D_Body_body_entered(body):	
	if body.get_collision_layer_bit(0):
		body.hurt()
