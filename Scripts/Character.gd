# No 'player controller' scripts here, but generic stuff for any characters!
class_name Character
extends KinematicBody

enum CHARACTER_STATE { 
	IDLE , 
	WALKING , 
	ON_AIR ,
	ACTION ,
	DISABLED ,
	LADDER # soon!
}
signal triggering_action
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
	
	var target_x_linear_velocity = 0
	if not is_on_floor():
		target_x_linear_velocity = linear_velocity.x
	if ( is_on_floor() 
	and character_state != CHARACTER_STATE.ACTION
	and character_state != CHARACTER_STATE.DISABLED):
		target_x_linear_velocity = input_direction.x * horizontal_speed

	linear_velocity.x = lerp( linear_velocity.x , target_x_linear_velocity , 0.8)
	linear_velocity.x = clamp(linear_velocity.x , -horizontal_speed , horizontal_speed )
	linear_velocity.y -= GRAV_ACCEL*delta
	
	move_and_slide( Vector3(linear_velocity.x,linear_velocity.y,0) )
	
	for i in range(0,get_slide_count()):
		var col = get_slide_collision(i)
		if col.normal.normalized().y > 0.1 :
			linear_velocity.y = 0
	
	avaliateCharacterState()

func avaliateCharacterState():
	
	if (character_state != CHARACTER_STATE.ACTION 
	and character_state != CHARACTER_STATE.DISABLED ):
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
	if linear_velocity.y <= 0 and character_state != CHARACTER_STATE.ACTION and is_on_floor() :
		linear_velocity.y = 30
		setCharacterState(CHARACTER_STATE.ON_AIR)

func action(action_name):
	if character_state != CHARACTER_STATE.ACTION:
		setCharacterState(CHARACTER_STATE.ACTION)
		emit_signal("triggering_action" , action_name)

func setInputDirection(new_dir):
	input_direction = new_dir
	if input_direction.x != 0 and character_state != CHARACTER_STATE.ACTION:
		# Only rotating it's geometry, not CollisionShape and other stuffs
		$model_root.rotation_degrees.y = -35 + 70*int(input_direction.x>0)
	if( input_direction.length_squared() > 1 ):
		input_direction = input_direction.normalized()

func setCharacterState(new_state):
	if character_state != new_state:
		_exitedState(character_state)
		character_state = new_state
		_enteredState(character_state)


func _getAnimationSuffix():
	return ""
func _enteredState(state):
	match state:
		CHARACTER_STATE.IDLE:
			_play( "Standing" )
		CHARACTER_STATE.WALKING:
			_play( "Walking" )
		CHARACTER_STATE.ON_AIR:
			_play(["Jumping","Standing"])
func _exitedState(state):
	pass

# just play an animation, will play the first available animation.
# Also, will try the animation with suffix from "_getAnimationSuffix" if it exists
func _play( anims_names ):
	if anims_names is String: 
		anims_names = [anims_names]
	for anim_name in anims_names:
		var anim_name_suffix = _getAnimationSuffix()
		var anim_name_suffixed = anim_name + anim_name_suffix
		if model_anim_player.has_animation(anim_name_suffixed):
			model_anim_player.play(anim_name_suffixed)
			return true
		if model_anim_player.has_animation(anim_name):
			model_anim_player.play(anim_name)
			return true
	return false

func _blink( ):
	var skeleton = find_node("Skeleton")
	var blink_timer = Timer.new()
	blink_timer.wait_time = 0.05 
	add_child(blink_timer)
	blink_timer.start()
	for mesh_instance in skeleton.get_children():
		for material_id in range(0,mesh_instance.get_surface_material_count()):
			mesh_instance.set_surface_material(material_id, preload("res://Resources/Materials/DamageBlink.tres") )
			blink_timer.connect("timeout",mesh_instance,"set_surface_material",[material_id,null])
	blink_timer.connect("timeout",blink_timer,"queue_free")
