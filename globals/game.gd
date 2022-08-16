extends Node2D

export(NodePath) onready var player = get_node(player)

var debug_display := true


func _ready():
	print("[game] starting %s"%self.get_path())
	print("[game] level %s"% $ViewportContainer/Viewport/default_level.get_path())
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	print("[game] player: %s"%player.get_path())
	
	# disable all mouse input for ui layer
	var uic = Util.get_all_children(self.get_node("ui_debug"))
	uic += Util.get_all_children(self.get_node("ui_persistent")) 
	print("[game] ui heirarchy: set to .MOUSE_FILTER_IGNORE")
	for c in uic:
		#print("[game]   %s"%c.get_path())
		if c is Control:
			c.set_mouse_filter( Control.MOUSE_FILTER_IGNORE )


func _input(_event):
	if Input.is_action_pressed("ui_cancel"):
		get_tree().quit()
	if Input.is_action_just_pressed("debug_display_toggle"):
		debug_display = !debug_display
		update_debug_display()


func _draw() -> void:
	if debug_display:
		var unproject_target = $ViewportContainer/Viewport/Camera.unproject_position( $ViewportContainer/Viewport/Camera.target.transform.origin )
		draw_arc( unproject_target, 12, 0, PI*2, 24, Color(0.933594, 0.481384, 0.862936, 0.803922), true)

		# draw camera track margins
		var ws = get_tree().get_root().size
		var _xminc = Color(1, 0.384314, 0.917647, 0.25)
		var _xmin1 = Vector2(ws.x * $ViewportContainer/Viewport/Camera.track_horizontal_margin_min, ws.y)
		var _xmin2 = Vector2(ws.x * (1-$ViewportContainer/Viewport/Camera.track_horizontal_margin_min), ws.y)
		draw_line( _xmin1 * Vector2(1.0,0.0), _xmin1, _xminc, 3 )
		draw_line( _xmin2 * Vector2(1.0,0.0), _xmin2, _xminc, 3 )
		_xmin1 = Vector2(ws.x * $ViewportContainer/Viewport/Camera.track_horizontal_margin_max, ws.y)
		_xmin2 = Vector2(ws.x * (1-$ViewportContainer/Viewport/Camera.track_horizontal_margin_max), ws.y)
		draw_line( _xmin1 * Vector2(1.0,0.0), _xmin1, _xminc, 1 )
		draw_line( _xmin2 * Vector2(1.0,0.0), _xmin2, _xminc, 1 )


func _process(_delta):
	if debug_display:
		var dl = player.dir.length()
		var dls = player.dir_length_smoothed
		
		#$fps_label.text = str(Engine.get_frames_per_second())
		$c_blend.text= "c_blend: %0.2f"%player.movement_walk_run_blend#TODO: temp
		$c_dir_length.text = "dl: %0.2f"%dl
		$c_dir_length_smoothed.text = "dl smoothed: %0.2f"%dls # TODO: temp
		$c_dir_length_plots.push_column(dl, Color(1, 1, 1, 0.098039))
		$c_dir_length_plots.push_point_blend(min(0.975, dls), Color(0.949219, 0.60583, 0.163147, 0.709804))

		$c_is_sprinting.text = "is_sprinting %s"%[player.is_sprinting]
		$c_dir_length_plots.push_point( player.sprint_blend, Color(0.286275, 0.827451, 0.211765, 0.5) )
		
		$c_camera_track_plots.push_point( $ViewportContainer/Viewport/Camera.target_margin_factor, Color(1, 0.570313, 0.942526, 0.407843) )
		update()


func update_debug_display() -> void:
	# 3.5: cannot switch collision shape 
	# visibility if switched on in 
	# Debug > Visible Collision Shapes menu
	print("[game] update_debug_display: %s"%debug_display)
	for c in self.get_children():
		if c.name != "ViewportContainer" and c.name != "ui_persistent": # TODO: ui_persistant has moved location and is now under a tree which gets hidden here.
			if c.get_class() == "Node": # TODO: UGH.
				for cc in c.get_children():
					cc.visible = debug_display
			else:
				c.visible = debug_display
	if !debug_display:
		yield(get_tree().create_timer(0.02), "timeout")
		update()

