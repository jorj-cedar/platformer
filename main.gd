extends Node2D

@export var pickup_scene : PackedScene
@export var enemy_scene : PackedScene

var total_pickups = 0
@onready var pickup_spawns = []
@onready var enemy_spawns = []

var player_hp = 5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	for p in $Pickups.get_children():
		pickup_spawns.append(Vector2(p.position))
	
	for e in $Enemies.get_children():
		enemy_spawns.append(Vector2(e.position))
	#


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func refresh_items(node: Node2D,spawn_bank,new_scene):
	for k in node.get_children(): #wipe all remaining pickups or enemies
		k.queue_free()
		
	var new_item
	var x = 0
	for p in spawn_bank: #respawn all the pickups and enemies in the starting positions
		new_item = new_scene.instantiate()
		new_item.position = Vector2(spawn_bank[x])
		x += 1
		node.add_child(new_item)

func new_game():
	total_pickups = 0
	$Player.hp = $Player.max_hp
	player_hp = $Player.hp
	$Player.dead = false
	update_hud()
	
	refresh_items($Pickups,pickup_spawns,pickup_scene)
	refresh_items($Enemies,enemy_spawns,enemy_scene)
	
	$HUD/Dead.hide()
	$Player/Camera2D.limit_top = 0
	$Player.position = $SpawnPos.position
	$Player.show()
	


func _on_player_died() -> void:
	#$Dead.position.x = $Player.position.x - 160
	$HUD/Dead.show()
	$RespawnTimer.start()
	$HUD/Health.text = str(0)
	


func _on_respawn_timer_timeout() -> void:
	new_game()

func update_hud():
	$HUD/PickupCounter.text = str(total_pickups)
	$HUD/Health.text = str(player_hp)

func _on_player_got_pickup() -> void:
	total_pickups += 1
	update_hud()


func _on_camera_change_body_entered(body: Node2D) -> void:
	if body == $Player:
		var tween = get_tree().create_tween()
		tween.tween_property($Player/Camera2D, "limit_top",-180,1)
		
		#$Player/Camera2D.limit_top = -360


func _on_camera_change_back_body_entered(body: Node2D) -> void:
	if body == $Player and $Player/Camera2D.limit_top < 0:
		var tween = get_tree().create_tween()
		tween.tween_property($Player/Camera2D, "limit_top",0,1)


func _on_player_hurt(damage) -> void:
	player_hp -= damage
	$HUD/AnimationPlayer.play("flash")
	update_hud() # Replace with function body.
