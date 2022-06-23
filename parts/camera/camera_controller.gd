extends Camera

export (NodePath) onready var target = get_node(target)
export (Resource) var camera_data

var pitch_limit : Vector2 = Vector2(-0.5, 0.5)

var target_rotation := Vector3.ZERO


func _ready():
	if camera_data.target_offset == Vector3.ZERO:
		camera_data.target_offset = self.transform.origin -\
									target.transform.origin -\
									camera_data.anchor_offset
	if camera_data.look_target == Vector3.ZERO:
		camera_data.look_target = Vector3(0.0, 0.0, -100.0)
	
	pitch_limit.x = deg2rad( camera_data.pitch_limit.x )
	pitch_limit.y = deg2rad( camera_data.pitch_limit.y )

	target_rotation = camera_data.rotation


func _process(delta):
	
	# handle gamepad
	var horizontal = Input.get_action_strength("look_right") - Input.get_action_strength("look_left")
	var vertical = Input.get_action_strength("look_up") - Input.get_action_strength("look_down")
	if horizontal != 0 or vertical != 0 :
		target_rotation.y -= horizontal * GameSettings.gamepad_look_sensitivity
		target_rotation.x -= vertical * GameSettings.gamepad_look_sensitivity * ( 1 if GameSettings.gamepad_look_invert_vertical else -1 )


	camera_data.rotation.y = lerp(camera_data.rotation.y, target_rotation.y, delta*10.0)
	camera_data.rotation.x = lerp(camera_data.rotation.x, target_rotation.x, delta*10.0)


	self.transform.origin = target.transform.origin + camera_data.anchor_offset
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
	if event is InputEventMouseMotion:
		var _mrel = event.get_relative()*0.005
		target_rotation.y -= _mrel.x
		target_rotation.x -= _mrel.y
	
	target_rotation.x = clamp( target_rotation.x, pitch_limit.x, pitch_limit.y)

