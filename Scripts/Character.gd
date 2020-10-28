# No 'player controller' scripts here, but generic stuff for any characters!
class_name Character
extends KinematicBody

enum CHARACTER_STATE { 
	IDLE , 
	WALKING , 
	ON_AIR ,
	LADDER # soon!
}
const GRAV_ACCEL = 100

# Controllers/Behaviors should be accessing and modifying these variables:
export (String) var character_name = 'Character'
export (float) var horizontal_speed = 20.0; # Final induced horizontal speed will be multiplied by input_direction.x
export (float) var vertical_speed = 10.0; # Final induced vertical speed will be multiplied by input_direction.x
export (Vector2) var input_direction = Vector2(0,0) setget setInputDirection 
var character_state = CHARACTER_STATE.IDLE setget setCharacterState
var linear_velocity = Vector2(0,0) # linear_velocity could contain input_direction, gravity, knockback , etc...

# Don't touch these variables from outside!
onready var model_anim_player = $model_root.find_node('AnimationPlayer')

func _ready():
	move_lock_z = true
	_enteredState(character_state)

func _physics_process(delta):
	
	linear_velocity = Vector3(
		horizontal_speed * input_direction.x ,
		linear_velocity.y - GRAV_ACCEL*delta,
		0
	)
	move_and_slide( linear_velocity )
	
	for i in range(0,get_slide_count()):
		var col = get_slide_collision(i)
		if col.normal.normalized().y > 0.1 :
			linear_velocity.y = 0
	
	avaliateCharacterState()

func avaliateCharacterState():
	if is_on_floor() and linear_velocity.y<0.1 :
		if linear_velocity.x * input_direction.x > 0 :
			setCharacterState(CHARACTER_STATE.WALKING)
		else:
			setCharacterState(CHARACTER_STATE.IDLE)
	else:
		setCharacterState(CHARACTER_STATE.ON_AIR)

func is_on_floor() -> bool :
	return test_move(transform,Vector3(0,-0.3,0))

func jump():
	if linear_velocity.y <= 0 and is_on_floor() :
		linear_velocity.y = 30
		setCharacterState(CHARACTER_STATE.ON_AIR)

func setInputDirection(new_dir):
	input_direction = new_dir
	if( input_direction.x != 0 ):
		# Only rotating it's geometry, not CollisionShape and other stuffs
		$model_root.rotation_degrees.y = -45 + 90*int(input_direction.x>0)
	if( input_direction.length_squared() > 1 ):
		input_direction = input_direction.normalized()

func setCharacterState(new_state):
	if character_state != new_state:
		_exitedState(character_state)
		character_state = new_state
		_enteredState(character_state)

func _enteredState(state):
	match state:
		CHARACTER_STATE.IDLE:
			model_anim_player.play("Standing")
		CHARACTER_STATE.WALKING:
			model_anim_player.play("Walking")
		CHARACTER_STATE.ON_AIR:
			model_anim_player.play("Jumping")

func _exitedState(state):
	pass
