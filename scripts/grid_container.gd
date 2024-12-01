extends GridContainer

# List of all items
@export var item_scene: Array[PackedScene]
# Item holder
@export var tileBG: PackedScene
# Board rows
@export var height: int = 9
# Patterns for board check: [[(0, -1), (0, -2)], [(-1, 0), (1, 0)], [(0, -1), (0, 1)], [(1, 0), (2, 0)], [(0, 1), (0, 2)], [(-1, 0), (-2, 0)]]
@export var patterns: Array[PackedVector2Array]

# Buttons
@export var restart_btn: Button

# Labels
@export var score_lbl: Label

# Block the board for animation
@export var block_lbl: Label
var board_block: bool = false

# Game score
var score: int = 0

# Dictionary of items' dictionaries
var board = Dictionary()

# For selected tile
var last_tile: Control = null
var touch_count: int = 0

# DEBUG mode and board
var debug_mode:bool = false
var board_debug: Dictionary = {
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


# Called when the node enters the scene tree for the first time
func _ready() -> void:
	# Scene preparation
	assert(patterns.size() > 0, "patterns should be properly filled")
	assert(restart_btn)
	restart_btn.pressed.connect(start)
	assert(score_lbl)
	assert(block_lbl)

	# Run the game
	start()

# Start
func start() -> void:
	# Creating a timer and waiting for timeout signal
	
	# Create board
	initialize_items_array()


func _process(dt):
	block_lbl_on(board_block)


# ------------------------------------------------------------
# MATCH3 LOGIC
# ------------------------------------------------------------


# Initialize the board 2D array
func initialize_items_array() -> void:
	# Clear filled board
	if not board.is_empty():
		# Clear board
		for tile in get_children():
			tile.queue_free()
		board.clear()
	reset_score()
	last_tile = null

	# Create board
	for x:int in range(self.columns):
		board[x] = Dictionary()
		for y:int in range(height):
			board[x][y] = null

	# Populate board
	for x:int in range(self.columns):
		for y:int in range(height):
			var temp_item: Control = tileBG.instantiate()
			add_child(temp_item)

			# Connects touch_process to temp_item.on_touch
			temp_item.connect("on_touch", touch_process)
			# TODO: Unselect already selected item
			if touch_count > 0:
				print("New selected ", touch_count)

			# Add item
			board[x][y] = temp_item
			temp_item.name = "x{0}_y{1}".format([x, y])
			var m3item:PackedScene

			# If "DEBUG MODE" get colors from debug board
			if debug_mode:
				var color: int = board_debug[x][y]
				m3item = item_scene[color-1]

			# Pick random item from the list of items
			else:
				m3item = item_scene.pick_random()
			temp_item.create_item(m3item, x, y, true)

			# Continue to change item if there is a match
			var loops: int = 0
			while match_at(x, y, temp_item.get_color()) and loops < 100:
				m3item = item_scene.pick_random()
				temp_item.create_item(m3item, x, y, true)
				loops += 1


# Check swap before swap()
func swap_check(a: TileBg, b: TileBg) -> void:
	board_block = true
	a.set_select(true)
	b.set_select(true)
	# Run swap
	swap(a, b)
	await get_tree().create_timer(1).timeout

	# Check match
	if not match_at(a.x_pos, a.y_pos, a.get_color()) and not match_at(b.x_pos, b.y_pos, b.get_color()):
		swap(b, a)
		await get_tree().create_timer(1).timeout
	a.set_select(false)
	b.set_select(false)

	# Check board
	await update_matches()

	# Unblock board
	board_block = false


# Swap items
func swap(a: TileBg, b: TileBg) -> void:	
	# Get items
	var temp_a: Control = a.get_item()
	var temp_b: Control = b.get_item()

	# Animation variables
	var a_prev_pos: Vector2 = b.global_position - a.global_position + Vector2(-60, -60)
	var b_prev_pos: Vector2 = a.global_position - b.global_position + Vector2(-60, -60)

	# Change parents
	if temp_a != null:
		temp_a.reparent(b.get_holder())
	if temp_b != null:
		temp_b.reparent(a.get_holder())
	a.set_item(temp_b)
	b.set_item(temp_a)

	# Change position
	if a.get_item() != null:
		a.get_item().position = Vector2(-60, -60)
	if b.get_item() != null:
		b.get_item().position = Vector2(-60, -60)

	# Run animation
	a.anim_start_move(a_prev_pos, Vector2(-60, -60))
	b.anim_start_move(b_prev_pos, Vector2(-60, -60))


# Touch_process
func touch_process(tile: TileBg) -> void:
	# Block board when animation is on
	if board_block:
		return

	# Unselect if already selected
	#if last_tile:
		#last_tile.set_select(false)

	# Return if last tile already exist and last tile isn't tile
	if last_tile and last_tile != tile:
		if (last_tile.x_pos + 1 == tile.x_pos && last_tile.y_pos == tile.y_pos) || (last_tile.x_pos - 1 == tile.x_pos && last_tile.y_pos == tile.y_pos) || (last_tile.y_pos + 1 == tile.y_pos && last_tile.x_pos == tile.x_pos) || (last_tile.y_pos - 1 == tile.y_pos && last_tile.x_pos == tile.x_pos):
			var item = last_tile
			last_tile = null
			swap_check(item, tile)
		
			return
	
	# Select tile
	#tile.set_select(true)
	last_tile = tile
	touch_count += 1
	print("Clicked on", tile.global_position)


# Check for matches in rows and columns
func match_at(x:int, y:int, color: ItemProp.ItemTypes):
	#print("Patterns: ", patterns)
	for pattern in patterns:
		assert(pattern.size() > 0, "No patterns")
		var size: int = pattern.size()
		for search in pattern:
			var next_x: int = x + search.x
			var next_y: int = y + search.y
			if board.has(next_x):
				if board[next_x].has(next_y):
					var test: TileBg = board[next_x][next_y]
					if board[next_x][next_y] != null && board[next_x][next_y].get_color() == color:
						size -= 1
		if size == 0:
			return true
	return false


func update_matches() -> bool:
	# Free board
	await get_tree().create_timer(1).timeout
	var matched_tiles: Array = []
	for x:int in range(self.columns):
		for y:int in range(height):
			var tile: TileBg = board[x][y]
			if match_at(tile.x_pos, tile.y_pos, tile.get_color()):
				matched_tiles.append(tile)
	for tile in matched_tiles:
		# Update score
		increase_score()
		if tile.get_item():
			tile.get_item().queue_free()
		tile.set_item(null)
	
	# Check board from bottom to top
	var is_any_update = false
	for y in board[board.size()-1]:
		var tile: TileBg = board[board.size()-1][y]
		if move_top_tiles(tile):
			is_any_update = true
	
	if search_null_tiles_column():
		await get_tree().create_timer(1).timeout
		for y in board[board.size()-1]:
			var tile: TileBg = board[board.size()-1][y]
			create_top_tiles(tile)
		return await update_matches()
	
	return true

# Move items from top to bottom
func move_top_tiles(tile:TileBg) -> bool:
	#print("Check top: tile is ", tile)
	var offset: int = 1
	var updated:bool = false

	while tile.x_pos - offset >= 0:
		if tile.get_item() != null:
			while tile.get_item() != null and tile.x_pos - 1 >= 0:
				var x: int = tile.x_pos
				tile = board[x - 1][tile.y_pos]
			continue
		var upper: TileBg = board[tile.x_pos - offset][tile.y_pos]
		if upper.get_item() != null && tile.get_item() == null:
			swap(tile, upper)
			updated = true
			while tile.get_item() != null and tile.x_pos - 1 >= 0:
				tile = board[tile.x_pos - 1][tile.y_pos]
		else:
			offset += 1
	return updated


# Generate new tiles on update
func create_top_tiles(tile:TileBg) -> void:
	for item in range(height):
		var tile_new: TileBg = board[item][tile.y_pos]
		if tile_new.get_item() == null:
			var m3item: PackedScene = item_scene.pick_random()
			tile_new.create_item(m3item, item, tile.y_pos, true)
			
			# DEBUG COLOR
			#var c: Control = tile_new.get_item()
			##print(c.self_modulate, c.modulate)
			#c.set_modulate(Color(1, 0.5, 1, 0.5))
			#print(c.self_modulate, c.modulate)


# Search null tiles in column
func search_null_tiles_column() -> bool:
	for x:int in range(self.columns):
		for y:int in range(height):
			if board[x][y].get_item() == null:
				return true
	return false

func increase_score() -> void:
	score += 1
	var text: String = "Score: %d" % score
	score_lbl.set_text(text)


func reset_score() -> void:
	score = 0
	var text: String = "Score: %d" % score
	score_lbl.set_text(text)


# DEBUG block on/off
func block_lbl_on(state: bool) -> void:
	if debug_mode:
		$"../../../BlockLabel".show()
		var text: String = "Block: on"
		if not state:
			text = "Block: off"
			block_lbl.set_text(text)
		block_lbl.set_text(text)
