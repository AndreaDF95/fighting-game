extends CharacterBody2D

@export var gravity := 900.0
@export var knockback_force := 300.0

var health: int = 100
var is_dead := false

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

	if is_dead:
		# rallenta piano piano lo scivolamento
		velocity.x = move_toward(velocity.x, 0, 500 * delta)

	move_and_slide()

func take_damage(damage: int):
	if is_dead:
		return

	health -= damage
	print("ENEMY HEALTH:", health)

	# 🔥 KNOCKBACK (semplice)
	velocity.x = 200   # spinta laterale
	velocity.y = -150  # piccolo salto

	# 🔴 FEEDBACK VISIVO
	modulate = Color(1, 0.4, 0.4)
	await get_tree().create_timer(0.1).timeout
	modulate = Color(1,1,1)

	if health <= 0:
		die()

func die():
	if is_dead:
		return

	is_dead = true
	print("EnemyKO")

	get_parent().on_enemy_dead()
