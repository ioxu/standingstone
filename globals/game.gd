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
	var dl = player.dir.length()
	var dls = player.dir_length_smoothed
	
	$fps_label.text = str(Engine.get_frames_per_second())
	$c_blend.text= "c_blend: %0.2f"%player.movement_walk_run_blend#TODO: temp
	$c_dir_length.text = "dl: %0.2f"%dl
	$c_dir_length_smoothed.text = "dl smoothed: %0.2f"%dls # TODO: temp
	$c_dir_length_plots.push_column(dl, Color(0.515625, 0.457214, 0.457214, 0.333333))
	$c_dir_length_plots.push_point_blend(min(0.975, dls), Color(0.949219, 0.60583, 0.163147, 0.709804))

