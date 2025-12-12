@tool

class_name CustomSkelModifier_undulator
extends SkeletonModifier3D

@export_enum(" ") var bone: String

@export var max_sy = 0.5
@export var min_sy = -0.75

@export var speed : float = 3.0
@export var time_offset : float = -0.5

@onready var global_time = 0.0

var bone_list := ["Spine", "Chest", "UpperChest", "Neck", "Head"]

var bone_index_list : Array[int] = []
var bone_initial_rest_transforms : Array[Transform3D] = []
var bone_x_rots : Array[float] = []


func _validate_property(property: Dictionary) -> void:
	if property.name == "bone":
		var skeleton: Skeleton3D = get_skeleton()
		if skeleton:
			property.hint = PROPERTY_HINT_ENUM
			property.hint_string = skeleton.get_concatenated_bone_names()


func _ready() -> void:
	var skeleton: Skeleton3D = get_skeleton()
	for i in range(bone_list.size()):
		bone_index_list.append( skeleton.find_bone(bone_list[i]) )
		bone_initial_rest_transforms.append( skeleton.get_bone_rest( bone_index_list[i] ) )
		bone_x_rots.append(0.0)
		print("bones_list %d %s (index %d)"%[i,bone_list[i], bone_index_list[i]])


func _process_modification() -> void:
	var skeleton: Skeleton3D = get_skeleton()
	if !skeleton:
		return # Never happen, but for the safety
	for i in range(bone_index_list.size()):
		var pose: Transform3D = skeleton.get_bone_global_pose( bone_index_list[i] )
		skeleton.set_bone_global_pose(bone_index_list[i], Transform3D( pose.basis.rotated( pose.basis.x, bone_x_rots[i] ), pose.origin ) )


func _process(delta: float) -> void:
	global_time += delta
	for i in range(bone_x_rots.size()):
		var ss = sin( (global_time * speed) + (time_offset*i)  ) / 2.0 + 0.5
		bone_x_rots[i] = lerp( min_sy, max_sy, ss)
	
