extends Node2D

@export var pickup_scene : PackedScene
@export var enemy_scene : PackedScene
@export var f_enemy_scene : PackedScene

var total_pickups = 0
@onready var pickup_spawns = []
@onready var enemy_spawns = []
@onready var f_enemy_spawns = []

var player_hp

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player_hp = $Player.hp
	save_item_locations()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func save_item_locations():
	for p in $Pickups.get_children():
		pickup_spawns.append(Vector2(p.position))
	
	for e in $Enemies.get_children():
		enemy_spawns.append(Vector2(e.position))
	
	for f in $FlyingEnemies.get_children():
		f_enemy_spawns.append(Vector2(f.position))

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
	refresh_items($FlyingEnemies,f_enemy_spawns,f_enemy_scene)
	
	$HUD/Dead.hide()
	$Player/Camera2D.limit_top = 0
	$Player.position = $SpawnPos.position
	$Player.show()
	


func _on_player_died() -> void:
	$HUD/Dead.show()
	$RespawnTimer.start()
	


func _on_respawn_timer_timeout() -> void:
	new_game()

func update_hud():
	$HUD/PickupCounter.text = str(total_pickups)
	
	if player_hp < $Player.max_hp:
		for h in $HUD/HealthBar.get_children():
			if h.get_index() > (player_hp -1):
				h.frame = 1
	elif player_hp == $Player.max_hp:
		for h in $HUD/HealthBar.get_children():
			h.frame = 0

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
	if not $Player.dead:
		$HUD/AnimationPlayer.play("flash") #or call a flash function once hud gets a script
	update_hud() # Replace with function body.
