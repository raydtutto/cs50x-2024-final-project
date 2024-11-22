extends GridContainer

@export var item_scene: Array[PackedScene]

@export var height: int = 9

var all_items = []

func _ready():
	start()
	#hide()
	
func start():
	initialize_items_array()
	spawn_items()
	show()

# Initialize the all_items 2D array
func initialize_items_array():
	all_items.clear()
	for i in range(self.columns):
		all_items.append([])
		for j in range(height):
			all_items[i].append(null)

# Randomize items and add to the grid
func spawn_items():
	for i in range(self.columns):
		for j in range(height):
			var item = item_scene.pick_random().instantiate()
			var loops = 0
			# Avoid matching items
			while match_at(i, j, item.color) and loops < 100:
				item = item_scene.pick_random().instantiate()
				loops += 1
			# Add item to the GridContainer
			add_child(item)
			all_items[i][j] = item  # Track the item in the 2D array
	#print(all_items)

# Check for matches in rows or columns
func match_at(i, j, color):
	# Check column matches
	if i > 1 and all_items[i - 1][j] != null and all_items[i - 2][j] != null:
		if all_items[i - 1][j].color == color and all_items[i - 2][j].color == color:
			return true
			
	# Check row matches
	if j > 1 and all_items[i][j - 1] != null and all_items[i][j - 2] != null:
		if all_items[i][j - 1].color == color and all_items[i][j - 2].color == color:
			return true
	
	return false
