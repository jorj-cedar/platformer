extends RigidBody2D

@export var direction = 1

var separate_amount_x = 5
var separate_amount_y = -3
var start_pos : Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_pos = position
		 # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if position.x - separate_amount_x < start_pos.x:
		position += Vector2(direction * separate_amount_x,separate_amount_y)
		
	if position.x + separate_amount_x > start_pos.x:
		position += Vector2(direction * separate_amount_x,separate_amount_y)


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free() 
