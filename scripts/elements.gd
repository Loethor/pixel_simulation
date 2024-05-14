extends Node

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

@onready var ELEMENT_TO_TEMPLATE:Dictionary = {
	ELEMENT.AIR:preload("res://resources/elements/air.tres"),
	ELEMENT.SAND:preload("res://resources/elements/sand.tres"),
	ELEMENT.WATER:preload("res://resources/elements/water.tres"),
	ELEMENT.ICE:preload("res://resources/elements/ice.tres"),
	ELEMENT.BEDROCK:preload("res://resources/elements/bedrock.tres"),
	ELEMENT.OIL:preload("res://resources/elements/oil.tres"),
	ELEMENT.FIRE:preload("res://resources/elements/fire.tres"),
	ELEMENT.STEAM:preload("res://resources/elements/steam.tres"),
	ELEMENT.SMOKE:preload("res://resources/elements/smoke.tres"),
	ELEMENT.FUSE:preload("res://resources/elements/fuse.tres"),
	ELEMENT.BURNING_FUSE:preload("res://resources/elements/burning_fuse.tres"),
	ELEMENT.BURNED_FUSE:preload("res://resources/elements/burned_fuse.tres"),
	ELEMENT.WATER_GENERATOR:preload("res://resources/elements/water_generator.tres"),
	ELEMENT.WATER_DRAIN:preload("res://resources/elements/water_drain.tres"),
	ELEMENT.METHANE:preload("res://resources/elements/methane.tres"),
	ELEMENT.HONEY:preload("res://resources/elements/honey.tres"),
}

enum STATE_OF_MATTER {GRAIN, LIQUID, SOLID, GAS}
