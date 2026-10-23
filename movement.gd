extends CharacterControllerPlatformer

var facing = 1.0
 
func _physics_process(delta: float) -> void:
	
	var input_dir := Vector2(Input.get_axis("move_left", "move_right"), Input.get_axis("move_up", "move_down"))
	CharacterVelocity.x = input_dir.x
	if input_dir.x != 0:
		facing = sign(input_dir.x); 
		
	if Input.is_action_just_pressed("jump"):
		Jump()
	
	if Input.is_action_just_released("jump"):
		StopJump()
	if Input.is_action_just_pressed("dash") && CanDash():
		var dash_dir := input_dir
		if dash_dir == Vector2.ZERO:
			dash_dir = Vector2(facing, 0.0)
		
		Dash(dash_dir.angle())
	super._physics_process(delta)	
