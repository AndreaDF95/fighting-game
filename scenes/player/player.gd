extends CharacterBody2D

@export var speed = 200
@export var jump_force = -400
@export var gravity = 900


var combo_step = 0
var combo_max = 3
var combo_window = 0.4
var combo_timer = 0.0
var combo_queued = false


var is_attacking = false
var attack_duration = 0.2
var health: int = 100
var hit_targets = []
var is_hit = false
var hit_duration = 0.2
var knockback_force = 250

func _physics_process(delta):
	
	if is_hit:
		velocity.y += gravity * delta
		move_and_slide()
		return
	# Gravità
	if not is_on_floor():
		velocity.y += gravity * delta

	# Movimento
	var direction = Input.get_axis("ui_left", "ui_right")
	velocity.x = direction * speed

	# Salto
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_force

	move_and_slide()
	# gestione finestra combo
	if combo_timer > 0:
		combo_timer -= delta
	else:
		combo_step = 0

func _input(event):
	if Input.is_action_just_pressed("attack"):

		if is_attacking:
			combo_queued = true
		else:
			start_attack()


func start_attack():
	is_attacking = true

	# combo
	if combo_timer > 0:
		combo_step += 1
	else:
		combo_step = 1

	if combo_step > combo_max:
		combo_step = 1

	print("COMBO STEP:", combo_step, " DAMAGE:", 10 + (combo_step - 1) * 5)

	combo_timer = combo_window
	hit_targets.clear()

	# attiva hitbox
	$AttackArea/CollisionShape2D.disabled = false

	await get_tree().create_timer(attack_duration).timeout

	# disattiva hitbox
	$AttackArea/CollisionShape2D.disabled = true

	is_attacking = false

	# combo chaining
	if combo_queued:
		combo_queued = false
		start_attack()
	

func take_damage(damage: int, from_position: Vector2):
	if is_hit:
		return

	health -= damage
	print("PLAYER HEALTH:", health)

	is_hit = true

	var dir = sign(global_position.x - from_position.x)

	# knockback
	velocity.x = dir * knockback_force
	velocity.y = -120

	# feedback visivo
	modulate = Color(1, 0.4, 0.4)

	await get_tree().create_timer(hit_duration).timeout

	modulate = Color(1,1,1)
	is_hit = false

func _on_attack_area_body_entered(body):

	var id = body.get_instance_id()

	if id in hit_targets:
		return

	hit_targets.append(id)

	if body.has_method("take_damage"):
		var damage = 10 + (combo_step - 1) * 5
		body.take_damage(damage, global_position)

		print("COLPITO QUALCOSA")
