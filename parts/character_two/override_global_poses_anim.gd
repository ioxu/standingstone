extends Node
@export var do:= true
@export var skeleton : Skeleton3D

var initial_spine_pose:Transform3D
var spine_pose:Transform3D
var spine_id := -2

var global_time := 0.0


func _ready() -> void:
	pprint("skeleton: %s"%skeleton)
	spine_id = skeleton.find_bone("Spine")
	initial_spine_pose = skeleton.get_bone_rest(spine_id)


func _process(delta: float) -> void:
	if do:
		global_time += delta
		spine_pose = initial_spine_pose * Transform3D().rotated( Vector3.RIGHT, (sin(global_time * 10) * 0.015))#* 0.15))
		var c_spine_pose = skeleton.get_bone_global_pose_no_override( spine_id )
		c_spine_pose = c_spine_pose.rotated_local( Vector3.FORWARD, (sin(global_time * 10) * 0.35) )
		skeleton.set_bone_global_pose_override( spine_id, c_spine_pose, 1.0, false )



func pprint(thing) -> void:
	print("[override global poses anim] %s"%thing)
