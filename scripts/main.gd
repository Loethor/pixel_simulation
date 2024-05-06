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

enum MATERIALS {AIR, SAND, WATER, BEDROCK, OIL, FIRE}
enum SOM {GRAIN, LIQUID, SOLID}

const MATERIAL_TO_ATLAS_COORD:Dictionary = {
	MATERIALS.AIR:Vector2i(-1,-1),
	MATERIALS.SAND:Vector2i(0,0),
	MATERIALS.WATER:Vector2i(0,1),
	MATERIALS.BEDROCK:Vector2i(0,2),
	MATERIALS.OIL:Vector2i(0,3),
	MATERIALS.FIRE:Vector2i(0,4),
}

const ATLAS_COORD_TO_MATERIAL:Dictionary = {
	Vector2i(-1,-1):MATERIALS.AIR,
	Vector2i(0,0):MATERIALS.SAND,
	Vector2i(0,1):MATERIALS.WATER,
	Vector2i(0,2):MATERIALS.BEDROCK,
	Vector2i(0,3):MATERIALS.OIL,
	Vector2i(0,4):MATERIALS.FIRE,
}

const MATERIAL_INFO: Dictionary = {
	MATERIALS.AIR:{"weight":0,"state":SOM.SOLID},
	MATERIALS.SAND:{"weight":3,"state":SOM.GRAIN},
	MATERIALS.WATER:{"weight":2,"state":SOM.LIQUID},
	MATERIALS.OIL:{"weight":1,"state":SOM.LIQUID},
	MATERIALS.BEDROCK:{"weight":0,"state":SOM.SOLID},
	MATERIALS.FIRE:{"weight":-1,"state":SOM.LIQUID},
}

class State:
	var cells: Array = []
	var width: int
	var height: int
	var modified_cells: Dictionary = {}
	
	func _init(w: int, h: int, tm: TileMap) -> void:
		cells = []
		width = w
		height = h
		cells.resize(width)
		for column in range(width):
			cells[column] = []
			cells[column].resize(height)
			cells[column].fill(MATERIALS.AIR)
			
		for tile in tm.get_used_cells(MAIN_LAYER):
			var tile_material: MATERIALS = ATLAS_COORD_TO_MATERIAL[tm.get_cell_atlas_coords(MAIN_LAYER, tile)]
			set_cell(tile, tile_material)
	
	func get_cell(position: Vector2i) -> MATERIALS:
		return cells[position[0]][position[1]]

	func set_cell(position: Vector2i, new_material: MATERIALS) -> void:
		cells[position[0]][position[1]] = new_material
		modified_cells[position] = null
		
	func swap_cells(position_a: Vector2i, position_b: Vector2i) -> void:
		var mat_a: MATERIALS = get_cell(position_a)
		var mat_b: MATERIALS = get_cell(position_b)
		set_cell(position_a, mat_b)
		set_cell(position_b, mat_a)

	func is_position_available(at_position: Vector2i) -> bool:
		return cells[at_position[0]][at_position[1]] == MATERIALS.AIR
		
	func modified_since_last() -> Array:
		var result: Array = modified_cells.keys()
		modified_cells.clear()
		return result

const MAIN_LAYER := 0

var material_in_hand: MATERIALS = MATERIALS.BEDROCK

@onready var tile_map: TileMap = $TileMap
@onready var view_width: int = get_viewport().size[0]
@onready var view_height: int = get_viewport().size[1]

var state: State

func _ready() -> void:
	state = State.new(view_width, view_height, tile_map)

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
		var mouse_pos := Vector2i(get_global_mouse_position())
		for i in range(mouse_pos.x - brush_size + 1, mouse_pos.x + brush_size):
			for j in range(mouse_pos.y - brush_size + 1, mouse_pos.y + brush_size):
				state.set_cell(Vector2i(i,j), material_in_hand)

func loop_tile_set() -> void:
	n_steps += 1

	if state:
		calculate_next_generation()
		update_cells()

	#print(n_steps)
	#print(len(sand_cells))
	#print(len(next_generation_sand_cells))
	#print(len(water_cells))
	#print(len(next_generation_water_cells))
	#print("")
	

func update_cells() -> void:
	for modified_position: Vector2i in state.modified_since_last():
		tile_map.set_cell(MAIN_LAYER, modified_position, 0, MATERIAL_TO_ATLAS_COORD[state.get_cell(modified_position)])

func calculate_next_generation() -> void:
	var used_cells: Array[Vector2i] = tile_map.get_used_cells(MAIN_LAYER)
	used_cells.sort_custom(func bottom_to_top(a: Vector2i, b: Vector2i)->bool: return a[1] > b[1])
	
	for cell in used_cells:
		var cell_material: MATERIALS = ATLAS_COORD_TO_MATERIAL[tile_map.get_cell_atlas_coords(MAIN_LAYER, cell)]
		var cell_info: Dictionary = MATERIAL_INFO[cell_material]
		var cell_type: SOM = cell_info["state"]
		
		if cell_type != SOM.SOLID:
			var cell_weight: int = cell_info["weight"]
			var direction: int = signi(cell_weight)
		
			var straight_cell: Vector2i = Vector2i(cell.x, cell.y + direction)

			if state.is_position_available(straight_cell):
				state.swap_cells(straight_cell, cell)
			else:
				var oc_material: MATERIALS = state.get_cell(straight_cell)
				var oc_info: Dictionary = MATERIAL_INFO[oc_material]
				var oc_weight: SOM = oc_info["weight"]
				
				if oc_weight < cell_weight and oc_info["state"] != SOM.SOLID:
					state.swap_cells(cell, straight_cell)
				else:
					var grain_modifier: int = direction if cell_type == SOM.GRAIN else 0
					
					var left_cell: Vector2i = Vector2i(cell.x - 1, cell.y + grain_modifier)
					var left_cell_material: MATERIALS = state.get_cell(left_cell)
					var left_cell_info: Dictionary = MATERIAL_INFO[left_cell_material]
					
					var right_cell: Vector2i = Vector2i(cell.x + 1, cell.y + grain_modifier)
					var right_cell_material: MATERIALS = state.get_cell(right_cell)
					var right_cell_info: Dictionary = MATERIAL_INFO[right_cell_material]
					
					var available_cells: Array[Vector2i] = []
					if left_cell_material == MATERIALS.AIR or (left_cell_info["weight"] < cell_weight and left_cell_info["state"] != SOM.SOLID):
						available_cells.append(left_cell)
					if right_cell_material == MATERIALS.AIR or (right_cell_info["weight"] < cell_weight and right_cell_info["state"] != SOM.SOLID):
						available_cells.append(right_cell)
					
					if available_cells.size() > 0:
						var target_cell: Vector2i = available_cells.pick_random()
						state.swap_cells(cell, target_cell)

# used for simulation speed
func _on_timer_timeout() -> void:
	loop_tile_set()
	$Timer.start()
