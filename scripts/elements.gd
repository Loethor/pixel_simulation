extends Resource
class_name Element

enum ELEMENT{
	AIR,
	SAND,
	WATER,
	ICE,
	BEDROCK,
	OIL,
	FIRE,
	STEAM,
	SMOKE,
	FUSE,
	BURNING_FUSE,
	BURNED_FUSE,
	WATER_GENERATOR,
	WATER_DRAIN,
	METHANE,
	HONEY,
}
const ATLAS_COORD_TO_ELEMENT: Dictionary = {
	Vector2i(-1,-1):ELEMENT.AIR,
	Vector2i(0,0):ELEMENT.SAND,
	Vector2i(1,0):ELEMENT.WATER,
	Vector2i(1,2):ELEMENT.ICE,
	Vector2i(4,0):ELEMENT.BEDROCK,
	Vector2i(3,0):ELEMENT.OIL,
	Vector2i(2,0):ELEMENT.FIRE,
	Vector2i(1,1):ELEMENT.STEAM,
	Vector2i(2,1):ELEMENT.SMOKE,
	Vector2i(5,0):ELEMENT.FUSE,
	Vector2i(5,1):ELEMENT.BURNING_FUSE,
	Vector2i(5,2):ELEMENT.BURNED_FUSE,
	Vector2i(6,0):ELEMENT.WATER_GENERATOR,
	Vector2i(6,1):ELEMENT.WATER_DRAIN,
	Vector2i(7,0):ELEMENT.METHANE,
	Vector2i(8,0):ELEMENT.HONEY,
}
const ELEMENT_TO_ATLAS_COORD:Dictionary = {
	ELEMENT.AIR:Vector2i(-1,-1),
	ELEMENT.SAND:Vector2i(0,0),
	ELEMENT.WATER:Vector2i(1,0),
	ELEMENT.ICE:Vector2i(1,2),
	ELEMENT.BEDROCK:Vector2i(4,0),
	ELEMENT.OIL:Vector2i(3,0),
	ELEMENT.FIRE:Vector2i(2,0),
	ELEMENT.STEAM:Vector2i(1,1),
	ELEMENT.SMOKE:Vector2i(2,1),
	ELEMENT.FUSE:Vector2i(5,0),
	ELEMENT.BURNING_FUSE:Vector2i(5,1),
	ELEMENT.BURNED_FUSE:Vector2i(5,2),
	ELEMENT.WATER_GENERATOR:Vector2i(6,0),
	ELEMENT.WATER_DRAIN:Vector2i(6,1),
	ELEMENT.METHANE:Vector2i(7,0),
	ELEMENT.HONEY:Vector2i(8,0),
}

const ELEMENT_TO_TEMPLATE:Dictionary = {
	ELEMENT.WATER:preload("res://resources/elements/water.tres"),
}

const ELEMENT_INFO: Dictionary = {
	ELEMENT.AIR:{"name":"Eraser", "weight":0,"state":SOM.SOLID, "decay_chance":0.0, "hot": false, "burn_chance": 0.0},
	ELEMENT.SAND:{"name":"Sand", "weight":4,"state":SOM.GRAIN, "decay_chance":0.0, "hot": false, "burn_chance": 0.0},
	ELEMENT.WATER:{"name":"Water", "weight":2,"state":SOM.LIQUID, "decay_chance":0.0, "hot": false, "burn_chance": 0.5, "burn_into": ELEMENT.STEAM, "viscosity":0.0},
	ELEMENT.ICE:{"name":"Ice", "weight":0,"state":SOM.SOLID, "decay_chance":0.0, "hot": false, "burn_chance": 0.5, "burn_into": ELEMENT.WATER},
	ELEMENT.OIL:{"name":"Oil", "weight":1,"state":SOM.LIQUID, "decay_chance":0.0, "hot": false, "burn_chance": 1.0, "burn_into": ELEMENT.FIRE, "viscosity":0.3},
	ELEMENT.BEDROCK:{"name":"Bedrock", "weight":0,"state":SOM.SOLID, "decay_chance":0.0, "hot": false, "burn_chance": 0.0},
	ELEMENT.FIRE:{"name":"Fire", "weight":-3,"state":SOM.GAS, "decay_chance":0.3, "decay_into": ELEMENT.SMOKE, "hot": true, "burn_chance": 0.0},
	ELEMENT.STEAM:{"name":"Steam", "weight":-2,"state":SOM.GAS, "decay_chance":0.05, "decay_into": ELEMENT.WATER, "hot": false, "burn_chance": 0.0},
	ELEMENT.SMOKE:{"name":"Smoke", "weight":-1,"state":SOM.GAS, "decay_chance":0.2, "decay_into": ELEMENT.AIR, "hot": false, "burn_chance": 0.1, "burn_into": ELEMENT.AIR},
	ELEMENT.FUSE:{"name":"Fuse", "weight":0,"state":SOM.SOLID, "decay_chance":0.0,"hot": false, "burn_chance": 1.0, "burn_into": ELEMENT.BURNING_FUSE},
	ELEMENT.BURNING_FUSE:{"name":"Burning Fuse", "weight":0,"state":SOM.SOLID, "decay_chance":0.0, "hot": true, "burn_chance": 1.0, "burn_into": ELEMENT.BURNED_FUSE},
	ELEMENT.BURNED_FUSE:{"name":"Burned Fuse", "weight":0,"state":SOM.SOLID, "decay_chance":0.0,"hot": false, "burn_chance": 0.0},
	ELEMENT.WATER_GENERATOR:{"name":"Water Generator", "weight":0,"state":SOM.SOLID, "decay_chance":0.0,"hot": false, "burn_chance": 0.0, "generates": ELEMENT.WATER},
	ELEMENT.WATER_DRAIN:{"name":"Water Drain", "weight":0,"state":SOM.SOLID, "decay_chance":0.0, "hot": false, "burn_chance": 0.0, "drains": ELEMENT.WATER},
	ELEMENT.METHANE:{"name":"Methane", "weight":-3,"state":SOM.GAS, "decay_chance":0.0,"hot": false, "burn_chance": 1.0,"burn_into": ELEMENT.FIRE},
	ELEMENT.HONEY:{"name":"Honey", "weight":3,"state":SOM.LIQUID, "decay_chance":0.0,"hot": false, "burn_chance": 0.0, "viscosity":0.8},
}
enum SOM {GRAIN, LIQUID, SOLID, GAS}
