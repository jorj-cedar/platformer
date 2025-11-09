extends RigidBody2D

var start_pos
var walking = false
var walk_range = 50
var walk_distance
var direction = 1
var speed = 30

var dead = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_pos = position.x
	#walk_distance = randf_range(walk_range/2,walk_range)
	walk_distance = 30


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if direction < 0:
		$Sprite2D.flip_h = false
	elif direction > 0:
		$Sprite2D.flip_h = true
	
	if walking and not dead:
		position.x += direction * speed * delta
		$AnimationPlayer.play("walk")
		if (position.x >= start_pos + walk_distance):
			direction = -1
			walking = false
			#walk_distance = randf_range(walk_range/2,walk_range)
			$MoveTimer.start()
			$AnimationPlayer.play("idle")
			#play idle animation (or have an update_animations function)

		if (position.x <= start_pos - walk_distance):
			direction = 1
			walking = false
			#walk_distance = randf_range(walk_range/2,walk_range)
			$MoveTimer.start()
			$AnimationPlayer.play("idle")
		
	
	#if position.x - walk_distance == start_pos:
		#walking = false
		#walk_distance = randf_range(walk_range/2,walk_range)
		#$MoveTimer.start()

func _on_move_timer_timeout() -> void:
	if not dead:
		walking = not walking # Replace with function body.


#func _on_body_entered(body: Node) -> void:
	#if body == %Player:
		#body.iframes() # Replace with function body.

func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		dead = true
		#process_mode = PROCESS_MODE_DISABLED
		$AnimationPlayer.play("death2")
		
		if Input.is_action_pressed("jump"):
			area.get_parent().velocity.y = -250
		else:
			area.get_parent().velocity.y = -150
		#var tween = get_tree().create_tween()
		#tween.tween_property(self,"position.x",(position.x + 30),1)
		#await tween.finished
		#queue_free()
		
