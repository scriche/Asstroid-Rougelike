extends Node

func on_bullet_hit(bullet: Area2D, target: Area2D) -> void:
	# Check for bullet hit triggers
	for upgrade in Stats.upgrades:
		if upgrade.trigger == "on_bullet_hit":
			upgrade.trigger_ability.call(bullet, target)

func on_bullet_fired(bullet: Area2D) -> void:
	# Check for bullet fired triggers
	for upgrade in Stats.upgrades:
		if upgrade.trigger == "on_bullet_fired":
			upgrade.trigger_ability.call(bullet)
