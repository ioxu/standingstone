extends MarginContainer

#export(NodePath) onready var game_node = get_node(game_node) # 3.5
@export var game_node : Node2D # should be the root node, called "game"
#export(NodePath) onready var graphics_settings_menu = get_node(graphics_settings_menu) # 3.5
@export var graphics_settings_menu : MarginContainer # should be: ui_menu/menu_container/Panel/VBoxContainer/HBoxContainer3/graphics_settings_menu
#export(NodePath) onready var render_viewport = get_node(render_viewport) # 3.5
@export var render_viewport : SubViewport # should be ViewportContainer/Viewport
#export(NodePath) onready var display_texture = get_node(display_texture) # 3.5
@export var display_texture : TextureRect # should be ViewportDisplay/ViewportDisplayTextureRect
#export(NodePath) onready var ui_debug_root = get_node(ui_debug_root) # 3.5
@export var ui_debug_root : Node # should be ui_debug
#export(NodePath) onready var camera = get_node(camera) # 3.5
@export var camera : Camera3D 

var MSAA_ENUM_STRINGS = ["Viewport.MSAA_DISABLED",
	"Viewport.MSAA_2X",
	"Viewport.MSAA_4X",
	"Viewport.MSAA_8X",
	"Viewport.MSAA_16X"]


var original_render_viewport_resolution :Vector2
var fullscreen_value := false

var debug_overlay_checkbox_node : CheckBox

@onready var default_focus_node = find_child("return_button")


func _ready() -> void:
	# graphics settings menu set to on by default
	self.graphics_settings_menu.set_visible( true )
	
	#self.find_node("settings_button").set_pressed(true) # 3.5
	self.find_child("settings_button").set_pressed(true)
	
	self.deactivate()

	original_render_viewport_resolution = render_viewport.get_size()

	#var msaa_options = self.find_node("msaa_options") # 3.5
	var msaa_options = self.find_child("msaa_options")
	msaa_options.add_item("Disabled")
	msaa_options.add_item("2 x")
	msaa_options.add_item("4 x")
	msaa_options.add_item("8 x")
	msaa_options.add_item("16 x")

	#msaa_options.select( render_viewport.get_msaa() ) # 3.5
	msaa_options.select( render_viewport.get_msaa_3d() )

	# set motionblur params from node
#	var mb_iter_count = camera.find_child("motion_blur").get_surface_material(0).get_shader_paramter( "iteration_count" )
#	var mb_intensity = camera.find_child("motion_blur").get_surface_material(0).get_shader_parameter( "intensity" )
	var mb_iter_count = camera.find_child("motion_blur").get_surface_override_material(0).get_shader_parameter( "iteration_count" )
	var mb_intensity = camera.find_child("motion_blur").get_surface_override_material(0).get_shader_parameter( "intensity" )

	#self.find_node("motionblur_iterations").set_value( mb_iter_count ) # 3.5
	self.find_child("motionblur_iterations").set_value( mb_iter_count )
	#self.find_node("motionblur_intensity").set_value( mb_intensity ) # 3.5
	self.find_child("motionblur_intensity").set_value( mb_intensity )

	# warning-ignore:return_value_discarded
	#WindowManager.connect( "change_fullscreen", self, "react_to_window_fullscreen", [fullscreen_value] ) # 3.5
	WindowManager.change_fullscreen.connect( react_to_window_fullscreen )

	#game_node.connect("toggle_debug_display", self, "_on_remote_toggle_debug_display") # 3.5
	game_node.toggle_debug_display.connect(_on_remote_toggle_debug_display)
	
	#debug_overlay_checkbox_node = self.find_node("debug_overlay_checkbox") # 3.5
	debug_overlay_checkbox_node = self.find_child("debug_overlay_checkbox")


func _input(event: InputEvent) -> void:
	#if event.is_action("ui_cancel") and event.is_pressed() and not event.is_echo():
	if ( event.is_action("ui_cancel") or event.is_action("ui_gamepad_options")) and event.is_pressed() and not event.is_echo():
		self.deactivate()
		#get_tree().set_input_as_handled() # 3.5
		get_viewport().set_input_as_handled()


func deactivate() -> void:
	pprint("deactivate")
	self.hide()
	self.set_process_input(false)
	self.set_process(false)
	
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func activate()->void:
	if not self.visible:
		pprint("activate")
		self.show()
		self.set_process_input(true)
		self.set_process(true)
		
		default_focus_node.grab_focus()
		#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func pprint(thing) -> void:
	print("[menu] %s"%str(thing))


#func react_to_window_fullscreen( _fullscreen_value, _ignored )->void:
func react_to_window_fullscreen( _fullscreen_value )->void:
	# keep option in graphics settings synced with fullscreen after hot-key fullscreen
	#self.find_node("fullscreen_checkbox").set_pressed_no_signal(_fullscreen_value) # 3.5
	self.find_child("fullscreen_checkbox").set_pressed_no_signal(_fullscreen_value)


#-------------------------------------------------------------------------------
# graphics settings signals
func _on_graphics_settings_button_toggled(button_pressed: bool) -> void:
	pprint("show graphics settings menu: %s"%button_pressed)
	graphics_settings_menu.set_visible( button_pressed )


func _on_filter_display_checkbox_toggled(button_pressed: bool) -> void:
	if button_pressed:
		#display_texture.get_texture().set_flags(Texture.FLAG_FILTER) # 3.5
		#display_texture.get_texture().set_texture_filter( CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS )
		display_texture.set_texture_filter( CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS )
	else:
		#display_texture.get_texture().set_flags(0) # 3.5
		#display_texture.get_texture().set_texture_filter( CanvasItem.TEXTURE_FILTER_NEAREST )
		display_texture.set_texture_filter( CanvasItem.TEXTURE_FILTER_NEAREST )


func _on_msaa_options_item_selected(index: int) -> void:
	pprint("msaa selected %s"%MSAA_ENUM_STRINGS[index])
	#render_viewport.msaa = index
	render_viewport.msaa_3d  = index


func _on_fullscreen_checkbox_toggled(button_pressed: bool) -> void:
	if WindowManager.fullscreen and button_pressed:
		pass
	elif not WindowManager.fullscreen and button_pressed:
		WindowManager.go_fullscreen()
	elif WindowManager.fullscreen and not button_pressed:
		WindowManager.go_fullscreen()


func _on_resolution_scale_value_changed(value: float) -> void:
	pprint("resolution scale %s (%s)"%[value, original_render_viewport_resolution * value] )
	render_viewport.set_size( original_render_viewport_resolution * value )


func _on_remote_toggle_debug_display(value) -> void:
	# gets fired when debug overlay is toggled, usually from input
	debug_overlay_checkbox_node.set_pressed_no_signal(value)


func _on_return_button_pressed() -> void:
	self.deactivate()


func _on_fps_checkbox_toggled(button_pressed: bool) -> void:
	#ui_debug_root.find_node( "fps_display_container" ).set_visible( button_pressed )
	ui_debug_root.find_child( "fps_display_container" ).set_visible( button_pressed )

func _on_debug_render_info_checkbox_toggled(button_pressed: bool) -> void:
	#ui_debug_root.find_node( "render_info_container" ).set_visible( button_pressed )
	ui_debug_root.find_child( "render_info_container" ).set_visible( button_pressed )	


func _on_resolutions_info_checkbox_toggled(button_pressed: bool) -> void:
	#ui_debug_root.find_node( "resolutions_info_container" ).set_visible( button_pressed )
	ui_debug_root.find_child( "resolutions_info_container" ).set_visible( button_pressed )


#-------------------------------------------------------------------------------
# effects
func _on_motionblur_enable_checkbox_toggled(button_pressed: bool) -> void:
	camera.find_child("motion_blur").set_visible( button_pressed )
	self.find_child("motionblur_iterations").set_editable( button_pressed )
	self.find_child("motionblur_intensity").set_editable( button_pressed )


func _on_motionblur_iterations_value_changed(value: float) -> void:
	#camera.find_node("motion_blur").get_surface_material(0).set_shader_param( "iteration_count", value ) # 3.5
	camera.find_child("motion_blur").get_surface_override_material(0).set_shader_parameter( "iteration_count", value )


func _on_motionblur_intensity_value_changed(value: float) -> void:
#	camera.find_node("motion_blur").get_surface_material(0).set_shader_param( "intensity", value ) # 3.5
	camera.find_child("motion_blur").get_surface_override_material(0).set_shader_parameter( "intensity", value )
