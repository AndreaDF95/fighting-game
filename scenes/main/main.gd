extends Node2D

# -------------------------
# RIFERIMENTI PLAYER / ENEMY
# -------------------------
@onready var player = $Player
@onready var enemy = $Enemy

# -------------------------
# UI BARRE PRINCIPALI
# -------------------------
@onready var player_bar = $UI/HUD/PlayerHealth
@onready var enemy_bar = $UI/HUD/EnemyHealth

# -------------------------
# UI BARRE DANNO (ritardate)
# -------------------------
@onready var player_damage_bar = $UI/HUD/PlayerHealthDamage
@onready var enemy_damage_bar = $UI/HUD/EnemyHealthDamage

# BARRA KO
@onready var ko_label = $UI/HUD/KOLabel


var player_start_pos
var enemy_start_pos

func _ready():
	player_start_pos = player.global_position
	enemy_start_pos = enemy.global_position
	ko_label.visible = false


# -------------------------
# LOOP
# -------------------------
func _process(delta):

	# PLAYER
	if is_instance_valid(player):
		player_bar.value = player.health
		update_bar_color(player_bar)

		# barra danno smooth
		player_damage_bar.value = lerp(
			player_damage_bar.value,
			float(player.health),
			0.1
		)
	else:
		player_bar.value = 0
		player_damage_bar.value = 0

	# ENEMY
	if is_instance_valid(enemy):
		enemy_bar.value = enemy.health
		update_bar_color(enemy_bar)

		enemy_damage_bar.value = lerp(
			enemy_damage_bar.value,
			float(enemy.health),
			0.1
		)
	else:
		enemy_bar.value = 0
		enemy_damage_bar.value = 0


# -------------------------
# COLORE DINAMICO
# -------------------------
func update_bar_color(bar):
	var ratio = bar.value / bar.max_value

	# verde → giallo → rosso
	var color = Color(1 - ratio, ratio, 0)

	bar.modulate = color
	
func on_character_dead(dead_char):
	print("ROUND OVER")
	
	Engine.time_scale = 0.2
	await get_tree().create_timer(0.1).timeout
	Engine.time_scale = 1.0
	
	await shake_camera()

	# mostra KO
	ko_label.visible = true

	await get_tree().create_timer(1.5).timeout
	
	ko_label.visible = false
	
	

	reset_round()
	
	
func shake_camera():
	var original_pos = position
	
	for i in range(5):
		position.x += randf_range(-5, 5)
		await get_tree().create_timer(0.02).timeout
	
	position = original_pos
	
func reset_round():
	print("RESET ROUND")
	
	# reset player
	if is_instance_valid(player):
		player.global_position = player_start_pos
		player.health = player.max_health
		player.set_physics_process(true)
	
	# reset enemy
	if is_instance_valid(enemy):
		enemy.global_position = enemy_start_pos
		enemy.health = enemy.max_health
		enemy.set_physics_process(true)
