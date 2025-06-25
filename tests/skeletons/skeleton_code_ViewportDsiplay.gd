extends TextureRect


@onready var window_res = get_viewport().size
#export(NodePath) onready var animtree = get_node(animtree)
@export var animtree : AnimationTree

var mouse_pos:Vector2

var blend : AnimationNodeBlendSpace2D

var ntris := -1
var tria_alpha = 0.15
var tri_colours= [ Color(0.859375, 0.37199, 0.181274, tria_alpha),
	Color(0.307671, 0.765625, 0.179443, tria_alpha),
	Color(0.179443, 0.394682, 0.765625, tria_alpha)]

var default_font


func _ready() -> void:
	#yield(owner, "ready")
	await get_owner().ready
	#default_font = Control.new().get_font("font")
	default_font = ThemeDB.get_fallback_font()
	blend = animtree.tree_root.get_node("BlendSpace2D")
	pprint("%s (%s)"%[blend.get_name(), blend.get_class()])
	pprint("%s points"%blend.get_blend_point_count())

	#yield(get_tree().create_timer(0.1), "timeout")
	await get_tree().create_timer(0.1).timeout
	ntris = blend.get_triangle_count()
	pprint("%s triangles"%ntris)


func _draw() -> void:
	draw_circle(mouse_pos, 10, Color(0.529412, 0.984314, 0.589828, 0.811765))
	for i in range(ntris):
		var pa:= PackedVector2Array([Vector2.ZERO, Vector2.ZERO, Vector2.ZERO])
		for ti in range(3):
			pa[ti] = ((blend.get_blend_point_position(blend.get_triangle_point(i,ti)) + Vector2.ONE) /2.0) * Vector2( window_res )
		#pa = PackedVector2Array( Geometry.offset_polygon_2d( pa, -5.0 )[0])
		pa = PackedVector2Array( Geometry2D.offset_polygon( pa, -5.0 )[0])
		draw_colored_polygon(pa, tri_colours[i%3])
		pa.append(pa[0])
		draw_polyline(pa, tri_colours[i%3], 2.5, true)

	for p in range(blend.get_blend_point_count()):
		var pn :String = blend.get_blend_point_node(p).get_animation()
		var pp = ((blend.get_blend_point_position(p) * 0.85 + Vector2.ONE) /2.0) * Vector2(window_res) + Vector2(-20,0)
		draw_string( default_font, pp , pn )


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_pos = Vector2(event.position.x, event.position.y)


func _process(_delta: float) -> void:
	#pprint("%s triangles"%blend.get_triangle_count())
	if ntris > -1:
		#update()
		queue_redraw()


func pprint(msg) -> void:
	print("[%s] %s"%[self.get_name(),str(msg)])
