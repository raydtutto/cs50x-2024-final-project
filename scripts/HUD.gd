extends Control

var touch_block: bool = false

@onready var main_scene: Control = $"."
var scene: Control
var labels: Container
var score_txt_lbl: Label
var score_lbl: Label

# Notifies `game` node that the button has been pressed
signal start_game

func _ready() -> void:
	# Scene preparation
	scene = main_scene.find_child("title",true,false) as Control
	labels = main_scene.find_child("MarginContainer",true,false) as Container
	score_txt_lbl = main_scene.find_child("LabelScore",true,false) as Label
	score_lbl = main_scene.find_child("BestScore",true,false) as Label
	$title/StartButton.button_down.connect(_on_StartButton_pressed)
	
	# Show best score or placeholder
	score_lbl.hide()
	var best_score: int = get_score()
	if best_score > 0:
		score_lbl.show()
		var text: String = "Best score: "
		var text_score: String = "%d" % best_score
		score_txt_lbl.set_text(text)
		score_lbl.set_text(text_score)
	
	# Animation on load
	$HomeMusic.play()
	appear_animation()
	var player: AnimationPlayer = find_child("AnimationPlayer",true) as AnimationPlayer
	player.play("blink")
	

func _process(delta: float) -> void:
	if not $HomeMusic.is_playing():
		$HomeMusic.play()


# Load animation
func appear_animation() -> void:
	var fade_in: Tween = get_tree().create_tween()
	var scale_node: Tween = get_tree().create_tween()
	var fade_in_labels: Tween = get_tree().create_tween()
	scene.modulate = Color(1, 1, 1, 0)
	labels.modulate = Color(1, 1, 1, 0)
	scene.set_pivot_offset(scene.size / 2)
	scene.scale = Vector2(.9, .9)
	scale_node.tween_property(scene, "scale", Vector2(1,1), .5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BACK)
	fade_in.tween_property(scene, "modulate", Color(1,1,1,1), .3).set_ease(Tween.EASE_IN)
	fade_in_labels.tween_property(labels, "modulate", Color(1,1,1,1), .3).set_ease(Tween.EASE_IN)
	
	scale_node.play()
	fade_in.play()
	fade_in_labels.play()


func _on_StartButton_pressed() -> void:
	# Prevent multiple clicks
	if touch_block:
		return
	touch_block = true

	$SoundTap.play()
	var player: AnimationPlayer = find_child("AnimationPlayer",true) as AnimationPlayer
	player.play("RESET")
	await get_tree().create_timer(.5).timeout
	start_game.emit()
	touch_block = false


func _on_button_pressed() -> void:
	# Prevent multiple clicks
	if touch_block:
		return
	touch_block = true

	var player: AnimationPlayer = find_child("AnimationPlayer",true) as AnimationPlayer
	player.play("RESET")
	await get_tree().create_timer(.5).timeout
	start_game.emit()


# Best score
func get_score() -> int:
	var score_config = ConfigFile.new()
	score_config.load("user://scores.cfg")
	var val = score_config.get_value("player","best_score", 0)
	return val
