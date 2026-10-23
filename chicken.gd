extends CharacterBody2D

@export var player: CharacterBody2D

@export var max_speed = 120.0 #increase if too slow
@onready var agent = $NavigationAgent2D
var hover_offset = Vector2(24, -24)
var repath_time = 0.0
var is_goal_set = false

func _physics_process(delta: float) -> void:
	if not is_instance_valid(player):
		velocity = Vector2.ZERO
		return
	
	if NavigationServer2D.map_get_iteration_id(agent.get_navigation_map()) == 0:
		return
	repath_time -= delta
	if repath_time <= 0:
		var goal = player.global_position + hover_offset
		if not is_goal_set or agent.target_position.distance_squared_to(goal) > 16.0:
			is_goal_set = true
			agent.target_position = goal
		repath_time = 0.1
	if agent.is_navigation_finished():
		velocity = Vector2.ZERO
		return
	
	var next_point = agent.get_next_path_position()
	velocity = global_position.direction_to(next_point) * max_speed
		
	move_and_slide()
