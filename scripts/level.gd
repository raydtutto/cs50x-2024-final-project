extends Control

var screen_block: bool = false

var button_tapped: bool = false

@onready var main_scene: Control = $"."
var board: Control
var score: Container
var sound_tap = AudioStreamPlayer

# Sound button
var SoundButton: Button
@export var icon_sound_on: Texture2D
@export var icon_sound_off: Texture2D
var SoundButton_hovered: bool = false

# Home button
var HomeButton: Button
var HomeButton_hovered: bool = false


func _ready() -> void:
	# Scene preparation
	board = main_scene.find_child("Board",true,false) as Control
	score = main_scene.find_child("ScoreContainer",true,false) as Container
	SoundButton = main_scene.find_child("SoundButton",true,false) as Button
	HomeButton = main_scene.find_child("HomeButton",true,false) as Button
	sound_tap = main_scene.find_child("Sound_tap",true,false) as AudioStreamPlayer
	
	# Check sound icon
	var master_bus_index = AudioServer.get_bus_index("Master")
	if AudioServer.is_bus_mute(master_bus_index):
		SoundButton.set_button_icon(icon_sound_off)
	else:
		SoundButton.set_button_icon(icon_sound_on)


# ------------------------------------------------------------
# Sound button
# ------------------------------------------------------------


func _on_sound_button_pressed() -> void:
	SoundButton.set_pivot_offset(SoundButton.size / 2)
	SoundButton.scale = Vector2(.95, .95)
	
	# Set sound off/on
	var master_bus_index = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_mute(master_bus_index, !AudioServer.is_bus_mute(master_bus_index))
	
	print("Sound is ", !AudioServer.is_bus_mute(master_bus_index))
	
	# Change button icon
	if AudioServer.is_bus_mute(master_bus_index):
		await get_tree().create_timer(.15).timeout
		SoundButton.set_button_icon(icon_sound_off)
	else:
		await get_tree().create_timer(.15).timeout
		SoundButton.set_button_icon(icon_sound_on)


func _on_sound_button_button_down() -> void:
	SoundButton.set_pivot_offset(SoundButton.size / 2)
	SoundButton.scale = Vector2(.95, .95)
	button_tapped = true
	if button_tapped:
		sound_tap.play()


func _on_sound_button_button_up() -> void:
	SoundButton.set_pivot_offset(SoundButton.size / 2)
	SoundButton.scale = Vector2(1, 1)
	button_tapped = false


# ------------------------------------------------------------
# Home button
# ------------------------------------------------------------


func _on_home_button_pressed() -> void:
	# Prevent multiple clicks
	print(screen_block)
	if screen_block:
		return
	screen_block = true

	
	HomeButton.set_pivot_offset(HomeButton.size / 2)
	HomeButton.scale = Vector2(.95, .95)
	
	print("Home button pressed")
	
	# Scale animation
	var tween: Tween = get_tree().create_tween()
	board.scale = Vector2(1, 1)
	tween.tween_property(board, "scale", Vector2(.7,.7), .5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BACK)
	
	# Fade out animation
	var fade_out: Tween = get_tree().create_tween()
	var fade_out_homebtn: Tween = get_tree().create_tween()
	var fade_out_soundbtn: Tween = get_tree().create_tween()
	var fade_out_score: Tween = get_tree().create_tween()
	fade_out.tween_property(board, "modulate", Color(1,1,1,0), .3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	fade_out_homebtn.tween_property(SoundButton, "modulate", Color(1,1,1,0), .3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	fade_out_soundbtn.tween_property(HomeButton, "modulate", Color(1,1,1,0), .3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	fade_out_score.tween_property(score, "modulate", Color(1,1,1,0), .3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	
	# Play animations
	fade_out_homebtn.play()
	fade_out_soundbtn.play()
	fade_out_score.play()
	tween.play()
	fade_out.play()
	await get_tree().create_timer(.3).timeout
	
	# Change scene
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_home_button_button_down() -> void:
	# Prevent multiple clicks
	print(screen_block)
	if screen_block:
		return
	
	HomeButton.set_pivot_offset(HomeButton.size / 2)
	HomeButton.scale = Vector2(.95, .95)
	button_tapped = true
	if button_tapped:
		sound_tap.play()


func _on_home_button_button_up() -> void:
	# Prevent multiple clicks
	print(screen_block)
	if screen_block:
		return

	HomeButton.set_pivot_offset(HomeButton.size / 2)
	HomeButton.scale = Vector2(1, 1)
	button_tapped = false
