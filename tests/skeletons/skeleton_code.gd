extends Node3D

#onready var window_res = get_viewport().size
@onready var window_res : Vector2 = get_viewport().size
#onready var half_window_res = window_res/2.0
@onready var half_window_res = window_res/2.0

var mouse_pos_blend := Vector2.ZERO
var proc_anim_blend := 1.0
var proc_anim_blend_rate := 0.05

var skel:Skeleton3D

var spine_id := -2
var spine1_id := -2
var spine2_id := -2
var neck_id := -2
var head_id := -2
var leftShoulder_id := -2
var leftArm_id := -2
var leftForeArm_id := -2
var leftHand_id := -2
var rightShoulder_id := -2
var rightArm_id := -2
var rightForeArm_id := -2
var rightHand_id := -2

var leftUpLeg_id := -2

var initial_spine_pose:Transform3D
var initial_spine1_pose:Transform3D
var initial_spine2_pose:Transform3D
var initial_neck_pose:Transform3D
var initial_head_pose:Transform3D
var initial_leftShoulder_pose:Transform3D
var initial_leftArm_pose:Transform3D
var initial_leftForeArm_pose:Transform3D
var initial_leftHand_pose:Transform3D
var initial_rightShoulder_pose:Transform3D
var initial_rightArm_pose:Transform3D
var initial_rightForeArm_pose:Transform3D
var initial_rightHand_pose:Transform3D

var spine_pose:Transform3D
var spine1_pose:Transform3D
var spine2_pose:Transform3D
var neck_pose:Transform3D
var head_pose:Transform3D
var leftShoulder_pose:Transform3D
var leftArm_pose:Transform3D
var leftForeArm_pose:Transform3D
var leftHand_pose:Transform3D
var rightShoulder_pose:Transform3D
var rightArm_pose:Transform3D
var rightForeArm_pose:Transform3D
var rightHand_pose:Transform3D

var gtime := 0.0

var time_scale = 5#2

@onready var animation_tree = $AnimationTree

func _ready() -> void:
	#skel = $ViewportContainer/mannequin/Armature/Skeleton #$mannequin/Armature/Skeleton
	skel = $ViewportContainer/SubViewport/mannequin/Armature/Skeleton3D 

	pprint("skeleton: %s"%skel.get_path())
	var blend = $AnimationTree.tree_root.get_node("BlendSpace2D")
	pprint("blend: %s"%blend)

	spine_id = skel.find_bone("Spine")
	spine1_id = skel.find_bone("Spine1")
	spine2_id = skel.find_bone("Spine2")
	neck_id = skel.find_bone("Neck")
	head_id = skel.find_bone("Head")
	leftShoulder_id = skel.find_bone("LeftShoulder")
	leftArm_id = skel.find_bone("LeftArm")
	leftForeArm_id = skel.find_bone("LeftForeArm")
	leftHand_id = skel.find_bone("LeftHand")
	rightShoulder_id = skel.find_bone("RightShoulder")
	rightArm_id = skel.find_bone("RightArm")
	rightForeArm_id = skel.find_bone("RightForeArm")
	rightHand_id = skel.find_bone("RightHand")

	leftUpLeg_id = skel.find_bone("LeftUpLeg")

	pprint("Spine %s"%spine_id)
	pprint("Spine1 %s"%spine1_id)
	pprint("Spine2 %s"%spine2_id)
	pprint("Neck %s"%neck_id)
	pprint("Head %s"%head_id)

#	initial_spine_pose = skel.get_bone_pose(spine_id)
#	initial_spine1_pose = skel.get_bone_pose(spine1_id)
#	initial_spine2_pose = skel.get_bone_pose(spine2_id)
#	initial_neck_pose = skel.get_bone_pose(neck_id)
#	initial_head_pose = skel.get_bone_pose(head_id)
#
#	initial_leftShoulder_pose = skel.get_bone_pose(leftShoulder_id)
#	initial_leftArm_pose = skel.get_bone_pose(leftArm_id)
#	initial_leftForeArm_pose = skel.get_bone_pose(leftForeArm_id)
#	initial_leftHand_pose = skel.get_bone_pose(leftHand_id)
#	initial_rightShoulder_pose = skel.get_bone_pose(rightShoulder_id)
#	initial_rightArm_pose = skel.get_bone_pose(rightArm_id)
#	initial_rightForeArm_pose = skel.get_bone_pose(rightForeArm_id)
#	initial_rightHand_pose = skel.get_bone_pose(rightHand_id)


#	initial_spine_pose = skel.get_bone_global_pose(spine_id)
#	initial_spine1_pose = skel.get_bone_global_pose(spine1_id)
#	initial_spine2_pose = skel.get_bone_global_pose(spine2_id)
#	initial_neck_pose = skel.get_bone_global_pose(neck_id)
#	initial_head_pose = skel.get_bone_global_pose(head_id)
#
#	initial_leftShoulder_pose = skel.get_bone_global_pose(leftShoulder_id)
#	initial_leftArm_pose = skel.get_bone_global_pose(leftArm_id)
#	initial_leftForeArm_pose = skel.get_bone_global_pose(leftForeArm_id)
#	initial_leftHand_pose = skel.get_bone_global_pose(leftHand_id)
#	initial_rightShoulder_pose = skel.get_bone_global_pose(rightShoulder_id)
#	initial_rightArm_pose = skel.get_bone_global_pose(rightArm_id)
#	initial_rightForeArm_pose = skel.get_bone_global_pose(rightForeArm_id)
#	initial_rightHand_pose = skel.get_bone_global_pose(rightHand_id)


	initial_spine_pose = skel.get_bone_rest(spine_id)
	initial_spine1_pose = skel.get_bone_rest(spine1_id)
	initial_spine2_pose = skel.get_bone_rest(spine2_id)
	initial_neck_pose = skel.get_bone_rest(neck_id)
	initial_head_pose = skel.get_bone_rest(head_id)

	initial_leftShoulder_pose = skel.get_bone_rest(leftShoulder_id)
	initial_leftArm_pose = skel.get_bone_rest(leftArm_id)
	initial_leftForeArm_pose = skel.get_bone_rest(leftForeArm_id)
	initial_leftHand_pose = skel.get_bone_rest(leftHand_id)
	initial_rightShoulder_pose = skel.get_bone_rest(rightShoulder_id)
	initial_rightArm_pose = skel.get_bone_rest(rightArm_id)
	initial_rightForeArm_pose = skel.get_bone_rest(rightForeArm_id)
	initial_rightHand_pose = skel.get_bone_rest(rightHand_id)
	
	skel.reset_bone_poses()
	$AnimationTree.set_active(true)
	
	pprint("root motion track: %s"%animation_tree.root_motion_track)
	
func _process(delta: float) -> void:
	gtime += delta

	#################################################
	#   https://godotforums.org/d/32828-global-vs-local-bone-pose-overrides-in-godot-4-rc2
	#   https://stackoverflow.com/questions/68400486/translated-function-not-working-in-godot-best-way-to-change-position-of-bone 
	#   https://ask.godotengine.org/154759/how-to-apply-a-pose-to-a-bone-after-an-animation-in-godot-4
	#################################################

	if true:
		# --
		spine_pose = initial_spine_pose * Transform3D().rotated( Vector3.RIGHT, proc_anim_blend * (sin(gtime * time_scale) * 0.015))#* 0.15))
		#skel.set_bone_custom_pose(spine_id, spine_pose )
#		skel.set_bone_global_pose_override(spine_id, spine_pose, 1.0 )
#		skel.set_bone_global_pose_override(spine_id, spine_pose * skel.get_bone_pose(spine_id), 1.0 )
#		skel.set_bone_global_pose_override(spine_id, spine_pose.affine_inverse() * skel.get_bone_pose(spine_id), 1.0 )
		#skel.set_bone_pose_position( spine_id, spine_pose.origin * skel.get_bone_pose(spine_id).origin )
#		skel.set_bone_pose_rotation( spine_id, spine_pose.basis )
#		skel.set_bone_rest(spine_id, spine_pose )

#		skel.set_bone_global_pose_override(spine_id, spine_pose.affine_inverse() * skel.get_bone_pose(spine_id), 1.0 )
#		skel.set_bone_global_pose_override(spine_id, skel.get_bone_global_pose(spine_id) * ( skel.get_bone_rest(spine_id).affine_inverse() * spine_pose) , 1.0 )
#		skel.set_bone_global_pose_override(spine_id, skel.get_bone_global_pose(spine_id) * ( spine_pose.affine_inverse() * skel.get_bone_rest(spine_id) ) , 1.0 )
		############################################################################################
		var c_spine_pose = skel.get_bone_global_pose_no_override( spine_id )
		c_spine_pose = c_spine_pose.rotated_local( Vector3.FORWARD, proc_anim_blend * (sin(gtime * time_scale) * 0.35) )
		skel.set_bone_global_pose_override( spine_id, c_spine_pose, 1.0, true )
		$axis1.transform = c_spine_pose
		############################################################################################

		spine1_pose = initial_spine1_pose * Transform3D().rotated( Vector3.RIGHT, proc_anim_blend * (sin((gtime-0.4) * time_scale) * 0.25))
#		skel.set_bone_custom_pose(spine1_id, spine1_pose )
#		skel.set_bone_global_pose_override(spine1_id, spine1_pose, 1.0 )
#		skel.set_bone_global_pose_override(spine1_id, spine1_pose * skel.get_bone_pose(spine1_id), 1.0 )
#		skel.set_bone_global_pose_override(spine1_id, spine1_pose, 1.0 )

#		skel.set_bone_pose_rotation( spine1_id, spine1_pose.basis ) 

#		skel.set_bone_rest(spine1_id, spine1_pose )

		spine2_pose = initial_spine2_pose * Transform3D().rotated( Vector3.RIGHT, proc_anim_blend *(sin((gtime-0.8) * time_scale) * 0.65))
#		skel.set_bone_custom_pose(spine2_id, spine2_pose )
#		skel.set_bone_global_pose_override(spine2_id, spine2_pose, 1.0 )
#		skel.set_bone_global_pose_override(spine2_id, spine2_pose * skel.get_bone_pose( spine2_id ), 1.0 )
#		skel.set_bone_global_pose_override(spine2_id, spine2_pose, 1.0 )
#		skel.set_bone_pose_rotation( spine2_id, spine2_pose.basis ) 

#		skel.set_bone_rest(spine2_id, spine2_pose )

		neck_pose = initial_neck_pose * Transform3D().rotated( Vector3.RIGHT, proc_anim_blend *(sin((gtime-1.2) * time_scale) * 0.35))
#		skel.set_bone_custom_pose(neck_id, neck_pose )
#		skel.set_bone_global_pose_override(neck_id, neck_pose, 1.0 )
#		skel.set_bone_global_pose_override(neck_id, neck_pose * skel.get_bone_pose(neck_id), 1.0 )
#		skel.set_bone_global_pose_override(neck_id, neck_pose, 1.0 )
#		skel.set_bone_rest(neck_id, neck_pose )

		head_pose = initial_head_pose * Transform3D().rotated( Vector3.RIGHT, proc_anim_blend *(sin((gtime-1.6) * time_scale) * 0.55))
#		skel.set_bone_custom_pose(head_id, head_pose )
#		skel.set_bone_global_pose_override(head_id, head_pose, 1.0 )
#		skel.set_bone_global_pose_override(head_id, head_pose * skel.get_bone_pose(head_id), 1.0 )
#		skel.set_bone_global_pose_override(head_id, head_pose , 1.0 )
#		skel.set_bone_rest(head_id, head_pose )

		# --
		leftShoulder_pose = initial_leftShoulder_pose * Transform3D().rotated( Vector3.FORWARD, proc_anim_blend *(sin((gtime-2.0) * time_scale) * 0.55))
#		skel.set_bone_custom_pose(leftShoulder_id, leftShoulder_pose )
#		skel.set_bone_global_pose_override(leftShoulder_id, leftShoulder_pose, 1.0 )
#		skel.set_bone_global_pose_override(leftShoulder_id, leftShoulder_pose * skel.get_bone_pose(leftShoulder_id), 1.0 )
#		skel.set_bone_global_pose_override(leftShoulder_id, leftShoulder_pose, 1.0 )
#		skel.set_bone_rest(leftShoulder_id, leftShoulder_pose )

		leftArm_pose = initial_leftArm_pose * Transform3D().rotated( Vector3.FORWARD, proc_anim_blend *(sin((gtime-2.8) * time_scale) * 0.55))
#		skel.set_bone_custom_pose(leftArm_id, leftArm_pose )
#		skel.set_bone_global_pose_override(leftArm_id, leftArm_pose, 1.0 )
#		skel.set_bone_global_pose_override(leftArm_id, leftArm_pose * skel.get_bone_pose(leftArm_id), 1.0 )
#		skel.set_bone_global_pose_override(leftArm_id, leftArm_pose, 1.0 )
#		skel.set_bone_rest(leftArm_id, leftArm_pose )

		leftForeArm_pose = initial_leftForeArm_pose * Transform3D().rotated( Vector3.FORWARD, proc_anim_blend *((sin((gtime-3.2) * time_scale) - 1.0 ) * 0.55))
#		skel.set_bone_custom_pose(leftForeArm_id, leftForeArm_pose )
#		skel.set_bone_global_pose_override(leftForeArm_id, leftForeArm_pose, 1.0 )
#		skel.set_bone_global_pose_override(leftForeArm_id, leftForeArm_pose * skel.get_bone_pose(leftForeArm_id), 1.0 )
#		skel.set_bone_global_pose_override(leftForeArm_id, leftForeArm_pose, 1.0 )
#		skel.set_bone_rest(leftForeArm_id, leftForeArm_pose )

		leftHand_pose = initial_leftHand_pose * Transform3D().rotated( Vector3.FORWARD, proc_anim_blend *((sin((gtime-3.6) * time_scale) - 1.0 ) * 0.35))
#		skel.set_bone_custom_pose(leftHand_id, leftHand_pose )
#		skel.set_bone_global_pose_override(leftHand_id, leftHand_Fppose, 1.0 )
#		skel.set_bone_global_pose_override(leftHand_id, leftHand_pose * skel.get_bone_pose(leftHand_id), 1.0 )
#		skel.set_bone_global_pose_override(leftHand_id, leftHand_pose, 1.0 )
#		skel.set_bone_rest(leftHand_id, leftHand_pose )

		# --
		rightShoulder_pose = initial_rightShoulder_pose * Transform3D().rotated( Vector3.FORWARD, proc_anim_blend *(sin((gtime-2.0) * time_scale) * -0.55))
#		skel.set_bone_custom_pose(rightShoulder_id, rightShoulder_pose )
#		skel.set_bone_global_pose_override(rightShoulder_id, rightShoulder_pose, 1.0 )
#		skel.set_bone_global_pose_override(rightShoulder_id, rightShoulder_pose * skel.get_bone_pose(rightShoulder_id), 1.0 )
#		skel.set_bone_global_pose_override(rightShoulder_id, rightShoulder_pose, 1.0 )
#		skel.set_bone_rest(rightShoulder_id, rightShoulder_pose )

		rightArm_pose = initial_rightArm_pose * Transform3D().rotated( Vector3.FORWARD, proc_anim_blend *(sin((gtime-2.8) * time_scale) * -0.55))
#		skel.set_bone_custom_pose(rightArm_id, rightArm_pose )
#		skel.set_bone_global_pose_override(rightArm_id, rightArm_pose, 1.0 )
#		skel.set_bone_global_pose_override(rightArm_id, rightArm_pose * skel.get_bone_pose(rightArm_id), 1.0 )
#		skel.set_bone_global_pose_override(rightArm_id, rightArm_pose, 1.0 )
#		skel.set_bone_rest(rightArm_id, rightArm_pose )

		rightForeArm_pose = initial_rightForeArm_pose * Transform3D().rotated( Vector3.FORWARD, proc_anim_blend *((sin((gtime-3.2) * time_scale) - 1.0 ) * -0.55))
#		skel.set_bone_custom_pose(rightForeArm_id, rightForeArm_pose )
#		skel.set_bone_global_pose_override(rightForeArm_id, rightForeArm_pose, 1.0 )
#		skel.set_bone_global_pose_override(rightForeArm_id, rightForeArm_pose * skel.get_bone_pose(rightForeArm_id), 1.0 )
#		skel.set_bone_global_pose_override(rightForeArm_id, rightForeArm_pose , 1.0 )
#		skel.set_bone_rest(rightForeArm_id, rightForeArm_pose )

		rightHand_pose = initial_rightHand_pose * Transform3D().rotated( Vector3.FORWARD, proc_anim_blend *((sin((gtime-3.6) * time_scale) - 1.0 ) * -0.35))
#		skel.set_bone_custom_pose(rightHand_id, rightHand_pose )
#		skel.set_bone_global_pose_override(rightHand_id, rightHand_pose, 1.0 )
#		skel.set_bone_global_pose_override(rightHand_id, rightHand_pose * skel.get_bone_pose(rightHand_id), 1.0 )
#		skel.set_bone_global_pose_override(rightHand_id, rightHand_pose , 1.0 )
#		skel.set_bone_rest(rightHand_id, rightHand_pose )
		
		#print(rightHand_pose.basis.get_rotation_quaternion())
	
	# --
	$AnimationTree.set("parameters/BlendSpace2D/blend_position", mouse_pos_blend )
	#pprint($AnimationTree.get("parameters/BlendSpace2D/blend_position"))
	
	self.global_position.y = $AnimationTree.get_root_motion_position().y


func _input(event: InputEvent) -> void:
	if Input.is_action_pressed("ui_cancel"):
		get_tree().quit()

	if event is InputEventMouseMotion:
		mouse_pos_blend.x = event.position.x/window_res.x *2 -1
		mouse_pos_blend.y = event.position.y/window_res.y *2 -1
		#pprint("mouse_pos_blend (%0.2f, %0.2f)"%[mouse_pos_blend.x, mouse_pos_blend.y])

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			proc_anim_blend -= proc_anim_blend_rate
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			proc_anim_blend += proc_anim_blend_rate

		proc_anim_blend = clamp(proc_anim_blend, 0.0, 1.0)
		pprint("proc anim blend %0.2f"%proc_anim_blend)

func pprint(msg) -> void:
	print("[skeleton_code] %s"%str(msg))
	
