extends CharacterControllerPlatformer


var facing = 1.0
var max_velocity = 2
var max_cvelocity = 300
var breaking_force = 0.03

var jump_animation_vel = 50
@export var max_health = 100
var current_health = max_health
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var sound_player: AudioStreamPlayer2D = %SoundPlayer
@onready var hitbox_yoyo: AnimatedSprite2D = %PlayerHitboxSprite
var attackCooldown = 48
var attackCounter = 0

func _ready() -> void:
    super._ready()
    current_health = max_health
    $Hurtbox.recieved_damage.connect(_on_recieved_damage)

func _physics_process(delta: float) -> void:
    var input_dir := Vector2(Input.get_axis("move_left", "move_right"), Input.get_axis("move_up", "move_down"))
    CharacterVelocity.x += input_dir.x * CharacterMovement.Acceleration * delta
    if abs(CharacterVelocity.x) >= max_velocity:
        CharacterVelocity.x = max_velocity * sign(CharacterVelocity.x)
    if abs(CharacterVelocity.y) >= max_velocity:
        CharacterVelocity.y = max_velocity * sign(CharacterVelocity.y)
    if abs(cVelocity.y) >= max_cvelocity:
        cVelocity.y = max_cvelocity * sign(cVelocity.y)
    if animated_sprite.animation == "attack" and animated_sprite.is_playing() and animated_sprite.frame != 7:
        if animated_sprite.frame == 3 or animated_sprite.frame == 5:
            hitbox_yoyo.visible = true
            hitbox_yoyo.frame = 0
        elif animated_sprite.frame == 4:
            hitbox_yoyo.visible = true
            hitbox_yoyo.frame = 1
        else:
            hitbox_yoyo.visible = false
    if input_dir.x != 0:
        facing = sign(input_dir.x)
        if CanDash():
            if !sound_player.is_playing():
                sound_player.stream = preload("res://Roller Skating Sound Effect ⛸🔉 HQ.mp3")
                sound_player.play()
            if attackCounter <= 0:
                animated_sprite.play("sprint")
        if facing > 0:
            animated_sprite.flip_h = false
        else:
            animated_sprite.flip_h = true
    elif CanDash() and onFloor:
        if abs(CharacterVelocity.x) > 0 and facing == sign(CharacterVelocity.x):
            if attackCounter <= 0:
                animated_sprite.play("braking")
            CharacterVelocity.x -= breaking_force * sign(CharacterVelocity.x)
        else:
            sound_player.stop()
            if attackCounter <= 0:
                animated_sprite.play("default")


    if onFloor:
        CharacterVelocity.x -= CharacterMovement.Friction * abs(CharacterVelocity.x) * sign(CharacterVelocity.x)

    if Input.is_action_just_released("jump"):
        StopJump()
    if Input.is_action_just_pressed("dash") && CanDash():
        var dash_dir := input_dir
        if dash_dir == Vector2.ZERO:
            dash_dir = Vector2(facing, 0.0)
        if dash_dir.x == 0:
            CharacterVelocity.x = 0
        if facing != sign(CharacterVelocity.x):
            CharacterVelocity.x *= -1
        if attackCounter <= 0:
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

    if !onFloor and cVelocity.y < jump_animation_vel and cVelocity.y > -jump_animation_vel:
        if attackCounter <= 0:
            animated_sprite.play("jump")
        animated_sprite.frame = 1
    elif !onFloor and cVelocity.y > jump_animation_vel:        
        if attackCounter <= 0:
            animated_sprite.play("jump")
        animated_sprite.frame = 2
        animated_sprite.pause()
    elif !onFloor and cVelocity.y < -jump_animation_vel:        
        if attackCounter <= 0:
            animated_sprite.play("jump")
        animated_sprite.frame = 0
        animated_sprite.pause()
    $Hitbox.scale.x = facing
    if Input.is_action_just_pressed("attack") and attackCounter <= attackCooldown and onFloor and not dashIsActive:
        animated_sprite.play("attack")
        attackCounter = attackCooldown
        $Hitbox.begin_attack()
    elif dashIsActive:
        $Hitbox.begin_attack()
    else:
        $Hitbox.end_attack()
    attackCounter -= 1
    super._physics_process(delta)

func _on_recieved_damage(amount: int, knockback: Vector2) -> void:
    if current_health <= 0:
        return
    current_health = maxi(current_health - amount, 0)
    cVelocity += knockback
