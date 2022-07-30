extends Camera

export (NodePath) onready var target = get_node(target)
export (Resource) var camera_data

export(Curve) var look_stick_response_curve
export(Array, Vector2) var look_stick_response_regions setget set_look_stick_response_regions

var pitch_limit : Vector2 = Vector2(-0.5, 0.5)
var target_rotation := Vector3.ZERO

var target_origin_track := Vector3.ZERO
const harmonic_motion_lib = preload("res://scripts/harmonic_motion.gd")
var target_origin_spring = harmonic_motion_lib.new()
var unproject_target := Vector2.ZERO

func _ready():
	yield(get_owner(), "ready")
	print("[camera] target reference: %s"%target.get_path())
	
	if camera_data.target_offset == Vector3.ZERO:
		camera_data.target_offset = self.transform.origin -\
									target.transform.origin -\
									camera_data.anchor_offset
	if camera_data.look_target == Vector3.ZERO:
		camera_data.look_target = Vector3(0.0, 0.0, -100.0)
	
	pitch_limit.x = deg2rad( camera_data.pitch_limit.x )
	pitch_limit.y = deg2rad( camera_data.pitch_limit.y )

	target_rotation = camera_data.rotation

	target_origin_track = target.transform.origin
	target_origin_spring.initialise( 0.965, 4.0 )


func _process(delta):
	
	# handle gamepad
	var horizontal = Input.get_action_strength("look_right") - Input.get_action_strength("look_left")
	var vertical = Input.get_action_strength("look_up") - Input.get_action_strength("look_down")
	
	# look stick sensitivity curve lookup
	var hsign := sign(horizontal)
	var vsign := sign(vertical)
	horizontal = hsign * look_stick_response_curve.interpolate_baked( abs(horizontal) )
	vertical = vsign * look_stick_response_curve.interpolate_baked( abs(vertical) )
	
	# times settings sensitivity and inverted-look
	if horizontal != 0 or vertical != 0 :
		target_rotation.y -= horizontal * GameSettings.gamepad_look_sensitivity
		target_rotation.x -= vertical * GameSettings.gamepad_look_sensitivity * ( 1 if GameSettings.gamepad_look_invert_vertical else -1 )

	# time smoothing
	camera_data.rotation.y = lerp(camera_data.rotation.y, target_rotation.y, delta*10.0)
	camera_data.rotation.x = lerp(camera_data.rotation.x, target_rotation.x, delta*10.0)

	# set camera rig
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

	unproject_target = self.unproject_position( target.transform.origin )


func _unhandled_input(event):
	if event is InputEventMouseMotion:
		var _mrel = event.get_relative()*0.005
		target_rotation.y -= _mrel.x
		target_rotation.x -= _mrel.y
	
	target_rotation.x = clamp( target_rotation.x, pitch_limit.x, pitch_limit.y)


func set_look_stick_response_regions(new_value) -> void:
	look_stick_response_regions = new_value
	print("[camera] set_look_stick_response_regions new_value %s"%str(new_value))
	Util.set_curve_from_array_linear( new_value, look_stick_response_curve )
	look_stick_response_curve.set_bake_resolution(32)
	print("[camera] look_stick_response_curve npoints %s"%[look_stick_response_curve.get_point_count()])
	



