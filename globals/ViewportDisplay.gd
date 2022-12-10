extends TextureRect

export(NodePath) onready var camera = get_node(camera)

var debug_display := true

func _ready() -> void:
	prep_dither()


# warning-ignore:unused_argument
func _process(delta: float) -> void:
	update()
	

func _draw() -> void:
	if debug_display:
		var unproject_target = camera.unproject_position_in_viewport( camera.target.transform.origin )
		unproject_target = unproject_target * self.rect_size
		draw_arc( unproject_target, 12, 0, PI*2, 24, Color(0.933594, 0.481384, 0.862936, 0.803922), true)

#		# draw camera track margins
#		var ws = get_tree().get_root().size
#		var _xminc = Color(1, 0.384314, 0.917647, 0.25)
#		var _xmin1 = Vector2(ws.x * camera.track_horizontal_margin_min, ws.y)
#		var _xmin2 = Vector2(ws.x * (1-camera.track_horizontal_margin_min), ws.y)
#		draw_line( _xmin1 * Vector2(1.0,0.0), _xmin1, _xminc, 3 )
#		draw_line( _xmin2 * Vector2(1.0,0.0), _xmin2, _xminc, 3 )
#		_xmin1 = Vector2(ws.x * camera.track_horizontal_margin_max, ws.y)
#		_xmin2 = Vector2(ws.x * (1-camera.track_horizontal_margin_max), ws.y)
#		draw_line( _xmin1 * Vector2(1.0,0.0), _xmin1, _xminc, 1 )
#		draw_line( _xmin2 * Vector2(1.0,0.0), _xmin2, _xminc, 1 )



# ------------------------------------------------------------------------------
#
# dither stuff
# https://github.com/ioxu/dithering
# https://www.shadertoy.com/view/4ddGWr

func prep_dither():
	var bm_size = 4
	var bm_size_dim = 1 << bm_size
	var bayer_m : Array = bayer_matrix(bm_size)

	pprint("bayer_matrix:")
	#pprint(bayer_m)
	pprint("%s (%s)"%[bayer_m.size(), sqrt(bayer_m.size())])

	var texim = ImageTexture.new()
	var image = Image.new()
	image.create( bm_size_dim, bm_size_dim, false, Image.FORMAT_L8 )
	image.lock()
	for y in bm_size_dim:
		for x in bm_size_dim:
			var idx = y * bm_size_dim + x
			var p = bayer_m[ idx ]
			image.set_pixel( x, y, Color( p/255.0, p/255.0, p/255.0 ) )
	image.unlock()
	texim.create_from_image(image, 0)
	self.material.set_shader_param("bayer_texture", texim)
	self.material.set_shader_param("bayer_matrix_size", bm_size)


func bayer_matrix(size : int = 2) -> Array:
	#https://gist.github.com/depp/f4dc0d50c22f28f3b6585725219d7eb8
	var dim = 1 << size
	pprint("[bayer_matrix] dim: %s"%dim)
	var arr : Array = []
	arr.resize( dim * dim )
	arr.fill(0)
	if size > 0:
		var sub : Array = bayer_matrix(size - 1)
		var subdim = dim >> 1
		var delta : int
		if size <= 4:
			delta = 1 << (2* (4-size)) 
		else:
			delta = 0
		for y in range(subdim):
			for x in range(subdim):
				var val = sub[y*subdim+x]
				var idx = y*dim+x
				arr[idx] = val
				arr[idx+subdim] = val+2*delta
				arr[idx+subdim*dim] = val+3*delta
				arr[idx+subdim*(dim+1)] = val+1*delta
	return arr


func pprint(thing) -> void:
	print("[ViewportDisplayTextreRect] %s"%str(thing))
