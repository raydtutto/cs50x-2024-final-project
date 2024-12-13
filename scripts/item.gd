extends Control
class_name TileBg

# Item node
var m3item: Control
@export var m3item_bg: PackedScene

signal on_touch
signal on_swipe

# Position
var x_pos: int
var y_pos: int

# Touch process
var selected_on: bool = false
var start_mouse_position: Vector2 = Vector2(0,0)
var end_mouse_position: Vector2 = Vector2(0,0)
var pressed: bool = false


# ------------------------------------------------------------
# LOGIC: add item to the board
# ------------------------------------------------------------


# Check mouse event
func _gui_input(event: InputEvent) -> void:
	# Tap or click
	if event is InputEventMouseButton:
		if event.is_pressed():
			pressed = true
			start_mouse_position = event.position
		else: # release or cancel
			end_mouse_position = event.position
			if pressed:
				on_touch.emit(self)
			pressed = false
			return

	# Swipe
	elif event is InputEventMouseMotion and pressed:
		# Swipe to right
		if event.position.x > start_mouse_position.x + 25:
			pressed = false
			on_swipe.emit(self, ItemProp.Touch.RIGHT)
		# Swipe to left
		elif event.position.x < start_mouse_position.x - 25:
			pressed = false
			on_swipe.emit(self, ItemProp.Touch.LEFT)
		# Swipe to down
		elif event.position.y > start_mouse_position.y + 25:
			pressed = false
			on_swipe.emit(self, ItemProp.Touch.DOWN)
		# Swipe to up
		elif event.position.y < start_mouse_position.y - 25:
			pressed = false
			on_swipe.emit(self, ItemProp.Touch.UP)
		return


# Add item to board
func create_item(item: PackedScene, x:int, y:int, instantly: bool=false) -> void:
	m3item = item.instantiate()
	
	# Add child item background
	var item_bg = m3item_bg.instantiate() as Control
	m3item.add_child(item_bg)
	item_bg.z_index = -1

	# Get holder's children
	var holder_children: Array = $holder.get_children()

	# Free already existed children
	for child in holder_children:
		$holder.remove_child(child)

	# Add child item
	$holder.add_child(m3item)

	# Add coordinates
	x_pos = x
	y_pos = y

	# Animation
	anim_new_item_appearance()


# Return item
func get_item() -> Control:
	return m3item


# Set item
func set_item(item: Control) -> void:
	m3item = item


# Get holder
func get_holder() -> Control:
	return $holder


# Set selected status
func set_select(value: bool) -> void:
	if m3item:
		var player: AnimationPlayer = m3item.find_child("anim_player",true,false) as AnimationPlayer
		if not player:
			return
		if value:
			if selected_on:
				print("already selected")
			else:
				selected_on = true
				player.play("selected")
		else:
			print("Unselect item")
			selected_on = false
			player.play("RESET")
	else:
		print("No item found")


# Return item's color
func get_color() -> ItemProp.ItemTypes:
	if m3item:
		return m3item.color
	#print("Color is unknown")
	return ItemProp.ItemTypes.UNKNOWN


# ------------------------------------------------------------
# ANIMATION
# ------------------------------------------------------------


# Direction movement
func anim_start_move(prev_pos:Vector2, next_pos:Vector2) -> void:
	if not m3item:
		print("No item found")
		return

	# Get current position
	m3item.position = prev_pos
	
	# Animation tween
	var tween: Tween = get_tree().create_tween()

	# Animation for multiple rows
	var threshold: int = prev_pos.y - next_pos.y
	var height: int = 120
	var rows: int = threshold / height
	if rows > 1 or rows < -1:
		if rows < -1:
			rows *= -1
		if rows > 1:
			if rows > 3:
				tween.tween_property(m3item, "position", next_pos, .9).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BACK)
				tween.play()
				return
			tween.tween_property(m3item, "position", next_pos, .7).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BACK)
			tween.play()
			return
		tween.tween_property(m3item, "position", next_pos, .5 * rows).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BACK)
		tween.play()
		return

	# Animation for one row
	tween.tween_property(m3item, "position", next_pos, .5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BACK)
	tween.play()


# Item appearance
func anim_new_item_appearance() -> void:
	if not m3item:
		print("No item found")
		return

	# Set scale with bounce
	var tween: Tween = get_tree().create_tween()
	m3item.scale = Vector2(.7, .7)
	tween.tween_property(m3item, "scale", Vector2(1,1), .5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BACK)
	tween.play()

	# Set opacity
	var fade_out: Tween = get_tree().create_tween()
	m3item.modulate = Color(1, 1, 1, 0)
	fade_out.tween_property(m3item, "modulate", Color(1,1,1,1), .3).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	fade_out.play()


# Set selected status
func anim_item_matched() -> void:
	if not m3item:
		print("No item found")
		return

	# Set opacity
	await get_tree().create_timer(.20).timeout
	var fade_out: Tween = get_tree().create_tween()
	m3item.modulate = Color(1, 1, 1, 1)
	fade_out.tween_property(m3item, "modulate", Color(1,1,1,0), .10).set_ease(Tween.EASE_OUT)
	fade_out.play()


# Set selected status
func anim_item_bg_matched() -> void:
	if not m3item:
		print("No item found")
		return

	var player: AnimationPlayer = m3item.find_child("anim_player",true,false) as AnimationPlayer
	if not player:
		print("No matched animation")
		return
	player.play("matched")


# Wrond direction movement
func anim_item_error() -> void:
	if not m3item:
		print("No item found")
		return
	
	var player: AnimationPlayer = find_child("anim_player_item",true) as AnimationPlayer
	var player_bg: AnimationPlayer = m3item.find_child("anim_player",true,false) as AnimationPlayer
	
	if not player or not player_bg:
		return

	player.play("error")
	player_bg.stop(false)
	player_bg.play("error")
