extends Node2D

# default viewport resolution: 1024x600

export(NodePath) onready var main_menu = get_node(main_menu)
export(NodePath) onready var player = get_node(player)
export(NodePath) onready var viewport_display_texture_rect = get_node(viewport_display_texture_rect)

var debug_display := true
signal toggle_debug_display(value)


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
		if c is Control:
			c.set_mouse_filter( Control.MOUSE_FILTER_IGNORE )


func _input(event):
	if event.is_action("ui_cancel") and event.is_pressed() and not event.is_echo():
		print("[game] show menu")
		get_tree().set_input_as_handled()
		main_menu.activate()


func _process(_delta):
	if Input.is_action_just_pressed("debug_display_toggle"):
		debug_display = !debug_display
		update_debug_display()

	if debug_display:
		var dl = player.dir.length()
		var dls = player.dir_length_smoothed
		
		$ui_debug/c_blend.text= "c_blend: %0.2f"%player.movement_walk_run_blend#TODO: temp
		$ui_debug/c_dir_length.text = "dl: %0.2f"%dl
		$ui_debug/c_dir_length_smoothed.text = "dl smoothed: %0.2f"%dls # TODO: temp
		$ui_debug/c_dir_length_plots.push_column(dl, Color(1, 1, 1, 0.098039))
		$ui_debug/c_dir_length_plots.push_point_blend(min(0.975, dls), Color(0.949219, 0.60583, 0.163147, 0.709804))

		$ui_debug/c_is_sprinting.text = "is_sprinting %s"%[player.is_sprinting]
		$ui_debug/c_dir_length_plots.push_point( player.sprint_blend, Color(0.286275, 0.827451, 0.211765, 0.5) )
		
		$ui_debug/c_camera_track_plots.push_point( $ViewportContainer/Viewport/Camera.target_margin_factor, Color(1, 0.570313, 0.942526, 0.407843) )


func update_debug_display() -> void:
	# 3.5: cannot switch collision shape 
	# visibility if switched on in 
	# Debug > Visible Collision Shapes menu
	print("[game] update_debug_display: %s"%debug_display)
	for c in self.get_children():
		if not c.name in ["ViewportDisplay", "ViewportContainer", "ui_persistent", "ui_menu"]:
			if c.get_class() == "Node":
				for cc in c.get_children():
					cc.visible = debug_display
			else:
				c.visible = debug_display
	if !debug_display:
		yield(get_tree().create_timer(0.02), "timeout")
		update()
	viewport_display_texture_rect.debug_display = debug_display
	emit_signal("toggle_debug_display", debug_display)


func quit_game() -> void:
	print("[game] quit.")
	get_tree().quit()


func _on_quit_button_pressed() -> void:
	self.quit_game()


func _on_debug_overlay_checkbox_toggled(button_pressed: bool) -> void:
	debug_display = button_pressed
	update_debug_display()
