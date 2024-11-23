extends Control

@export var m3item : Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			print("Touched node: ", self.name, " ", "Position: ", global_position);


func create_item(item: PackedScene, instantly: bool=false):
	m3item = item.instantiate()
	$holder.add_child(m3item)
	pass


func get_item() -> Node:
	return m3item
	
func get_color() -> Enums.ItemTypes:
	if m3item:
		return m3item.color
	print("Color is unknown")
	return Enums.ItemTypes.UNKNOWN
