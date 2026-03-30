extends Node2D

@onready var player = $Player
@onready var enemy = $Enemy

@onready var player_bar = $UI/HUD/PlayerHealth
@onready var enemy_bar = $UI/HUD/EnemyHealth

@onready var player_damage_bar = $UI/HUD/PlayerHealthDamage
@onready var enemy_damage_bar = $UI/HUD/EnemyHealthDamage

func _process(delta):
	if is_instance_valid(player):
		player_bar.value = player.health
		update_bar_color(player_bar)
		
		# effetto ritardato
		#player_damage_bar.value = lerp(player_damage_bar.value, player.health, 0.1)
		player_damage_bar.value = lerp(player_damage_bar.value, float(player.health), 0.1)

	if is_instance_valid(enemy):
		enemy_bar.value = enemy.health
		update_bar_color(enemy_bar)
		
		#enemy_damage_bar.value = lerp(enemy_damage_bar.value, enemy.health, 0.1)
		enemy_damage_bar.value = lerp(enemy_damage_bar.value, float(enemy.health), 0.1)
		
		
func update_bar_color(bar):
	var ratio = bar.value / bar.max_value
	
	# verde → giallo → rosso
	var color = Color(1 - ratio, ratio, 0)
	
	bar.modulate = color
