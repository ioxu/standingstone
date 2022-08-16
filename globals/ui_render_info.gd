extends PanelContainer

export(NodePath) var viewport

var _timer:Timer

var objects:int
var objects_label:Label
var vertices:int
var vertices_label:Label
var material_changes:int
var material_changes_label:Label
var shader_changes:int
var shader_changes_label:Label
var surface_changes:int
var surface_changes_label:Label
var draw_calls:int
var draw_calls_label:Label
var twod_items:int
var twod_items_label:Label
var twod_draw_calls:int
var twod_draw_calls_label:Label


func _ready() -> void:
	viewport=get_node(viewport)#get_viewport()
	print("[render_info_panel] viewport: %s"%viewport.get_path())
	
	# fetch labels
	objects_label = self.find_node("objects_in_frame")
	vertices_label = self.find_node("vertices_in_frame")
	material_changes_label = self.find_node("material_changes_in_frame")
	shader_changes_label = self.find_node("shader_changes_in_frame")
	surface_changes_label = self.find_node("surface_changes_in_frame")
	draw_calls_label = self.find_node("draw_calls_in_frame")
	twod_items_label = self.find_node("twod_items_in_frame")
	twod_draw_calls_label = self.find_node("twod_draw_calls_in_frame")

	# update-timer
	_timer = Timer.new()
	add_child(_timer)
	# warning-ignore:return_value_discarded
	_timer.connect("timeout", self, "refresh_stats")
	_timer.set_wait_time(1.0)
	_timer.set_one_shot(false)
	_timer.start()
	
	refresh_stats()


func refresh_stats() -> void:
	objects = viewport.get_render_info(Viewport.RENDER_INFO_OBJECTS_IN_FRAME)
	objects_label.text = "objects:  %s"%objects
	vertices = viewport.get_render_info(Viewport.RENDER_INFO_VERTICES_IN_FRAME)
	vertices_label.text = "vertices:  %s"%Util.format_thousands(str(vertices))
	material_changes = viewport.get_render_info(Viewport.RENDER_INFO_MATERIAL_CHANGES_IN_FRAME)
	material_changes_label.text = "material changes:  %s"%material_changes
	shader_changes = viewport.get_render_info(Viewport.RENDER_INFO_SHADER_CHANGES_IN_FRAME)
	shader_changes_label.text = "shader changes:  %s"%shader_changes	
	surface_changes = viewport.get_render_info(Viewport.RENDER_INFO_SURFACE_CHANGES_IN_FRAME)
	surface_changes_label.text = "surface changes:  %s"%surface_changes	
	draw_calls = viewport.get_render_info(Viewport.RENDER_INFO_DRAW_CALLS_IN_FRAME)
	draw_calls_label.text = "draw calls:  %s"%draw_calls
	twod_items = viewport.get_render_info(Viewport.RENDER_INFO_2D_ITEMS_IN_FRAME)
	twod_items_label.text = "2d items:  %s"%twod_items
	twod_draw_calls = viewport.get_render_info(Viewport.RENDER_INFO_2D_DRAW_CALLS_IN_FRAME)
	twod_draw_calls_label.text = "2d draw calls:  %s"%twod_draw_calls


func _on_ui_render_info_visibility_changed() -> void:
	if self.visible:
		self.set_process(true)
	else:
		self.set_process(false)
