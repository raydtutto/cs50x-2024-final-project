extends Control

@onready var scene: Control = $title
@onready var labels: Container = $MarginContainer
@onready var HUD: Control = $"."

# Notifies `game` node that the button has been pressed
signal start_game

func _ready() -> void:
	$HomeMusic.play()
	appear_animation()
	$title/StartButton.button_down.connect(_on_StartButton_pressed)
	var player: AnimationPlayer = find_child("AnimationPlayer",true) as AnimationPlayer
	player.play("blink")


func appear_animation() -> void:
	var fade_in: Tween = get_tree().create_tween()
	var scale: Tween = get_tree().create_tween()
	var fade_in_labels: Tween = get_tree().create_tween()
	scene.modulate = Color(1, 1, 1, 0)
	labels.modulate = Color(1, 1, 1, 0)
	scene.set_pivot_offset(scene.size / 2)
	scene.scale = Vector2(.9, .9)
	scale.tween_property(scene, "scale", Vector2(1,1), .5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BACK)
	fade_in.tween_property(scene, "modulate", Color(1,1,1,1), .3).set_ease(Tween.EASE_IN)
	fade_in_labels.tween_property(labels, "modulate", Color(1,1,1,1), .3).set_ease(Tween.EASE_IN)


func _on_StartButton_pressed() -> void:
	$SoundTap.play()
	var player: AnimationPlayer = find_child("AnimationPlayer",true) as AnimationPlayer
	player.play("RESET")
	await get_tree().create_timer(.5).timeout
	start_game.emit()


func _on_button_pressed() -> void:
	var player: AnimationPlayer = find_child("AnimationPlayer",true) as AnimationPlayer
	player.play("RESET")
	await get_tree().create_timer(.5).timeout
	start_game.emit()
