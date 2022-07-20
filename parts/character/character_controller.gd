extends KinematicBody

export(NodePath) var animation_tree_path
onready var animation_tree = get_node( animation_tree_path )

export(NodePath) onready var camera = get_node(camera)

var gravity : Vector3 = Vector3.ZERO

var ms_collision_vel := Vector3.ZERO
var dir := Vector3.ZERO
var _raw_dir_input := Vector2.ZERO

#---------------------------------------------
# TODO: make most character locomotion parameters into a struct/resource (single object for other objects to read from)
var movement_walk_run_blend = 0.0 # TODO: temp
var dir_length_smoothed := 0.0
#---------------------------------------------
# timescales are set in the blendspace, calculated to normalise their length egainst each other
# and set to 'sync' mode in the blend
var initial_timescale_walk := 1.0
var initial_timescale_run := 1.0
var initial_timescale_fastrun := 1.0
#---------------------------------------------


func _ready():
	print("[character] camera reference: %s"%camera.get_path())
	$AnimationTree.set_active(true)
	initial_timescale_walk = animation_tree.get("parameters/WalkRun_blendspace/walk_timescale/scale")
	initial_timescale_run = animation_tree.get("parameters/WalkRun_blendspace/run_timescale/scale")
	initial_timescale_fastrun = animation_tree.get("parameters/WalkRun_blendspace/fastrun_timescale/scale")


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
	dir = Vector3.ZERO
	
	# handle gamepad
	_raw_dir_input.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	_raw_dir_input.y = Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")

	if GameSettings.gamepad_move_square_to_circle: # TODO: review
		_raw_dir_input = Util.square_to_circle(_raw_dir_input)

	dir.z += _raw_dir_input.y
	dir.x += _raw_dir_input.x

	#dir_length_smoothed = lerp( dir_length_smoothed, dir.length(), 0.95 * delta * 5.5 )
	dir_length_smoothed = lerp( dir_length_smoothed, dir.length(), 0.95 * delta * 3.5 )
	if dir.length_squared() > 0.005:
		dir = dir.rotated(Vector3.UP, camera.camera_data.rotation.y)

		var player_heading_2d := Vector2(self.transform.basis.z.x, self.transform.basis.z.z)
		var desired_heading_2d := Vector2(dir.x, dir.z)

		var phi : float = desired_heading_2d.angle_to( player_heading_2d )
		phi = phi * delta * 3.0
		self.rotation.y += phi
		v = v.rotated( Vector3.UP, self.rotation.y)

		animation_tree["parameters/playback"].travel("WalkRun_blendspace")
		
		var _dir_length_bias = dir_length_smoothed #Util.bias(dir_length_smoothed, 0.3)#TODO: curve control instead of bias
		movement_walk_run_blend = Util.remap(_dir_length_bias, 0.0, 1.0, -1.0, 1.0 )
		
		var _ts = Util.remap( _dir_length_bias, 0.0, 1.0, 1.0, 2.5 )
		animation_tree.set("parameters/WalkRun_blendspace/walk_timescale/scale", initial_timescale_walk * _ts)
		animation_tree.set("parameters/WalkRun_blendspace/run_timescale/scale", initial_timescale_run * _ts )
		animation_tree.set("parameters/WalkRun_blendspace/fastrun_timescale/scale", initial_timescale_fastrun * _ts)
		
		animation_tree.set("parameters/WalkRun_blendspace/blend_walk_running/blend_amount", movement_walk_run_blend )
	else:
		movement_walk_run_blend = -1.0
		v = v.rotated( Vector3.UP, self.rotation.y)
		animation_tree["parameters/playback"].travel("IdleAction")

	ms_collision_vel = move_and_slide(v, Vector3.UP)


