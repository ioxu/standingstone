extends Node
# contains utility functions
# - math shaping functions

func _ready():
	print("[util] autoload ready")


# ------------------------------------------------------------------------------
# context 
# ------------------------------------------------------------------------------


func is_f6(node:Node):
	# checks if node is running through GUI by F6,
	# TODO: needs rigorous testing
	return node.get_parent().get_path() == "/root/"


# ------------------------------------------------------------------------------
# maths 
# ------------------------------------------------------------------------------


func remap( f, start1, stop1, start2, stop2):
	return start2 + (stop2 - start2) * ((f - start1) / (stop1 - start1))


# remap that clamps between start2 and stop2
func remap_clamp(f, start1, stop1, start2, stop2):
	return clamp( start2 + (stop2 - start2) * ((f - start1) / (stop1 - start1)), start2, stop2 )


# fast bias, C. Schlick, Graphics Gems IV, pp. 401–403
func bias(value, b):
	value = clamp(value, 0.0, 1.0)
	#assert(b > 0.0, "[Util.bias] b=%s but 0.0 causes divide-by-zero here"%b)
	b = -log2(1.0 - b)
	return 1.0 - pow(1.0 - pow(value, 1.0/b), b)


# fast gain, C. Schlick, Graphics Gems IV, pp. 401–403
func gain(t, g):
	if(t < 0.5):
		return bias(t * 2.0, g)/2.0
	else:
		return bias( t * 2.0 - 1.0, 1.0 - g )/2.0 + 0.5


func log2(value):
	return log(value) / log(2)


func bias_lut( b = 0.5, resolution = 32 ) -> Curve:
	# baked lut of biased values for a given bias, b.
	var lut = Curve.new()
	lut.bake_resolution = resolution
	resolution = float(resolution)
	for i in range(resolution):
		lut.add_point( Vector2(i/resolution, bias(i/resolution, b) ) )
	return lut


func square_to_circle(inv: Vector2) -> Vector2:
	# for remapping the square domain of thumbstick controls back into a circle
	# https://youtu.be/Q4aQiuJYZ2s?t=1524
	# https://www.xarg.org/2017/07/how-to-map-a-square-to-a-circle/
	# args:
	#	inv: Vector2 - members from -1 to +1
	var _o:Vector2
	_o.x = inv.x * sqrt( 1-inv.y*inv.y/2.0 )
	_o.y = inv.y * sqrt( 1-inv.x*inv.x/2.0 )
	return _o


# ------------------------------------------------------------------------------
# arrays
# ------------------------------------------------------------------------------


func ring_points(npoints:int = 32, radius:float = 5.0) -> Array:
	# a ring of points on the x-z plane
	var ring_points = []
	for i in range(npoints):
		var p = (i/float(npoints)) * (2*PI)
		ring_points.append( Vector3( sin( p ) , 0.0, cos( p ) ) * radius )
	ring_points.append( Vector3( sin( 2*PI ) , 0.0, cos( 2*PI ) ) * radius )
	return ring_points


func arc_points(npoints:int = 10, start:float = 45.0, end:float = 315.0, radius:float = 5.0) -> Array:
	# an arc of points on the x-z plane
	# start and end are in degrees,
	# 0 degrees is at 3 o'clock on the x-z plane
	var arc_points = []
	for i in range(npoints+1):
		var p = deg2rad(start + i * (end-start) / float(npoints) - 90)
		arc_points.append( Vector3( cos( p ) , 0.0, sin( p ) ) * radius )
	return arc_points


func set_curve_from_array_linear(in_array: Array, curve:Curve) -> void:
	# sets a Curve resource's CVs by Vector2s in an Array.
	curve.clear_points()
	var _ret := int()
	for v in in_array:
		_ret = curve.add_point(v, 0.0, 0.0, Curve.TANGENT_LINEAR, Curve.TANGENT_LINEAR)
	#curve.clean_dupes() # seems to leave the curve with a single cv
	curve.bake()



# ------------------------------------------------------------------------------
# nodes
# ------------------------------------------------------------------------------


func set_tree_visible( node : Node, visible : bool) -> void:
	if node.has_method("set_visible"):
		node.set_visible( visible )
	for n in node.get_children():
		set_tree_visible( n, visible )


func get_all_children(node):
	# reursively get a list of all children
	var cl = []
	_gac_r(node, cl)
	return cl


func _gac_r(node, acc):
	# get_all_children recursion
	for c in node.get_children():
		acc.append(c)
		if c.get_child_count() > 0 :
			_gac_r(c, acc)


# ------------------------------------------------------------------------------
# debug
# ------------------------------------------------------------------------------


func debug(text):
	# https://github.com/godotengine/godot/issues/18319#issuecomment-389895583
	var frame = get_stack()[1]
	print( "%30s:%-4d %s" % [frame.source.get_file(), frame.line, text] )


func debug_stack(text):
	# https://github.com/godotengine/godot/issues/18319#issuecomment-389895583
	print("debug_stack: %s"%[text])
	var st = get_stack()
	st.remove(0)
	for frame in st:
		print( "%30s:%-4d %s()" % [frame.source.get_file(), frame.line, frame.function] )


# ------------------------------------------------------------------------------
# strings
# ------------------------------------------------------------------------------


func format_thousands(number : String) -> String:
	var i : int = number.length() - 3
	while i > 0:
		number = number.insert(i, ",")
		i = i - 3
	return number
