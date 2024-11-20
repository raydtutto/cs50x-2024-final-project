extends Node2D

# Grid variables
@export var width: int;
@export var height: int;
@export var x_start: int;
@export var y_start: int;
@export var offset: int;

var possible_items = [
	preload("res://scenes/items/blue_item.tscn"),
	preload("res://scenes/items/green_item.tscn"),
	preload("res://scenes/items/red_item.tscn"),
	preload("res://scenes/items/violet_item.tscn"),
	preload("res://scenes/items/yellow_item.tscn")
];

var all_items = [];

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize();
	all_items = make_2d_array();
	spawn_items();

func make_2d_array():
	var array = [];
	for i in width:
		array.append([]);
		for j in height:
			array[i].append(null);
	return array;

func spawn_items():
	for i in width:
		for j in height:
#			Get a random number
			var rand = randi_range(0, possible_items.size()-1);
			var item = possible_items[rand].instantiate();
			add_child(item);
			item.set_position(grid_to_pixel(i, j));

func grid_to_pixel(column, row):
	var new_x = x_start + offset * column;
	var new_y = y_start + -offset * row;
	return Vector2(new_x, new_y);

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
