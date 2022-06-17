extends KinematicBody2D

onready var healthbar = $HealthBar
export var health = 100
const DAMAGE = 50
const UP = Vector2(0, -1)
const JUMP = 200
const GRAVITY = 10
const knockback_player = 200
onready var Player = get_node("../Player")
onready var TheGame = get_node("../")
onready var tilemap = get_node("../ground")
onready var raycast_tile_right = $RayCastRight
onready var raycast_tile_left = $RayCastLeft
onready var hitbox = $Area2D
var can_see = false #this is not currently in use but can be used to detect player in range.
					#This variable is kinda buggy so be careful when using it
var right_colliding = false
var left_colliding = false
var colliding = false
var motion = Vector2()
var onground = false
var working = 0
var amount = 0
var knockbacked = false
var knockebackedonce = false
var futurepositionleft
var futurepositionright
signal dead
signal hit
export var Dummy_Hit_By_Sword = false


func _ready():
	if hitbox.overlaps_body(tilemap):
		position.y -= 100
		print("ready")

func _physics_process(_delta):
	
	
	if knockbacked:
		if knockebackedonce:
			$knockbacktimer.start()
			knockebackedonce = false
	
	
	working += 1
	
	if right_colliding or left_colliding:
		colliding = true
	else:
		colliding = false
	if raycast_tile_right.is_colliding():
		right_colliding = true
	else:
		right_colliding = false
	if raycast_tile_left.is_colliding():
		left_colliding = true
	else:
		left_colliding = false
	if colliding and onground:
		motion.y -= JUMP
	if is_on_floor():
		onground = true
	else:
		onground = false
	if onground == false:
		motion.y += GRAVITY
	if health <= 0:
		queue_free()
		connect("dead", Player, "_on_Dummy_dead")
		connect("dead", TheGame, "_on_Dummy_dead")
		emit_signal("dead")
	if Player.position.x >= position.x:
		position.x += 1
		if knockbacked == true:
			position.x = lerp(position.x, position.x - 20, 0.5)
	elif Player.position.x <= position.x:
		position.x -= 1
		if knockbacked == true:
			position.x = lerp(position.x, position.x + 20, 0.5)
	
	motion = move_and_slide(motion, UP)
	





func _on_collision_detection_body_entered(body):
	if body.name == "Player":
		can_see = true


func _on_collision_detection_body_exited(_body):
	can_see = false


func _on_Area2D_area_shape_entered(_area_id, area, _area_shape, _local_shape):
	if area.name == "sword" or area.name == "sword2":
		health -= DAMAGE
		healthbar.value = health
		Dummy_Hit_By_Sword = true
		knockbacked = true
		knockebackedonce = true
		CONNECT_ONESHOT
		connect("hit", Player, "_on_Dummy_hit")
		emit_signal("hit")
		disconnect("hit", Player, "_on_Dummy_hit")



func _on_knockbacktimer_timeout():
	knockbacked = false
	knockebackedonce = false
