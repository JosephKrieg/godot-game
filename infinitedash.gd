extends Area2D

var fading = false
var player
var teleported = false

func _ready():
	pass

func _physics_process(delta):
	if fading == true:
		$Sprite.self_modulate.a = lerp($Sprite.self_modulate.a, 0, 0.01)
		if $Sprite.self_modulate.a <= 0.01:
			print($Sprite.self_modulate.a)
			if teleported == false:
				player.position.x = 992
				player.position.y = -896
				teleported = true


func _on_infinitedash_area_entered(area):
	if area.name == "Area2D":
		player = area.get_parent()
		fading = true
		$CPUParticles2D.emitting = false
