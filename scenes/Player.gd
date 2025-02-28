extends CharacterBody2D

@export var walk_speed = 200
@export var gravity = 500
@export var jump_speed = -300
@export var dash_speed = 1000

var hold_delay = 0.01
var MAX_DOUBLE_TAP_TIME = 0.2
var dash_timer = 0.1
var is_dashing = false
var is_jumping = false
var last_right_move = 0.0
var last_left_move = 0.0
var dash_direction = 1
var default_collider_size
var crouch_collider_size
var default_sprite_position
var crouch_sprite_position
var is_crouching = false
# Called when the node enters the scene tree for the first time.
@onready var collision_shape = $CollisionShape2D
@onready var sprite = $AnimatedSprite2D
func _ready() -> void:
	default_collider_size = collision_shape.shape.get_size()
	crouch_collider_size = Vector2(default_collider_size.x, default_collider_size.y / 2)
	
	default_sprite_position = sprite.position
	crouch_sprite_position = default_sprite_position + Vector2(0, -default_collider_size.y / 4)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _physics_process(delta):
	# gravity
	velocity.y += delta * gravity
	# jump
	if is_on_floor() and Input.is_action_just_pressed('ui_up'):
		sprite.play("jump")
		velocity.y = jump_speed
		is_jumping = true
	# double jump
	elif is_jumping and Input.is_action_just_pressed('ui_up'):
			#sprite.play("jump")
			velocity.y = jump_speed
			is_jumping = false
	# dash mechanic
	if is_dashing:
		velocity.x = dash_speed * dash_direction
		dash_timer -= delta
		
		if dash_timer <= 0:
			is_dashing = false
			dash_timer = 0.1
			#print("not anymore")
	else:
		# dash detection
		if Input.is_action_just_pressed("ui_right"):
			var current_time = Time.get_ticks_msec() / 1000.0
			if current_time - last_right_move < MAX_DOUBLE_TAP_TIME:
				dash(1)
			last_right_move = current_time
		if Input.is_action_just_pressed("ui_left"):
			var current_time = Time.get_ticks_msec() / 1000.0
			if current_time - last_left_move < MAX_DOUBLE_TAP_TIME:
				dash(-1)
			last_left_move = current_time
			# Normal input, tidak dash
		if Input.is_action_pressed("ui_down"):
			crouch()
		if Input.is_action_just_released("ui_down"):
			exit_crouch()
		if Input.is_action_pressed("ui_left"):
			if not is_on_floor():
				sprite.play("jump")
			elif is_crouching:
				sprite.play("crouch")
			else:
				sprite.play("run")
			velocity.x = -walk_speed

		elif Input.is_action_pressed("ui_right"):
			if not is_on_floor():
				sprite.play("jump")
			elif is_crouching:
				sprite.play("crouch")
			else:
				sprite.play("run")
			velocity.x =  walk_speed
		
		else:
			#sprite.play("idle")
			velocity.x = 0
		if Input.is_action_just_released("ui_right") or Input.is_action_just_released("ui_left"):
			sprite.play("idle")
	
	# "move_and_slide" already takes delta time into account.
	move_and_slide()

# activate dash function
func dash(direction):
	velocity.x = dash_speed * direction
	dash_direction = direction
	#print("I'm dashing")
	is_dashing = true
	
func crouch():
	is_crouching = true
	sprite.play("crouch")
	collision_shape.shape.set_size(crouch_collider_size)
	sprite.position = crouch_sprite_position
	#sprite.scale.y = 0.5
func exit_crouch():
	is_crouching = false
	sprite.play("idle")
	collision_shape.shape.set_size(default_collider_size)
	sprite.position = default_sprite_position
	#sprite.scale.y = 1
