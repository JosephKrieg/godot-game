extends Area2D

signal spikedup
onready var player = get_node("../../Player")

func _ready():
	pass
	

func _on_decaying():
	queue_free()


func _on_decaytimer_timeout():
	queue_free()


func _on_spike_area_entered(area):
	if area.name == "Area2D":
		connect("spikedup", player, "_on_spike_hit")
		emit_signal("spikedup")
