extends Node2D

# brush stuff
@export var brush_size: int = MIN_BRUSH_SIZE : set = set_brush
const MIN_BRUSH_SIZE := 1
const MAX_BRUSH_SIZE := 5
func set_brush(value:int) -> void:
	brush_size = clamp(value, MIN_BRUSH_SIZE, MAX_BRUSH_SIZE)

@onready var sand_label: Label = $GUI/VBoxContainer/SandLabel
@onready var water_label: Label = $GUI/VBoxContainer/WaterLabel
@onready var fps: Label = $GUI/FPS

var n_steps := 0	

enum MATERIALS {
	FIRE = 0,
	BEDROCK = 1,
	OIL = 2,
	WATER = 3,
	SAND = 4
	}

var current_layer = 0

var material_in_hand: MATERIALS = MATERIALS.BEDROCK

@onready var tile_map: TileMap = $TileMap


func _input(event: InputEvent) -> void:

	# changing materials with 1,2,3...
	if event.is_action_pressed("sand"):
		material_in_hand = MATERIALS.SAND
	if event.is_action_pressed("water"):
		material_in_hand = MATERIALS.WATER
	if event.is_action_pressed("bedrock"):
		material_in_hand = MATERIALS.BEDROCK
	if event.is_action_pressed("oil"):
		material_in_hand = MATERIALS.OIL
	if event.is_action_pressed("fire"):
		material_in_hand = MATERIALS.FIRE

func _process(delta: float) -> void:
	fps.text = "%s" % Engine.get_frames_per_second()

	if Input.is_action_just_pressed("increase_brush"):
		brush_size += 1
	if Input.is_action_just_pressed("decrease_brush"):
		brush_size -= 1

	# placing pixels in a square of brush_size size around mouse position
	if Input.is_action_pressed("place"):
		var mouse_pos = Vector2i(get_global_mouse_position())
		for i in range(mouse_pos.x - brush_size + 1, mouse_pos.x + brush_size):
			for j in range(mouse_pos.y - brush_size + 1, mouse_pos.y + brush_size):
				tile_map.set_cell(current_layer, Vector2i(i,j), 0, Vector2i(0, material_in_hand))

func loop_tile_set() -> void:
	n_steps += 1

	clear_other_layer()
	process_cells()
	swap_layers()

func clear_other_layer() -> void:
	tile_map.clear_layer(1 - current_layer)
	
func swap_layers() -> void:
	tile_map.set_layer_modulate(current_layer, Color.TRANSPARENT)
	tile_map.set_layer_modulate(1 - current_layer, Color.WHITE)
	current_layer = 1 - current_layer

func process_cells() -> void:
	var used_cells: Array[Vector2i] = tile_map.get_used_cells(current_layer)
	used_cells.sort_custom(func y_bottom_to_top(a: Vector2i, b: Vector2i): return a[1] > b[1] or a[1] == b[1] and a[0] > b[0])
	
	for cell in used_cells:
		process_cell(cell)
		
func process_cell(cell: Vector2i) -> void:
	var cell_type: MATERIALS = tile_map.get_cell_atlas_coords(current_layer, cell)[1]
	var cell_data: TileData = tile_map.get_cell_tile_data(current_layer, cell)
	var cell_weight: int = cell_data.get_custom_data("weight")
	var cell_direction: int = signi(cell_weight)
	var liquid_modifier: int = 0 if cell_data.get_custom_data("is_liquid") else cell_direction
	
	var target_position: Vector2i = cell
	if is_cell_empty_at(1 - current_layer, target_position):
		target_position = Vector2i(cell[0], cell[1] + cell_direction)
	else:
		# try other targets
		var left_target_position: Vector2i = Vector2i(cell[0] - 1, cell[1] + liquid_modifier)
		var right_target_position: Vector2i = Vector2i(cell[0] + 1, cell[1] + liquid_modifier)
		var remaining_available = []
		if is_cell_empty_at(1 - current_layer, left_target_position):
			remaining_available.append(left_target_position)
		if is_cell_empty_at(1 - current_layer, right_target_position):
			remaining_available.append(right_target_position)
			
		if remaining_available.size() > 0:
			target_position = remaining_available.pick_random()
			
	tile_map.set_cell(1 - current_layer, target_position, 0, Vector2i(0, cell_type))

# checks if the id of the cell at cell_position is -1 (empty)
func is_cell_empty_at(layer: int, cell_position: Vector2i) -> bool :
	var atlas = tile_map.get_cell_atlas_coords(layer, cell_position)[1] == -1
	return atlas

# used for simulation speed
func _on_timer_timeout() -> void:
	loop_tile_set()
	$Timer.start()
