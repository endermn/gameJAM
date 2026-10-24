extends Area2D
class_name Hitbox
#bottom ten codes of all time
@export var actor: Node2D
@export var damage = 10
@export var knockback_force = 150.0
var is_attacking = false
var hit_characters = []

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func begin_attack() -> void:
	if is_attacking or not is_instance_valid(actor):
		return
	is_attacking = true
	hit_characters.clear()
	for area in get_overlapping_areas():
		check_hit(area)

func end_attack() -> void:
	is_attacking = false
	hit_characters.clear()

func _on_area_entered(area: Area2D) -> void:
	check_hit(area)

func check_hit(area) -> void:
	if not is_attacking or not is_instance_valid(actor):
		return
	if not is_instance_valid(area) or not area is Hurtbox:
		return
	var target = area.actor
	if not is_instance_valid(target) or target == actor or target.is_queued_for_deletion():
		return
	if target in hit_characters:
		return
	hit_characters.append(target)
	var direction = (target.global_position - actor.global_position).normalized()
	area.take_damage(damage, direction * knockback_force) #cus like u need kb to defend urself
