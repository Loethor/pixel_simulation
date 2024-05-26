extends Node2D

# Tilemap Layer
const MAIN_LAYER:int = 0

# Brush settings
const MIN_BRUSH_SIZE: int = 1
const MAX_BRUSH_SIZE:int = 7
@export var brush_size: int = MIN_BRUSH_SIZE : set = set_brush
func set_brush(value: int) -> void:
	brush_size = clamp(value, MIN_BRUSH_SIZE, MAX_BRUSH_SIZE)

# Current material selected to place
var material_in_hand: Elements.ELEMENT = Elements.ELEMENT.AIR
var is_placing_blocks :bool = false
var state: State

@onready var tool_tip_label: Label = $GUI/ToolTipLabel
@onready var sand_label: Label = %SandLabel
@onready var water_label: Label = %WaterLabel
@onready var rock_label: Label = %RockLabel
@onready var oil_label: Label = %OilLabel
@onready var fire_label: Label = %FireLabel
@onready var fps: Label = $GUI/FPS
@onready var counts_panel: PanelContainer = %CountsPanel
@onready var hot_bar: HotBar = $GUI/HotBar
@onready var tile_map: TileMap = $TileMap
@onready var still_life: TileMap = $StillLife

func _ready() -> void:
	state = State.new(tile_map)
	hot_bar.index_changed.connect(_on_hot_bar_index_changed)
	hot_bar.scrolled.connect(flick_element_name)

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
				state.set_placed_cell(Vector2i(i,j), material_in_hand)

func main_loop() -> void:
	if state:
		state.update(tile_map)
		update_tilemap_from_state(state)
		update_stilllife_from_state(state)

func update_tilemap_from_state(_state: State) -> void:
	for modified_position: Vector2i in _state.next_cells:
		tile_map.set_cell(MAIN_LAYER, modified_position, 0, Elements.ELEMENT_TO_ATLAS_COORD[state.next_cells[modified_position]])

func update_stilllife_from_state(_state: State) -> void:
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


func update_counts_panel() -> void:
	sand_label.text = "%s" % len(tile_map.get_used_cells_by_id(MAIN_LAYER,0,Elements.ELEMENT_TO_ATLAS_COORD[Elements.ELEMENT.SAND]))
	water_label.text = "%s" % len(tile_map.get_used_cells_by_id(MAIN_LAYER,0,Elements.ELEMENT_TO_ATLAS_COORD[Elements.ELEMENT.WATER]))
	rock_label.text = "%s" % len(tile_map.get_used_cells_by_id(MAIN_LAYER,0,Elements.ELEMENT_TO_ATLAS_COORD[Elements.ELEMENT.BEDROCK]))
	oil_label.text = "%s" % len(tile_map.get_used_cells_by_id(MAIN_LAYER,0,Elements.ELEMENT_TO_ATLAS_COORD[Elements.ELEMENT.OIL]))
	fire_label.text = "%s" % len(tile_map.get_used_cells_by_id(MAIN_LAYER,0,Elements.ELEMENT_TO_ATLAS_COORD[Elements.ELEMENT.FIRE]))

func _on_hot_bar_index_changed(current_material: Elements.ELEMENT) -> void:
	material_in_hand = current_material

func flick_element_name() ->void:
	tool_tip_label.text = Elements.ELEMENT_TO_TEMPLATE[material_in_hand].name
	tool_tip_label.show()
	await get_tree().create_timer(.4).timeout
	tool_tip_label.hide()
