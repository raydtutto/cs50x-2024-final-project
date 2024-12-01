extends Control
class_name TileBg

var m3item : Control
@export var m3item_bg : PackedScene

#@onready var m3item_bg = get_node("res://scenes/tiles/tile.tscn")

signal on_touch

var x_pos: int
var y_pos: int


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
		var select = m3item.find_child("select",true,false) as Panel
		if not player or not select:
			print("No select animation")
			return
		if value:
			select.show()
			player.play("selected")
		else:
			player.play("RESET")
			select.hide()
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


func anim_selected(anim_on:bool) -> void:
	if m3item:
		var player: AnimationPlayer = m3item.find_child("anim_player",true,false) as AnimationPlayer
		var select: Panel = m3item.find_child("select",true,false) as Panel
		var count: int = 0
		if not player or not select:
			print("No select animation")
			return
		if anim_on:
			if count > 0:
				select.show()
			select.show()
			player.play("selected")
			count += 1
		else:
			player.play("RESET")
			select.hide()
			count -= 1


func anim_start_move(prev_pos:Vector2, next_pos:Vector2) -> void:
	if not m3item:
		return
	m3item.position = prev_pos
	var tween: Tween = get_tree().create_tween()
	#print("Animation position: ", prev_pos, next_pos)
	tween.tween_property(m3item, "position", next_pos, .5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BACK)
	tween.play()


func anim_new_item_appearance(falling:bool = false) -> void:
	# TODO: add falling animation
	if falling == true:
		pass

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
