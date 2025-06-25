extends CharacterBody3D
#extends KinematicBody

#export(NodePath) var animation_tree_path
@export var animation_tree : AnimationTree
@export var animation_player : AnimationPlayer
#onready var animation_tree = get_node( animation_tree_path )

#export(NodePath) onready var camera = get_node(camera)
@export var camera : Camera3D

@export var y_control : float

var gravity : Vector3 = Vector3.ZERO

# var ms_collision_vel := Vector3.ZERO # TODO : 3.5 : is this used??
var ms_collided := false
var dir := Vector3.ZERO
var _raw_dir_input := Vector2.ZERO

#---------------------------------------------
const harmonic_motion_lib = preload("res://scripts/harmonic_motion.gd")
var global_time = 0.0

#---------------------------------------------
#var character_speed = 0.0

#---------------------------------------------
# TODO: make most character locomotion parameters into a struct/resource (single object for other objects to read from)
var movement_walk_run_blend = 0.0 # TODO: temp
var dir_length_smoothed := 0.0
#---------------------------------------------
# timescales are set in the blendspace, calculated to normalise their length egainst each other
# and set to 'sync' mode in the blend 
var initial_timescale_walk := 1.0
var initial_timescale_jog := 1.0
var initial_timescale_sprint := 1.0
#---------------------------------------------
var is_sprinting := false
var sprint_blend := 0.0
var sprint_blend_hm = harmonic_motion_lib.new()
#---------------------------------------------
# random idle
# these vars are involved in choosing and blending to random idle animations in 
# animation_tree parameters/IdleAction2/BlendSpace2D.
#var idle_blend_coords = [Vector2(1, 0)]# [Vector2(0.0,1.0), Vector2(1.0,0.0), Vector2(0,-1), Vector2(-1, 0)]
var idle_blend_coords = [Vector2(0.0,1.0), Vector2(1.0,0.0), Vector2(0,-1), Vector2(-1, 0)]
var this_idle_coord = idle_blend_coords[0]
var next_idle_coord = idle_blend_coords[0]
var idle_blend_speed = 2.0
var idle_blend_blend = 0.0
var blend_coord : Vector2

#---------------------------------------------
# TODO: footfall / foot call method trackm in AnimationPlyer is temporary
@onready var puff : PackedScene = preload( "res://parts/effects/footfalls/footfall_puff.tscn" )
@onready var skeleton : Skeleton3D = $AnimationLibrary_Godot/Rig/GeneralSkeleton #$AnimationLibrary_Godot/Rig/Skeleton3D #$mannequin/Armature/Skeleton3D #$mannequin/Armature/Skeleton # 3.5

@onready var leftFootBone_index = skeleton.find_bone("LeftFoot")#"DEF-foot.L")#"LeftFoot")
@onready var rightFootBone_index = skeleton.find_bone("RightFoot")#"DEF-foot.R")#"RightFoot")


func _ready():
	pprint("camera reference: %s"%camera.get_path())

	pprint("#############################")
	pprint("skeleton: %s"%skeleton)
	pprint("#############################")

	pprint("animations:")
	# normalise WalkRun blendspace animation lengths
	var animation_player = self.find_child("AnimationPlayer") # self.find_node("AnimationPlayer")

	# 3.5 looks like animation import REMOVES "-loop" from animation names
#	var standardWalkLoop_length = animation_player.get_animation("Standard Walk-loop").length
#	pprint("  Standard Walk-loop length %s"%standardWalkLoop_length)
#	var runningLoop_length = animation_player.get_animation("Running-loop").length
#	pprint("  Running-loop length %s (timescale %s)"%[runningLoop_length, runningLoop_length/standardWalkLoop_length])
#	var fastRunLoop_length = animation_player.get_animation("Fast Run-loop").length
#	pprint("  Fast Run-loop length %s (timescale %s)"%[fastRunLoop_length,fastRunLoop_length/standardWalkLoop_length])

	var standardWalkLoop_length = animation_player.get_animation("Walk").length
	pprint("  Walk length %s"%standardWalkLoop_length)
	var runningLoop_length = animation_player.get_animation("Jog_Fwd").length
	pprint("  Jog length %s (timescale %s)"%[runningLoop_length, runningLoop_length/standardWalkLoop_length])
	var fastRunLoop_length = animation_player.get_animation("Sprint").length
	pprint("  Sprint length %s (timescale %s)"%[fastRunLoop_length,fastRunLoop_length/standardWalkLoop_length])

	animation_tree.set("parameters/WalkRun_blendspace/walk_timescale/scale", 1.0)
	animation_tree.set("parameters/WalkRun_blendspace/jog_timescale/scale", runningLoop_length/standardWalkLoop_length)
	animation_tree.set("parameters/WalkRun_blendspace/sprint_timescale/scale", fastRunLoop_length/standardWalkLoop_length)

	initial_timescale_walk = animation_tree.get("parameters/WalkRun_blendspace/walk_timescale/scale")
	initial_timescale_jog = animation_tree.get("parameters/WalkRun_blendspace/jog_timescale/scale")
	initial_timescale_sprint = animation_tree.get("parameters/WalkRun_blendspace/sprint_timescale/scale")
	
	pprint("initial_timescale_walk %s"%initial_timescale_walk )
	pprint("initial_timescale_jog %s"%initial_timescale_jog )
	pprint("initial_timescale_sprint %s"%initial_timescale_sprint )	
	$AnimationTree.set_active(true)

	sprint_blend_hm.initialise(0.95, 4.5)

	pprint("animation list:")
	var animation_list = animation_player.get_animation_list()
	for a in animation_list:
		pprint("  %s"%a )
		if a == "Sprint_Root":
			var anim = animation_player.get_animation( a )
			pprint("    %s"%anim)
	
	var anim : Animation = animation_player.get_animation("Sprint_Root")
	var tc = anim.get_track_count()
	for ti in range(tc):
		print("track: %s"%anim.track_get_path(ti) )
	pprint("Sprint_Root:")
	var track_idx = animation_player.get_animation("Sprint_Root").find_track("Rig/Skeleton3D:root:property:extra_prop", Animation.TYPE_BEZIER)
	if track_idx != -1:
		var cur_val = animation_player.get_animation("Sprint_Root").track_get_key_value(track_idx, animation_player.current_animation_position)
		pprint("bone_prop = %s"%cur_val)
	else:
		pprint( "can't find 'Rig/Skeleton3D:root:property:extra_prop' " )


var root_pos : Vector3
var root_velocity : Vector3

func _process(delta: float) -> void:
	root_pos = animation_tree.get_root_motion_position() * 0.5
	root_velocity = root_pos / delta
	#pprint("root_pos %s"%root_pos )

func _physics_process(delta):
	global_time += delta
	# **AnimationTree** must run in Physics frame; .set_process_callback(0) # (default is 1)
	# in 4.0 AnimationTree.get_root_motion_transform() has been split into
	# .get_root_motion_position()
	# .get_root_motion_rotation()
	# .get_root_motion_scale()

	#var root_motion : Transform3D = animation_tree.get_root_motion_transform() # 3.5
	# var v = root_motion.origin / delta # 3.5
	
	#var v : Vector3 = animation_tree.get_root_motion_position() / delta
	#var v : Vector3 = animation_tree.get_root_motion_position() /delta


	#skeleton.position.y = -v.y * delta * y_control
	#--------------------------------------------------------------------------
	# gravity
	if is_on_floor():
		gravity = Vector3.ZERO
		#print("on floor")
		#v *= Vector3(1, 0, 1)
	else:
		gravity += Vector3(0.0, -9.8, 0.0) * delta
		#print("NOT on floor")

	
	var v = root_velocity + gravity
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

	dir_length_smoothed = lerp( dir_length_smoothed, dir.length(), 0.95 * delta * 3.5 )
	#dir_length_smoothed = clamp(Util.remap(dir_length_smoothed, 0.0, 0.9,  0.0, 1.0), 0.0, 1.0)
	
	if dir.length_squared() > 0.005:
		dir = dir.rotated(Vector3.UP, camera.camera_data.rotation.y)

		var player_heading_2d := Vector2(self.transform.basis.z.x, self.transform.basis.z.z)
		var desired_heading_2d := Vector2(dir.x, dir.z)

		var phi : float = desired_heading_2d.angle_to( player_heading_2d )
		phi = phi * delta * 6.0 #3.0
		self.rotation.y += phi
		v = v.rotated( Vector3.UP, self.rotation.y)

		animation_tree["parameters/playback"].travel("WalkRun_blendspace")

		# account for small errors at the 'circle' of stick movement.
		# TODO: parameterise the remap stop1 limit here
		#dir_length_smoothed = clamp(Util.remap(dir_length_smoothed, 0.0, 0.96,  0.0, 1.0), 0.0, 1.0)

		# bias the dir_length so that walking is finer at the lower end of dir_length.6
		var _dir_length_bias = Util.bias(dir_length_smoothed, 0.255)#TODO: curve control instead of bias
		
		movement_walk_run_blend = Util.remap(_dir_length_bias, 0.0, 1.0, -1.0, self.sprint_blend )
		#var _top_speed = Util.remap(self.sprint_blend, 0.0, 1.0, 1.5, 2.5)
		var _top_speed = Util.remap(self.sprint_blend, 0.0, 1.0, 1.5, 2.5)
		#var _top_speed = Util.remap(self.sprint_blend, 0.0, 1.0, 5.0, 20.0)
		#pprint("top speed: %s"%_top_speed)
		var _ts = Util.remap( _dir_length_bias, 0.0, 1.0, 1.0, _top_speed )
		animation_tree.set("parameters/WalkRun_blendspace/walk_timescale/scale", initial_timescale_walk * _ts)
		animation_tree.set("parameters/WalkRun_blendspace/jog_timescale/scale", initial_timescale_jog * _ts )
		animation_tree.set("parameters/WalkRun_blendspace/sprint_timescale/scale", initial_timescale_sprint * _ts)

		movement_walk_run_blend = clamp( movement_walk_run_blend, -1.0, 1.0 )
		animation_tree.set("parameters/WalkRun_blendspace/blend_walk_running/blend_amount", movement_walk_run_blend )


		if dir.length() > 0.5:
			if !is_sprinting and Input.is_action_just_pressed("sprint"):
				self.is_sprinting = true
			elif is_sprinting and Input.is_action_just_pressed("sprint"):
				self.is_sprinting = false
		elif dir.length() < 0.5 and self.is_sprinting:
			self.is_sprinting = false

		if self.is_sprinting:
			self.sprint_blend = sprint_blend_hm.calculate( self.sprint_blend, 1.0 )
		else:
			self.sprint_blend = sprint_blend_hm.calculate( self.sprint_blend, 0.0 )

	else:
		movement_walk_run_blend = -1.0
		v = v.rotated( Vector3.UP, self.rotation.y)
		animation_tree["parameters/playback"].travel("IdleAction")
		self.is_sprinting = false
		self.sprint_blend = sprint_blend_hm.calculate( self.sprint_blend, 0.0 )
		
		if idle_blend_blend < 1.0:
			idle_blend_blend += delta*idle_blend_speed
			blend_coord = lerp( this_idle_coord, next_idle_coord, idle_blend_blend )
		else:
			blend_coord = next_idle_coord

		animation_tree.set("parameters/IdleAction/BlendSpace2D/blend_position", blend_coord )
 
	set_velocity(v)
	set_up_direction( Vector3.UP )
	ms_collided = move_and_slide()


# warning-ignore:unused_argument
# warning-ignore:unused_argument
func foot_fall(strength:float=1.0, side:= "left", source:="undefined") -> void:
	"""callable for footfall effects, driven by animations"""
	#pprint("[foot_fall] %s (%s) %s"%[strength, side, source])
	var ft = null
	if side == "left":
		ft = skeleton.get_bone_global_pose( leftFootBone_index )
	elif side == "right":
		ft = skeleton.get_bone_global_pose( rightFootBone_index )
	var p = puff.instantiate()
	self.get_parent().add_child(p)
	p.transform.origin = skeleton.global_transform * ft.origin


func _exit_tree() -> void:
	sprint_blend_hm.queue_free()


func pprint(thing) -> void:
	print("[character two] %s"%thing)


func _on_idle_loop_timeout_timeout() -> void:
	this_idle_coord = next_idle_coord
	next_idle_coord = idle_blend_coords[randi() % idle_blend_coords.size()]
	idle_blend_blend = 0.0
	#pprint("choosing a new idle loop ... %s"%next_idle_coord)
	
