extends Control

@onready var cooldown_timer: Timer = $"../CooldownTimer"
@onready var progress_bar: ProgressBar = $ProgressBar


func _ready() -> void:
	# Hide the cooldown bar initially
	hide()
	# Connect the cooldown timer's timeout signal to the hide function
	progress_bar.max_value = cooldown_timer.wait_time


func _process(_delta: float) -> void:
	if cooldown_timer.is_stopped():
		hide()
		return
	var progress = cooldown_timer.time_left / cooldown_timer.wait_time
	progress_bar.value = progress
	show()
