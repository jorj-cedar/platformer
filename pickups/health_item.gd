extends RigidBody2D
var bob_max = 3
var bob_amount = 0.1
var start_pos : Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_pos = position # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.y += bob_amount
	if position.y >= start_pos.y + bob_max:
		bob_amount = -0.1
	elif position.y <= start_pos.y - bob_max:
		bob_amount = 0.1
