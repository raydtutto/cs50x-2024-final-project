extends GridContainer

@export var item_scene: Array[PackedScene]
@export var tileBG: PackedScene

@export var height: int = 9

var board = [] # 2D array for items

func _ready():
	start()
	#hide()
	
func start():
	initialize_items_array()
	#spawn_items()
	show()

# Initialize the all_items 2D array
func initialize_items_array():
	for x in range(self.columns):
		board.append([])
		for y in range(height):
			board[x].append(null)
			var temp_item = tileBG.instantiate()
			add_child(temp_item)
			board[x][y] = temp_item
			temp_item.name = "x{0}_y{1}".format([x, y])
			var m3item = item_scene.pick_random()
			temp_item.create_item(m3item, true)
			var loops = 0
			# Avoid matching items
			while match_at(x, y, temp_item.get_color()) and loops < 100:
				m3item = item_scene.pick_random()
				temp_item.create_item(m3item, true)
				loops += 1
			print(loops)
			
			

## Randomize items and add to the grid
#func spawn_items():
	#for i in range(self.columns):
		#for j in range(height):
			#var item = item_scene.pick_random().instantiate()
			#var loops = 0
			## Avoid matching items
			##while match_at(i, j, item.color) and loops < 100:
				##item = item_scene.pick_random().instantiate()
				##loops += 1
			## Add item to the GridContainer
			#add_child(item)
			##all_items[i][j] = item  # Track the item in the 2D array
	##print(all_items)

# Check for matches in rows or columns
func match_at(i, j, color):
	# Check column matches
	if i > 1 and board[i - 1][j] != null and board[i - 2][j] != null:
		if board[i - 1][j].get_color() == color and board[i - 2][j].get_color() == color:
			return true
			
	# Check row matches
	if j > 1 and board[i][j - 1] != null and board[i][j - 2] != null:
		if board[i][j - 1].get_color() == color and board[i][j - 2].get_color() == color:
			return true
	
	return false
