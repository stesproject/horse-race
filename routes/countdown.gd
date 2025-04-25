extends Control

@onready var rich_text_label: RichTextLabel = $RichTextLabel
@onready var timer: Timer = $Timer
@onready var game_stream_player: AudioStreamPlayer2D = $"../../GameStreamPlayer"

var count := 3

const COUNTDOWN_SE = preload("res://routes/countdown-se.ogg")
const GO_SE = preload("res://routes/go-se.ogg")

func _ready() -> void:
	await SignalBus.start_countdown
	show_count()


func show_count():
	play_sound(COUNTDOWN_SE)
	rich_text_label.text = str(count)
	TweenAnim.punch_in(rich_text_label, 1)
	timer.start()
	await timer.timeout
	count -= 1
	if count > 0:
		show_count()
	else:
		play_sound(GO_SE)
		rich_text_label.text = "GO!"
		TweenAnim.punch_in(rich_text_label, 1)
		SignalBus.start_race.emit()
		timer.start()
		await timer.timeout
		queue_free()


func play_sound(stream: AudioStream):
	game_stream_player.stream = stream
	game_stream_player.play()
