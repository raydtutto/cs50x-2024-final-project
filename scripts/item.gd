extends Node2D

# Init color types
enum ItemTypes { BLUE, GREEN, RED, VIOLET, YELLOW };
@export var color: ItemTypes;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _input_event(viewport, event, shape_idx):
	if event is InputEventScreenTouch and event.pressed:
		print("Touched node: ", self.name);

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
