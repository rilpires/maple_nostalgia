
# So basically this is a "A.I." that alternates between two states:
# - IDLE
# - MOVING
# (Almost the same as the old Maple Story, except some monster jumps sometimes)
# These aren't the same as the states defined in 'Character' class, but states
# that only exists in the scope of this behavior/controller class.

class_name MonsterBehavior
extends Node

onready var character:Character = get_parent()
var current_state = STATE.IDLE

enum STATE {
	IDLE,
	MOVING,
}

func generate_interval():
	return rand_range(2,5)

func _ready():
	request_ready()
	$Timer.wait_time = generate_interval()
	$Timer.start()


func _on_Timer_timeout():
	# Toggle state:
	if current_state == STATE.IDLE:
		current_state = STATE.MOVING
		character.input_direction = Vector2( [-1,1][randi()%2] , 0 )
	elif current_state == STATE.MOVING:
		current_state = STATE.IDLE
		character.input_direction = Vector2( 0 , 0 )
	$Timer.wait_time = generate_interval()
	$Timer.start()
