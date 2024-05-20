extends Resource
class_name State


var current_cells: Dictionary = {}  # Vector2i => Element.ELEMENT
var next_cells: Dictionary = {}  # Vector2i => Element.ELEMENT

const MAIN_LAYER:int = 0

func _init(tm: TileMap) -> void:
	_update_cells_from_tilemap(tm)

func update(tile_map:TileMap) -> void:
	_update_cells_from_tilemap(tile_map)
	_calculate_next_generation()
	_apply_modifications()
	_clear_next_cells()

func _update_cells_from_tilemap(tile_map:TileMap) -> void:
	_clear_current_cells()
	for tile:Vector2i in tile_map.get_used_cells(MAIN_LAYER):
		var tile_material: Elements.ELEMENT = Elements.ATLAS_COORD_TO_ELEMENT[tile_map.get_cell_atlas_coords(MAIN_LAYER, tile)]
		_set_cell(tile, tile_material)

func _clear_current_cells() -> void:
	current_cells.clear()

func _clear_next_cells() -> void:
	next_cells.clear()

func _calculate_next_generation() -> void:

	for cell: Vector2i in current_cells:
		var cell_material: Elements.ELEMENT = current_cells[cell]
		var cell_info: element_template = Elements.ELEMENT_TO_TEMPLATE[cell_material]
		var cell_type: Elements.STATE_OF_MATTER = cell_info.state_of_matter

		# Handle drain
		if cell_info.is_drainage:
			var down:Vector2i = cell + Vector2i(0, 1)
			var up:Vector2i = cell + Vector2i(0, -1)
			var left:Vector2i = cell + Vector2i(-1, 0)
			var right:Vector2i = cell + Vector2i(1, 0)
			# Can be extended
			for pos:Vector2i in [down, up, left, right]:
				if _get_element(pos) == cell_info.drains:
					set_next_cell(pos, Elements.ELEMENT.AIR)
			continue

		# Handle generation
		if cell_info.is_generator:
			var down:Vector2i = cell + Vector2i(0, 1)
			# Can be extended
			for pos:Vector2i in [down]:
				if _is_position_available(pos):
					set_next_cell(pos, cell_info.generates)
			continue

		# Handle decay
		if cell_info.decay_chance > 0.0 and randf() < cell_info.decay_chance:
			set_next_cell(cell, cell_info.decay_into)
			continue

		# Handle hot
		if cell_info.is_hot:
			for dx: int in range(-1, 2, 1):
				for dy: int in range(-1, 2, 1):
					var burn_target: Vector2i = cell + Vector2i(dx, dy)

					if current_cells.has(burn_target):
						var burn_material: Elements.ELEMENT = current_cells[burn_target]
						var burn_info: element_template = Elements.ELEMENT_TO_TEMPLATE[burn_material]
						if burn_info.burn_chance > 0.0 and randf() < burn_info.burn_chance:
							set_next_cell(burn_target, burn_info.burn_into)

		# Ignore solids
		if cell_type == Elements.STATE_OF_MATTER.SOLID:
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
				# directional modifier if the cell is grain type
				var grain_modifier: int = direction if cell_type == Elements.STATE_OF_MATTER.GRAIN else 0

				var left_cell: Vector2i = Vector2i(cell.x - 1, cell.y + grain_modifier)
				var left_cell_material: Elements.ELEMENT = _get_element(left_cell)
				var left_cell_info: element_template = Elements.ELEMENT_TO_TEMPLATE[left_cell_material]

				var right_cell: Vector2i = Vector2i(cell.x + 1, cell.y + grain_modifier)
				var right_cell_material: Elements.ELEMENT = _get_element(right_cell)
				var right_cell_info: element_template = Elements.ELEMENT_TO_TEMPLATE[right_cell_material]

				var available_cells: Array[Vector2i] = []
				if _is_position_available(left_cell) or (left_cell_info.weight < cell_weight and left_cell_info.state_of_matter != Elements.STATE_OF_MATTER.SOLID):
					available_cells.append(left_cell)
				if _is_position_available(right_cell) or (right_cell_info.weight < cell_weight and right_cell_info.state_of_matter != Elements.STATE_OF_MATTER.SOLID):
					available_cells.append(right_cell)

				if available_cells.size() > 0:
					var target_cell: Vector2i = available_cells.pick_random()
					_swap_cells(cell, target_cell)

func _get_element(position: Vector2i) -> Elements.ELEMENT:
	return current_cells[position] if current_cells.has(position) else Elements.ELEMENT.AIR

func _set_cell(position: Vector2i, new_material: Elements.ELEMENT) -> void:
	current_cells[position] = new_material

func set_next_cell(position: Vector2i, new_material: Elements.ELEMENT) -> void:
	next_cells[position] = new_material

func _swap_cells(position_a: Vector2i, position_b: Vector2i) -> void:
	if not _is_position_modified(position_a) and not _is_position_modified(position_b):
		var mat_a: Elements.ELEMENT = _get_element(position_a)
		var mat_b: Elements.ELEMENT = _get_element(position_b)
		set_next_cell(position_a, mat_b)
		set_next_cell(position_b, mat_a)

func _is_position_available(at_position: Vector2i) -> bool:
	return _get_element(at_position) == Elements.ELEMENT.AIR and not _is_position_modified(at_position)

func _is_position_modified(at_position: Vector2i) -> bool:
	return next_cells.has(at_position)

func _apply_modifications() -> void:
	for changed_position: Vector2i in next_cells:
		current_cells[changed_position] = next_cells[changed_position]
