extends Control

@export var m3item : Node

signal on_touch

var x_pos
var y_pos


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Check mouse event
func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			print("Touched node: ", self.name, " ", "Position: ", x_pos, y_pos);
			on_touch.emit(self)


# Add item to board
func create_item(item: PackedScene, x:int, y:int, instantly: bool=false):
	m3item = item.instantiate()
	$holder.add_child(m3item)
	# Add coordinates
	x_pos = x
	y_pos = y
	pass


# Return item
func get_item() -> Control:
	return m3item
	
func set_item(item: Control):
	m3item = item
	

func get_holder() -> Control:
	return $holder
	

func set_select(value: bool):
	if value:
		$select.show()
	else:
		$select.hide()

# Return item's color
func get_color() -> Enums.ItemTypes:
	if m3item:
		return m3item.color
	print("Color is unknown")
	return Enums.ItemTypes.UNKNOWN
