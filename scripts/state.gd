extends Resource
class_name State


var cells: Dictionary = {}  # Vector2i => Element.ELEMENT
var next_cells: Dictionary = {}  # Vector2i => Element.ELEMENT

var width: int
var height: int

const MAIN_LAYER:int = 0

func _init(w: int, h: int, tm: TileMap) -> void:
	width = w
	height = h

	for tile:Vector2i in tm.get_used_cells(MAIN_LAYER):
		var tile_material: Elements.ELEMENT = Elements.ATLAS_COORD_TO_ELEMENT[tm.get_cell_atlas_coords(MAIN_LAYER, tile)]
		set_cell(tile, tile_material)

#func step() -> void:
	#for x in range(width):
		#for y in range(height):
			#step_cell(Vector2i(x, y))
			#
#func step_cell(pos: Vector2i) -> void:
	#var cell_element: Elements.ELEMENT = Elements.get_cell(pos)
	#var cell_template: element_template = Elements.ELEMENT_TO_TEMPLATE[cell_element]
	#var cell_state_of_matter: Elements.STATE_OF_MATTER = cell_template.state_of_matter
	#
	#if next_cells.has(pos):
		#return
		#
	## drain
	## generate
	## decay
	## burn
	#
	## cell movements
	#if cell_state_of_matter == Elements.STATE_OF_MATTER.SOLID:
		#return
	#
	#var move_candidates: Array[Vector2i] = []
	#for dx in range(-1, 2, 1):
		#for dy in range(-1, 2, 1):
			#if dx == 0 and dy == 0:
				#continue
			#var neighbour_pos: Vector2i = pos + Vector2i(dx, dy)
			#if next_cells.has(neighbour_pos):
				#continue
			#var neighbour_element: Elements.ELEMENT = get_cell(neighbour_pos)
			#var neighbour_template: element_template = Elements.ELEMENT_TO_TEMPLATE[neighbour_element]
			#if neighbour_template.state_of_matter == Elements.STATE_OF_MATTER.SOLID:
				#continue
			#var neighbour_weight: int = neighbour_template.weight
			#
			## add to candidates if...
			#
			#move_candidates.append(neighbour_pos)
	#
	## swap with random choice in move_candidates
	#
	#pass

func get_cell(position: Vector2i) -> Elements.ELEMENT:
	return cells[position] if cells.has(position) else Elements.ELEMENT.AIR

func set_cell(position: Vector2i, new_material: Elements.ELEMENT) -> void:
	if not is_position_modified(position):
		next_cells[position] = new_material

func swap_cells(position_a: Vector2i, position_b: Vector2i) -> void:
	if not is_position_modified(position_a) and not is_position_modified(position_b):
		var mat_a: Elements.ELEMENT = get_cell(position_a)
		var mat_b: Elements.ELEMENT = get_cell(position_b)
		set_cell(position_a, mat_b)
		set_cell(position_b, mat_a)

func is_position_available(at_position: Vector2i) -> bool:
	return get_cell(at_position) == Elements.ELEMENT.AIR and not is_position_modified(at_position)
	
func is_position_modified(position: Vector2i) -> bool:
	return next_cells.has(position)

func modified_since_last() -> Array:
	var result: Array = next_cells.keys()
	for changed_position: Vector2i in result:
		cells[changed_position] = next_cells[changed_position]
	
	next_cells.clear()
	return result
