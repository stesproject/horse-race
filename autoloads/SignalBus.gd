extends Node

var horses_speed = 0.0

@warning_ignore_start("unused_signal")
signal start_countdown
signal start_race
signal win_race(winner: Player)
signal slow_down(player: Player, duration: float)
@warning_ignore_restore("unused_signal")
