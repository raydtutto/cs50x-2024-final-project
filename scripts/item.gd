extends Area2D

# Init color types
enum ItemTypes { BLUE, GREEN, RED, VIOLET, YELLOW };
@export var color: ItemTypes;

# Threshold for detecting significant movement (in pixels)
@export var drag_threshold: float = 8.0;

# Click detector
var clicked : bool = false;

# # Track the initial position of the touch
var init_click_pos = Vector2.ZERO;

# Track item's original position when dragging starts
var start_item_pos = Vector2.ZERO;

# Reference to the grid node
var grid_node: Node = null;

# Maximum allowable positions
var max_x = 0;
var max_y = 0;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Check if the grid_node is set and calculate max values from it
	if grid_node:
		# Access the grid properties dynamically
		var grid_width = grid_node.width;
		var grid_height = grid_node.height;
		var offset = grid_node.offset;
		
		# Calculate max X and Y based on grid dimensions and offset
		max_x = grid_width * offset;
		max_y = grid_height * offset;
		
		print("Grid width: ", grid_width, " ", "Grid height: ", grid_height);
		print("Max X: ", max_x, " ", "Max Y: ", max_y);
	else:
		print("Grid node not set!");
	#pass # Replace with function body.

func _input_event(viewport, event, shape_idx):
#	Init first positions
	if event is InputEventScreenTouch and event.pressed:
		clicked = true;
		init_click_pos = event.position;
		start_item_pos = global_position;
		print("Touched node: ", self.name);
		# Print grid position on click
		if grid_node:
			var grid_pos = grid_node.pixel_to_grid(global_position.x, global_position.y);
			print("Clicked on grid position: ", grid_pos);
		else:
			print("Grid node is not set!");
		
#	Check drag distance
	if clicked and event is InputEventScreenDrag:
		var drag_distance = event.position.distance_to(init_click_pos);
		if drag_distance > drag_threshold:
			var drag_delta = event.position - init_click_pos;
			var new_position = round(start_item_pos + drag_delta);
			
			# Prevent negative movement
			new_position.x = clamp(new_position.x, 0, max_x);
			new_position.y = clamp(new_position.y, 0, max_y);

			global_position = new_position;

			#global_position = new_position;
			print(self.name, " Dragged. Distance: ", drag_distance, " ", "Relative movement:", event.screen_relative);
			
			# Print grid position while dragging
			if grid_node:
				var grid_pos = grid_node.pixel_to_grid(global_position.x, global_position.y);
				var snapped_grid_pos = Vector2(round(grid_pos.x), round(grid_pos.y));
				# Optionally clamp the snapped position within grid bounds
				var grid_width = grid_node.width;
				var grid_height = grid_node.height;
				#snapped_grid_pos.x = clamp(snapped_grid_pos.x, 0, grid_width);
				#snapped_grid_pos.y = clamp(snapped_grid_pos.y, 0, grid_height);
				snapped_grid_pos.x = clamp(snapped_grid_pos.x, 0, grid_width - 1);
				snapped_grid_pos.y = clamp(snapped_grid_pos.y, 0, grid_height - 1);
				print("Dragged to grid position: ", grid_pos);
	
#	Release
	if clicked and event is InputEventScreenTouch and not event.pressed:
		clicked = false;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass;
