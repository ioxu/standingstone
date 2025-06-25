extends Camera3D

#export (NodePath) onready var target = get_node(target)
#export (Resource) var camera_data

@export var target : CharacterBody3D
@export var camera_data : Resource

#export(Curve) var look_stick_response_curve
#export(Array, Vector2) var look_stick_response_regions setget set_look_stick_response_regions

@export var look_stick_response_curve : Curve
@export var look_stick_response_regions : Array[Vector2]:
	set = set_look_stick_response_regions


var pitch_limit : Vector2 = Vector2(-0.5, 0.5)
var target_rotation := Vector3.ZERO

#export(float) var track_horizontal_margin_min := 0.3
#export(float) var track_horizontal_margin_max := 0.075

@export var track_horizontal_margin_min := 0.3
@export var track_horizontal_margin_max := 0.075

#export(float) var track_bottom_margin_min := .95 # (very bottom of screen)
#export(float) var track_bottom_margin_max := 1.2

@export var track_bottom_margin_min := 0.95  # (very bottom of screen)
@export var track_bottom_margin_max := 1.2

#export(float) var track_distance_margin_min := 1.0
#export(float) var track_distance_margin_max := 3.0

@export var track_distance_margin_min := 1.0
@export var track_distance_margin_max := 3.0

var target_origin_track := Vector3.ZERO
const harmonic_motion_lib = preload("res://scripts/harmonic_motion.gd")
var target_origin_spring = harmonic_motion_lib.new()
var target_margin_factor := 0.0 # the factor thaat the target origin is in the edge margins of the camera view


func _ready():
	#yield(get_owner(), "ready")
	await get_owner().ready
	
	print("[camera] target reference: %s"%target.get_path())
	
	if camera_data.target_offset == Vector3.ZERO:
		camera_data.target_offset = self.transform.origin -\
									target.transform.origin -\
									camera_data.anchor_offset
		print("[camera] calculated target_offset: %s"%camera_data.target_offset)
	if camera_data.look_target == Vector3.ZERO:
		camera_data.look_target = Vector3(0.0, 0.0, -100.0)
	
	pitch_limit.x = deg_to_rad( camera_data.pitch_limit.x )
	pitch_limit.y = deg_to_rad( camera_data.pitch_limit.y )

	target_rotation = camera_data.rotation

	target_origin_track = target.transform.origin
	target_origin_spring.initialise( 0.965, 2.0 )

	print("[camera] viewport %s size %s"%[get_viewport().get_path(), get_viewport().size] )

func _process(delta):
	
	# handle gamepad
	var horizontal = Input.get_action_strength("look_right") - Input.get_action_strength("look_left")
	var vertical = Input.get_action_strength("look_up") - Input.get_action_strength("look_down")
	
	# look stick sensitivity curve lookup
	var hsign := signf(horizontal)
	var vsign := signf(vertical)
	horizontal = hsign * look_stick_response_curve.sample_baked( abs(horizontal) )
	vertical = vsign * look_stick_response_curve.sample_baked( abs(vertical) )
	
	# times settings sensitivity and inverted-look
	# TODO: gamepad camera look sensitivity is not time delta dependant
	if horizontal != 0 or vertical != 0 :
		target_rotation.y -= horizontal * GameSettings.gamepad_look_sensitivity
		target_rotation.x -= vertical * GameSettings.gamepad_look_sensitivity * ( 1 if GameSettings.gamepad_look_invert_vertical else -1 )

	# time smoothing
	camera_data.rotation.y = lerp(camera_data.rotation.y, target_rotation.y, delta * GameSettings.gamepad_look_smoothing)
	camera_data.rotation.x = lerp(camera_data.rotation.x, target_rotation.x, delta * GameSettings.gamepad_look_smoothing)

	# clamp here, too
	target_rotation.x = clamp( target_rotation.x, pitch_limit.x, pitch_limit.y)

	# set camera rig
	target_margin_factor = calculate_target_margin_factor()
	if target_margin_factor > 0.0:
		target_origin_spring.initialise( 0.965, 2.0 + exp(target_margin_factor * 2.5) )
	else:
		target_origin_spring.initialise( 0.965, 2.0 )
		
	target_origin_track = target_origin_spring.calculate_v3( target_origin_track, target.transform.origin )
	self.transform.origin = target_origin_track + camera_data.anchor_offset
	#self.transform.origin = target.transform.origin + camera_data.anchor_offset
	
	var target_offset = camera_data.target_offset
	var look_at = camera_data.look_target
	var up_down_axis = Vector3.RIGHT.rotated(Vector3.UP, camera_data.rotation.y)
	target_offset = target_offset.rotated(Vector3.UP, camera_data.rotation.y)
	look_at = look_at.rotated(Vector3.UP, camera_data.rotation.y)
	target_offset = target_offset.rotated(up_down_axis, camera_data.rotation.x)
	look_at = look_at.rotated(up_down_axis, camera_data.rotation.x)
	
	self.transform.origin += target_offset
	self.look_at(look_at, Vector3.UP)


func _unhandled_input(event):
#	if event is InputEventMouseButton:
#		print("[camera] _unhandled_input, event %s"%event )

	#if event is InputEventMouseMotion:
		##print("[camera] _unhandled_input, event %s"%event )
		##print("[camera] _unhandled_input, event.get_relative %s"%event.get_relative() )
		#var _mrel = event.get_relative()*0.005
		#target_rotation.y -= _mrel.x
		#target_rotation.x -= _mrel.y
		
	target_rotation.x = clamp( target_rotation.x, pitch_limit.x, pitch_limit.y)


func set_look_stick_response_regions(new_value) -> void:
	look_stick_response_regions = new_value
	print("[camera] set_look_stick_response_regions new_value %s"%str(new_value))
	Util.set_curve_from_array_linear( new_value, look_stick_response_curve )
	look_stick_response_curve.set_bake_resolution(32)
	print("[camera] look_stick_response_curve npoints %s"%[look_stick_response_curve.get_point_count()])
	

func calculate_target_margin_factor() -> float:
	"""calculate a factor for when the camera's target (the player)
	has entered the cameras "edge" margins, and an amplification to 
	the lerping spring should be applied to track the camera faster
	with its target
	"""
	var _tmf := 0.0
	var unproject_target = self.unproject_position( target.transform.origin )
	var ws = get_viewport().size #get_tree().get_root().size
	var norm_uproject_target : Vector2 = unproject_target / Vector2(ws)
	_tmf = max( Util.remap_clamp( norm_uproject_target.x,
		track_horizontal_margin_min,
		track_horizontal_margin_max,
		0.0,
		1.0 )
		,
		Util.remap_clamp( norm_uproject_target.x,
		1.0-track_horizontal_margin_min,
		1.0-track_horizontal_margin_max,
		0.0,
		1.0 )
		)
	_tmf = max(_tmf,
		Util.remap_clamp(norm_uproject_target.y,
			track_bottom_margin_min,
			track_bottom_margin_max,
			0.0,
			1.0)
		)
	_tmf = max(_tmf,
		Util.remap_clamp( (target_origin_track-target.transform.origin).length(),
			track_distance_margin_min,
			track_distance_margin_max,
			0.0,
			1.0
			)
	)
	return _tmf


func _exit_tree() -> void:
	target_origin_spring.queue_free()


func unproject_position_in_viewport(pos:Vector3) -> Vector2:
	# unproject_position, but normalised to viewport
	return self.unproject_position( pos ) / Vector2( get_viewport().size )
