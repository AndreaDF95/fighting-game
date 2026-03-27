extends CharacterBody2D

# -------------------------
# MOVIMENTO
# -------------------------
@export var speed := 200
@export var jump_force := -400
@export var gravity := 900

# -------------------------
# ATTACCO
# -------------------------
@export var attack_duration := 0.2
var is_attacking := false

# -------------------------
# HIT / KNOCKBACK
# -------------------------
var is_hit := false
@export var knockback_force := 300
@export var hit_duration := 0.2

# -------------------------
# PLAYER FLAG
# -------------------------
@export var is_player := true

# -------------------------
# NODI (SAFE)
# -------------------------
@onready var attack_area = get_node_or_null("AttackArea")
@onready var attack_shape = get_node_or_null("AttackArea/CollisionShape2D")
@onready var sprite = $Sprite2D

# -------------------------
# READY
# -------------------------
func _ready():
	if attack_shape:
		attack_shape.disabled = true


# -------------------------
# ATTACCO
# -------------------------
func attack():
	print("ATTACK!")

	is_attacking = true

	if attack_shape:
		attack_shape.disabled = false

	await get_tree().create_timer(attack_duration).timeout

	if attack_shape:
		attack_shape.disabled = true

	is_attacking = false


# -------------------------
# HIT DETECTION
# -------------------------
func _on_attack_area_body_entered(body):
	print("COLLISION WITH:", body.name)

	if body.has_method("take_damage"):
		body.take_damage(global_position)


# -------------------------
# PRENDERE DANNO
# -------------------------
func take_damage(from_position: Vector2):
	is_hit = true

	# knockback
	var direction = sign(global_position.x - from_position.x)
	velocity.x = direction * knockback_force
	velocity.y = -150

	# 💥 FLASH
	sprite.modulate = Color(1, 0.3, 0.3)  # rosso

	await get_tree().create_timer(0.1).timeout

	sprite.modulate = Color(1, 1, 1)  # normale

	await get_tree().create_timer(hit_duration).timeout

	is_hit = false


# -------------------------
# LOOP FISICO
# -------------------------
func _physics_process(delta):

	# gravità
	if not is_on_floor():
		velocity.y += gravity * delta

	# se colpito → blocco input
	if is_hit:
		move_and_slide()
		return

	# PLAYER
	if is_player:

		# movimento
		var direction = Input.get_axis("ui_left", "ui_right")
		velocity.x = direction * speed

		# salto
		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			velocity.y = jump_force

		# attacco
		if Input.is_action_just_pressed("attack") and not is_attacking:
			attack()

	# ENEMY (fermo)
	else:
		velocity.x = 0

	move_and_slide()
