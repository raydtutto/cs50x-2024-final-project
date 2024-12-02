extends Control
class_name TileBg

var m3item : Control
@export var m3item_bg : PackedScene

#@onready var m3item_bg = get_node("res://scenes/tiles/tile.tscn")

signal on_touch

var x_pos: int
var y_pos: int

var selected_on: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# ------------------------------------------------------------
# LOGIC: add item to the board
# ------------------------------------------------------------


# Check mouse event
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			on_touch.emit(self)


# Add item to board
func create_item(item: PackedScene, x:int, y:int, instantly: bool=false) -> void:
	m3item = item.instantiate()
	var item_bg = m3item_bg.instantiate() as Control
	m3item.add_child(item_bg)
	item_bg.z_index = -1
	#print("Color: ", m3item.color)
	var holder_children: Array = $holder.get_children()
	for child in holder_children:
		$holder.remove_child(child)
	$holder.add_child(m3item)
	# Add coordinates
	x_pos = x
	y_pos = y
	# DEBUG
	#var text: String = "c: %d, x: %d, y: %d" % [m3item.color, x_pos, y_pos]
	#$Label.set_text(text)
	# TODO: animation
	anim_new_item_appearance()


# Return item
func get_item() -> Control:
	return m3item


func set_item(item: Control) -> void:
	m3item = item


func get_holder() -> Control:
	return $holder


# Set selected status
func set_select(value: bool) -> void:
	if m3item:
		var player: AnimationPlayer = m3item.find_child("anim_player",true,false) as AnimationPlayer
		if not player:
			print("No select animation")
			return
		if value:
			if selected_on:
				print("already selected")
			else:
				selected_on = true
				player.play("selected")
		else:
			selected_on = false
			player.play("RESET")
	else:
		print("No item found")


# Return item's color
func get_color() -> ItemProp.ItemTypes:
	if m3item:
		return m3item.color
	print("Color is unknown")
	return ItemProp.ItemTypes.UNKNOWN


# ------------------------------------------------------------
# ANIMATION
# ------------------------------------------------------------


func anim_start_move(prev_pos:Vector2, next_pos:Vector2) -> void:
	if not m3item:
		return
	m3item.position = prev_pos
	var tween: Tween = get_tree().create_tween()
	
	# Animation for multiple rows
	var threshold: int = prev_pos.y - next_pos.y
	var height: int = 120
	var rows = threshold / height
	if rows > 1 or rows < -1:
		if rows < -1:
			rows *= -1
		rows /= 2.5
		tween.tween_property(m3item, "position", next_pos, .5 * rows).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BACK)
		tween.play()
		return
	
	# Animation for one row
	tween.tween_property(m3item, "position", next_pos, .5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BACK)
	tween.play()


func anim_new_item_appearance() -> void:
	
	# Set scale with bounce
	var tween: Tween = get_tree().create_tween()
	m3item.scale = Vector2(.7, .7)
	tween.tween_property(m3item, "scale", Vector2(1,1), .5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BACK)
	tween.play()

	# Set opacity
	var fade_out: Tween = get_tree().create_tween()
	m3item.modulate = Color(1, 1, 1, 0)
	fade_out.tween_property(m3item, "modulate", Color(1,1,1,1), .3).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	fade_out.play()


# Set selected status
func anim_item_matched() -> void:
	if m3item:
		# Set opacity
		await get_tree().create_timer(.20).timeout
		var fade_out: Tween = get_tree().create_tween()
		m3item.modulate = Color(1, 1, 1, 1)
		fade_out.tween_property(m3item, "modulate", Color(1,1,1,0), .10).set_ease(Tween.EASE_OUT)
		fade_out.play()


# Set selected status
func anim_item_bg_matched() -> void:
	if m3item:
		var player: AnimationPlayer = m3item.find_child("anim_player",true,false) as AnimationPlayer
		if not player:
			print("No matched animation")
			return
		player.play("matched")
	else:
		print("No item found")
