extends Control

@onready var rich_text_label: RichTextLabel = $RichTextLabel


func _ready() -> void:
	SignalBus.win_race.connect(show_winner)


func show_winner(winner: Player):
	rich_text_label.add_theme_font_size_override("normal_font_size", 96)
	rich_text_label.add_theme_color_override("default_color", Color("#ffd900"))
	rich_text_label.add_theme_color_override("font_outline_color", Color("#94000a"))
	rich_text_label.add_theme_constant_override("outline_size", 18)
	rich_text_label.text = "%s WINS!" % winner.name
	show()
