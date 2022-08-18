extends SceneTree
# godot --no-window --script in.gd

func _init() -> void:
	print('if "thing" in ["thing", "thang", "thong"]:')
	if "thing" in ["thing", "thang", "thong"]:
		print("true")
	else:
		print("false")

	print('if not "thwang" in ["thing", "thang", "thong"]:')
	if not "thwang" in ["thing", "thang", "thong"]:
		print("true")
	else:
		print("false")
	
	quit()
