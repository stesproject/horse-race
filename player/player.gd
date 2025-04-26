class_name Player
extends CharacterBody2D

@export var speed := 250.0
@export var cooldown := 2.0
@export var recovery_time := 0.75

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var sprite_details: Sprite2D = $Sprite2D/SpriteDetails
@onready var animation_timer: Timer = $AnimationTimer
@onready var cooldown_timer: Timer = $CooldownTimer
@onready var recovery_timer: Timer = $RecoveryTimer
@onready var anim_speed = speed / (speed * 10.0)
@onready var player_name: RichTextLabel = $PlayerName
@onready var hits_label: RichTextLabel = $HitsLabel
@onready var hit_box: Area2D = $HitBox
@onready var audio_stream_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var audio_stream_gallop: AudioStreamPlayer2D = $AudioStreamGallop
@onready var blow_particles: GPUParticles2D = $BlowParticles
@onready var power_sprite: Sprite2D = $PowerSprite

const HORSE_GALLOP = preload("res://player/sounds/horse-gallop.ogg")
const HORSE_JOIN_SE = preload("res://player/sounds/horse-join-se.tres")
const HORSE_HURT_SE = preload("res://player/sounds/horse-hurt-se.tres")
const HORSE_ATTACK_SE = preload("res://player/sounds/horse-attack-se.tres")
const WIN_SE = preload("res://player/win-se.ogg")

var direction: Vector2:
	set(value):
		direction = value
		hit_box.rotation = direction.angle()
var key_input := KEY_0
var hits := 0:
	set(value):
		hits = value
		hits_label.text = str(hits)
var in_hitbox_area: Player
var invincible := false:
	set(value):
		power_sprite.visible = value
var fury_attack := false


func setup(_player_id: int, key, is_joypad := false):
	player_name.text += OS.get_keycode_string(key) if !is_joypad else str(key)
	self.name = player_name.text
	key_input = key
	var color = Color(
		randf_range(0.0, 1.0),
		randf_range(0.0, 1.0),
		randf_range(0.0, 1.0),
	   1.0
	)
	sprite_2d.material.set_shader_parameter("color_1_to_replace", color)
	play_sound(HORSE_JOIN_SE)
	print(player_name.text, " joined the race!")


func _ready() -> void:
	stop()
	set_process_unhandled_input(false)
	animation_timer.wait_time = anim_speed * 2
	cooldown_timer.wait_time = cooldown
	recovery_timer.wait_time = recovery_time
	var unique_material = sprite_2d.material.duplicate() as ShaderMaterial
	sprite_2d.material = unique_material
	await SignalBus.start_race
	set_process_unhandled_input(true)
	SignalBus.win_race.connect(func(_winner): stop())
	SignalBus.slow_down.connect(func(player, duration):
		if player != self:
			increment_speed(0.5, duration))
	start()


func _process(_delta: float) -> void:
	sprite_2d.flip_h = direction.x < 0
	sprite_details.flip_h = sprite_2d.flip_h


func _physics_process(delta: float) -> void:
	var collision = move_and_collide(direction * speed * delta)
	if collision:
		direction = direction.bounce(collision.get_normal())


func _unhandled_input(event: InputEvent) -> void:
	var valid = event is InputEventJoypadButton or event is InputEventKey
	if valid and event.pressed:
		var key = event.button_index if event is InputEventJoypadButton else event.keycode
		if key == key_input and cooldown_timer.time_left == 0:
			if in_hitbox_area:
				attack()


func start():
	direction = _get_random_direction()
	set_physics_process(true)
	audio_stream_gallop.play()
	sprite_2d.rotation_degrees = 0
	animate()


func stop():
	velocity = Vector2.ZERO
	audio_stream_gallop.stop()
	set_physics_process(false)


func attack():
	if !fury_attack:
		flash(Color("#990000"), 0.6, 0.3)
	play_sound(HORSE_ATTACK_SE)
	blow_particles.emitting = true
	cooldown_timer.start()
	in_hitbox_area.hurt()
	in_hitbox_area = null
	if !fury_attack:
		hit_box.monitoring = false
		await cooldown_timer.timeout
		hit_box.monitoring = true


func animate():
	animation_timer.start()
	await animation_timer.timeout
	TweenAnim.warp(sprite_2d, Vector2(1.25, 0.75), anim_speed)
	animate()


func hurt():
	if invincible:
		return
	stop()
	play_sound(HORSE_HURT_SE)
	hits += 1
	TweenAnim.spin(sprite_2d, 2, 0.5)
	recovery_timer.start()
	await recovery_timer.timeout
	start()


func flash(color: Color, intensity: float = 0.5, duration: float = 0.3):
	sprite_2d.material.set_shader_parameter("glow_color", color)
	sprite_2d.material.set_shader_parameter("glow_intensity", intensity)
	await get_tree().create_timer(duration).timeout
	sprite_2d.material.set_shader_parameter("glow_intensity", 0)


func win():
	play_sound(WIN_SE)
	SignalBus.win_race.emit(self)
	stop()


func play_sound(stream: AudioStream):
	audio_stream_player.stop()
	audio_stream_player.stream = stream
	audio_stream_player.play()


func increment_speed(increment: float, duration: float):
	if increment > 1.0:
		flash(Color("#ffee00"), 0.35, duration)
		play_sound(HORSE_JOIN_SE)
	else:
		flash(Color("#007cea"), 0.7, duration)
	speed *= increment
	await get_tree().create_timer(duration).timeout
	speed /= increment
	sprite_2d.material.set_shader_parameter("glow_intensity", 0)


func invincibility(duration: float):
	play_sound(HORSE_JOIN_SE)
	invincible = true
	sprite_2d.modulate = Color(1, 1, 1, 0.5)
	await get_tree().create_timer(duration).timeout
	invincible = false
	sprite_2d.modulate = Color.WHITE


func enable_fury_attack(duration: float):
	flash(Color("#990000"), 0.6, duration)
	play_sound(HORSE_JOIN_SE)
	fury_attack = true
	await get_tree().create_timer(duration).timeout
	fury_attack = false


func _get_random_direction():
	var new_dir = Vector2()
	new_dir.x = [1, -1].pick_random()
	new_dir.y = randf_range(-1, 1)
	return new_dir.normalized()


func _on_hit_box_area_entered(area: Area2D) -> void:
	if area.owner == self:
		return
	in_hitbox_area = area.owner
	if in_hitbox_area and fury_attack:
		attack()


func _on_hit_box_area_exited(area: Area2D) -> void:
	if area.owner == self:
		return
	in_hitbox_area = null
