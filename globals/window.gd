extends Node
# window size/fullscreen manager audotoload

var minimum_size : Vector2 = Vector2(1024,600)#(960, 540)
var BORDERLESS_FULLSCREEN = false

var window_position := Vector2.ZERO
var fullscreen : = false

func _ready():
	pprint("window.dg autoload ready")
	var root = get_node("/root")
	root.connect("size_changed",self,"resize")

	pprint("get_windows_size %s"%OS.get_window_size())
	pprint("get_screen_size %s"%OS.get_screen_size())

	window_position = OS.get_window_position()

	if fullscreen:
		if not BORDERLESS_FULLSCREEN:
			OS.window_fullscreen = true
		else:
			OS.set_window_position(Vector2(0.0, 0.0))
			OS.set_window_size(OS.get_screen_size())
			OS.set_borderless_window(true)


func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
	elif event.is_action_pressed("ui_fullscreen"):
		go_fullscreen()
		get_tree().set_input_as_handled()


func resize():
	var root = get_node("/root")
	var resolution = root.get_visible_rect() #root.get_rect()
	pprint("resolution: %s"%resolution)


func go_fullscreen():
	if not BORDERLESS_FULLSCREEN:
		OS.window_fullscreen = !OS.window_fullscreen
		fullscreen = !fullscreen
		if not OS.window_fullscreen:
			OS.set_window_size(minimum_size)
			OS.set_borderless_window(false)
		else:
			OS.set_window_position(window_position)
	else:
		fullscreen = !fullscreen
		if fullscreen:
			OS.set_window_size(OS.get_screen_size())
			OS.set_borderless_window(true)
			OS.set_window_position(Vector2(0.0, 0.0))
		else:
			OS.set_borderless_window(false)
			OS.set_window_size(minimum_size)
			OS.set_window_position(window_position)


func pprint(thing) -> void:
	print("[window] %s"%thing)
