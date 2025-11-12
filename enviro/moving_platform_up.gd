extends AnimatableBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", Vector2(0, -65), 1.5).as_relative()
	tween.tween_interval(0.5)
	tween.tween_property(self, "position", Vector2(0, 65), 1.5).as_relative()
	tween.tween_interval(0.5)
	tween.set_loops() # Replace with function body.
