extends RigidBody2D

var start_pos : Vector2
var walking = false
var walk_range = 50
var walk_distance
var direction = 1
var speed = 30
var bob_max = 3
var bob_amount = 0.1

@export var dead_prop_scene : PackedScene


var dead = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_pos = position
	#walk_distance = randf_range(walk_range/2,walk_range)
	walk_distance = 30


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	
	if not dead:
		position.y += bob_amount
		if position.y >= start_pos.y + bob_max:
			bob_amount = -0.1
		elif position.y <= start_pos.y - bob_max:
			bob_amount = 0.1
			
	
		if walking:
			position.x += direction * speed * delta
			if direction < 0:
				$Sprite2D.flip_h = false
			elif direction > 0:
				$Sprite2D.flip_h = true
			#$AnimationPlayer.play("idle")
			if (position.x >= start_pos.x + walk_distance):
				direction = -1
				walking = false
				#walk_distance = randf_range(walk_range/2,walk_range)
				$MoveTimer.start()
				#$AnimationPlayer.play("idle")
				#play idle animation (or have an update_animations function)

			if (position.x <= start_pos.x - walk_distance):
				direction = 1
				walking = false
				#walk_distance = randf_range(walk_range/2,walk_range)
				$MoveTimer.start()
				#$AnimationPlayer.play("idle")
				
			
		
	
	#if position.x - walk_distance == start_pos:
		#walking = false
		#walk_distance = randf_range(walk_range/2,walk_range)
		#$MoveTimer.start()

func _on_move_timer_timeout() -> void:
	if not dead:
		walking = not walking # Replace with function body.

func spawn_props():
	var dead_prop_front = dead_prop_scene.instantiate()
	dead_prop_front.position = position + Vector2(5,2)
	#dead_prop_front.rotation = 45
	dead_prop_front.direction = 1
	get_parent().add_child(dead_prop_front)
	
	var dead_prop_back = dead_prop_scene.instantiate()
	dead_prop_back.position = position + Vector2(-5,2)
	dead_prop_back.get_node("Sprite2D").frame = 1
	#dead_prop_back.rotation = -45
	dead_prop_back.direction = -1
	get_parent().add_child(dead_prop_back)
		
func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		dead = true
		#process_mode = PROCESS_MODE_DISABLED
		
		
		
		if Input.is_action_pressed("jump"):
			area.get_parent().velocity.y = -250
			area.get_parent().available_dashes = 1
		else:
			area.get_parent().velocity.y = -150
			area.get_parent().available_dashes = 1
			
		$AnimationPlayer.play("death")
		
		if area.get_parent().dashing == true:
			area.get_parent().dashing = false
		
		
		#var tween = get_tree().create_tween()
		#tween.tween_property(self,"position.x",(position.x + 30),1)
		#await tween.finished
		#queue_free()  # Replace with function body.
