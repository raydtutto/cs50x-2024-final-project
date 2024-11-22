extends Node2D

# Grid variables
@export var width: int;
@export var height: int;
@export var x_start: int;
@export var y_start: int;
@export var offset: int;

# Items array
var possible_items = [
	preload("res://scenes/items/BlueItem.tscn"),
	preload("res://scenes/items/GreenItem.tscn"),
	preload("res://scenes/items/RedItem.tscn"),
	preload("res://scenes/items/VioletItem.tscn"),
	preload("res://scenes/items/YellowItem.tscn")
];

# Current items on the scene
var all_items = [];

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Starting the game");
	randomize();
	all_items = make_2d_array();
	spawn_items();

# Create board
func make_2d_array():
	var array = [];
	for i in width:
		array.append([]);
		for j in height:
			array[i].append(null);
	return array;

# Randomize items
func spawn_items():
	for i in width:
		for j in height:
#			Get a random number
			#var rand = randi_range(0, possible_items.size()-1);
#			Instance item from an array
			#var item = possible_items[rand].instantiate();
			var item = possible_items.pick_random()
#			Avoid generating matching items
			var loops = 0;
			while(match_at(i, j, item.color) && loops < 100):
				#rand = randi_range(0, possible_items.size()-1);
				item = possible_items.pick_random()
				loops += 1;
				#item = possible_items[rand].instantiate();
			#print("Item at grid position: ", i, j, "Pixel position: ", grid_to_pixel(i, j))	# DEBUG
			
			# Set the grid_node property before adding to the scene
			item.set("grid_node", self);
			
#			Create item if no match around
			add_child(item);
			item.set_position(grid_to_pixel(i, j));
			# Pass a reference to the grid to the item
			item.set("grid_node", self)  # Set the grid_node property dynamically
#			Get coordinates of an item on the grid
			all_items[i][j] = item;

# Find matches around an item
func match_at(i, j, color):
#	Column
	if i > 1:
		if all_items[i - 1][j] != null && all_items[i - 2][j] != null:
			if all_items[i - 1][j].color == color && all_items[i - 2][j].color == color:
				return true;
#	Row
	if j > 1:
		if all_items[i][j - 1] != null && all_items[i][j - 2] != null:
			if all_items[i][j - 1].color == color && all_items[i][j - 2].color == color:
				return true;
	pass;

# Convert coordinates
func grid_to_pixel(column, row):
	var new_x = round(x_start + offset * column);
	var new_y = round(y_start + offset * row);
	return Vector2(new_x, new_y);
	
func pixel_to_grid(pixel_x, pixel_y):
	var new_x = round((pixel_x - x_start) / offset);
	var new_y = round((pixel_y - y_start) / offset);
	return Vector2(new_x, new_y);

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
