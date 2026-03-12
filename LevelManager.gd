extends Node2D

# 3 planet options from a list

# selecting planet

# loading planet and moddifiers

# create a level sequnce timeline

# add astroids and enemys to timeline

# disable enemys and astroids spawn in boss

# overlay shop with stats mods and health
var planetgenerator : Node2D
var roundtimer : Timer

signal planet_selection(planetA, planetB, planetC)

func _ready():

	planetgenerator = $PlanetGenerator
	roundtimer = $"Round Time"

func DisplayPlanets():
	# Display 3 boxes with a picture of a planet and a name and below is random planet modifier pulled from a list
	# get 3 random planett name and pictures from a list
	# pick a random modifer and and random multiplier to the modifier each modifer has a value equal to how good it is
	# balance the modifers so that they are equal to 0
	# the first planet should have the least amount of modifers and the last planet should have the most amount of modifers
	Global.planetA = planetgenerator.genPlanet(randi_range(0,1), 1)
	Global.planetB = planetgenerator.genPlanet(2, 3)
	Global.planetC = planetgenerator.genPlanet(3, 5)
	emit_signal("planet_selection", Global.planetA, Global.planetB, Global.planetC)

func _on_round_time_timeout():
	# Pause the game
	get_tree().paused = true
	# Show the planet selection UI
	DisplayPlanets()

func GenerateEnemy(modifiers):
	# Generate an enemy based on the modifiers and return the packed scene modified
	var enemy_scene : PackedScene = preload("res://Scenes/Enemy.tscn")
	var enemy = enemy_scene.instantiate()
	# Apply modifiers to the enemy
	for mod in modifiers:
		if mod["effect"] == "enemy":
			# TODO
			pass
	add_child(enemy)

func GenerateLevel(modifiers):
	# Start the round timer
	roundtimer.start()
	# Unpause the game
	get_tree().paused = false
	# Hide the planet selection UI
	get_node("/root/Main/Control/Planet Board").visible = false
	# Create a variable that holds at what time what happens
	var timeline = []
	# Pick a round length between 3 and 6 minutes
	var round_length = randi_range(180, 360)
	# if there are event types in the modifiers then add to a random segment then add them to the timeline
	for mod in modifiers:
		if mod["effect"] == "event":
			timeline.append({"time": randi_range(10, round_length - 10), "event": mod.name + ":" + str(round(mod.multiplier))})
	# Then fill the rest of the timeline with enemy spawns n amount based on the diff
	var enemy_count = int(Global.diff * 5)
	for i in range(enemy_count):
		timeline.append({"time": randi_range(10, round_length - 10), "enemy": GenerateEnemy(modifiers)})
	# Sort the timeline by time
	timeline.sort_custom(func(a, b): return a["time"] < b["time"])
	# Now create a timer that goes off at the time of the first event and then when it goes off it does the event and sets the timer to the next event
	print(timeline)

func _on_margin_container_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		GenerateLevel(Global.planetA["modifiers"])

func _on_margin_container_2_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		GenerateLevel(Global.planetB["modifiers"])

func _on_margin_container_3_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		GenerateLevel(Global.planetC["modifiers"])
		print(Global.planetC["modifiers"])
