extends Resource
class_name element_template

@export var tile_map_atlas_coords:Vector2i
@export var element_type:Element.ELEMENT
@export var atlas :AtlasTexture

@export_group("Properties")
@export var name:String
@export var weight:int
@export var state_of_matter:Element.SOM
@export var decay_chance:float
@export var decay_into:Element.ELEMENT
@export var viscosity:float
@export var is_generator:bool
@export_subgroup("Generator properties")
@export var generates:Element.ELEMENT
@export_subgroup("")
@export var is_drain:bool
@export_subgroup("Drain properties")
@export var drains:Element.ELEMENT
@export_subgroup("Hot properties")
@export var is_hot:bool
@export var burn_chance:float
@export var burn_into:Element.ELEMENT
@export_group("")
