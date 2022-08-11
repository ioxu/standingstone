extends Node2D

var viewport:Viewport
var _timer:Timer

var objects:int
var vertices:int
var material_changes:int
var shader_changes:int
var surface_changes:int
var draw_calls:int
var twod_items:int
var twod_draw_calls:int


func _ready() -> void:
	viewport=get_viewport()
	_timer = Timer.new()
	add_child(_timer)

	_timer.connect("timeout", self, "refresh_stats")
	_timer.set_wait_time(1.0)
	_timer.set_one_shot(false)
	_timer.start()


func refresh_stats() -> void:
	objects = viewport.get_render_info(Viewport.RENDER_INFO_OBJECTS_IN_FRAME)
	$PanelContainer/MarginContainer/VBoxContainer/objects_in_frame.text = "objects:  %s"%objects
	vertices = viewport.get_render_info(Viewport.RENDER_INFO_VERTICES_IN_FRAME)
	$PanelContainer/MarginContainer/VBoxContainer/vertices_in_frame.text = "vertices:  %s"%Util.format_thousands(str(vertices))
	material_changes = viewport.get_render_info(Viewport.RENDER_INFO_MATERIAL_CHANGES_IN_FRAME)
	$PanelContainer/MarginContainer/VBoxContainer/material_changes_in_frame.text = "material changes:  %s"%material_changes
	shader_changes = viewport.get_render_info(Viewport.RENDER_INFO_SHADER_CHANGES_IN_FRAME)
	$PanelContainer/MarginContainer/VBoxContainer/shader_changes_in_frame.text = "shader changes:  %s"%shader_changes
	surface_changes = viewport.get_render_info(Viewport.RENDER_INFO_SURFACE_CHANGES_IN_FRAME)
	$PanelContainer/MarginContainer/VBoxContainer/surface_changes_in_frame.text = "surface changes:  %s"%surface_changes
	draw_calls = viewport.get_render_info(Viewport.RENDER_INFO_DRAW_CALLS_IN_FRAME)
	$PanelContainer/MarginContainer/VBoxContainer/draw_calls_in_frame.text = "draw calls:  %s"%draw_calls
	twod_items = viewport.get_render_info(Viewport.RENDER_INFO_2D_ITEMS_IN_FRAME)
	$PanelContainer/MarginContainer/VBoxContainer/twod_items_in_frame.text = "2d items:  %s"%twod_items
	twod_draw_calls = viewport.get_render_info(Viewport.RENDER_INFO_2D_DRAW_CALLS_IN_FRAME)
	$PanelContainer/MarginContainer/VBoxContainer/twod_draw_calls_in_frame.text = "2d draw calls:  %s"%twod_draw_calls


func _on_ui_render_info_visibility_changed() -> void:
	if self.visible:
		self.set_process(true)
	else:
		self.set_process(false)
