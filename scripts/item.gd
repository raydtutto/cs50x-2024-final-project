extends Control

# Init color types
enum ItemTypes { BLUE, GREEN, RED, VIOLET, YELLOW };
@export var color: ItemTypes;

# Click detector
var clicked : bool = false;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func _on_button_pressed() -> void:
	set_process(not is_processing());
	print("Touched node: ", self.name, " ", "Position: ", global_position);
