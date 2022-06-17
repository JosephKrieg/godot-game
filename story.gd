extends CanvasLayer

var starting = false

func _ready():
	pass
func _physics_process(delta):
	if starting:
		$ColorRect.color.a = lerp($ColorRect.color.a, 0, 0.005)
		$Label.modulate.a = lerp($Label.modulate.a, 0, 0.05)


func _on_Timer_timeout():
	starting = true
