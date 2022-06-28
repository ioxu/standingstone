extends KinematicBody

export(NodePath) var animation_tree_path
onready var animation_tree = get_node( animation_tree_path )

export(NodePath) onready var camera = get_node(camera)

var gravity : Vector3 = Vector3.ZERO

var ms_collision_vel := Vector3.ZERO


func _ready():
	print("[character] camera reference: %s"%camera.get_path())


func _physics_process(delta):
	var root_motion : Transform = animation_tree.get_root_motion_transform()

	var v = root_motion.origin / delta
	
	#--------------------------------------------------------------------------
	# gravity
	if is_on_floor():
		gravity = Vector3.ZERO
		#print("on floor")
		v *= Vector3(1, 0, 1)
	else:
		gravity += Vector3(0.0, -9.8, 0.0) * delta
		#print("NOT on floor")

	v += gravity #*.01 
	# TODO: gravity: Y animation in the root motion is screwing this
	# TODO: root_motion: take Y animation out of root_motion and add it to the hips channel
	#--------------------------------------------------------------------------


	if Input.is_action_pressed("ui_select") || Input.is_action_pressed("action_stance"):
		animation_tree["parameters/playback"].travel("IdleFistsUp")
		#animation_tree["parameters/playback"].travel("Running")

	else:
		#animation_tree["parameters/playback"].travel("IdleAction")
		animation_tree["parameters/playback"].travel("Idle Tap Foot-loop")


	#--------------------------------------------------------------------------
	# movement
	var dir := Vector3.ZERO
	
	# handle gamepad
	var left_right = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var forward_back = Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")

	dir.z += forward_back 
	dir.x += left_right 


	if dir.length_squared() > 0.01:
		dir = dir.rotated(Vector3.UP, camera.camera_data.rotation.y)

		var player_heading_2d := Vector2(self.transform.basis.z.x, self.transform.basis.z.z)
		var desired_heading_2d := Vector2(dir.x, dir.z)
		
		var phi : float = desired_heading_2d.angle_to( player_heading_2d )
		phi = phi * delta * 3.0
		self.rotation.y += phi
		v = v.rotated( Vector3.UP, self.rotation.y)

		animation_tree["parameters/playback"].travel("WalkRun_blendspace")
		var _blend = Util.remap(dir.length(), 0.0, 1.05, -1.0, 1.0 )
		#print("[character] move blend: %0.2f"%_blend)
		animation_tree.set("parameters/WalkRun_blendspace/blend_walk_running/blend_amount", _blend )
	else:
		v = v.rotated( Vector3.UP, self.rotation.y)	
		animation_tree["parameters/playback"].travel("IdleAction")


	ms_collision_vel = move_and_slide(v, Vector3.UP)

	
	
	
