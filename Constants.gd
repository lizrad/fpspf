extends Node

# Player constants
var max_health := 3

export(Array, Color) var character_colors = [
	Color(1.0, 0.0, 0.0), # Player 1
	Color(0.0, 0.0, 1.0), # Player 2
	Color(0.0, 0.0, 1.0), # Player 3
	Color(0.0, 0.0, 1.0), # Player 4
	Color("#fd9292"), # Ghost 1
	Color("#9a9bff"), # Ghost 2
	Color("#9a9bff"), # Ghost 3
	Color("#9a9bff"), # Ghost 4
	Color(0.2, 0.6, 0.2), # Ghosts
]

enum CharacterID {
	PLAYER_1 = 0,
	PLAYER_2 = 1,
	PLAYER_3 = 2,
	PLAYER_4 = 3,
	GHOST = 4
}

const PLAYER_GENERAL = 1

export var move_acceleration:= 0.8
export var move_drag := 0.2

export var dash_impulse := 5.0
export var dash_exponent := 0.1

export var view_distance := 20.0
export var view_angle := 30.0
export var circular_view_radius := 3.0
export var player_camera_height := 40.0

var ranged_attack_type := preload("res://Attacking/Shots/HitscanShot/hitscan_shot_instant_burst.tres")
var melee_attack_type := preload("res://Attacking/Melee/melee_instant.tres")

