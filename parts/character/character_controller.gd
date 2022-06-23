extends KinematicBody

export(NodePath) var animation_tree_path
onready var animation_tree = get_node( animation_tree_path )

var gravity : Vector3 = Vector3.ZERO

var ms_collision_vel := Vector3.ZERO

func _ready():
	pass


func _physics_process(delta):
	var root_motion : Transform = animation_tree.get_root_motion_transform()

	var v = root_motion.origin #/ delta
	v = Vector3(-1* v.x, -1* v.z, -1* v.y) # what
	v *= 0.01 / delta

	if is_on_floor():
		gravity = Vector3.ZERO
	else:
		gravity += Vector3(0.0, -9.8, 0.0) * delta

	v += gravity

	if Input.is_action_pressed("ui_select"):
		animation_tree["parameters/playback"].travel("Running")
	else:
		animation_tree["parameters/playback"].travel("IdleFistsUp")

	ms_collision_vel = move_and_slide(v, Vector3.UP)


