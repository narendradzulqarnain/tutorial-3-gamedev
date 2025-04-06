extends Area2D

@export var is_on: bool = false
@export var bgm_on: AudioStream
@export var bgm_off: AudioStream

@onready var anim_sprite = $AnimatedSprite2D
@onready var sound = $AudioStreamPlayer2D
@onready var bgm_player = get_node("/root/Main/BGMPlayer")

var player_in_range = false
var was_pressed = false

func _ready():
	update_flag()

func _process(_delta):
	var pressed = Input.is_physical_key_pressed(KEY_E)
	if player_in_range and pressed and !was_pressed:
		was_pressed = true
		toggle_flag()
	elif not pressed:
		was_pressed = false

func toggle_flag():
	is_on = !is_on
	update_flag()
	sound.play()
	update_bgm()

func update_flag():
	if is_on:
		anim_sprite.play("on")
	else:
		anim_sprite.play("off")

func update_bgm():
	if bgm_player == null:
		return
	bgm_player.stream = bgm_on if is_on else bgm_off
	bgm_player.play()


func _on_area_2d_body_entered(body):
	if body.name == "Player":
		player_in_range = true

func _on_area_2d_body_exited(body):
	if body.name == "Player":
		player_in_range = false
