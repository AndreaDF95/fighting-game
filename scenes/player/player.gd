extends CharacterBody2D

@export var speed = 200
@export var jump_force = -400
@export var gravity = 900

var is_attacking = false
var attack_duration = 0.2
var health: int = 100

func _physics_process(delta):
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

func _input(event):
	if event.is_action_pressed("attack"):
		print("ATTACCO")

		scale = Vector2(1.2, 0.8)  # effetto punch

		var enemy = get_parent().get_node("Enemy")
		enemy.take_damage(10)

		await get_tree().create_timer(0.1).timeout
		scale = Vector2(1,1)

func start_attack():
	is_attacking = true
	print("ATTACCO PARTITO")
	$AttackArea.monitoring = true
	await get_tree().create_timer(0.2).timeout
	$AttackArea.monitoring = false
	is_attacking = false

# 👉 QUESTO È IL CUORE
func _on_attack_area_body_entered(body):
	print("COLPITO QUALCOSA")
	if body.has_method("take_damage"):
		body.take_damage(10)
