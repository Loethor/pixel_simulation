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

func could_swap(cell: Vector2i, target: Vector2i) -> bool:
	var cell_element: Element.ELEMENT = get_cell(cell)
	var target_element: Element.ELEMENT = get_cell(target)
	
	# always allow swapping into air
	if target_element == Element.ELEMENT.AIR:
		return true
	# avoid swapping cell more than once (unless it is air)
	if is_cell_modified(target) or cell_element == target_element:
		return false
	
	var cell_info: Dictionary = Element.ELEMENT_INFO[cell_element]
	var target_info: Dictionary = Element.ELEMENT_INFO[target_element]
	
	var cell_state: Element.SOM = cell_info["state"]
	var target_state: Element.SOM = target_info["state"]
	if cell_state == Element.SOM.SOLID or target_state == Element.SOM.SOLID:
		return false
		
	var cell_weight: int = cell_info["weight"]
	var target_weight: int = target_info["weight"]
	return cell_weight > target_weight

func swap_cells(position_a: Vector2i, position_b: Vector2i) -> void:
	var mat_a: Element.ELEMENT = get_cell(position_a)
	var mat_b: Element.ELEMENT = get_cell(position_b)
	set_cell(position_a, mat_b)
	set_cell(position_b, mat_a)

func is_position_available(at_position: Vector2i) -> bool:
	return get_cell(at_position) == Element.ELEMENT.AIR

func is_cell_modified(at_position: Vector2i) -> bool:
	return modified_cells.has(at_position)

func modified_since_last() -> Array:
	var result: Array = modified_cells.keys()
	modified_cells.clear()
	return result
