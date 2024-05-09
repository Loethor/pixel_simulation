extends Node2D

const MAIN_LAYER:int = 0

@export var brush_size: int = MIN_BRUSH_SIZE : set = set_brush
const MIN_BRUSH_SIZE: int = 1
const MAX_BRUSH_SIZE:int = 5
func set_brush(value: int) -> void:
	brush_size = clamp(value, MIN_BRUSH_SIZE, MAX_BRUSH_SIZE)

var n_steps: int = 0
var material_in_hand: Element.ELEMENT = Element.ELEMENT.BEDROCK
var is_placing_blocks :bool = false
var state: State

@onready var sand_label: Label = %SandLabel
@onready var water_label: Label = %WaterLabel
@onready var rock_label: Label = %RockLabel
@onready var oil_label: Label = %OilLabel
@onready var fire_label: Label = %FireLabel
@onready var fps: Label = $GUI/FPS
@onready var counts_panel: PanelContainer = %CountsPanel
@onready var hot_bar: HotBar = $GUI/HotBar
@onready var tile_map: TileMap = $TileMap
@onready var view_width: int = int(get_viewport().get_visible_rect().size[0])
@onready var view_height: int = int(get_viewport().get_visible_rect().size[1])

func _ready() -> void:
	state = State.new(view_width, view_height, tile_map)

func _input(event: InputEvent) -> void:

	# changing materials with 1,2,3...
	if event.is_action_pressed("sand"):
		hot_bar.current_index = 0
	if event.is_action_pressed("water"):
		hot_bar.current_index = 1
	if event.is_action_pressed("bedrock"):
		hot_bar.current_index = 2
	if event.is_action_pressed("oil"):
		hot_bar.current_index = 3
	if event.is_action_pressed("fire"):
		hot_bar.current_index = 4
	if event.is_action_pressed("fuse"):
		hot_bar.current_index = 5

	if event.is_action_pressed("show_counts"):
		counts_panel.visible = !counts_panel.visible

	if event.is_action_pressed("increase_brush"):
		brush_size += 1
	if event.is_action_pressed("decrease_brush"):
		brush_size -= 1

func _unhandled_input(event: InputEvent) -> void:
	# placing pixels in a square of brush_size size around mouse position
	if event.is_action_pressed("place"):
		is_placing_blocks = true
	if event.is_action_released("place"):
		is_placing_blocks = false


func _process(_delta: float) -> void:
	fps.text = "%s" % Engine.get_frames_per_second()
	if counts_panel.visible:
		update_counts_panel()

	if is_placing_blocks:
		var mouse_pos:Vector2i = Vector2i(get_global_mouse_position())
		for i: int in range(mouse_pos.x - brush_size + 1, mouse_pos.x + brush_size):
			for j: int in range(mouse_pos.y - brush_size + 1, mouse_pos.y + brush_size):
				state.set_cell(Vector2i(i,j), material_in_hand)





func loop_tile_set() -> void:
	n_steps += 1

	if state:
		#var time_start:int = Time.get_ticks_usec()
		calculate_next_generation()
		update_cells()
		#var time_end:int = Time.get_ticks_usec()
		#print("update_enemies() took %d microseconds" % (time_end - time_start))


func update_cells() -> void:
	for modified_position: Vector2i in state.modified_since_last():
		tile_map.set_cell(MAIN_LAYER, modified_position, 0, Element.ELEMENT_TO_ATLAS_COORD[state.get_cell(modified_position)])

func calculate_next_generation() -> void:
	var used_cells: Array[Vector2i] = tile_map.get_used_cells(MAIN_LAYER)

	for cell: Vector2i in used_cells:
		var cell_material: Element.ELEMENT = state.get_cell(cell)
		var cell_info: Dictionary = Element.ELEMENT_INFO[cell_material]
		var cell_type: Element.SOM = cell_info["state"]

		if cell_info["decay_chance"] > 0.0 and randf() < cell_info["decay_chance"]:
			state.set_cell(cell, cell_info["decay_into"])
			continue

		if cell_info["hot"]:
			for dx: int in range(-1, 2, 1):
				for dy: int in range(-1, 2, 1):
					var burn_target: Vector2i = cell + Vector2i(dx, dy)
					var burn_material: Element.ELEMENT = state.get_cell(burn_target)
					var burn_info: Dictionary = Element.ELEMENT_INFO[burn_material]
					if burn_info["burn_chance"] > 0.0 and randf() < burn_info["burn_chance"]:
						state.set_cell(burn_target, burn_info["burn_into"])

		if cell_type == Element.SOM.SOLID:
			continue

		var direction: int = signi(cell_info["weight"])
		var target_cells: Array[Vector2i] = []
		
		# straight target
		var straight_cell: Vector2i = Vector2i(cell.x, cell.y + direction)
		if state.could_swap(cell, straight_cell):
			for _i in range(3):
				target_cells.append(straight_cell)
		elif state.is_cell_modified(straight_cell):
			target_cells.append(straight_cell)

		# diagonal targets
		for d: int in [-1, 1]:
			var diagonal_target: Vector2i = Vector2i(cell.x + d, cell.y + direction)
			if state.could_swap(cell, diagonal_target):
				target_cells.append(diagonal_target)
		
		# horizontal targets
		if cell_type == Element.SOM.LIQUID:
			for d: int in [-1, 1]:
				var horizontal_target: Vector2i = Vector2i(cell.x + d, cell.y)
				if state.could_swap(cell, horizontal_target):
					for  _i in range(2):
						target_cells.append(horizontal_target)

		if target_cells.size() > 0:
			var target_cell: Vector2i = target_cells.pick_random()
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


func _on_hot_bar_index_changed(current_material: Element.ELEMENT) -> void:
	material_in_hand = current_material
