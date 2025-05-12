## Global
extends Node

static var bootsplash_path: PackedScene = preload("res://ui/menus/boot/bootsplash_scene.tscn")
static var menu_path: PackedScene = preload("res://ui/menus/main_menu_scene.tscn")
static var game_path: PackedScene = load("res://scenes/ingame_scene.tscn")
static var settings_path: PackedScene = load("res://ui/menus/game_settings_scene.tscn")

var world: World
var fade_overlay: FadeOverlay
var pause_overlay: PauseOverlay
