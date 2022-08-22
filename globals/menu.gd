extends MarginContainer

export(NodePath) onready var graphics_settings_menu = get_node(graphics_settings_menu)


func _ready() -> void:
	self.graphics_settings_menu.set_visible( false )
	self.deactivate()


	var msaa_options = self.find_node("msaa_options")
	msaa_options.add_item("Disabled")
	msaa_options.add_item("2 x")
	msaa_options.add_item("4 x")
	msaa_options.add_item("8 x")
	msaa_options.add_item("16 x")


func _input(event: InputEvent) -> void:
	if event.is_action("ui_cancel") and event.is_pressed() and not event.is_echo():
		self.deactivate()
		get_tree().set_input_as_handled()


func deactivate() -> void:
	pprint("deactivate")
	self.hide()
	self.set_process_input(false)
	self.set_process(false)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func activate()->void:
	if not self.visible:
		pprint("activate")
		self.show()
		self.set_process_input(true)
		self.set_process(true)
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _on_graphics_settings_button_toggled(button_pressed: bool) -> void:
	pprint("show graphics settings menu: %s"%button_pressed)
	graphics_settings_menu.set_visible( button_pressed )


func pprint(thing) -> void:
	print("[menu] %s"%str(thing))

