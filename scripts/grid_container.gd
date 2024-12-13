extends GridContainer

# List of all items
@export var item_scene: Array[PackedScene]
# Item holder
@export var tileBG: PackedScene
# Board rows
@export var height: int = 7

# Patterns for board check: [[(0, -1), (0, -2)], [(-1, 0), (1, 0)], [(0, -1), (0, 1)], [(1, 0), (2, 0)], [(0, 1), (0, 2)], [(-1, 0), (-2, 0)]]
@export var patterns: Array[PackedVector2Array]

# Pattens for possible matches:
	# Horizontal [(0, -1), (-1, -2)], [(0, -1), (1, -2)], [(0, -1), (0, -3)], [(0, 1), (-1, 2)], [(0, 1), (1, 2)], [(0, 1), (0, 3)]
	# Vertical [(-1, 0), (-2, -1)], [(-1, 0), (-2, 1)], [(-1, 0), (-3, 0)], [(1, 0), (2, -1)], [(1, 0), (2, 1)], [(1, 0), (3, 0)]
	# Offset horizontal [(0, -2), (-1, -1)], [(0, -2),(1, -1)], [(0, 2), (-1, 1)], [(0, 2), (1, 1)]
	# Offset vertical [(-2, 0), (-1, -1)], [(-2, 0),(-1, 1)], [(2, 0), (1, -1)], [(2, 0), (1, 1)]
@export var possible_matches_patterns: Array[PackedVector2Array]

# Buttons
#@export var restart_btn: Button
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
var selected: bool = false
var selected_tile: Control = null
var last_tile: Control = null

# DEBUG mode and board
var debug_mode: bool = false
var board_debug: Dictionary = {
	0: {
		0: ItemProp.ItemTypes.BLUE,
		1: ItemProp.ItemTypes.RED,
		2: ItemProp.ItemTypes.GREEN,
		3: ItemProp.ItemTypes.VIOLET,
		4: ItemProp.ItemTypes.GREEN
		},
	1: {
		0: ItemProp.ItemTypes.VIOLET,
		1: ItemProp.ItemTypes.YELLOW,
		2: ItemProp.ItemTypes.YELLOW,
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
		1: ItemProp.ItemTypes.YELLOW,
		2: ItemProp.ItemTypes.GREEN,
		3: ItemProp.ItemTypes.GREEN,
		4: ItemProp.ItemTypes.RED
		},
	4: {
		0: ItemProp.ItemTypes.RED,
		1: ItemProp.ItemTypes.BLUE,
		2: ItemProp.ItemTypes.RED,
		3: ItemProp.ItemTypes.YELLOW,
		4: ItemProp.ItemTypes.BLUE
		}
}


# Called when the node enters the scene tree for the first time
func _ready() -> void:
	# Scene preparation
	assert(patterns.size() > 0, "patterns should be properly filled")
	assert(possible_matches_patterns.size() > 0, "possible matches patterns should be properly filled")
	#assert(restart_btn)
	#restart_btn.pressed.connect(start)
	assert(score_lbl)
	assert(block_lbl)

	# Run the game
	start()

# Start
func start() -> void:
	# Create board
	clear_board()
	create_board()
	populate_tiles_on_board()
	populate_items_on_board()
	$"../../../../Sound_hoot_small".play()
	print("Play hoot small")
	
	board_block = false


# Check block status every frame
func _process(_dt) -> void:
	block_lbl_on(board_block)


# ------------------------------------------------------------
# CREATE BOARD
# ------------------------------------------------------------


# Clear board
func clear_board() -> void:
	if not board.is_empty():
		# Clear board
		for tile in get_children():
			tile.queue_free()
		board.clear()
	reset_score()
	last_tile = null


# Clear items on board
func clear_items_on_board(reset: bool = false) -> void:
	if not board.is_empty():
		for tile in get_children():
			var temp_holder = tile.find_child("holder")
			for child in temp_holder.get_children():
				child.queue_free()
	if reset:
		reset_score()
	last_tile = null


# Initialize the board 2D array
func create_board() -> void:
	clear_items_on_board(true)
	
	# Create board
	for x: int in range(self.columns):
		board[x] = Dictionary()
		for y: int in range(height):
			board[x][y] = null


# Populate board with tiles
func populate_tiles_on_board():
	for x: int in range(self.columns):
		for y: int in range(height):
			var temp_item: Control = tileBG.instantiate()
			add_child(temp_item)

			# Connect touch and swipe to the item
			temp_item.connect("on_touch", touch_process)
			temp_item.connect("on_swipe", swipe_process)

			# Add item
			board[x][y] = temp_item
			temp_item.name = "x{0}_y{1}".format([x, y])


# Populate board with items
func populate_items_on_board():
	for x: int in range(self.columns):
		for y: int in range(height):
			var m3item: PackedScene
			# Get colors from debug board
			if debug_mode:
				var color: int = board_debug[x][y]
				m3item = item_scene[color-1]

			# Pick random item from the list of items
			else:
				m3item = item_scene.pick_random()
			
			# Get tileBG
			var temp_item: Control
			temp_item = board[x][y]
			
			# Create item
			temp_item.create_item(m3item, x, y, true)
			
			# Continue to change item if there is a match
			var loops: int = 0
			while match_at(x, y, temp_item.get_color()) and loops < 100:
				m3item = item_scene.pick_random()
				temp_item.create_item(m3item, x, y, true)
				loops += 1
			
	# Recreate board if no match
	while not search_possible_matches():
		clear_items_on_board(false)
		populate_items_on_board()


# ------------------------------------------------------------
# SWAP ITEMS
# ------------------------------------------------------------


# Check swap before swap()
func swap_check(a: TileBg, b: TileBg) -> void:
	board_block = true
	a.set_select(true)
	b.set_select(true)
	print("a: ", a.x_pos, ", ", a.y_pos)
	print("b: ", b.x_pos, ", ", b.y_pos)

	# Run swap
	await swap(a, b)
	await get_tree().create_timer(.6).timeout

	# Check match
	if not match_at(a.x_pos, a.y_pos, a.get_color()) and not match_at(b.x_pos, b.y_pos, b.get_color()):
		swap(b, a)
		await get_tree().create_timer(.5).timeout
	a.set_select(false)
	b.set_select(false)

	# Check board
	await update_matches()
	
	# Search for possible matches
	while not search_possible_matches():
		# Wait for animations
		await get_tree().create_timer(.5).timeout
				
		# Play error animation
		$"../../../../Sound_shuffle".play()
		for row: int in range(self.columns):
			for column: int in range(height):
				var item = board[row][column]
				item.anim_item_error()
		await get_tree().create_timer(.8).timeout
					
		# Create new board
		clear_items_on_board(false)
		populate_items_on_board()
		$"../../../../Sound_hoot_small".play()
		print("Play hoot small")
	
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
	$"../../../../Sound_hoot".play()
	a.anim_start_move(a_prev_pos, Vector2(-60, -60))
	b.anim_start_move(b_prev_pos, Vector2(-60, -60))


# ------------------------------------------------------------
# TOUCH AND SWIPE
# ------------------------------------------------------------


# Touch_process
func touch_process(tile: TileBg) -> void:
	# Block board when animation is on
	if board_block:
		return

	# Return if last tile already exist and last tile isn't tile
	if (last_tile 
	and last_tile != tile 
	and ((last_tile.x_pos + 1 == tile.x_pos && last_tile.y_pos == tile.y_pos) 
	or (last_tile.x_pos - 1 == tile.x_pos && last_tile.y_pos == tile.y_pos) 
	or (last_tile.y_pos + 1 == tile.y_pos && last_tile.x_pos == tile.x_pos) 
	or (last_tile.y_pos - 1 == tile.y_pos && last_tile.x_pos == tile.x_pos))):
		var item = last_tile
		last_tile = null
		selected = false
		selected_tile = null
		swap_check(item, tile)

	# Unselect if already selected
	else:
		if last_tile:
			last_tile.set_select(false)

		# Select tile
		tile.set_select(true)
		selected = true
		selected_tile = tile
		$"../../../../Sound_hoot_small".play()
		print("Play hoot small")
		last_tile = tile


# Swipe process: 0: TAP, 1: UP, 2: DOWN, 3: LEFT, 4: RIGHT
func swipe_process(tile: TileBg, direction : ItemProp.Touch) -> void:
	# Block board when animation is on
	if board_block:
		return

	# Prevent already selected item
	last_tile = null
	if selected:
		selected_tile.set_select(false)
		pass

	# Swipe movements
	var item = null
	if tile and direction:
		var x: int = tile.x_pos
		var y: int = tile.y_pos

		# Up
		if (x - 1 >= 0 and x - 1 < height and y == tile.y_pos) and direction == 1:
			item = board[tile.x_pos - 1][tile.y_pos]
			swap_check(item, tile)

		# Down
		elif (x + 1 >= 0 and x + 1 < height and y == tile.y_pos) and direction == 2:
			item = board[tile.x_pos + 1][tile.y_pos]
			swap_check(item, tile)

		# Left
		elif (y - 1 >= 0 and y - 1 < height and x == tile.x_pos) and direction == 3:
			item = board[tile.x_pos][tile.y_pos - 1]
			swap_check(item, tile)

		# Right
		elif (y + 1 >= 0 and y + 1 < height and x == tile.x_pos) and direction == 4:
			item = board[tile.x_pos][tile.y_pos + 1]
			swap_check(item, tile)

		# Wrong direction out of board
		else:
			$"../../../../Sound_error".play()
			tile.anim_item_error()


# ------------------------------------------------------------
# MATCHES
# ------------------------------------------------------------


# Check for matches in rows and columns
func match_at(x : int, y : int, color : ItemProp.ItemTypes):
	# Search for match
	for pattern in patterns:
		assert(pattern.size() > 0, "No patterns")
		var size: int = pattern.size()
		for search in pattern:
			var next_x: int = x + search.x
			var next_y: int = y + search.y
			if board.has(next_x):
				if board[next_x].has(next_y):
					if board[next_x][next_y] != null && board[next_x][next_y].get_color() == color:
						size -= 1
		if size == 0:
			return true
	return false


# Update matches
func update_matches() -> bool:
	# Free board
	var matched_tiles: Array = []
	for x: int in range(self.columns):
		for y: int in range(height):
			var tile: TileBg = board[x][y]
			if match_at(tile.x_pos, tile.y_pos, tile.get_color()):
				matched_tiles.append(tile)

	# Play matched sound and animation
	if matched_tiles.size() > 0:
		$"../../../../Sound_trumpet".play()
		for tile in matched_tiles:
			tile.anim_item_matched()
			tile.anim_item_bg_matched()
		await get_tree().create_timer(.3).timeout

	# Free matched items
	var freed: bool = false
	for tile in matched_tiles:
		# Update score
		increase_score()
		if tile.get_item():
			tile.get_item().queue_free()
			freed = true
		tile.set_item(null)
	if freed:
		await get_tree().create_timer(.3).timeout

	# Check board from bottom to top
	for y in board[board.size()-1]:
		var tile: TileBg = board[board.size()-1][y]
		move_top_tiles(tile)

	# Create new items
	if search_null_tiles_column():
		await get_tree().create_timer(.3).timeout
		for y in board[board.size()-1]:
			var tile: TileBg = board[board.size()-1][y]
			create_top_tiles(tile)
		
		$"../../../../Sound_hoot_small".play()
		print("Play hoot small")
		
		await get_tree().create_timer(.3).timeout
		
		
		return await update_matches()
	return true


# Move items from top to bottom
func move_top_tiles(tile:TileBg) -> bool:
	var offset: int = 1
	var updated: bool = false

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
	await get_tree().create_timer(.3).timeout


# Search null tiles in column
func search_null_tiles_column() -> bool:
	for x: int in range(self.columns):
		for y: int in range(height):
			if board[x][y].get_item() == null:
				return true
	return false


# ------------------------------------------------------------
# POSSIBLE MATCHES
# ------------------------------------------------------------

# Search for possible matches
func search_possible_matches() -> bool:
	# Check all tiles within board
	for x: int in range(self.columns):
		for y: int in range(height):
			# Check patterns for current tile
			var color = board[x][y].get_color()
			for pattern in possible_matches_patterns:
				assert(possible_matches_patterns.size() > 0, "No patterns")
				var size: int = pattern.size()
				for search in pattern:
					var next_x: int = x + search.x
					var next_y: int = y + search.y
					if board.has(next_x):
						if board[next_x].has(next_y):
							if board[next_x][next_y] != null && board[next_x][next_y].get_color() == color:
								size -= 1
				if size == 0:
					print("Matches exist at ", x, ", ", y)
					return true

	print("No matches")
	return false


# ------------------------------------------------------------
# SCORE UPDATE
# ------------------------------------------------------------


func increase_score() -> void:
	score += 1
	var text: String = "%d" % score
	score_lbl.set_text(text)


func reset_score() -> void:
	save_best_score()
	score = 0
	var text: String = "%d" % score
	score_lbl.set_text(text)


func save_best_score() -> void:
	var score_config = ConfigFile.new()
	score_config.load("user://scores.cfg")
	var val = score_config.get_value("player","best_score", 0)
	if score > val:
		score_config.set_value("player","best_score", score)
		score_config.save("user://scores.cfg")


func _exit_tree() -> void:
	save_best_score()

# ------------------------------------------------------------
# DEBUG BLOCK
# ------------------------------------------------------------


# DEBUG block on/off
func block_lbl_on(state: bool) -> void:
	if debug_mode:
		block_lbl.show()
		var text: String = "Block: on"
		if not state:
			text = "Block: off"
			block_lbl.set_text(text)
		block_lbl.set_text(text)
