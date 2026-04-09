extends CharacterBody2D


@export var gravity := 900.0
@export var knockback_force := 120.0
@onready var player = get_parent().get_node("Player")



var health: int = 100
var is_dead := false
var attack_range = 120
var attack_cooldown = 1.0
var can_attack = true
var is_hit = false
var hit_duration = 0.2
var is_attacking = false
var attack_duration = 0.2

var can_move = true

var follow_speed = 100

func attack():
	if not can_attack or is_attacking:
		return

	is_attacking = true
	can_attack = false
	
	print("OVERLAP COUNT:", $AttackArea.get_overlapping_bodies().size())

	# attiva hitbox
	$AttackArea/CollisionShape2D.disabled = false
	#  FIX: colpisce anche chi è già dentro
	for body in $AttackArea.get_overlapping_bodies():
		if body.has_method("take_damage"):
			body.take_damage(10, global_position)
			

	await get_tree().create_timer(attack_duration).timeout

	# disattiva hitbox
	$AttackArea/CollisionShape2D.disabled = true

	is_attacking = false

	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true
	
func _physics_process(delta):
	
	if not can_move:
		velocity.y += gravity * delta
		move_and_slide()
		return

	if is_dead:
		return

	if is_hit:
		velocity.y += gravity * delta
		move_and_slide()
		return

	# gravità
	if not is_on_floor():
		velocity.y += gravity * delta

	# distanza dal player
	var distance = player.global_position.x - global_position.x

	if not is_hit:
		if abs(distance) > attack_range:
			var dir = sign(distance)
			velocity.x = dir * follow_speed
		else:
			velocity.x = 0
	# 👉 NON toccare velocity.x quando is_hit = true

	# attrito
	if is_on_floor():
		velocity.x = move_toward(velocity.x, 0, 800 * delta)
		
	# ATTACCO
	if abs(distance) <= attack_range and can_attack:
		attack()

	move_and_slide()


func take_damage(damage: int, from_position: Vector2):
	if is_dead:
		return
	if is_hit:
		return

	health -= damage
	
	get_parent().screen_shake()
	# 💥 HIT STOP
	Engine.time_scale = 0.1
	await get_tree().create_timer(0.05).timeout
	Engine.time_scale = 1
	is_hit = true
	print("ENEMY HEALTH:", health)

	var dir = sign(global_position.x - from_position.x)

	# knockback DIREZIONALE
	var kb = knockback_force + damage * 2

	velocity.x = dir * kb
	velocity.y = -80 - damage

	# feedback visivo
	#modulate = Color(1, 0.4, 0.4)
	modulate = Color(2, 0.2, 0.2)
	await get_tree().create_timer(0.1).timeout
	modulate = Color(1,1,1)

	if health <= 0:
		die()
		
	await get_tree().create_timer(hit_duration).timeout
	is_hit = false

func die():
	if is_dead:
		return

	is_dead = true
	print("EnemyKO")
	
	Engine.time_scale = 0.2
	await get_tree().create_timer(0.2).timeout
	
	Engine.time_scale = 1

	get_parent().on_enemy_dead()
		
		
func _on_attack_area_body_entered(body):
	print("ENEMY SIGNAL:", body.name)
	if body.has_method("take_damage"):
		body.take_damage(10, global_position)
		var spark = preload("res://scenes/HitSpark.tscn").instantiate()
		spark.global_position = body.global_position
		get_tree().current_scene.add_child(spark)
