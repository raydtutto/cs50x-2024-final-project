extends CanvasLayer

# Notifies `game` node that the button has been pressed
signal start_game


func _ready() -> void:
	$StartButton.button_down.connect(_on_StartButton_pressed)


func _on_StartButton_pressed() -> void:
	start_game.emit()


func _on_ExitButton_pressed() -> void:
	get_tree().quit()
