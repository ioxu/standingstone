extends PanelContainer

export(NodePath) onready var main_viewport = get_node(main_viewport)
export(NodePath) onready var viewport_display_rect = get_node(viewport_display_rect)

var _r = false

func _ready() -> void:
	pprint( "main viewport %s (%s)"%[main_viewport.get_path(), main_viewport.get_class() ])
	pprint( "viewport display rect %s"%viewport_display_rect.get_path() )
	self._r = true
	update()


func update() -> void:
	var rr = main_viewport.get_size()
	self.find_node("viewport_resolution").text = "render %s x %s"%[rr[0], rr[1]]
	var wr = get_viewport().get_visible_rect().size
	self.find_node("window_resolution").text = "display %s x %s"%[wr[0], wr[1]]
	pass


func pprint(thing) -> void:
	print( "[resolutions_info_panel] %s"%str(thing) )


func _on_Viewport_size_changed() -> void:
	if self._r:
		self.update()


func _on_ViewportDisplayTextureRect_resized() -> void:
	if self._r:
		self.update()

