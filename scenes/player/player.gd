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
@export var attack_range := 120
@export var follow_speed := 100
@export var attack_cooldown := 1.0

var is_attacking := false
var can_attack := true

# -------------------------
# HIT / DAMAGE
# -------------------------
var is_hit := false
@export var knockback_force := 300
@export var hit_duration := 0.2

# -------------------------
# HEALTH
# -------------------------
@export var max_health := 100
var health := 100

# -------------------------
# PLAYER / ENEMY
# -------------------------
@export var is_player := true
var target: Node2D

# -------------------------
# NODI
# -------------------------
@onready var attack_shape = get_node_or_null("AttackArea/CollisionShape2D")
@onready var sprite = $Sprite2D


# -------------------------
# READY
# -------------------------
func _ready():
	health = max_health
	
	if attack_shape:
		attack_shape.disabled = true
	
	if not is_player:
		target = get_parent().get_node("Player")


# -------------------------
# ATTACCO
# -------------------------
func attack():
	is_attacking = true
	
	if attack_shape:
		attack_shape.disabled = false

	await get_tree().create_timer(attack_duration).timeout

	if attack_shape:
		attack_shape.disabled = true

	is_attacking = false


# -------------------------
# HIT (UNA VOLTA SOLA)
# -------------------------
func _on_attack_area_body_entered(body):
	if not is_attacking:
		return
	
	if body.has_method("take_damage"):
		body.take_damage(global_position)
		
		if attack_shape:
			attack_shape.disabled = true

#----------
# MORTE
#----------
func die():
	print(name, "KO")

	velocity = Vector2.ZERO
	set_physics_process(false)

	# 💥 freeze breve
	Engine.time_scale = 0.2
	
	await get_tree().create_timer(0.1).timeout
	
	Engine.time_scale = 1.0

	get_parent().on_character_dead(self)


# -------------------------
# PRENDERE DANNO
# -------------------------
func take_damage(from_position: Vector2):
	if is_hit:
		return
	
	is_hit = true
	health -= 10
	
	# knockback
	var dir = sign(global_position.x - from_position.x)
	velocity.x = dir * knockback_force
	velocity.y = -150

	await get_tree().create_timer(hit_duration).timeout
	
	is_hit = false

	if health <= 0:
		die()


# -------------------------
# COOLDOWN
# -------------------------
func start_cooldown():
	can_attack = false
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true


# -------------------------
# LOOP
# -------------------------
func _physics_process(delta):

	# gravità
	if not is_on_floor():
		velocity.y += gravity * delta

	# se colpito
	if is_hit:
		move_and_slide()
		return

	# -------------------------
	# PLAYER
	# -------------------------
	if is_player:

		var dir = Input.get_axis("ui_left", "ui_right")
		velocity.x = dir * speed

		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			velocity.y = jump_force

		if Input.is_action_just_pressed("attack") and not is_attacking:
			attack()

	# -------------------------
	# ENEMY (STABILE)
	# -------------------------
	else:
		if not is_instance_valid(target):
			move_and_slide()
			return
		
		var dx = target.global_position.x - global_position.x
		var dist = abs(dx)
		var dir = sign(dx)

		# flip semplice (NO jitter)
		if dir > 0:
			sprite.flip_h = false
		elif dir < 0:
			sprite.flip_h = true

		# movimento
		if dist > attack_range:
			velocity.x = dir * follow_speed
		else:
			velocity.x = 0
			
			if can_attack and not is_attacking:
				attack()
				start_cooldown()

	move_and_slide()
