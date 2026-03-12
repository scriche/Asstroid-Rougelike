extends Control

var scrap
var lives
var timer
var diffdisplay
var planetboard
var planetdisplay1
var planetdisplay2
var planetdisplay3
var levelmanager : Node2D

func _ready():
	scrap = $GridContainer/Scrap
	lives = $GridContainer/Lives
	timer = $Time
	levelmanager = get_node("/root/Main/World/LevelManager")
	diffdisplay = $Diff
	planetboard = $"Planet Board"
	planetdisplay1 = $"Planet Board/Panel/HBoxContainer/MarginContainer"
	planetdisplay2 = $"Planet Board/Panel/HBoxContainer/MarginContainer2"
	planetdisplay3 = $"Planet Board/Panel/HBoxContainer/MarginContainer3"

func _process(_delta):
	scrap.text = "" + str(Global.scrap)
	lives.text = "" + str(Global.lives)
	var time = Time.get_ticks_msec() / 1000
	var time_string = "%02d:%02d:%02d" % [(time / 3600), (time % 3600) / 60, (time % 60)]
	timer.text = time_string
	diffdisplay.text = "%.2f" % Global.diff

func _format_modifiers(modifiers: Array) -> String:
	# Format the modifiers into a string
	var formatted = ""
	for mod in modifiers:
		if mod["value"] > 0:
			formatted += "[color=green]+%s %.2f[/color]\n" % [mod["name"], mod["impact"]]
		else:
			formatted += "[color=red]%s %.2f[/color]\n" % [mod["name"], mod["impact"]]
	return formatted.strip_edges()

func _on_level_manager_planet_selection(planetA:Variant, planetB:Variant, planetC:Variant):

	planetboard.visible = true

	# Update the planet displays with the selected planets
	planetdisplay1.get_node("Image").texture = load(planetA["image"])
	planetdisplay1.get_node("Name").text = planetA["name"]
	planetdisplay1.get_node("Modifiers").text = _format_modifiers(planetA["modifiers"])

	planetdisplay2.get_node("Image").texture = load(planetB["image"])
	planetdisplay2.get_node("Name").text = planetB["name"]
	planetdisplay2.get_node("Modifiers").text = _format_modifiers(planetB["modifiers"])

	planetdisplay3.get_node("Image").texture = load(planetC["image"])
	planetdisplay3.get_node("Name").text = planetC["name"]
	planetdisplay3.get_node("Modifiers").text = _format_modifiers(planetC["modifiers"])