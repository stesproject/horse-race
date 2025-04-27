extends Control

@onready var rich_text_label: RichTextLabel = $RichTextLabel
@onready var continue_button: Button = $"../ContinueButton"
@onready var controls: Panel = $Controls


func _ready() -> void:
	SignalBus.win_race.connect(show_winner)


func show_winner(winner: Player):
	controls.hide()
	rich_text_label.add_theme_font_size_override("normal_font_size", 96)
	rich_text_label.add_theme_color_override("default_color", Color("#ffd900"))
	rich_text_label.add_theme_color_override("font_outline_color", Color("#94000a"))
	rich_text_label.add_theme_constant_override("outline_size", 18)
	rich_text_label.text = "%s wins!" % winner.name
	show()
	await get_tree().create_timer(3.5).timeout
	continue_button.show()
	continue_button.grab_focus()
