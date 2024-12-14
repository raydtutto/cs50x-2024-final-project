extends Control
#
var moves: int = 0

func _ready() -> void:
	$HUD.start_game.connect(new_game)
	
func new_game() -> void:
	var level: PackedScene = preload("res://scenes/levels/level.tscn")
	
	# Clear level holder
	for node in $level_holder.get_children():
		$level_holder.remove_child(node)
	
	# Add level to scene
	$level_holder.add_child(level.instantiate())
	
	# Miscellaneous
	$HUD.hide()
