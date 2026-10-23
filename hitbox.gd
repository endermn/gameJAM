extends Area2D


@export var damage: int = 10
@export var knockback_force: float = 150.0

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	if area is Hurtbox:
		var direction := (area.global_position - global_position).normalized()
		area.take_damage(damage, direction * knockback_force)
