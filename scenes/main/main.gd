extends Node2D

@onready var player = $Player
@onready var enemy = $Enemy

@onready var ko_label = $UI/HUD/KOLabel

# PLAYER UI
@onready var player_bar = $UI/HUD/PlayerHealth
@onready var player_damage_bar = $UI/HUD/PlayerHealthDamage

# ENEMY UI
@onready var enemy_bar = $UI/HUD/EnemyHealth
@onready var enemy_damage_bar = $UI/HUD/EnemyHealthDamage


func _ready():
	ko_label.visible = false


func _process(delta):

	# PLAYER
	player_bar.value = player.health
	player_damage_bar.value = lerp(player_damage_bar.value, float(player.health), 5 * delta)

	# ENEMY
	enemy_bar.value = enemy.health
	enemy_damage_bar.value = lerp(enemy_damage_bar.value, float(enemy.health), 5 * delta)


# 🔥 CHIAMATA QUANDO MUORE L'ENEMY
func on_enemy_dead():
	ko_label.visible = true
	print("ROUND OVER")

	await get_tree().create_timer(2).timeout

	reset_round()


# 🔁 RESET ROUND
func reset_round():
	print("RESET ROUND")

	# reset enemy
	enemy.health = 100
	enemy.is_dead = false
	enemy.global_position = Vector2(600, 300)

	# reset player (se vuoi)
	player.health = 100
	player.global_position = Vector2(300, 300)

	# reset UI
	ko_label.visible = false
