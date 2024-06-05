extends Node2D

const MAIN_LAYER:int = 0

@onready var simulation_tile_map: TileMap = $SimulationTileMap
@onready var timer: Timer = $Timer

var state: State

func _ready() -> void:
	state = State.new(simulation_tile_map)
	$Background.show()

func main_loop() -> void:
	if state:
		state.update(simulation_tile_map)
		update_tilemap_from_state(state)

func update_tilemap_from_state(_state: State) -> void:
	for modified_position: Vector2i in _state.next_cells:
		simulation_tile_map.set_cell(MAIN_LAYER, modified_position, 0, Elements.ELEMENT_TO_ATLAS_COORD[state.next_cells[modified_position]])

# used for simulation speed
func _on_timer_timeout() -> void:
	main_loop()


func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_quit_button_pressed() -> void:
	get_tree().quit()
