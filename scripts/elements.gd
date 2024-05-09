extends Resource
class_name Element

enum ELEMENT{
	AIR,
	SAND,
	WATER,
	BEDROCK,
	OIL,
	FIRE,
	STEAM,
	SMOKE,
	FUSE,
	BURNING_FUSE,
	BURNED_FUSE,
}
const ATLAS_COORD_TO_ELEMENT: Dictionary = {
	Vector2i(-1,-1):ELEMENT.AIR,
	Vector2i(0,0):ELEMENT.SAND,
	Vector2i(1,0):ELEMENT.WATER,
	Vector2i(4,0):ELEMENT.BEDROCK,
	Vector2i(3,0):ELEMENT.OIL,
	Vector2i(2,0):ELEMENT.FIRE,
	Vector2i(1,1):ELEMENT.STEAM,
	Vector2i(2,1):ELEMENT.SMOKE,
	Vector2i(5,0):ELEMENT.FUSE,
	Vector2i(5,1):ELEMENT.BURNING_FUSE,
	Vector2i(5,2):ELEMENT.BURNED_FUSE,
}
const ELEMENT_TO_ATLAS_COORD:Dictionary = {
	ELEMENT.AIR:Vector2i(-1,-1),
	ELEMENT.SAND:Vector2i(0,0),
	ELEMENT.WATER:Vector2i(1,0),
	ELEMENT.BEDROCK:Vector2i(4,0),
	ELEMENT.OIL:Vector2i(3,0),
	ELEMENT.FIRE:Vector2i(2,0),
	ELEMENT.STEAM:Vector2i(1,1),
	ELEMENT.SMOKE:Vector2i(2,1),
	ELEMENT.FUSE:Vector2i(5,0),
	ELEMENT.BURNING_FUSE:Vector2i(5,1),
	ELEMENT.BURNED_FUSE:Vector2i(5,2),
}

const ELEMENT_INFO: Dictionary = {
	ELEMENT.AIR:{"weight":0,"state":SOM.SOLID, "decay_chance":0.0, "hot": false, "burn_chance": 0.0},
	ELEMENT.SAND:{"weight":3,"state":SOM.GRAIN, "decay_chance":0.0, "hot": false, "burn_chance": 0.0},
	ELEMENT.WATER:{"weight":2,"state":SOM.LIQUID, "decay_chance":0.0, "hot": false, "burn_chance": 0.5, "burn_into": ELEMENT.STEAM},
	ELEMENT.OIL:{"weight":1,"state":SOM.LIQUID, "decay_chance":0.0, "hot": false, "burn_chance": 1.0, "burn_into": ELEMENT.FIRE},
	ELEMENT.BEDROCK:{"weight":0,"state":SOM.SOLID, "decay_chance":0.0, "hot": false, "burn_chance": 0.0},
	ELEMENT.FIRE:{"weight":-3,"state":SOM.LIQUID, "decay_chance":0.3, "decay_into": ELEMENT.SMOKE, "hot": true, "burn_chance": 0.0},
	ELEMENT.STEAM:{"weight":-2,"state":SOM.LIQUID, "decay_chance":0.05, "decay_into": ELEMENT.WATER, "hot": false, "burn_chance": 0.0},
	ELEMENT.SMOKE:{"weight":-1,"state":SOM.LIQUID, "decay_chance":0.2, "decay_into": ELEMENT.AIR, "hot": false, "burn_chance": 0.1, "burn_into": ELEMENT.AIR},
	ELEMENT.FUSE:{"weight":0,"state":SOM.SOLID, "decay_chance":0.0, "decay_into": ELEMENT.AIR, "hot": false, "burn_chance": 1.0, "burn_into": ELEMENT.BURNING_FUSE},
	ELEMENT.BURNING_FUSE:{"weight":0,"state":SOM.SOLID, "decay_chance":0.0, "decay_into": ELEMENT.AIR, "hot": true, "burn_chance": 1.0, "burn_into": ELEMENT.BURNED_FUSE},
	ELEMENT.BURNED_FUSE:{"weight":0,"state":SOM.SOLID, "decay_chance":0.0, "decay_into": ELEMENT.AIR, "hot": false, "burn_chance": 0.0},
}
enum SOM {GRAIN, LIQUID, SOLID}
