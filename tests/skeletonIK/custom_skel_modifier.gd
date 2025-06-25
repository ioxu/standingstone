#@tool

class_name CustomSkelModifier
extends SkeletonModifier3D

@export_enum(" ") var bone: String

@export var max_sy = 1.3
@export var min_sy = 0.5
#@export var this_sy = 1.0
var this_sy = 1.0

@export var speed : float = 2.0


@onready var global_time = 0.0

var initial_rest_transform : Transform3D
var this_rest_transform : Transform3D

func _validate_property(property: Dictionary) -> void:
	if property.name == "bone":
		var skeleton: Skeleton3D = get_skeleton()
		if skeleton:
			property.hint = PROPERTY_HINT_ENUM
			property.hint_string = skeleton.get_concatenated_bone_names()


func _process_modification() -> void:
	var skeleton: Skeleton3D = get_skeleton()
	if !skeleton:
		return # Never happen, but for the safety
	var bone_idx: int = skeleton.find_bone(bone)
	var s : Vector3 = Vector3(1.0, this_sy, 1.0)
	this_rest_transform.origin = initial_rest_transform.origin + Vector3(0.0, this_sy, 0.0)
	
	#skeleton.set_bone_rest( bone_idx, this_rest_transform  )
	#skeleton.set_bone_pose_scale( bone_idx, Vector3(1.0, this_sy*1.0, 1.0)  )
	
	#print(this_rest_transform.origin)
	

func _ready() -> void:
	var skeleton: Skeleton3D = get_skeleton()
	var bone_idx: int = skeleton.find_bone(bone)
	initial_rest_transform = skeleton.get_bone_rest( bone_idx )
	this_rest_transform = Transform3D( initial_rest_transform )
	print("INITIAL rest origin: %s (%s)"%[initial_rest_transform.origin, bone_idx] )


func _process(delta: float) -> void:
	global_time += delta
	var ss = sin(global_time * speed ) / 2.0 + 0.5
	this_sy = lerp( min_sy, max_sy, ss)
