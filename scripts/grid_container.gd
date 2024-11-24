extends GridContainer

@export var item_scene: Array[PackedScene]
@export var tileBG: PackedScene
@export var height: int = 9
@export var patterns: Array[PackedVector2Array]

var board = [] # 2D array for items

var last_tile = null


# Called when the node enters the scene tree for the first time.
func _ready():
	assert(patterns.size() > 0, "patterns should be properly filled")
	start()


# Start
func start():
	initialize_items_array()
	show()


# Initialize the board 2D array
func initialize_items_array():
	for x in range(self.columns):
		board.append([])
		for y in range(height):
			board[x].append(null)
			var temp_item = tileBG.instantiate()
			add_child(temp_item)
			# todo connect touch_process to temp_item.on_touch
			temp_item.connect("on_touch", touch_process)
			board[x][y] = temp_item
			temp_item.name = "x{0}_y{1}".format([x, y])
			var m3item = item_scene.pick_random()
			temp_item.create_item(m3item, x, y, true)
			var loops = 0
			# Avoid matching items
			while match_at(x, y, temp_item.get_color()) and loops < 100:
				m3item = item_scene.pick_random()
				temp_item.create_item(m3item, x, y, true)
				loops += 1
			#print(loops)	# DEBUG


# todo func swap
func swap(a, b, skip_update: bool=false):
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
	print("x: ", tile.x_pos, " y: ", tile.y_pos)    # DEBUG
	if last_tile:
		last_tile.set_select(false)
	
	if last_tile and last_tile != tile:
		if (last_tile.x_pos + 1 == tile.x_pos && last_tile.y_pos == tile.y_pos) || (last_tile.x_pos - 1 == tile.x_pos && last_tile.y_pos == tile.y_pos) || (last_tile.y_pos + 1 == tile.y_pos && last_tile.x_pos == tile.x_pos) || (last_tile.y_pos - 1 == tile.y_pos && last_tile.x_pos == tile.x_pos):
			swap(last_tile, tile)
			last_tile = null
			return
	tile.set_select(true)
	last_tile = tile


# Check for matches in rows and columns
func match_at(x, y, color):
	for pattern in patterns:
		assert(pattern.size() > 0, "No patterns")
		var size = pattern.size()
		for search in pattern:
			if x + search.x >= 0 && y + search.y >= 0 && board.size() > x + search.x && board[x + search.x].size() > y + search.y && board[x + search.x][y + search.y] != null && board[x + search.x][y + search.y].get_color() == color:
				size -= 1
		if size == 0:
			return true
	return false


func update_matches():
#	Free board
	var matched_tiles = []
	for row in board:
		for tile in row:
			if match_at(tile.x_pos, tile.y_pos, tile.get_color()):
				matched_tiles.append(tile)
	print(matched_tiles)
	for tile in matched_tiles:
		# TODO: add score
		tile.get_item().free()
		tile.set_item(null)
	
#	Check board from bottom to top
	var updated:bool=false
	for i in range(board.size()-1, -1, -1):
		var row = board[i]
		print("row: ", row)
		for tile in row:
			if tile.get_item() == null:
				print("NULL: ", tile.name, " position: ", tile.x_pos, tile.y_pos)
				check_top_tiles(tile)
				#if check_top_tiles(tile) > 0:
					#updated = true
	#if updated:
		#update_matches()

		
func check_top_tiles(tile):
	var count:int = 0
	if tile.get_item() == null:
		for x in range(0, tile.x_pos+1):
			if tile.x_pos - x >= 0:
				swap(tile, board[tile.x_pos - x][tile.y_pos], true)
		for x in range(0, tile.x_pos+1):
			if tile.get_item() == null:
				count += 1
				var m3item = item_scene.pick_random()
				tile.create_item(m3item, tile.x_pos, tile.y_pos, true)
	return count
