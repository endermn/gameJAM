extends CharacterBody2D

signal died

@export var patrol_speed = 35.0
@export var chase_speed = 70.0
@export var patrol_distance = 80.0
@export var detection_range = 180.0
@export var max_health = 30
@onready var player = get_tree().get_first_node_in_group("player")
@onready var animated_sprite = $AnimatedSprite2D
@onready var hitbox = $Hitbox
@onready var hurtbox = $Hurtbox
@onready var attack_cooldown = $AtkCD
@onready var floor_check = $FloorCheck

var direction = 1.0
var start_x = 0.0
var current_health = 0
var is_attacking = false
var hurt_time = 0.0

func _ready() -> void:
	start_x = global_position.x
	current_health = max_health
	hurtbox.recieved_damage.connect(_on_recieved_damage)
	animated_sprite.animation_finished.connect(_on_animation_finished)
	animated_sprite.play("default")

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	if current_health <= 0 or hurt_time > 0:
		hurt_time -= delta
		velocity.x = move_toward(velocity.x, 0, 400 * delta)
		move_and_slide()
		return
	if is_attacking:
		velocity.x = 0
		if animated_sprite.frame >= 2 and animated_sprite.frame <= 3:
			hitbox.begin_attack()
		else:
			hitbox.end_attack()
		move_and_slide()
		return
	if not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player")
	var chasing = is_instance_valid(player) and not player.is_queued_for_deletion() and global_position.distance_to(player.global_position) <= detection_range
	var move_speed = patrol_speed
	if chasing:
		var offset = player.global_position - global_position
		move_speed = chase_speed
		if abs(offset.x) > 1:
			direction = sign(offset.x)
		else:
			move_speed = 0
		face_direction()
		if is_on_floor() and hitbox.overlaps_area(player.get_node("Hurtbox")):
			velocity.x = 0
			if attack_cooldown.is_stopped():
				is_attacking = true
				animated_sprite.play("attack")
			else:
				animated_sprite.play("default")
			move_and_slide()
			return
	else:
		if global_position.x >= start_x + patrol_distance:
			direction = -1.0
		elif global_position.x <= start_x - patrol_distance:
			direction = 1.0
		if is_on_wall() and get_wall_normal().x * direction < 0:
			direction *= -1
	face_direction()
	floor_check.force_raycast_update()
	if is_on_floor() and not floor_check.is_colliding():
		if chasing:
			move_speed = 0
		else:
			direction *= -1
			face_direction()
	velocity.x = direction * move_speed
	if velocity.x == 0:
		animated_sprite.play("default")
	else:
		animated_sprite.play("run")
	move_and_slide()

func face_direction() -> void:
	animated_sprite.flip_h = direction < 0
	hitbox.scale.x = direction
	floor_check.position.x = 18 * direction

func _on_recieved_damage(amount: int, knockback: Vector2) -> void:
	if current_health <= 0:
		return
	current_health = maxi(current_health - amount, 0)
	velocity = knockback
	is_attacking = false
	hitbox.end_attack()
	attack_cooldown.start()
	if current_health == 0:
		animated_sprite.play("death")
	else:
		hurt_time = 0.2
		animated_sprite.play("hurt")

func _on_animation_finished() -> void:
	if animated_sprite.animation == "attack":
		hitbox.end_attack()
		is_attacking = false
		attack_cooldown.start()
	elif animated_sprite.animation == "death":
		died.emit()
