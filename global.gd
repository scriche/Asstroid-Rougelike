extends Node

var scrap : int = 0
var lives : int = 1
var diff : float = 1.0
var viewpos : Vector2 = Vector2.ZERO
var viewend : Vector2 = Vector2.ZERO
var playerpos : Vector2 = Vector2.ZERO
var planetA
var planetB
var planetC


func _process(_delta):
	diff = 1 + Time.get_ticks_msec()/1000.0/600.0
	viewpos = get_viewport().get_visible_rect().position
	viewend = get_viewport().get_visible_rect().end
