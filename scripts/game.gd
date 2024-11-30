extends Control
#
var moves: int = 0

func _ready() -> void:
	$HUD.start_game.connect(new_game)
	$HUD.snake_game.connect(snake_new_game)

#func game_over():
	#$Music.stop()
	
func new_game() -> void:
	var level: PackedScene = preload("res://scenes/levels/level_1.tscn")
	
#	Clear level holder
	for node in $level_holder.get_children():
		$level_holder.remove_child(node)
	
#	Add level to scene
	$level_holder.add_child(level.instantiate())
	
#	Miscellaneous
	$HUD.hide()
	$Music.play()
	
func snake_new_game() -> void:
	var snake: PackedScene = preload("res://scenes/snake_game/snake_level_1.tscn")
	
#	Clear level holder
	for node in $level_holder.get_children():
		$level_holder.remove_child(node)
	
#	Add level to scene
	$level_holder.add_child(snake.instantiate())
	
#	Miscellaneous
	$HUD.hide()
	$Music.play()
