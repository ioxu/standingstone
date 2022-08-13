extends PanelContainer


func _process(_delta: float) -> void:
	$MarginContainer/fps_label.text = "fps %s"%str(Engine.get_frames_per_second())
