extends Node2D

@export var brush_size: int = 1
@onready var sand_label: Label = $GUI/VBoxContainer/SandLabel
@onready var water_label: Label = $GUI/VBoxContainer/WaterLabel
@onready var fps: Label = $GUI/FPS

var n_steps := 0



enum MATERIALS {AIR, BEDROCK, SAND, WATER}
const MATERIAL_TO_ATLAS_COORD:Dictionary = {
	MATERIALS.BEDROCK:Vector2i(0,2),
	MATERIALS.SAND:Vector2i(0,0),
	MATERIALS.WATER:Vector2i(0,1),
}
const MAIN_LAYER := 0

var material_in_hand: MATERIALS = MATERIALS.BEDROCK

@onready var tile_map: TileMap = $TileMap

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("sand"):
		material_in_hand = MATERIALS.SAND
	if event.is_action_pressed("water"):
		material_in_hand = MATERIALS.WATER
	if event.is_action_pressed("bedrock"):
		material_in_hand = MATERIALS.BEDROCK

func _process(delta: float) -> void:
	fps.text = "%s" % Engine.get_frames_per_second()

	if Input.is_action_pressed("drop"):
		var mouse_pos = Vector2i(get_global_mouse_position())
		tile_map.set_cell(MAIN_LAYER,mouse_pos,0,MATERIAL_TO_ATLAS_COORD[material_in_hand])

func loop_tile_set() -> void:
	n_steps += 1

	var sand_cells = get_cells_by_material(MATERIALS.SAND)
	var water_cells = get_cells_by_material(MATERIALS.WATER)
	sand_label.text = "Sand: %s" % len(sand_cells)
	water_label.text = "Water: %s" % len(water_cells)
	#var bedrock_cells = get_cells_by_material(MATERIALS.BEDROCK)

	var next_generation_sand_cells = process_cells(sand_cells, MATERIALS.SAND)
	var next_generation_water_cells = process_cells(water_cells, MATERIALS.WATER)

	set_cells_next_generation(next_generation_sand_cells, MATERIALS.SAND)
	set_cells_next_generation(next_generation_water_cells, MATERIALS.WATER)

	#print(n_steps)
	#print(len(sand_cells))
	#print(len(next_generation_sand_cells))
	#print(len(water_cells))
	#print(len(next_generation_water_cells))
	#print("")

func get_cells_by_material(cell_material: MATERIALS) -> Array[Vector2i]:
	return tile_map.get_used_cells_by_id(MAIN_LAYER,0, MATERIAL_TO_ATLAS_COORD[cell_material])

func set_cells_next_generation(next_generation_cells: Array[Vector2i], cell_material: MATERIALS) -> void:
	for cell in next_generation_cells:
		tile_map.set_cell(MAIN_LAYER, cell, 0, MATERIAL_TO_ATLAS_COORD[cell_material])

func process_cells(array_of_cells:Array[Vector2i], cell_material:MATERIALS) -> Array[Vector2i]:
	var next_generation_cells: Array[Vector2i] = []


	match cell_material:
		MATERIALS.SAND:
			next_generation_cells = get_next_generation_sand(array_of_cells)
		MATERIALS.WATER:
			next_generation_cells = get_next_generation_water(array_of_cells)

	return next_generation_cells
func get_next_generation_sand(array_of_cells:Array[Vector2i]) -> Array[Vector2i]:
	var next_generation_cells: Array[Vector2i] = []

	for cell in array_of_cells:
		var down_cell := Vector2i(cell.x, cell.y + 1)
		var down_left_cell := Vector2i(cell.x - 1, cell.y + 1)
		var down_right_cell := Vector2i(cell.x + 1, cell.y + 1)

		# down empty
		if is_position_available(down_cell, next_generation_cells):
			tile_map.set_cell(MAIN_LAYER, cell, -1)
			next_generation_cells.append(down_cell)
		# both down right and down left empty
		elif is_position_available(down_left_cell, next_generation_cells) and \
			 is_position_available(down_right_cell, next_generation_cells):
			tile_map.set_cell(MAIN_LAYER, cell, -1)
			var choices = [down_left_cell, down_right_cell]
			var rand_choice = choices[randi() % len(choices)]
			next_generation_cells.append(rand_choice)
		# only down right empty
		elif is_position_available(down_left_cell, next_generation_cells):
			tile_map.set_cell(MAIN_LAYER, cell, -1)
			next_generation_cells.append(down_left_cell)
		# only down left empty
		elif is_position_available(down_right_cell, next_generation_cells):
			tile_map.set_cell(MAIN_LAYER, cell, -1)
			next_generation_cells.append(down_right_cell)
		# nothing happens
		else:
			pass
	return next_generation_cells

func get_next_generation_water(array_of_cells:Array[Vector2i]) -> Array[Vector2i]:
	var next_generation_cells: Array[Vector2i] = []

	for cell in array_of_cells:
		var down_cell := Vector2i(cell.x, cell.y + 1)
		var left_cell := Vector2i(cell.x - 1, cell.y)
		var right_cell := Vector2i(cell.x + 1, cell.y)

		# down empty
		if is_position_available(down_cell, next_generation_cells):
			tile_map.set_cell(MAIN_LAYER, cell, -1)
			next_generation_cells.append(down_cell)
		# both right and left empty
		elif is_position_available(left_cell, next_generation_cells) and \
			 is_position_available(right_cell, next_generation_cells):
			tile_map.set_cell(MAIN_LAYER, cell, -1)
			var choices = [left_cell, right_cell]
			var rand_choice = choices[randi() % len(choices)]
			next_generation_cells.append(rand_choice)
		# only left empty
		elif is_position_available(left_cell, next_generation_cells):
			tile_map.set_cell(MAIN_LAYER, cell, -1)
			next_generation_cells.append(left_cell)
		# only right empty
		elif is_position_available(right_cell, next_generation_cells):
			tile_map.set_cell(MAIN_LAYER, cell, -1)
			next_generation_cells.append(right_cell)
		# nothing happens
		else:
			pass
	return next_generation_cells

func process_sand_cells(sand_cells:Array[Vector2i]) -> Array[Vector2i]:
	var future_sand_cells:Array[Vector2i] = []
	for sand_cell in sand_cells:
		var is_down_empty = is_cell_empty_at(Vector2i(sand_cell.x, sand_cell.y + 1))
		#var is_left_empty = is_cell_empty_at(Vector2i(cell.x - 1, cell.y))
		#var is_right_empty = is_cell_empty_at(Vector2i(cell.x + 1, cell.y))
		var is_down_left_empty = is_cell_empty_at(Vector2i(sand_cell.x - 1, sand_cell.y + 1))
		var is_down_right_empty = is_cell_empty_at(Vector2i(sand_cell.x + 1, sand_cell.y + 1))

		if is_down_empty:
			tile_map.set_cell(MAIN_LAYER, sand_cell, -1)
			future_sand_cells.append(Vector2i(sand_cell.x, sand_cell.y + 1))
		elif is_down_left_empty and is_down_right_empty:
			tile_map.set_cell(MAIN_LAYER, sand_cell, -1)
			if randi() % 2 == 1:
				future_sand_cells.append(Vector2i(sand_cell.x - 1, sand_cell.y + 1))
			else:
				future_sand_cells.append(Vector2i(sand_cell.x + 1, sand_cell.y + 1))
		elif is_down_left_empty:
			tile_map.set_cell(MAIN_LAYER, sand_cell, -1)
			future_sand_cells.append(Vector2i(sand_cell.x - 1, sand_cell.y + 1))
		elif is_down_right_empty:
			tile_map.set_cell(MAIN_LAYER, sand_cell, -1)
			future_sand_cells.append(Vector2i(sand_cell.x + 1, sand_cell.y + 1))
		else:
			pass

	return future_sand_cells

func is_position_available(at_position: Vector2i, next_generation_cells: Array[Vector2i]) -> bool:
	return is_cell_empty_at(at_position) and at_position not in next_generation_cells

func process_water_cells(water_cells:Array[Vector2i]) -> Array[Vector2i]:
	var future_water_cells:Array[Vector2i] = []

	for cell in water_cells:
		var down_cell := Vector2i(cell.x, cell.y + 1)
		var is_down_empty = is_cell_empty_at(down_cell)
		var left_cell := Vector2i(cell.x - 1, cell.y)
		var is_left_empty = is_cell_empty_at(left_cell)
		var right_cell := Vector2i(cell.x + 1, cell.y)
		var is_right_empty = is_cell_empty_at(right_cell)

		if is_down_empty and down_cell not in future_water_cells:
			tile_map.set_cell(MAIN_LAYER, cell, -1)
			future_water_cells.append(Vector2i(cell.x, cell.y + 1))
		elif is_left_empty and is_right_empty:
			var choices = [left_cell, right_cell]
			var rand_choice = choices[randi() % len(choices)]
			if rand_choice not in future_water_cells:
				future_water_cells.append(rand_choice)
				tile_map.set_cell(MAIN_LAYER, cell, -1)
		elif is_left_empty and left_cell not in future_water_cells:
			tile_map.set_cell(MAIN_LAYER, cell, -1)
			future_water_cells.append(left_cell)
		elif is_right_empty and right_cell not in future_water_cells:
			tile_map.set_cell(MAIN_LAYER, cell, -1)
			future_water_cells.append(right_cell)
		else:
			pass

	return future_water_cells


func is_cell_empty_at(cell_position: Vector2i) -> bool :
	return tile_map.get_cell_source_id(MAIN_LAYER, cell_position) == -1

func _on_timer_timeout() -> void:
	loop_tile_set()

	$Timer.start()
