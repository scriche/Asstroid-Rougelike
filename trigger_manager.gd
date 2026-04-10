extends Node

func on_bullet_hit(bullet, target):
	notify_upgrades("on_bullet_hit", {bullet = bullet, target = target})

func on_bullet_fired(bullet):
	notify_upgrades("on_bullet_fired", {bullet = bullet})

func on_damage_dealt(target, damage):
	notify_upgrades("on_damage_dealt", {target = target, damage = damage})

func on_damage_recv(player, damage, target):
	notify_upgrades("on_damage_recv", {player = player, target = target, damage = damage})

func on_health_regen(player):
	notify_upgrades("on_health_regen", {player = player})

## Central function to notify upgrades of an event
func notify_upgrades(trigger_name: String, params: Dictionary = {}):
	for upgrade in Stats.get_upgrades():
		if upgrade.trigger == trigger_name:
			upgrade.trigger_effect(params)
