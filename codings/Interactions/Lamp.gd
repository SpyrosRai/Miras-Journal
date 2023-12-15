extends PointLight2D
var Light: bool=true


func _on_interactable_action():
	var t = create_tween()
	if Light:
		t.tween_property(self, "energy", 0, 0.1)
		Light = false
	else:
		t.tween_property(self, "energy", 1.5, 0.5)
		Light = true

