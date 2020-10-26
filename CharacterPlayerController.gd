extends Node


func _physics_process(delta):
	pass
	# no polling
	
	
func _input(event):
	var character = get_parent()
	
	if event.is_action("jump") and event.is_pressed():
		character.jump()
	
	character.input_direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
