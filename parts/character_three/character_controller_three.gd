extends CharacterBody3D

var global_time := 0.0
var local_gravity := Vector3(0.0, -9.8, 0.0)
var gravity : Vector3 = local_gravity


func _physics_process(delta):
	global_time += delta
	if is_on_floor():
		gravity = Vector3.ZERO
	else:
		gravity += local_gravity * delta
