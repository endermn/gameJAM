class_name CharacterController2D extends CharacterBody2D



#################################
#||                            ||
#||     Default Variables      ||
#||                            ||
#################################

@export var CharacterMovement:PlatformerResource;

## The character's velocity value. This value works in accordance with acceleration and friction.
var CharacterVelocity:Vector2 = Vector2.ZERO;
## For final friction value, Normal friction and Air Friction.
@onready var RealFriction:float = CharacterMovement.Friction;
## For final acceleration value, Normal acceleration and Air acceleration.
@onready var RealAcceleration:float = CharacterMovement.Acceleration;

var physicsfps:int = 0;
var cVelocity:Vector2 = Vector2.ZERO;
var deactive_input:float = 0.;
var move_cooldown:Vector2 = Vector2(0.,0.);
var dashIsActive:bool = false;
var dashRemaining:int = 0;

#################################
#||                            ||
#||          Signals           ||
#||                            ||
#################################

signal onDash
signal onDashFinished

func Dash(direction:float):
		dashRemaining -= 1;
		var multiplier:Vector2 = Vector2.ONE;
		var _d = round(rad_to_deg(direction))
		if _d == 0: multiplier.x = CharacterMovement.Dash_right_scale;
		elif _d == 180: multiplier.x = CharacterMovement.Dash_left_scale;
		elif _d >= -90-45 && _d <= -90+45: multiplier.y = CharacterMovement.Dash_up_scale;
		elif _d == 90: multiplier.y = CharacterMovement.Dash_down_scale;
		var speed = Vector2.RIGHT.rotated((direction) );
		cVelocity = speed * CharacterMovement.Dash_Strength * multiplier * physicsfps;
		deactive_input = CharacterMovement.Dash_input_cooldown;
		move_cooldown = Vector2(.5, 1) * CharacterMovement.Dash_input_cooldown;
		dashIsActive = true;
		onDash.emit();
		await get_tree().create_timer(CharacterMovement.Dash_Strength * CharacterMovement.Dash_input_cooldown).timeout;
		dashIsActive = false;
		onDashFinished.emit();

func CanDash() -> bool:
	return dashRemaining > 0;
