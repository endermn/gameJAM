extends Area2D
class_name Hurtbox

signal recieved_damage(amount: int, knockback: Vector2)

func take_damage(amount: int, knockback: Vector2 = Vector2.ZERO) -> void:
	recieved_damage.emit(amount, knockback)
