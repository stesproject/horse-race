extends PowerUp


func apply_powerup(player: Player):
	SignalBus.slow_down.emit(player, duration)
