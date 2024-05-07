extends Node2D

# brush stuff
@export var brush_size: int = MIN_BRUSH_SIZE : set = set_brush
const MIN_BRUSH_SIZE: int = 1
const MAX_BRUSH_SIZE:int = 5
func set_brush(value: int) -> void:
	brush_size = clamp(value, MIN_BRUSH_SIZE, MAX_BRUSH_SIZE)

@onready var sand_label: Label = %SandLabel
@onready var water_label: Label = %WaterLabel
@onready var rock_label: Label = %RockLabel
@onready var oil_label: Label = %OilLabel
@onready var fire_label: Label = %FireLabel
@onready var fps: Label = $GUI/FPS
@onready var counts_panel: PanelContainer = %CountsPanel



var n_steps: int = 0

const MAIN_LAYER:int = 0

var material_in_hand: Element.ELEMENT = Element.ELEMENT.BEDROCK

@onready var tile_map: TileMap = $TileMap
@onready var view_width: int = get_viewport().size[0]
@onready var view_height: int = get_viewport().size[1]

var state: State

func _ready() -> void:
	state = State.new(view_width, view_height, tile_map)

func _input(event: InputEvent) -> void:

	# changing materials with 1,2,3...
	if event.is_action_pressed("sand"):
		material_in_hand = Element.ELEMENT.SAND
	if event.is_action_pressed("water"):
		material_in_hand = Element.ELEMENT.WATER
	if event.is_action_pressed("bedrock"):
		material_in_hand = Element.ELEMENT.BEDROCK
	if event.is_action_pressed("oil"):
		material_in_hand = Element.ELEMENT.OIL
	if event.is_action_pressed("fire"):
		material_in_hand = Element.ELEMENT.FIRE
	if event.is_action_pressed("show_counts"):
		counts_panel.visible = !counts_panel.visible

func _process(_delta: float) -> void:
	fps.text = "%s" % Engine.get_frames_per_second()
	if counts_panel.visible:
		update_counts_panel()

	if Input.is_action_just_pressed("increase_brush"):
		brush_size += 1
	if Input.is_action_just_pressed("decrease_brush"):
		brush_size -= 1

	# placing pixels in a square of brush_size size around mouse position
	if Input.is_action_pressed("place"):
		var mouse_pos:Vector2i = Vector2i(get_global_mouse_position())
		for i: int in range(mouse_pos.x - brush_size + 1, mouse_pos.x + brush_size):
			for j: int in range(mouse_pos.y - brush_size + 1, mouse_pos.y + brush_size):
				state.set_cell(Vector2i(i,j), material_in_hand)

func loop_tile_set() -> void:
	n_steps += 1

	if state:
		calculate_next_generation()
		update_cells()


func update_cells() -> void:
	for modified_position: Vector2i in state.modified_since_last():
		tile_map.set_cell(MAIN_LAYER, modified_position, 0, Element.ELEMENT_TO_ATLAS_COORD[state.get_cell(modified_position)])

func calculate_next_generation() -> void:
	var used_cells: Array[Vector2i] = tile_map.get_used_cells(MAIN_LAYER)
	used_cells.sort_custom(func bottom_to_top(a: Vector2i, b: Vector2i)->bool: return a[1] > b[1])

	for cell: Vector2i in used_cells:
		var cell_material: Element.ELEMENT = Element.ATLAS_COORD_TO_ELEMENT[tile_map.get_cell_atlas_coords(MAIN_LAYER, cell)]
		var cell_info: Dictionary = Element.ELEMENT_INFO[cell_material]
		var cell_type: Element.SOM = cell_info["state"]

		if cell_type == Element.SOM.SOLID:
			continue

		var cell_weight: int = cell_info["weight"]
		var direction: int = signi(cell_weight)

		var straight_cell: Vector2i = Vector2i(cell.x, cell.y + direction)

		# if target position is air, just swap them
		if state.is_position_available(straight_cell):
			state.swap_cells(straight_cell, cell)
		else:
			var oc_material: Element.ELEMENT = state.get_cell(straight_cell)
			var oc_info: Dictionary = Element.ELEMENT_INFO[oc_material]
			var oc_weight: Element.SOM = oc_info["weight"]

			# if cell is heavier than the occupied cell and the other is not solid
			# swap
			if oc_weight < cell_weight and oc_info["state"] != Element.SOM.SOLID:
				state.swap_cells(cell, straight_cell)
			else:
				# directional modifier if the cell is grain type
				var grain_modifier: int = direction if cell_type == Element.SOM.GRAIN else 0

				var left_cell: Vector2i = Vector2i(cell.x - 1, cell.y + grain_modifier)
				var left_cell_material: Element.ELEMENT = state.get_cell(left_cell)
				var left_cell_info: Dictionary = Element.ELEMENT_INFO[left_cell_material]

				var right_cell: Vector2i = Vector2i(cell.x + 1, cell.y + grain_modifier)
				var right_cell_material: Element.ELEMENT = state.get_cell(right_cell)
				var right_cell_info: Dictionary = Element.ELEMENT_INFO[right_cell_material]

				var available_cells: Array[Vector2i] = []
				if left_cell_material == Element.ELEMENT.AIR or (left_cell_info["weight"] < cell_weight and left_cell_info["state"] != Element.SOM.SOLID):
					available_cells.append(left_cell)
				if right_cell_material == Element.ELEMENT.AIR or (right_cell_info["weight"] < cell_weight and right_cell_info["state"] != Element.SOM.SOLID):
					available_cells.append(right_cell)

				if available_cells.size() > 0:
					var target_cell: Vector2i = available_cells.pick_random()
					state.swap_cells(cell, target_cell)

# used for simulation speed
func _on_timer_timeout() -> void:
	loop_tile_set()
	$Timer.start()

func update_counts_panel() -> void:
	sand_label.text = "%s" % len(tile_map.get_used_cells_by_id(MAIN_LAYER,0,Element.ELEMENT_TO_ATLAS_COORD[Element.ELEMENT.SAND]))
	water_label.text = "%s" % len(tile_map.get_used_cells_by_id(MAIN_LAYER,0,Element.ELEMENT_TO_ATLAS_COORD[Element.ELEMENT.WATER]))
	rock_label.text = "%s" % len(tile_map.get_used_cells_by_id(MAIN_LAYER,0,Element.ELEMENT_TO_ATLAS_COORD[Element.ELEMENT.BEDROCK]))
	oil_label.text = "%s" % len(tile_map.get_used_cells_by_id(MAIN_LAYER,0,Element.ELEMENT_TO_ATLAS_COORD[Element.ELEMENT.OIL]))
	fire_label.text = "%s" % len(tile_map.get_used_cells_by_id(MAIN_LAYER,0,Element.ELEMENT_TO_ATLAS_COORD[Element.ELEMENT.FIRE]))
