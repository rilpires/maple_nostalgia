extends Node

onready var character:Character = get_parent()

func _physics_process(delta):
	character.input_direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")

func _input(event):
	if event.is_action("jump") and event.is_pressed():
		character.jump()
	if event.is_action("attack") and event.is_pressed():
		character.action("attack")
