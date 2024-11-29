extends Control
class_name TileBg

@export var m3item : Control

signal on_touch

var x_pos
var y_pos


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# ------------------------------------------------------------
# LOGIC: add item to the board
# ------------------------------------------------------------


# Check mouse event
func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			on_touch.emit(self)


# Add item to board
func create_item(item: PackedScene, x:int, y:int, instantly: bool=false):
	m3item = item.instantiate()
	print("Color: ", m3item.color)
	var holder_children = $holder.get_children()
	for child in holder_children:
		$holder.remove_child(child)
	$holder.add_child(m3item)
	# Add coordinates
	x_pos = x
	y_pos = y
	var text = "c: %d, x: %d, y: %d" % [m3item.color, x_pos, y_pos]
	$Label.set_text(text)
	# TODO: animation


# Return item
func get_item() -> Control:
	return m3item


func set_item(item: Control):
	m3item = item


func get_holder() -> Control:
	return $holder


# Set selected status
func set_select(value: bool):
	if value:
		$select.show()
	else:
		$select.hide()


# Return item's color
func get_color() -> ItemProp.ItemTypes:
	if m3item:
		return m3item.color
	print("Color is unknown")
	return ItemProp.ItemTypes.UNKNOWN


# ------------------------------------------------------------
# ANIMATION
# ------------------------------------------------------------


func start_move_animation(prev_pos:Vector2, next_pos:Vector2):
	if not m3item:
		return
	m3item.position = prev_pos
	var tween = get_tree().create_tween()
	tween.tween_property(m3item, "position", next_pos, .5).set_ease(Tween.EASE_IN_OUT)
	tween.play()


#func 
