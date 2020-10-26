# No 'player controller' scripts here, but generic stuff for any characters!
extends KinematicBody

enum CHARACTER_STATE { 
	IDLE , 
	WALKING , 
	ON_AIR ,
	LADDER # soon!
}
const GRAV_ACCEL = 100

export (String) var character_name = 'Character'
export (float) var horizontal_speed = 20.0; # Final induced horizontal speed will be multiplied by input_direction.x
export (float) var vertical_speed = 10.0; # Final induced vertical speed will be multiplied by input_direction.x
export (Vector2) var input_direction = Vector2(0,0) setget setInputDirection 
var character_state = CHARACTER_STATE.IDLE setget setCharacterState
var linear_velocity = Vector2(0,0) # linear_velocity could contain input_direction, gravity, knockback , etc...
var on_floor = false

func _ready():
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
			if character_state == CHARACTER_STATE.ON_AIR:
				setCharacterState(CHARACTER_STATE.IDLE)

func jump():
	if linear_velocity.y <= 0 and test_move(transform,Vector3(0,-0.3,0)) :
		linear_velocity.y = 30
		setCharacterState(CHARACTER_STATE.ON_AIR)

func setInputDirection(new_dir):
	input_direction = new_dir
	if( input_direction.x != 0 ):
		# Only rotating it's geometry, not CollisionShape and other stuffs
		$character_template.rotation_degrees.y = -45 + 90*int(input_direction.x>0)
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
			$character_template/AnimationPlayer.play("Idle")
		CHARACTER_STATE.WALKING:
			$character_template/AnimationPlayer.play("Walking")
		CHARACTER_STATE.ON_AIR:
			$character_template/AnimationPlayer.play("Jumping")

func _exitedState(state):
	pass
