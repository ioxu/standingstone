extends TextureRect


func _ready() -> void:
	prep_dither()


func _process(delta: float) -> void:
	pass



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
	pprint("%s (%s)"%[bayer_m.size(), sqrt(bayer_m.size())])

	var image = Image.create( bm_size_dim, bm_size_dim, false, Image.FORMAT_L8 ) 
	for y in bm_size_dim:
		for x in bm_size_dim:
			var idx = y * bm_size_dim + x
			var p = bayer_m[ idx ]
			image.set_pixel( x, y, Color( p/255.0, p/255.0, p/255.0 ) )
	var texim = ImageTexture.create_from_image(image)
	self.material.set_shader_parameter("bayer_texture", texim)
	self.material.set_shader_parameter("bayer_matrix_dim_size", bm_size_dim)

	$bayer_matrix.set_texture( texim )


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
