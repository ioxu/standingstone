extends Node2D

export(NodePath) onready var player = get_node(player)

func _ready():
	print("[game] starting %s"%self.get_path())
	print("[game] level %s"% $ViewportContainer/default_level.get_path())
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	print("[game] player: %s"%player.get_path())

func _input(_event):
	if Input.is_action_pressed("ui_cancel"):
		get_tree().quit()


func _process(_delta):
	$fps_label.text = str(Engine.get_frames_per_second())
	$c_dir.text= "c_dir: %0.2f (%0.2f)"%[player.dir.length(), player.dir.length_squared()] #TODO: temp
	$c_blend.text= "c_blend: %0.2f"%player.movement_walk_run_blend#TODO: temp
	$c_dir_length_smoothed.text = "dl smoothed: %0.2f"%player.dir_length_smoothed # TODO: temp


