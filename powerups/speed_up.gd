extends PowerUp

@export var speed_increment: float = 2.0


func apply_powerup(player: Player):
	player.increment_speed(speed_increment, duration)
