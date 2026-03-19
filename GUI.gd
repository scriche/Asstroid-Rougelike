extends Control

var scrap: RichTextLabel
var lives: RichTextLabel
var roundtime: Timer
var diffdisplay: RichTextLabel
var rounddisplay: RichTextLabel
var levelmanager : Node2D
var timer: RichTextLabel
var expdisplay: TextureProgressBar
var bosshealthbar: TextureProgressBar

func _ready():
	scrap = $HBoxContainer/GridContainer/Scrap
	lives = $HBoxContainer/GridContainer/Lives
	diffdisplay = $HBoxContainer/Diff
	rounddisplay = $HBoxContainer/HBoxContainer/RoundCompletion
	timer = $HBoxContainer/Time
	bosshealthbar = $BossHealthbar
	levelmanager = get_node("/root/Main/World/LevelManager")
	expdisplay = $ExpBar
	roundtime = levelmanager.get_child(0)

func _process(_delta):
	scrap.text = "" + str(Global.scrap)
	lives.text = "" + str(Global.lives)
	var time = Time.get_ticks_msec() / 1000
	var time_string = "%02d:%02d:%02d" % [(time / 3600), (time % 3600) / 60, (time % 60)]
	timer.text = time_string
	diffdisplay.text = "%.2f" % Global.diff
	rounddisplay.text = str(int((1 - (roundtime.time_left / roundtime.wait_time)) * 100))+"%"
	expdisplay.value = Global.experience
	bosshealthbar.value = Global.boss_health
	if expdisplay.value >= expdisplay.max_value:
		Global.experience = 0
		expdisplay.max_value *= 1.2
		$Upgradepopup.show()
		$Upgradepopup.popup()
