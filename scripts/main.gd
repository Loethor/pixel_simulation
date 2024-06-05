extends Node2D

# Tilemap Layer
const MAIN_LAYER:int = 0



# Current material selected to place
var material_in_hand: Elements.ELEMENT = Elements.ELEMENT.AIR
var is_placing_blocks :bool = false
var state: State

@onready var gui: GUIInterface = $GUI/GUI
@onready var hot_bar: HotBar = $GUI/GUI/PanelContainer/MarginContainer/HotBar
@onready var simulation_tile_map: TileMap = $SimulationTileMap
@onready var still_life: TileMap = $StillLife

func _ready() -> void:
	state = State.new(simulation_tile_map)
	gui.hotbal_index_changed.connect(_on_hotbar_index_changed)





func _unhandled_input(event: InputEvent) -> void:
	# placing pixels in a square of brush_size size around mouse position
	if event.is_action_pressed("place"):
		is_placing_blocks = true
	if event.is_action_released("place"):
		is_placing_blocks = false

func _process(_delta: float) -> void:
	if is_placing_blocks:
		var mouse_pos:Vector2i = Vector2i(get_global_mouse_position())
		for i: int in range(mouse_pos.x - gui.brush_size + 1, mouse_pos.x + gui.brush_size):
			for j: int in range(mouse_pos.y - gui.brush_size + 1, mouse_pos.y + gui.brush_size):
				state.set_placed_cell(Vector2i(i,j), material_in_hand)

func main_loop() -> void:
	if state:
		state.update(simulation_tile_map)
		update_tilemap_from_state(state)
		update_stilllife_from_state(state)

func update_tilemap_from_state(_state: State) -> void:
	for modified_position: Vector2i in _state.next_cells:
		simulation_tile_map.set_cell(MAIN_LAYER, modified_position, 0, Elements.ELEMENT_TO_ATLAS_COORD[state.next_cells[modified_position]])

func update_stilllife_from_state(_state: State) -> void:
	if still_life.visible == false:
		return

	# Empty the still life tilemap
	still_life.clear()

	# Re-draw it with the current cell and still cells information
	for cell: Vector2i in _state.current_cells:
			still_life.set_cell(MAIN_LAYER, cell, 1, Vector2i(0,0))
	for cell: Vector2i in _state.still_cells:
			still_life.set_cell(MAIN_LAYER, cell, 1, Vector2i(1,0))

# used for simulation speed
func _on_timer_timeout() -> void:
	main_loop()

func _on_hotbar_index_changed(current_material: Elements.ELEMENT) -> void:
	material_in_hand = current_material
