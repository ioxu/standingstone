extends Spatial


func _ready():
	print("[game] starting %s"%self.get_path())
	print("[game] level %s"% $default_level.get_path())
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _input(_event):
	if Input.is_action_pressed("ui_cancel"):
		get_tree().quit()


