extends Resource
class_name State


var current_cells: Dictionary = {}  # Vector2i => Element.ELEMENT
var next_cells: Dictionary = {}  # Vector2i => Element.ELEMENT
var placed_cells: Dictionary = {}  # Vector2i => Element.ELEMENT
var still_cells: Dictionary = {} # Vector2i => null
var cell_to_neigh: Dictionary = {} # Vector2i => Array[Vector2i]

# needed because "air" is a cell that represents nothing, but this position
# is stored in current_cells. Everything that is in to_be_deleted will be deleted
# from current cells
var to_be_deleted: Dictionary = {} # Vector2i => null

const MAIN_LAYER:int = 0
enum {TOP_LEFT=0, TOP, TOP_RIGHT, LEFT, RIGHT, BOTTOM_LEFT, BOTTOM, BOTTOM_RIGHT}

var iter:int = 0

func _init(tm: TileMap) -> void:
	_update_cells_from_tilemap(tm)

func update(_tile_map:TileMap) -> void:
	_clear_next_cells()
	_update_next_cells_with_placed()
	_calculate_next_generation()
	_update_current_cells_with_next_cells()
	_remove_air_from_current()

# This is done only the first time to initialize current cells
func _update_cells_from_tilemap(tile_map:TileMap) -> void:
	for tile:Vector2i in tile_map.get_used_cells(MAIN_LAYER):
		var tile_material: Elements.ELEMENT = Elements.ATLAS_COORD_TO_ELEMENT[tile_map.get_cell_atlas_coords(MAIN_LAYER, tile)]
		_set_cell(tile, tile_material)

func _obtain_all_cell_neighbors(at_cell:Vector2i) -> Array[Vector2i]:
	#if the values are there, cache them
	if at_cell in cell_to_neigh:
		return cell_to_neigh[at_cell]

	# TOP_LEFT
	var top_left: Vector2i = at_cell + Vector2i(-1, -1)
	# TOP
	var top: Vector2i = at_cell + Vector2i( 0, -1)
	# TOP_RIGHT
	var top_right: Vector2i = at_cell + Vector2i( 1, -1)
	# LEFT
	var left: Vector2i = at_cell + Vector2i(-1,  0)
	# RIGHT
	var right: Vector2i = at_cell + Vector2i( 1,  0)
	# BOTTOM_LEFT
	var bottom_left: Vector2i = at_cell + Vector2i(-1, 1)
	# BOTTOM
	var bottom: Vector2i = at_cell + Vector2i( 0 ,1)
	# BOTTOM_RIGHT
	var bottom_right: Vector2i = at_cell + Vector2i( 1, 1)
	var neighbor_cells:Array[Vector2i] = [
		top_left,
		top,
		top_right,
		left,
		right,
		bottom_left,
		bottom,
		bottom_right
	]

	cell_to_neigh[at_cell] = neighbor_cells
	return neighbor_cells

func _are_neighbors_of_same_type(as_cell:Vector2i, neighbor_cells:Array[Vector2i]) -> bool:
	# do not consider neighbours the same when a cell has been changed within this timeframe
	if (next_cells[as_cell] != current_cells[as_cell] if as_cell in next_cells else false):
		return false
	for neighbor_cell:Vector2i in neighbor_cells:
		# rock is wildcar
		if current_cells.get(neighbor_cell, -1) == Elements.ELEMENT.BEDROCK:
			continue
		# we use get because neighbor_cell may not be in current cells
		if current_cells.get(neighbor_cell, -1) != current_cells[as_cell]:
			return false
	return true

func _calculate_next_generation() -> void:
	var shuffled_cells:Array = current_cells.keys()
	shuffled_cells.shuffle()
	for cell: Vector2i in shuffled_cells:

		# still cells optimization
		# TODO make sure everything is needed in all the dictionaries...
		# check to_be_deleted mechanic
		# Don't process still-life cells
		if cell in still_cells:
			continue

		var neighbor_cells: Array[Vector2i] = _obtain_all_cell_neighbors(cell)
		if _are_neighbors_of_same_type(cell, neighbor_cells):
			still_cells[cell] = null
			continue

		var cell_material: Elements.ELEMENT = current_cells[cell]
		var cell_info: element_template = Elements.ELEMENT_TO_TEMPLATE[cell_material]
		var cell_type: Elements.STATE_OF_MATTER = cell_info.state_of_matter

		# Handle drain
		if cell_info.is_drainage:
			var top_cell:Vector2i = neighbor_cells[TOP]

			if _get_element(top_cell) == cell_info.drains:
				set_next_cell(top_cell, Elements.ELEMENT.AIR)
			continue

		# Handle generation
		if cell_info.is_generator:
			var bottom_cell:Vector2i = neighbor_cells[BOTTOM]
			if _is_position_available(bottom_cell):
				set_next_cell(bottom_cell, cell_info.generates)
			continue

		# Handle decay
		if cell_info.decay_chance > 0.0 and randf() < cell_info.decay_chance:
			set_next_cell(cell, cell_info.decay_into)
			continue

		# Handle hot
		if cell_info.is_hot:
			for burn_target: Vector2i in neighbor_cells:
				if current_cells.has(burn_target):
					var burn_material: Elements.ELEMENT = current_cells[burn_target]
					var burn_info: element_template = Elements.ELEMENT_TO_TEMPLATE[burn_material]
					if burn_info.burn_chance > 0.0 and randf() < burn_info.burn_chance:
						set_next_cell(burn_target, burn_info.burn_into)

		# Ignore solids
		if cell_type == Elements.STATE_OF_MATTER.SOLID:
			still_cells[cell] = null
			continue

		# Handle viscosity
		if cell_info.viscosity > 0.0 and randf() < cell_info.viscosity:
			continue

		var cell_weight: int = cell_info.weight
		var direction: int = signi(cell_weight)
		var straight_cell: Vector2i = Vector2i(cell.x, cell.y + direction)

		# Handle the movements
		# if target position is air, just swap them
		if _is_position_available(straight_cell):
			_swap_cells(straight_cell, cell)
		else:
			var oc_material: Elements.ELEMENT = _get_element(straight_cell)
			var oc_info: element_template = Elements.ELEMENT_TO_TEMPLATE[oc_material]
			var oc_weight: int = oc_info.weight

			# if cell is heavier than the occupied cell and the other is not solid
			# swap
			if oc_weight < cell_weight and oc_info.state_of_matter != Elements.STATE_OF_MATTER.SOLID:
				_swap_cells(cell, straight_cell)
			else:
				var candidate_cells: Array[Vector2i] = []
				match cell_type:
					Elements.STATE_OF_MATTER.GRAIN:
						candidate_cells.append(neighbor_cells[BOTTOM_LEFT])
						candidate_cells.append(neighbor_cells[BOTTOM_RIGHT])
					Elements.STATE_OF_MATTER.GAS:
						candidate_cells.append(neighbor_cells[TOP_LEFT])
						candidate_cells.append(neighbor_cells[TOP_RIGHT])
					Elements.STATE_OF_MATTER.LIQUID:
						# increate water diagonal flow chance :-)
						candidate_cells.append(neighbor_cells[BOTTOM_LEFT])
						candidate_cells.append(neighbor_cells[BOTTOM_RIGHT])
						candidate_cells.append(neighbor_cells[BOTTOM_LEFT])
						candidate_cells.append(neighbor_cells[BOTTOM_RIGHT])
						candidate_cells.append(neighbor_cells[BOTTOM_LEFT])
						candidate_cells.append(neighbor_cells[BOTTOM_RIGHT])
						candidate_cells.append(neighbor_cells[LEFT])
						candidate_cells.append(neighbor_cells[RIGHT])
					_:
						continue

				var available_cells: Array[Vector2i] = []
				for candidate:Vector2i in candidate_cells:
					var candiate_material: Elements.ELEMENT = _get_element(candidate)
					var candiate_cell_info: element_template = Elements.ELEMENT_TO_TEMPLATE[candiate_material]
					if _is_position_candidate(candidate, candiate_cell_info.weight, cell_weight, candiate_cell_info.state_of_matter):
						available_cells.append(candidate)

				if available_cells.size() > 0:
					var target_cell: Vector2i = available_cells.pick_random()
					_swap_cells(cell, target_cell)

func _get_element(position: Vector2i) -> Elements.ELEMENT:
	return current_cells.get(position,Elements.ELEMENT.AIR)

func _set_cell(position: Vector2i, new_material: Elements.ELEMENT) -> void:
	current_cells[position] = new_material

func set_next_cell(position: Vector2i, new_material: Elements.ELEMENT) -> void:
	if new_material == Elements.ELEMENT.AIR:
		to_be_deleted[position] = null

	next_cells[position] = new_material

	# remove neigh from still
	for alive_cell:Vector2i in _obtain_all_cell_neighbors(position):
		# rocks remain still-life
		if current_cells.get(alive_cell, -1) == Elements.ELEMENT.BEDROCK:
			continue
		still_cells.erase(alive_cell)
	still_cells.erase(position)

func set_placed_cell(position: Vector2i, new_material: Elements.ELEMENT) -> void:
	placed_cells[position] = new_material

	# air needs to be deleted from current cells
	if new_material == Elements.ELEMENT.AIR:
		to_be_deleted[position] = null

func _swap_cells(position_a: Vector2i, position_b: Vector2i) -> void:
	if not _is_position_modified(position_a) and not _is_position_modified(position_b):
		var mat_a: Elements.ELEMENT = _get_element(position_a)
		var mat_b: Elements.ELEMENT = _get_element(position_b)
		set_next_cell(position_a, mat_b)
		set_next_cell(position_b, mat_a)

func _is_position_candidate(where: Vector2i, target_weight: int, my_weight: int, target_state:Elements.STATE_OF_MATTER) -> bool:
	return _is_position_available(where) or \
	 (target_weight < my_weight and target_state != Elements.STATE_OF_MATTER.SOLID)


func _is_position_available(at_position: Vector2i) -> bool:
	return not _is_position_modified(at_position) and _get_element(at_position) == Elements.ELEMENT.AIR

func _is_position_modified(at_position: Vector2i) -> bool:
	return next_cells.has(at_position)

func _update_next_cells_with_placed() -> void:
	for cell: Vector2i in placed_cells:
		next_cells[cell] = placed_cells[cell]
		if cell in still_cells:
			still_cells.erase(cell)
	placed_cells.clear()

func _update_current_cells_with_next_cells() -> void:
	for cell: Vector2i in next_cells:
		current_cells[cell] = next_cells[cell]

func _remove_air_from_current() -> void:
	for cell: Vector2i in to_be_deleted:
		if cell in current_cells:
			current_cells.erase(cell)
	to_be_deleted.clear()

func _clear_current_cells() -> void:
	current_cells.clear()

func _clear_next_cells() -> void:
	next_cells.clear()
