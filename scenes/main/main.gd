extends Node2D


@onready var player_rounds = $UI/HUD/PlayerRounds
@onready var enemy_rounds = $UI/HUD/EnemyRounds
@onready var player = $Player
@onready var enemy = $Enemy

@onready var ko_label = $UI/HUD/KOLabel
@onready var round_label = $UI/HUD/RoundLabel

# PLAYER UI
@onready var player_bar = $UI/HUD/PlayerHealth
@onready var player_damage_bar = $UI/HUD/PlayerHealthDamage

# ENEMY UI
@onready var enemy_bar = $UI/HUD/EnemyHealth
@onready var enemy_damage_bar = $UI/HUD/EnemyHealthDamage

var player_score = 0
var enemy_score = 0

var max_rounds = 2  # best of 3 → chi arriva a 2 vince

func screen_shake():
	var original_pos = position

	for i in range(5):
		position = original_pos + Vector2(
			randf_range(-5, 5),
			randf_range(-5, 5)
		)
		await get_tree().create_timer(0.02).timeout

	position = original_pos

func _ready():
	ko_label.visible = false
	update_round_ui()
	start_round()
	
func update_round_ui():

	# PLAYER
	for i in range(player_rounds.get_child_count()):
		var label = player_rounds.get_child(i)

		if i < player_score:
			label.text = "●"
		else:
			label.text = "○"

	# ENEMY
	for i in range(enemy_rounds.get_child_count()):
		var label = enemy_rounds.get_child(i)

		if i < enemy_score:
			label.text = "●"
		else:
			label.text = "○"


func _process(delta):

	# PLAYER
	player_bar.value = player.health
	player_damage_bar.value = lerp(player_damage_bar.value, float(player.health), 5 * delta)

	# ENEMY
	enemy_bar.value = enemy.health
	enemy_damage_bar.value = lerp(enemy_damage_bar.value, float(enemy.health), 5 * delta)


# 🔥 CHIAMATA QUANDO MUORE L'ENEMY
func on_enemy_dead():
	print("ROUND WIN: PLAYER")
	

	player_score += 1
	update_round_ui()

	check_end_match()
	ko_label.visible = true
	print("ROUND OVER")

	await get_tree().create_timer(2).timeout

func on_player_dead():
	print("ROUND WIN: ENEMY")
	

	enemy_score += 1
	update_round_ui()

	check_end_match()
	ko_label.visible = true
	print("GAME OVER")

	# piccolo delay per vedere KO
	await get_tree().create_timer(1.0).timeout



func start_round():
	
	player.velocity.x = 0
	enemy.velocity.x = 0
	# blocca movimento
	player.can_move = false
	enemy.can_move = false

	# ROUND TEXT
	round_label.text = "ROUND " + str(player_score + enemy_score + 1)
	round_label.visible = true

	await get_tree().create_timer(1.5).timeout

	# FIGHT TEXT
	round_label.text = "FIGHT!"

	await get_tree().create_timer(1.0).timeout

	round_label.visible = false

	# sblocca movimento
	player.can_move = true
	enemy.can_move = true
	
	
#  RESET ROUND
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
	
	player.is_hit = false
	enemy.is_hit = false
	start_round()
	
func check_end_match():

	print("SCORE → Player:", player_score, "Enemy:", enemy_score)

	# qualcuno ha vinto il match?
	if player_score >= max_rounds:
		print("PLAYER WINS THE MATCH")

		await get_tree().create_timer(2.0).timeout

		reset_match()

	elif enemy_score >= max_rounds:
		print("ENEMY WINS THE MATCH")

		await get_tree().create_timer(2.0).timeout

		reset_match()

	else:
		print("NEW ROUND")

		await get_tree().create_timer(1.0).timeout

		reset_round()

func reset_match():

	print("RESET MATCH")
	

	player_score = 0
	enemy_score = 0
	update_round_ui()

	reset_round()
