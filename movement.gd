extends CharacterControllerPlatformer


var facing = 1.0
var max_velocity = 2
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
 
func _physics_process(delta: float) -> void:
	
	var input_dir := Vector2(Input.get_axis("move_left", "move_right"), Input.get_axis("move_up", "move_down"))
	CharacterVelocity.x += input_dir.x * CharacterMovement.Acceleration * delta
	if abs(CharacterVelocity.x) >= max_velocity:
		CharacterVelocity.x = max_velocity * sign(CharacterVelocity.x)
	
	if input_dir.x != 0:
		facing = sign(input_dir.x)
		if CanDash():
			animated_sprite.play("sprint")
		if facing > 0:
			animated_sprite.flip_h = false
		else:
			animated_sprite.flip_h = true
	elif CanDash():
		animated_sprite.play("default")
		animated_sprite.frame = 0
		
		
	if onFloor:
		CharacterVelocity.x -= CharacterMovement.Friction * abs(CharacterVelocity.x) * sign(CharacterVelocity.x)
	
	if Input.is_action_just_released("jump"):
		StopJump()
	if Input.is_action_just_pressed("dash") && CanDash():
		var dash_dir := input_dir
		if dash_dir == Vector2.ZERO:
			dash_dir = Vector2(facing, 0.0)
		print(dash_dir)
		if dash_dir.x == 0:
			CharacterVelocity.x = 0
		if facing != sign(CharacterVelocity.x):
			CharacterVelocity.x *= -1
		animated_sprite.play("dash")
		Dash(dash_dir.angle())
		dashTimer = dashCooldown
	if Input.is_action_just_pressed("jump"):
		dashRemaining = 1
		Jump()
	super._physics_process(delta)	
