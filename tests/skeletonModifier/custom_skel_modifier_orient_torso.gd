@tool

class_name CustomSkelModifier_OrientTorso

extends SkeletonModifier3D

@export_enum(" ") var bone: String

var global_time := 0.0


func _validate_property(property: Dictionary) -> void:
	if property.name == "bone":
		var skeleton: Skeleton3D = get_skeleton()
		if skeleton:
			property.hint = PROPERTY_HINT_ENUM
			property.hint_string = skeleton.get_concatenated_bone_names()


func _ready() -> void:
	var skeleton: Skeleton3D = get_skeleton()


func _process_modification() -> void:
	var skeleton: Skeleton3D = get_skeleton()
	if !skeleton:
		return # Never happen, but for the safety


func _process(delta: float) -> void:
	global_time += delta
	
