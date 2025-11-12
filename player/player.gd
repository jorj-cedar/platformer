extends CharacterBody2D

@export var dash_ghost_scene : PackedScene

const SPEED = 100.0
@export var JUMP_VELOCITY = -400.0

var gravity = 400
var acceleration = 15
var max_speed = 88

var jump_force = 200
var jump_release_force = 10
var ground_friction = 8
var air_friction = 2

var previous_frame_velocity = Vector2.ZERO

var falling = false
var blinking = false
var invincible = false
var move_freeze = false

var got_dash = false

var dashing = false
var available_dashes = 1
var dead
@export var hp = 5
@export var max_hp = 5


var enemy_position: Vector2 

signal died
signal got_pickup
signal hurt
signal health_up
signal max_health_up

func _physics_process(delta: float) -> void:
	var areas = $HurtBox.get_overlapping_areas()
	for area in areas:
		if area.is_in_group("enemies_") and not invincible:
			damage_player(area)
	
	if not dead:
		#if invincible:
			#knockback()
		#else:
		if is_on_floor() and not dashing:
			available_dashes = 1
			
		if not is_on_floor() and not dashing:
			#velocity += get_gravity() * delta
			velocity.y += gravity * delta

		# Handle jump.
		if Input.is_action_just_pressed("jump") and is_on_floor() and not move_freeze:
			jump(jump_force)
		
			#velocity.y = JUMP_VELOCITY
		if Input.is_action_just_released("jump") and velocity.y < -jump_release_force and not move_freeze:
			velocity.y = -jump_release_force
		
		#if Input.is_action_just_pressed("ui_accept") and not is_on_floor():
			##do hover stuff here?
			#pass
		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var direction := Input.get_axis("left", "right")
		
		if not move_freeze:
			if direction:
				velocity.x = direction * SPEED
			else:
				velocity.x = move_toward(velocity.x, 0, 10)
		
		if Input.is_action_just_pressed("dash") and available_dashes > 0 and got_dash and not move_freeze:
			dashing = true
			dash()
			
		
		#if abs(velocity.x) < max_speed:
			#velocity.x += direction  * acceleration
		if velocity.y >= 300:
			velocity.y = 300
		
		if velocity.y <= -200:
			velocity.y = -200
			
		
		move_and_slide()
		update_animations(direction)
		previous_frame_velocity = velocity

func jump(force):
	$AnimationPlayer.play("jump")
	velocity.y = -force

func dash():
	available_dashes -= 1
	move_freeze = true
	if $Sprite2D.flip_h:
		velocity.x = -150
	else:
		velocity.x = 150
	velocity.y = 0
	

func update_animations(direction):
	#var prev_frame_direction
	
	if direction < 0:
		$Sprite2D.flip_h = true
	elif direction > 0:
		$Sprite2D.flip_h = false
	
	if dashing:
		var dash_ghost = dash_ghost_scene.instantiate()
		#dash_ghost.global_position = self.global_position
		dash_ghost.get_node("Sprite2D").flip_h = $Sprite2D.flip_h
		add_child(dash_ghost)
	
	if direction < 0:
		$Sprite2D.flip_h = true
	elif direction > 0:
		$Sprite2D.flip_h = false
	
	if move_freeze and not dashing:
		$AnimationPlayer.play("hurt")
	elif move_freeze and dashing:
		$AnimationPlayer.play("dash")
		await $AnimationPlayer.animation_finished
		move_freeze = false
		dashing = false
	else:
		if is_on_floor():
			falling = false
			if direction == 0:
				if blinking:
					$AnimationPlayer.play("blink")
				else:
					$AnimationPlayer.play("idle")
					
			else:
				$AnimationPlayer.play("run")
				if blinking:
					blinking = false
					$BlinkTimer.start()
					
				#if not $WalkSound.playing and not disabled:
					#$WalkSound.play()
				
				#
		else:
			if velocity.y > 0 and previous_frame_velocity.y <= 0:
				falling = true
				$AnimationPlayer.play("fall")

#func damage_handler():
	#if not invincible:
		#pass

func _on_hurt_box_area_entered(area: Area2D) -> void:
	#check if the body is in a group? deathpits? then do death stuff
	if area.is_in_group("deathpits"):
		reset_movement()
		dead = true
		died.emit()
		hide()
	
	if area.is_in_group("enemies_") and not invincible:
		#hurt the player
		damage_player(area)

func damage_player(area: Area2D):
	hp -= 1
	hurt.emit(1)
	if hp <= 0:
		died.emit()
		dead = true
		$AnimationPlayer.play("hurt")
		reset_movement()
	else:
		enemy_position = area.global_position
		knockback(0.1,300,50)
		dashing = false
		#knockback()
		iframes()

func _on_blink_timer_timeout() -> void:
	blinking = not blinking
	$BlinkTimer.wait_time = randf_range(2,5)
	$BlinkTimer.start()

func reset_movement():
	velocity = Vector2.ZERO

func _on_pickup_box_body_entered(body: Node2D) -> void:
	if body.is_in_group("pickups"): 
		got_pickup.emit()
		body.queue_free()
	
	if body.is_in_group("health_items"):
		if hp < max_hp:
			hp += 1
			health_up.emit(1)
			body.queue_free()
		else:
			body.get_node("AnimationPlayer").play("flicker")
		
	if body.is_in_group("max_health_up"):
		max_hp += 1
		hp = max_hp #full heal
		max_health_up.emit(1)
		body.queue_free()
	
	if body.is_in_group("dash_powerup"):
		got_dash = true
		#add powerup stuff here
		body.queue_free()

func iframes():
	$IFrameAnimationPlayer.play("iframes")
	$IFramesTimer.start()
	$MoveFreezeTimer.start()
	invincible = true
	move_freeze = true



func knockback(force: float, x_pos: float, up_force: float):
	if (global_position.x - enemy_position.x > 0): #enemy is to the left of player
		velocity = Vector2(force * 2 * x_pos, -force * up_force)
		print(velocity)
	else: #enemy is to the right of player
		velocity = Vector2(-force * 2 * x_pos, -force * up_force)
		print(velocity)

	
func _on_i_frames_timer_timeout() -> void:
	$IFrameAnimationPlayer.stop()
	modulate.a = 1
	invincible = false


func _on_move_freeze_timer_timeout() -> void:
	move_freeze = false 
