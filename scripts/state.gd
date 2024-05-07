extends Resource
class_name State


var cells: Array[Array] = []
var width: int
var height: int
var modified_cells: Dictionary = {}

const MAIN_LAYER:int = 0



func _init(w: int, h: int, tm: TileMap) -> void:
	cells = []
	width = w
	height = h
	cells.resize(width)
	for column: int in range(width):
		cells[column] = []
		cells[column].resize(height)
		cells[column].fill(Element.ELEMENT.AIR)

	for tile:Vector2i in tm.get_used_cells(MAIN_LAYER):
		var tile_material: Element.ELEMENT = Element.ATLAS_COORD_TO_ELEMENT[tm.get_cell_atlas_coords(MAIN_LAYER, tile)]
		set_cell(tile, tile_material)

func get_cell(position: Vector2i) -> Element.ELEMENT:
	return cells[position[0]][position[1]]

func set_cell(position: Vector2i, new_material: Element.ELEMENT) -> void:
	cells[position[0]][position[1]] = new_material
	modified_cells[position] = null

func swap_cells(position_a: Vector2i, position_b: Vector2i) -> void:
	var mat_a: Element.ELEMENT = get_cell(position_a)
	var mat_b: Element.ELEMENT = get_cell(position_b)
	set_cell(position_a, mat_b)
	set_cell(position_b, mat_a)

func is_position_available(at_position: Vector2i) -> bool:
	return cells[at_position[0]][at_position[1]] == Element.ELEMENT.AIR

func modified_since_last() -> Array[Vector2i]:
	var result: Array[Vector2i] = modified_cells.keys()
	modified_cells.clear()
	return result
