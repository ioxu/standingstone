extends MarginContainer

export(NodePath) onready var graphics_settings_menu = get_node(graphics_settings_menu)
export(NodePath) onready var render_viewport = get_node(render_viewport)
export(NodePath) onready var display_texture = get_node(display_texture)

var MSAA_ENUM_STRINGS = ["Viewport.MSAA_DISABLED",
	"Viewport.MSAA_2X",
	"Viewport.MSAA_4X",
	"Viewport.MSAA_8X",
	"Viewport.MSAA_16X"]


var original_render_viewport_resolution :Vector2
var fullscreen_value := false

func _ready() -> void:
	self.graphics_settings_menu.set_visible( false )
	self.deactivate()

	original_render_viewport_resolution = render_viewport.get_size()

	var msaa_options = self.find_node("msaa_options")
	msaa_options.add_item("Disabled")
	msaa_options.add_item("2 x")
	msaa_options.add_item("4 x")
	msaa_options.add_item("8 x")
	msaa_options.add_item("16 x")

	msaa_options.select( render_viewport.get_msaa() )

	# warning-ignore:return_value_discarded
	Window.connect( "fullscreen", self, "react_to_window_fullscreen", [fullscreen_value] )


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


func react_to_window_fullscreen( _fullscreen_value, _ignored )->void:
	# keep option in graphics settings synced with fullscreen after hot-key fullscreen
	self.find_node("fullscreen_checkbox").set_pressed_no_signal(_fullscreen_value)


#-------------------------------------------------------------------------------
# graphics settings signals
func _on_graphics_settings_button_toggled(button_pressed: bool) -> void:
	pprint("show graphics settings menu: %s"%button_pressed)
	graphics_settings_menu.set_visible( button_pressed )


func _on_sharpen_intensity_slider_value_changed(value: float) -> void:
	render_viewport.set_sharpen_intensity(value)


func _on_filter_display_checkbox_toggled(button_pressed: bool) -> void:
	if button_pressed:
		display_texture.get_texture().set_flags(Texture.FLAG_FILTER)
	else:
		display_texture.get_texture().set_flags(0)


func _on_fxaa_checkbox_toggled(button_pressed: bool) -> void:
	render_viewport.fxaa = button_pressed


func _on_msaa_options_item_selected(index: int) -> void:
	pprint("msaa selected %s"%MSAA_ENUM_STRINGS[index])
	render_viewport.msaa = index


func _on_fullscreen_checkbox_toggled(button_pressed: bool) -> void:
	if Window.fullscreen and button_pressed:
		pass
	elif not Window.fullscreen and button_pressed:
		Window.go_fullscreen()
	elif Window.fullscreen and not button_pressed:
		Window.go_fullscreen()


func _on_resolution_scale_value_changed(value: float) -> void:
	pprint("resolution scale %s (%s)"%[value, original_render_viewport_resolution * value] )
	render_viewport.set_size( original_render_viewport_resolution * value )
