extends MarginContainer


func _ready() -> void:
	self.deactivate()


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


func pprint(thing) -> void:
	print("[menu] %s"%str(thing))


