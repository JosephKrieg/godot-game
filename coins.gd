extends CanvasLayer

var coins = 0

func _ready():
	pass


func _physics_process(delta):
	coins = get_node("../Player").get("coins")
	$Label2.text = String(coins)

func _on_Dummy_dead():
#	coins += randi() % 10
	pass
#	might change it to a solid value if I feel like it
