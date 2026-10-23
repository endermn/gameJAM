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
		animated_sprite.play("sprint")
		if facing > 0:
			animated_sprite.flip_h = false
		else:
			animated_sprite.flip_h = true
	else:
		animated_sprite.play("default")
		animated_sprite.frame = 0
		animated_sprite.pause()
		
		
	if Input.is_action_just_pressed("jump"):
		Jump()
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
		if input_dir.x != sign(CharacterVelocity.x):
			CharacterVelocity.x *= -1
		
		Dash(dash_dir.angle())
	super._physics_process(delta)	
