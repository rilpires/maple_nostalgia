extends Character


enum ARMATURE_MODE {
	BARE_HANDS, 
	TWO_HANDED_SPEAR
}

export (ARMATURE_MODE) var current_armature_mode = null setget _setCurrentArmatureMode

var hitboxes = {}

func _ready():
	_setCurrentArmatureMode(current_armature_mode)
	for hitbox_area in $model_root.get_children():
		if "hitbox_" in hitbox_area.name:
			hitboxes[ hitbox_area.name.substr(7,-1) ] = hitbox_area
			hitbox_area.get_parent().remove_child(hitbox_area)

func _setCurrentArmatureMode(new_val):
	find_node('_2H_spear').visible = (new_val==ARMATURE_MODE.TWO_HANDED_SPEAR)
	current_armature_mode = new_val

func _getAnimationSuffix():	
	match current_armature_mode:
		ARMATURE_MODE.TWO_HANDED_SPEAR:
			return '_2H_spear'
		_:
			return ""

func _on_triggering_action( action_name ):
	var anim_name
	match action_name:
		"attack":
			anim_name = "Attacking"
	if not _play(anim_name):
		print("Couldn't find animation for " , anim_name )
		setCharacterState(CHARACTER_STATE.IDLE)

func _on_AnimationPlayer_animation_finished(anim_name):
	if character_state == CHARACTER_STATE.ACTION:
		setCharacterState(CHARACTER_STATE.IDLE)
		avaliateCharacterState()

func _on_hitbox_colliding_enemy( enemy ):
	enemy.find_node('KnockbackTimer').start()
	enemy.setCharacterState(CHARACTER_STATE.DISABLED)
	enemy._play("Knockbacked")
	enemy._blink()
	

func _spawn_hitbox( hitbox_area_name ):
	var hitbox_instance:Area = hitboxes[hitbox_area_name].duplicate()
	var hitbox_lifetimer = Timer.new()
	hitbox_instance.add_child(hitbox_lifetimer)
	$model_root.add_child( hitbox_instance )
	hitbox_instance.connect("body_entered",self,"_on_hitbox_colliding_enemy")
	
	hitbox_lifetimer.wait_time = 0.1
	hitbox_lifetimer.start()
	hitbox_lifetimer.connect("timeout",hitbox_instance,"queue_free")
	
