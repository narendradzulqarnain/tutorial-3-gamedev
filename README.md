# Tutorial 3 (Implementasi Fitur)

## **Double Jump**
Fitur *double jump* dapat dibuat dengan menambahkan pendengar jika ada input `"ui_up"` saat sedang berada di udara. Untuk memastikan hanya dapat melakukan *jump* dua kali, pada *if condition*, tambahkan variabel *state* `is_jumping` yang akan bernilai `true` saat pertama kali melompat dan bernilai `false` sesudah melompat kedua kalinya.

## **Dash**
Fitur ini cukup *complicated* untuk diimplementasi karena perlu mendeteksi input *double press*. Pertama, untuk mendeteksi *double press* kita dapat mendefinisikan jeda waktu antar input agar terhitung sebagai *double press*.

```gdscript
var MAX_DOUBLE_TAP_TIME = 0.2
```

Saat ada input, rekam waktu tekan tersebut dan hitung perbedaan dengan waktu tekan input sebelumnya. Jika masih dalam rentang *double press*, maka lakukan *dash*.

```gdscript
if Input.is_action_just_pressed("ui_right"):
    var current_time = Time.get_ticks_msec() / 1000.0
    if current_time - last_right_move < MAX_DOUBLE_TAP_TIME:
        dash(1)
    last_right_move = current_time
```

Untuk melakukan *dash*, kita hanya perlu bergerak ke arah yang ditentukan dengan kecepatan yang lebih tinggi.

```gdscript
func dash(direction):
    velocity.x = dash_speed * direction
    dash_direction = direction
    is_dashing = true
```

Agar tidak terinterupsi selama *dash*, buat *state* `is_dashing`, lalu ubah fungsi `_physics_process` agar tidak meng-handle input lain saat melakukan *dash*.

```gdscript
func _physics_process(delta):
    # Gravity
    velocity.y += delta * gravity
    
    # Jump
    if is_on_floor() and Input.is_action_just_pressed("ui_up"):
        sprite.play("jump")
        velocity.y = jump_speed
        is_jumping = true
    
    # Double Jump
    elif is_jumping and Input.is_action_just_pressed("ui_up"):
        velocity.y = jump_speed
        is_jumping = false
    
    # Dash Mechanic
    if is_dashing:
        velocity.x = dash_speed * dash_direction
        dash_timer -= delta
        if dash_timer <= 0:
            is_dashing = false
            dash_timer = 0.1
    else:
        # Jika tidak *dash*
        # ...
```

*Dash* juga perlu diberi *timer*, agar tidak berlangsung selamanya.

## **Crouch**
Implementasi *crouch* cukup sederhana, kita hanya perlu mengubah ukuran dari *collision shape* dan *sprite* saat ada input untuk *crouch*.

```gdscript
func crouch():
    sprite.play("crouch")
    collision_shape.shape.set_size(crouch_collider_size)
    sprite.position = crouch_sprite_position
```

Untuk keluar dari *crouch*:

```gdscript
func exit_crouch():
    sprite.play("idle")
    collision_shape.shape.set_size(default_collider_size)
    sprite.position = default_sprite_position
```

## **Animation Sprite**
Di sini, saya menambahkan animasi untuk *sprite* saat bergerak menggunakan *asset* yang ada. Implementasi yang dilakukan adalah mengganti `Sprite2D` dengan `AnimatedSprite2D`. Lalu, kita dapat menambahkan animasi. Untuk mengaplikasikan animasi, cukup menambahkan kode *play animation* sesuai dengan gerakan yang dilakukan.

```gdscript
if Input.is_action_pressed("ui_left"):
    if not is_on_floor():
        sprite.play("jump")
    elif is_crouching:
        sprite.play("crouch")
    else:
        sprite.play("run")
    velocity.x = -walk_speed
```
# Tutorial 5

Pada tutorial ini, saya menambahkan objek bendera yang dapat di-toggle (on/off) menggunakan `AnimatedSprite2D`. Ketika player berada di dekat bendera dan menekan tombol `E`, bendera akan berubah status, memainkan animasi, efek suara, serta mengganti background music (BGM).

---

## Deteksi Posisi Player

```gdscript
var player_in_range = false  # Menyimpan apakah player sedang berada di dekat bendera

func _on_area_2d_body_entered(body):
	if body.name == "Player":
		player_in_range = true

func _on_area_2d_body_exited(body):
	if body.name == "Player":
		player_in_range = false
```

---

## Deteksi Input Interaksi (E)

```gdscript
var was_pressed = false

func _process(_delta):
	var pressed = Input.is_physical_key_pressed(KEY_E)
	if player_in_range and pressed and !was_pressed:
		was_pressed = true
		toggle_flag()
	elif not pressed:
		was_pressed = false
```

---

## Toggle Bendera, Animasi, dan SFX

```gdscript
func toggle_flag():
	is_on = !is_on
	update_flag()
	sound.play()
	update_bgm()
```

```gdscript
func update_flag():
	if is_on:
		anim_sprite.play("on")
	else:
		anim_sprite.play("off")
```

---

## Ganti Background Music (BGM)

```gdscript
func update_bgm():
	if bgm_player == null:
		return
	bgm_player.stream = bgm_on if is_on else bgm_off
	bgm_player.play()
```

Untuk itu, ditambahkan variabel berikut agar bisa diset langsung dari editor:

```gdscript
@export var bgm_on: AudioStream
@export var bgm_off: AudioStream
```

Untuk mendapatkan akses ke BGM player di scene utama:

```gdscript
@onready var bgm_player = get_node("/root/Main/BGMPlayer")
```

---

## Referensi Asset

- SFX Bendera: [Kenney RPG Audio](https://kenney.nl/assets/rpg-audio)  
- BGM: [YouTube - Genderang UI](https://www.youtube.com/watch?v=2NvinfnNd1c&ab_channel=AnthemEnthusiastsIndonesia)  
- Sprite: [Kenney Platformer Pack (Medieval)](https://kenney.nl/assets/platformer-pack-medieval)

## **Referensi (Tutorial 3)**
- [Godot 2D Sprite Animation](https://docs.godotengine.org/en/stable/tutorials/2d/2d_sprite_animation.html)
- [Forum Godot - Double Click Detection](https://forum.godotengine.org/t/how-to-detect-double-click-in-process/69606)
- Dokumentasi *Godot*

