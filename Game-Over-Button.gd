extends Button


func _ready():
	pass

func _physics_process(delta):
	if Input.is_action_just_pressed("ui_end"):
		get_tree().quit()


func _on_Button_pressed():
	get_tree().change_scene("res://startscreen.tscn")
