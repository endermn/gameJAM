extends Area2D
class_name Hurtbox

signal recieved_damage(amount: int, knockback: Vector2)
@export var actor: Node2D

func take_damage(amount: int, knockback: Vector2 = Vector2.ZERO) -> void:
	if not is_instance_valid(actor):
		return
	if amount <= 0 or actor.is_queued_for_deletion():
		return
	recieved_damage.emit(amount, knockback)
