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

func attack():
	can_attack = false
	print("ENEMY ATTACK")

	if player.has_method("take_damage"):
		player.take_damage(10, global_position)

	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true

func _physics_process(delta):
	#if not is_on_floor():
	#	velocity.y += gravity * delta
	#	velocity.x = lerp(velocity.x, 0.0, 5 * delta)
	var distance = abs(player.global_position.x - global_position.x)
	
	if is_hit:
		velocity.y += gravity * delta
		move_and_slide()
		return

# ATTACCO
	if distance < attack_range and can_attack:
		attack()
		
	velocity.y += gravity * delta
#  ATTRITO ORIZZONTALE
	if is_on_floor():
		velocity.x = move_toward(velocity.x, 0, 500 * delta)
	
	if is_dead:
		# rallenta piano piano lo scivolamento
		velocity.x = move_toward(velocity.x, 0, 500 * delta)

	move_and_slide()

func take_damage(damage: int, from_position: Vector2):
	if is_dead:
		return
	if is_hit:
		return

	health -= damage
	is_hit = true
	print("ENEMY HEALTH:", health)

	var dir = sign(global_position.x - from_position.x)

	# knockback DIREZIONALE
	var kb = knockback_force + damage * 2

	velocity.x = dir * kb
	velocity.y = -80 - damage

	# feedback visivo
	modulate = Color(1, 0.4, 0.4)
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

	get_parent().on_enemy_dead()
