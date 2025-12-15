#@tool

class_name CustomSkelModifier_OrientTorso

extends SkeletonModifier3D

@export_enum(" ") var bone: String

@export var character_body : CharacterBody3D

var player_desired_heading_marker : Node3D

var global_time := 0.0

var bone_names : Array = ["UpperChest", "Chest", "Spine"]
var bone_indices : Array[int] = [-2, -2, -2]

# https://github.com/natsu-anon/DampedHarmonicOscillatorDemo/blob/master/src/SecondaryMotion.gd
class Spring1:
	var spring_coefficient: float
	var damping_coefficient: float
	var velocity: float = 0.0
	var target: float = 0.0

	func _init(spring: float, damping: float) -> void:
		spring_coefficient = spring
		damping_coefficient = damping

	func tick(delta: float, position: float) -> float:
		var deceleration: float = delta * damping_coefficient * velocity
		if abs(velocity) > abs(deceleration):
			velocity -= deceleration
		else:
			velocity = 0.0
		velocity += delta * spring_coefficient * (target - position)
		return position + delta * velocity


var angle : float = 0.0
var angle_spring : Spring1 = Spring1.new( 80.0, 10.0 )


func _validate_property(property: Dictionary) -> void:
	var skeleton: Skeleton3D = get_skeleton()
	if property.name == "bone":
		if skeleton:
			property.hint = PROPERTY_HINT_ENUM
			property.hint_string = skeleton.get_concatenated_bone_names()


func _ready() -> void:
	var skeleton: Skeleton3D = get_skeleton()
	player_desired_heading_marker = find_child("player_desired_heading")
	
	bone_indices = [skeleton.find_bone(bone_names[0]), skeleton.find_bone(bone_names[1]), skeleton.find_bone(bone_names[2]) ]
	print("### bone_indices ", bone_indices)


func _process_modification() -> void:
	var skeleton: Skeleton3D = get_skeleton()
	if !skeleton:
		return # Never happen, but for the safety
	
	var pose_UpperChest: Transform3D = skeleton.get_bone_global_pose( bone_indices[0] )
	var pose_Chest: Transform3D = skeleton.get_bone_global_pose( bone_indices[1] )
	var pose_Spine: Transform3D = skeleton.get_bone_global_pose( bone_indices[2] )
	
	var angle_third = angle/3.0
	skeleton.set_bone_global_pose(bone_indices[0], Transform3D( pose_UpperChest.basis.rotated( Vector3.UP, -angle_third ), pose_UpperChest.origin ) )
	skeleton.set_bone_global_pose(bone_indices[1], Transform3D( pose_Chest.basis.rotated( Vector3.UP, -angle_third ), pose_Chest.origin ) )
	skeleton.set_bone_global_pose(bone_indices[2], Transform3D( pose_Spine.basis.rotated( Vector3.UP, -angle_third ), pose_Spine.origin ) )


func _process(delta: float) -> void:
	global_time += delta

	player_desired_heading_marker.global_rotation.y = -Vector2.DOWN.angle_to( character_body.desired_heading_2d )
	var from : Vector2 = Vector2(self.get_parent().global_basis.z.x, self.get_parent().global_basis.z.z).normalized()

	angle_spring.target = from.angle_to( character_body.desired_heading_2d.normalized() )
	angle = angle_spring.tick( delta, angle )


	
