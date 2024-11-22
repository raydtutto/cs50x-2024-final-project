extends CanvasLayer

# Notifies `game` node that the button has been pressed
signal start_game


func _ready() -> void:
	$StartButton.button_down.connect(_on_StartButton_pressed)


#func show_message(text):
	#$MessageLabel.text = text
	#$MessageLabel.show()
	#$MessageTimer.start()
#
#
#func show_game_over():
	#show_message("Game Over")
	#await $MessageTimer.timeout
	#$MessageLabel.text = "Dodge the\nCreeps"
	#$MessageLabel.show()
	#await get_tree().create_timer(1).timeout
	#$StartButton.show()


#func update_score(score):
	#$ScoreLabel.text = str(score)


func _on_StartButton_pressed():
	print("Start pressed")
	start_game.emit()


func _on_ExitButton_pressed() -> void:
	print("Exit pressed")
	get_tree().quit()
