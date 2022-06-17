extends KinematicBody2D

onready var Player = get_node("../Player")
onready var pathfinding = get_node("../Navigation2D")
onready var line = get_node("../Line2D")
onready var theguardian = get_node("../Theguardian")
onready var theguardianarm = get_node("../Theguardian/Sprite/body/rightlegsprite1/rightlegsprite2")
onready var theguardianhead = get_node("../Theguardian/Sprite")
var speed = 200
var futurespeed = 400
var velocity
var direction
var pathfindingpoints = null
var looking
var friendly = false
var exploding = false
signal guardianhit


func _ready():
	position = theguardianarm.global_position

func _physics_process(delta):
	if exploding == false:
		if futurespeed <= speed:
			futurespeed = lerp(futurespeed, speed, 0.5)
		if friendly == false:
			pathfindingpoints = pathfinding.get_simple_path(global_position, Player.position)
			line.points = pathfindingpoints
			direction = global_position.direction_to(pathfindingpoints[1])
			velocity = direction * futurespeed
			velocity = move_and_slide(velocity)
			look_at(pathfindingpoints[1])
		#	$CollisionShape2D.look_at(Player.position)
		#	global_rotation = lerp(global_rotation, $CollisionShape2D.global_rotation, 0.1)
		if !is_instance_valid(theguardian):
			queue_free()
		if friendly and is_instance_valid(theguardian):
			if theguardianarm == null:
				queue_free()
			pathfindingpoints = pathfinding.get_simple_path(global_position, theguardianarm.global_position)
			line.points = pathfindingpoints
			direction = global_position.direction_to(pathfindingpoints[1])
			velocity = direction * futurespeed
			velocity = move_and_slide(velocity)
			look_at(pathfindingpoints[1])
	if exploding == true:
		$missilearea.visible = false
		$Area2D2.visible = false
		$CPUParticles2D.emitting = false

func _on_Area2D_area_shape_entered(area_id, area, area_shape, local_shape):
	if area.name == "sword" or area.name == "sword2":
		friendly = true
		
func _begin_to_explode():
	if exploding == false:
		exploding = true
		$explosion.emitting = true
		$explosiontimer.start()


func _on_Area2D2_body_entered(body):
	if body.name == "Theguardian" and friendly and !exploding:
#		$Area2D2/CollisionShape2D.disabled = true
		set_deferred("disabled", true)
		connect("guardianhit", theguardian, "_on_guardian_hit")
		emit_signal("guardianhit")
		_on_Timer_timeout()

func _on_theguardian_dead():
	print("i am dead")
	queue_free()


func _on_Timer_timeout():
	if exploding == false:
		exploding = true
		$explosion.emitting = true
		$explosiontimer.start()



func _on_explosiontimer_timeout():
	queue_free()
