extends TextureRect

export(NodePath) onready var camera = get_node(camera)

func _ready() -> void:
	pass
	

# warning-ignore:unused_argument
func _process(delta: float) -> void:
	update()
	

func _draw() -> void:
	var unproject_target = camera.unproject_position_in_viewport( camera.target.transform.origin )
	unproject_target = unproject_target * self.rect_size
	draw_arc( unproject_target, 12, 0, PI*2, 24, Color(0.933594, 0.481384, 0.862936, 0.803922), true)

	# draw camera track margins
	var ws = get_tree().get_root().size
	var _xminc = Color(1, 0.384314, 0.917647, 0.25)
	var _xmin1 = Vector2(ws.x * camera.track_horizontal_margin_min, ws.y)
	var _xmin2 = Vector2(ws.x * (1-camera.track_horizontal_margin_min), ws.y)
	draw_line( _xmin1 * Vector2(1.0,0.0), _xmin1, _xminc, 3 )
	draw_line( _xmin2 * Vector2(1.0,0.0), _xmin2, _xminc, 3 )
	_xmin1 = Vector2(ws.x * camera.track_horizontal_margin_max, ws.y)
	_xmin2 = Vector2(ws.x * (1-camera.track_horizontal_margin_max), ws.y)
	draw_line( _xmin1 * Vector2(1.0,0.0), _xmin1, _xminc, 1 )
	draw_line( _xmin2 * Vector2(1.0,0.0), _xmin2, _xminc, 1 )
