extends GridContainer

@export var item_scene: Array[PackedScene]
@export var tileBG: PackedScene
@export var height: int = 9
@export var patterns: Array[PackedVector2Array]
@export var restart_btn: Button
@export var score_lbl: Label

#TODO: board_block false, if swipe block true, disable all touch().disa
var board_block: bool = false

var score: int = 0

# TODO: dictionary of items' dictionaries
var board = Dictionary()

var last_tile = null

# 1. Add debug true or false
# 2. var dictionary filled with default
var debug:bool = true
var board_debug = {
	0: {
		0: ItemProp.ItemTypes.BLUE,
		1: ItemProp.ItemTypes.RED,
		2: ItemProp.ItemTypes.GREEN,
		3: ItemProp.ItemTypes.GREEN,
		4: ItemProp.ItemTypes.GREEN
		},
	1: {
		0: ItemProp.ItemTypes.VIOLET,
		1: ItemProp.ItemTypes.GREEN,
		2: ItemProp.ItemTypes.RED,
		3: ItemProp.ItemTypes.BLUE,
		4: ItemProp.ItemTypes.RED
		},
	2: {
		0: ItemProp.ItemTypes.VIOLET,
		1: ItemProp.ItemTypes.RED,
		2: ItemProp.ItemTypes.VIOLET,
		3: ItemProp.ItemTypes.BLUE,
		4: ItemProp.ItemTypes.YELLOW
		},
	3: {
		0: ItemProp.ItemTypes.BLUE,
		1: ItemProp.ItemTypes.VIOLET,
		2: ItemProp.ItemTypes.GREEN,
		3: ItemProp.ItemTypes.GREEN,
		4: ItemProp.ItemTypes.RED
		},
	4: {
		0: ItemProp.ItemTypes.YELLOW,
		1: ItemProp.ItemTypes.BLUE,
		2: ItemProp.ItemTypes.RED,
		3: ItemProp.ItemTypes.YELLOW,
		4: ItemProp.ItemTypes.GREEN
		}
}


# Called when the node enters the scene tree for the first time.
func _ready():
	assert(patterns.size() > 0, "patterns should be properly filled")
	assert(restart_btn)
	restart_btn.pressed.connect(start)
	assert(score_lbl)
	start()

# Start
func start():
	print("before timer")
#	Creating a timer and waiting for timeout signal
	await get_tree().create_timer(1).timeout
	print("AFTER timer")
	
	initialize_items_array()
	#get_node("../../../AnimationTimer").start()
	#show()


# Initialize the board 2D array
func initialize_items_array():
#	DEBUG Clear filled board
	if not board.is_empty():
#		Clear board
		for tile in get_children():
			tile.queue_free()
		board.clear()
	reset_score()
	last_tile = null
	
	for x:int in range(self.columns):
		board[x] = Dictionary()
		for y:int in range(height):
			board[x][y] = null
		
	for x:int in range(self.columns):
		for y:int in range(height):
			var temp_item = tileBG.instantiate()
			add_child(temp_item)
			# todo connect touch_process to temp_item.on_touch
			temp_item.connect("on_touch", touch_process)
			board[x][y] = temp_item
			temp_item.name = "x{0}_y{1}".format([x, y])
			var m3item:PackedScene
#			If debug get board debug color
			if debug:
				var color = board_debug[x][y]
				m3item = item_scene[color-1]
			else:
				m3item = item_scene.pick_random()
			temp_item.create_item(m3item, x, y, true)
			var loops = 0
			# Avoid matching items
			print(board.keys())
			print(board[x].keys())
			while match_at(x, y, temp_item.get_color()) and loops < 100:
				m3item = item_scene.pick_random()
				temp_item.create_item(m3item, x, y, true)
				loops += 1
			print(loops)	# DEBUG


# todo func swap
func swap(a, b, skip_update: bool=false):
#	TODO: if swap && skip_update == false: 1 sec animation, block swap
# 	if no matches swap back
	print("swap a: ", a.x_pos, a.y_pos, " b: ", b.x_pos, b.y_pos)	# DEBUG
	var temp_a = a.get_item()
	var temp_b = b.get_item()
	
	if temp_a != null:
		temp_a.reparent(b.get_holder())
	if temp_b != null:
		temp_b.reparent(a.get_holder())
	a.set_item(temp_b)
	b.set_item(temp_a)
	
	if a.get_item() != null:
		a.get_item().position = Vector2(-60, -60)
	if b.get_item() != null:
		b.get_item().position = Vector2(-60, -60)
		
	if not skip_update:
		update_matches()


# todo func touch_process x y
func touch_process(tile):
	# TODO: if block board true: return
	if board_block:
		return
	print("x: ", tile.x_pos, " y: ", tile.y_pos)    # DEBUG
	if last_tile:
		last_tile.set_select(false)
	
	if last_tile and last_tile != tile:
		if (last_tile.x_pos + 1 == tile.x_pos && last_tile.y_pos == tile.y_pos) || (last_tile.x_pos - 1 == tile.x_pos && last_tile.y_pos == tile.y_pos) || (last_tile.y_pos + 1 == tile.y_pos && last_tile.x_pos == tile.x_pos) || (last_tile.y_pos - 1 == tile.y_pos && last_tile.x_pos == tile.x_pos):
			swap(last_tile, tile)
			board_block = true
			last_tile = null
			return
	tile.set_select(true)
	last_tile = tile


# Check for matches in rows and columns
func match_at(x:int, y:int, color):
	for pattern in patterns:
		assert(pattern.size() > 0, "No patterns")
		var size = pattern.size()
		for search in pattern:
			var next_x:int = x + search.x
			var next_y:int = y + search.y
			if board.has(next_x):
				if board[next_x].has(next_y):
					if board[next_x][next_y] != null && board[next_x][next_y].get_color() == color:
						size -= 1
		print("size is ", size)
		if size == 0:
			return true
	return false


func update_matches():
#	Free board
	await get_tree().create_timer(1).timeout
	var matched_tiles = []
	for x:int in range(self.columns):
		for y:int in range(height):
			var tile = board[x][y]
			if match_at(tile.x_pos, tile.y_pos, tile.get_color()):
				matched_tiles.append(tile)

	print(matched_tiles)
	for tile in matched_tiles:
		# TODO: add score
		increase_score()
		if tile.get_item():
			tile.get_item().queue_free()
		tile.set_item(null)
	if last_tile:
		last_tile.set_select(false)
	last_tile = null
	
#	Check board from bottom to top
	for y in board[board.size()-1]:
		var tile = board[board.size()-1][y]
		check_top_tiles(tile)
		

		
func check_top_tiles(tile:TileBg):
	print("Check top: tile is ", tile)
	var offset: int = 1

	while tile.x_pos - offset >= 0:
		var temp_data = tile.get_item()
		if tile.get_item() != null:
			while tile.get_item() != null and tile.x_pos - 1 >= 0:
				var x: int = tile.x_pos
				tile = board[x - 1][tile.y_pos]
			continue
		var upper = board[tile.x_pos - offset][tile.y_pos]
		if upper.get_item() != null && tile.get_item() == null:
			swap(tile, upper, true)
			var test_tile = tile.get_item()
			var test_upper = upper.get_item()
			var test_x = tile.x_pos
			var test_bool = tile.get_item() != null and tile.x_pos - offset >= 0
			while tile.get_item() != null and tile.x_pos - 1 >= 0:
				tile = board[tile.x_pos - 1][tile.y_pos]
		else:
			offset += 1
# TODO: add await Timer
	await get_tree().create_timer(1).timeout
	print("Generate new tiles")
	var updated:bool = false
	for item in range(height):
		var tile_new = board[item][tile.y_pos]
		if tile_new.get_item() == null:
			var m3item = item_scene.pick_random()
			tile_new.create_item(m3item, item, tile.y_pos, true)
			var c = tile_new.get_item()
			print(c.self_modulate, c.modulate)
			c.set_modulate(Color(1, 0.5, 1, 0.5))
			print(c.self_modulate, c.modulate)
			updated = true
	if updated:
		update_matches()
	#else:
		#board_block = false
#		


func increase_score():
	score += 1
	var text = "Score: %d" % score
	score_lbl.set_text(text)
	
func reset_score():
	score = 0
	var text = "Score: %d" % score
	score_lbl.set_text(text)


#func _on_timer_timeout() -> void:
	#print("Timer has finished")
