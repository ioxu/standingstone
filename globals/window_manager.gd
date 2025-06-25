extends Node
# window size/fullscreen manager audotoload

var minimum_size : Vector2 = Vector2(1024,600)#(960, 540)
var BORDERLESS_FULLSCREEN = false

var window_position := Vector2.ZERO
var fullscreen : = false

signal change_fullscreen(value)


func _ready():
	pprint("window.dg autoload ready")
	var root = get_node("/root")
	#root.connect("size_changed",resize, )
	root.size_changed.connect( resize )

	pprint("get_windows_size %s"% DisplayServer.window_get_size()) #OS.get_window_size())
	pprint("get_screen_size %s"% DisplayServer.screen_get_size())  #OS.get_screen_size())

	window_position = DisplayServer.window_get_position() #OS.get_window_position()

	if fullscreen:
		if not BORDERLESS_FULLSCREEN:
			#OS.window_fullscreen = true # 3.5
			DisplayServer.window_set_mode( DisplayServer.WINDOW_MODE_FULLSCREEN )
		else:
			#OS.set_window_position(Vector2(0.0, 0.0)) # 3.5
			DisplayServer.window_set_position(Vector2(0.0, 0.0))
			#OS.set_window_size(OS.get_screen_size()) # 3.5
			DisplayServer.window_set_size( DisplayServer.screen_get_size() )
			#OS.set_borderless_window(true) # 3.5
			DisplayServer.window_set_flag( DisplayServer.WINDOW_FLAG_BORDERLESS, true )


func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
	elif event.is_action_pressed("ui_fullscreen"):
		go_fullscreen()
		#get_tree().set_input_as_handled() # 3.5
		get_viewport().set_input_as_handled()


func resize():
	var root = get_node("/root")
	var resolution = root.get_visible_rect() #root.get_rect()
	pprint("resized. resolution: %s"%resolution)


func go_fullscreen():
	if not BORDERLESS_FULLSCREEN:
		#OS.window_fullscreen = !OS.window_fullscreen # 3.5
		fullscreen = !fullscreen
		if fullscreen:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		
		# if not OS.window_fullscreen: # 3.5
		if not fullscreen:
			#OS.set_window_size(minimum_size) # 3.5
			DisplayServer.window_set_size( minimum_size )
			#OS.set_borderless_window(false) # 3.5
			DisplayServer.window_set_flag( DisplayServer.WINDOW_FLAG_BORDERLESS, false )
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			#OS.set_window_position(window_position) 3.5
			DisplayServer.window_set_position( window_position )

# TODO : 3.5 to 4.0 : on BORDERLESS_FULLSCREEN
#	else:
#		fullscreen = !fullscreen
#		if fullscreen:
#			OS.set_window_size(OS.get_screen_size())
#			OS.set_borderless_window(true)
#			OS.set_window_position(Vector2(0.0, 0.0))
#		else:
#			OS.set_borderless_window(false)
#			OS.set_window_size(minimum_size)
#			OS.set_window_position(window_position)
	emit_signal("change_fullscreen", fullscreen)


func pprint(thing) -> void:
	print("[window] %s"%str(thing))
