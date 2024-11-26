extends Control
#
var moves = 0

func _ready():
	$HUD.start_game.connect(new_game)

#func game_over():
	#$Music.stop()
	
func new_game():
	var level = preload("res://scenes/levels/level_1.tscn")
	
#	Clear level holder
	for node in $level_holder.get_children():
		$level_holder.remove_child(node)
	
#	Add level to scene
	$level_holder.add_child(level.instantiate())
	
#	Miscellaneous
	$HUD.hide()
	$Music.play()
