extends KinematicBody

export(NodePath) var animation_tree_path
onready var animation_tree = get_node( animation_tree_path )

var gravity : Vector3 = Vector3.ZERO

var ms_collision_vel := Vector3.ZERO

func _ready():
	pass


func _physics_process(delta):
	var root_motion : Transform = animation_tree.get_root_motion_transform()


	var v = root_motion.origin / (delta * Vector3(-1,1,-1)) # TODO: WHY
	
	if is_on_floor():
		gravity = Vector3.ZERO
		#print("on floor")
		v *= Vector3(1, 0, 1)
	else:
		gravity += Vector3(0.0, -9.8, 0.0) * delta
		#print("NOT on floor")

	v += gravity *.01 # TODO: slight gravity is causing move_and_slide to bounce off floor

	if Input.is_action_pressed("ui_select"):
		animation_tree["parameters/playback"].travel("IdleFistsUp")
		#animation_tree["parameters/playback"].travel("Running")

	else:
		#animation_tree["parameters/playback"].travel("IdleAction")
		animation_tree["parameters/playback"].travel("Idle Tap Foot-loop")

	ms_collision_vel = move_and_slide(v, Vector3.UP)
	#ms_collision_vel = move_and_slide_with_snap(v, Vector3.DOWN, Vector3.UP)
	
	
	
