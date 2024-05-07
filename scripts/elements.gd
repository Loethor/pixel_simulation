extends Resource
class_name Element

enum ELEMENT{AIR, SAND, WATER, BEDROCK, OIL, FIRE}
const ATLAS_COORD_TO_ELEMENT: Dictionary = {
	Vector2i(-1,-1):ELEMENT.AIR,
	Vector2i(0,0):ELEMENT.SAND,
	Vector2i(0,1):ELEMENT.WATER,
	Vector2i(0,2):ELEMENT.BEDROCK,
	Vector2i(0,3):ELEMENT.OIL,
	Vector2i(0,4):ELEMENT.FIRE,
}
const ELEMENT_TO_ATLAS_COORD:Dictionary = {
	ELEMENT.AIR:Vector2i(-1,-1),
	ELEMENT.SAND:Vector2i(0,0),
	ELEMENT.WATER:Vector2i(0,1),
	ELEMENT.BEDROCK:Vector2i(0,2),
	ELEMENT.OIL:Vector2i(0,3),
	ELEMENT.FIRE:Vector2i(0,4),
}

const ELEMENT_INFO: Dictionary = {
	ELEMENT.AIR:{"weight":0,"state":SOM.SOLID, "decay_chance":0.0},
	ELEMENT.SAND:{"weight":3,"state":SOM.GRAIN, "decay_chance":0.0},
	ELEMENT.WATER:{"weight":2,"state":SOM.LIQUID, "decay_chance":0.0},
	ELEMENT.OIL:{"weight":1,"state":SOM.LIQUID, "decay_chance":0.0},
	ELEMENT.BEDROCK:{"weight":0,"state":SOM.SOLID, "decay_chance":0.0},
	ELEMENT.FIRE:{"weight":-1,"state":SOM.LIQUID, "decay_chance":0.3},
}
enum SOM {GRAIN, LIQUID, SOLID}
