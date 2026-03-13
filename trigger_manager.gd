extends Node

func on_bullet_hit(bullet: Area2D, target: Area2D) -> void:
	# Check for bullet hit triggers
	for upgrade in Stats.upgrades:
		if "on_bullet_hit" in upgrade.trigger_ability:
			upgrade.trigger_ability["on_bullet_hit"].call(bullet, target)
