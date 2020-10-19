extends Node


func _physics_process(delta):
	var character = get_parent()
	character.input_direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	
	
func _input(event):
	var character = get_parent()
	if event.is_action("jump") and event.is_pressed() and not event.is_echo():
		character.jump()
