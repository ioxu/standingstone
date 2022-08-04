extends Spatial
var gtime = 0.0
var initial_colour : Color


func _ready() -> void:
	$Timer.start()
	initial_colour = $MeshInstance.get_active_material(0).albedo_color


func _process(delta: float) -> void:
	gtime += delta
	var st = Util.remap( gtime, 0.0, 1.0, 0.25, 1.5 )
	$MeshInstance.set_scale(Vector3(st, st, st))
	$MeshInstance.get_active_material(0).albedo_color = initial_colour * Color(1.0, 1.0, 1.0, Util.remap( gtime, 0.0, 1.0, initial_colour.a, 0.0  ))


func _on_Timer_timeout() -> void:
	self.queue_free()
