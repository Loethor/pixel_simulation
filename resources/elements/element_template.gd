extends Resource
class_name element_template


@export_group("Element Properties")
@export_subgroup("Main Properties")
@export var element_type:Elements.ELEMENT
@export var tile_map_atlas_coords:Vector2i
@export var name:String
@export var weight:int
@export var state_of_matter:Elements.STATE_OF_MATTER
@export var viscosity:float
@export_subgroup("Decay properties")
@export var decay_chance:float
@export var decay_into:Elements.ELEMENT
@export_subgroup("Generator properties")
@export var is_generator:bool
@export var generates:Elements.ELEMENT
@export_subgroup("")
@export_subgroup("Drain properties")
@export var is_drainage:bool
@export var drains:Elements.ELEMENT
@export_subgroup("Temperature properties")
@export var is_hot:bool
@export var burn_chance:float
@export var burn_into:Elements.ELEMENT
@export_subgroup("Texture")
@export var atlas :AtlasTexture
@export_group("")

