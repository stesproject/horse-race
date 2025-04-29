extends HBoxContainer

@onready var horses_speed_label: RichTextLabel = $HorsesSpeedLabel
@onready var horses_speed_slider: HSlider = $HorsesSpeedSlider


func _ready() -> void:
	_on_horses_speed_slider_value_changed(horses_speed_slider.value)


func _on_horses_speed_slider_value_changed(value: float) -> void:
	horses_speed_label.text = "Horses Speed: 0"
	horses_speed_label.text = horses_speed_label.text.replace("0", str(value))
	Globals.horses_speed = value
