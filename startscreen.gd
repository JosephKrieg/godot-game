extends Control


func _ready():
	pass

func _physics_process(delta):
	if Input.is_action_just_pressed("ui_end"):
		get_tree().quit()

func _on_Button_pressed():
	get_tree().change_scene("res://mainworld.tscn")


func _on_Button2_pressed():
	if $ColorRect.visible == true:
		$ColorRect.visible = false
	elif $ColorRect.visible == false:
		$ColorRect.visible = true
