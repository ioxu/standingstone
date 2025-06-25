extends PanelContainer

#export(NodePath) var viewport
@export var viewport : SubViewport

var _timer:Timer

# viewport info
var objects:int
var objects_label:Label
var draw_calls:int
var draw_calls_label:Label
var n_primitives:int
var primitives_label:Label

#RenderingServer info
var texture_mem : int
var texture_mem_label : Label
var buffer_mem : int
var buffer_mem_label : Label


var _r = false

func _ready() -> void:
	#viewport=get_node(viewport)#get_viewport() # 3.5
	print("[render_info_panel] viewport: %s"%viewport.get_path())
	
	# fetch labels
	objects_label = self.find_child("objects_in_frame")
	primitives_label = self.find_child("primitives_in_frame")
	draw_calls_label = self.find_child("draw_calls_in_frame")

	texture_mem_label = self.find_child("texture_mem")
	buffer_mem_label = self.find_child("buffer_mem")
	
	# update-timer
	_timer = Timer.new()
	add_child(_timer)
	# warning-ignore:return_value_discarded
	#_timer.connect("timeout", self, "refresh_stats") # 3.5
	_timer.timeout.connect(refresh_stats)
	_timer.set_wait_time(1.0)
	_timer.set_one_shot(false)
	_timer.start()
	
	refresh_stats()
	
	_r = true


func refresh_stats() -> void:
	objects = viewport.get_render_info(viewport.RENDER_INFO_TYPE_VISIBLE, Viewport.RENDER_INFO_OBJECTS_IN_FRAME)
	objects_label.text = "objects:  %s"%objects

	n_primitives = viewport.get_render_info(viewport.RENDER_INFO_TYPE_VISIBLE, Viewport.RENDER_INFO_PRIMITIVES_IN_FRAME)
	primitives_label.text = "primitives:  %s"%Util.format_thousands(str(n_primitives))

	draw_calls = viewport.get_render_info(viewport.RENDER_INFO_TYPE_VISIBLE, Viewport.RENDER_INFO_DRAW_CALLS_IN_FRAME)
	draw_calls_label.text = "draw calls:  %s"%draw_calls

	texture_mem = RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TEXTURE_MEM_USED)
	texture_mem_label.text = "texture mem: %s"%"".humanize_size(texture_mem)

	buffer_mem = RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_BUFFER_MEM_USED)
	buffer_mem_label.text = "buffer mem: %s"%"".humanize_size(buffer_mem)

	pass


func _on_render_info_container_visibility_changed() -> void:
	update_on_visibility_changed()


func update_on_visibility_changed() -> void:
	# TODO: vulgar display of find_parent(), cache these instead
	if _r:
		if self.find_parent("render_info_container").visible and self.find_parent("ui_debug_root_container").visible:
			self.set_process(true)
			self._timer.set_paused(false)
		else:
			self.set_process(false)
			self._timer.set_paused(true)
