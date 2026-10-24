extends CharacterControllerPlatformer


var facing = 1.0
var max_velocity = 2
var breaking_force = 0.03
@export var max_health = 100
var current_health = max_health
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var sound_player: AudioStreamPlayer2D = %SoundPlayer

func _physics_process(delta: float) -> void:
	var input_dir := Vector2(Input.get_axis("move_left", "move_right"), Input.get_axis("move_up", "move_down"))
	CharacterVelocity.x += input_dir.x * CharacterMovement.Acceleration * delta
	if abs(CharacterVelocity.x) >= max_velocity:
		CharacterVelocity.x = max_velocity * sign(CharacterVelocity.x)
	
	if input_dir.x != 0:
		facing = sign(input_dir.x)
		if CanDash():
			if !sound_player.is_playing():
				sound_player.stream = preload("res://Roller Skating Sound Effect ⛸🔉 HQ.mp3")
				sound_player.play()
			animated_sprite.play("sprint")
		if facing > 0:
			animated_sprite.flip_h = false
		else:
			animated_sprite.flip_h = true
	elif CanDash() and onFloor:
		if abs(CharacterVelocity.x) > 0 and facing == sign(CharacterVelocity.x):
			animated_sprite.play("braking")
			CharacterVelocity.x -= breaking_force * sign(CharacterVelocity.x)
		else:
			sound_player.stop()
			animated_sprite.play("default")
		
		
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
		sound_player.stream = preload("res://assets/dash.wav")
		sound_player.play()
		Dash(dash_dir.angle())
		dashTimer = dashCooldown
	if Input.is_action_just_pressed("jump"):
		if onFloor:
			dashRemaining = 1
			sound_player.stream = preload("res://assets/jetpack.wav")
			sound_player.play()
		Jump()
	super._physics_process(delta)	
