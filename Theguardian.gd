extends KinematicBody2D

onready var healthbar = get_node("../Theguardianhealth/Healthbar")
export var health = 1000
var damage_dealt_to_boss = 250
const DAMAGE = 50
const UP = Vector2(0, -1)
const JUMP = 200
const GRAVITY = 10
const knockback_player = 200
onready var Player = get_node("../Player")
onready var TheGame = get_node("../")
onready var tilemap = get_node("../ground")
onready var pathfinding = get_node("../Navigation2D")
onready var line = get_node("../Line2D")
onready var victorymusic = get_node("../youwin")
onready var thememusic = get_node("../thememusic")
onready var bossmusic = get_node("../bossmusic")
onready var bossmusicintro = get_node("../bossmusicintro")
onready var missile = preload("res://missile.tscn")
onready var spike = preload("res://spike.tscn")
var randomnum = RandomNumberGenerator.new()
var spikelocation = RandomNumberGenerator.new()
var colliding = false
var motion = Vector2()
var onground = false
var amount = 0
var armcannon = false
var missilesalive = false
var pathfindingpoints = null
var themissile = null
var radiusx = 10000
var radiusy = 10000
var entered = false
onready var armcannonright = $rightlegarea2.position
onready var animation = $AnimationPlayer
var attacktype
var spikeup = false
var spiking = false
var thespike
var spikespawned = false
signal dead
signal hit
signal launch_missile
signal decaying
export var Dummy_Hit_By_Sword = false

var origin

func _ready():
	connect("launch_missile", TheGame, "_on_missile_launch")
	healthbar.value = health
	attacktype = randomnum.randi_range(1, 2)

func _physics_process(_delta):
#	origin = self.global_transform.origin
#	pathfindingpoints = pathfinding.get_simple_path(origin, Player.position)
#	line.points = pathfindingpoints
	if entered and attacktype == 1:
		if armcannon == true:
			$missilelaunchtimer.start()
			$AnimationPlayer.play("armcannon")
			armcannon = false
	if entered and attacktype == 2:
		if spiking == true:
			$AnimationPlayer.play("spikes")
			spiking = false
			$spikedtimer.start()
	if $spikedtimer.time_left >= 0.5 and $spikedtimer.time_left <= 1.1 and spikespawned == false:
		thespike = spike.instance()
		add_child(thespike)
		thespike.position.x = 500
		thespike.position.y = 500
		spikespawned = true
	
	if $spikedtimer.time_left >= 0.5 and spikeup == false and is_instance_valid(thespike):
		thespike.position.y = lerp(thespike.position.y, 150, 0.1)
		if thespike.position.y <= 200:
			spikeup = true
			$decaytimer.start()
	if $spikedtimer.time_left <= 0:
		spikespawned = false
		spikeup = false

		
	if is_on_floor():
		onground = true
	else:
		onground = false
	if onground == false:
		motion.y += GRAVITY
	if health <= 0 or health == 0:
		bossmusic.stop()
		victorymusic.play()
		connect("dead", missile, "_on_theguardian_dead")
		emit_signal("dead")
		queue_free()
		
	if Player.position.x >= position.x and $missilelaunchtimer.time_left == 0 and $resetTimer.time_left == 0 and $spikedtimer.time_left == 0 and entered:
		position.x += 1
		$AnimationPlayer.play("walkright")
	elif Player.position.x <= position.x and $missilelaunchtimer.time_left == 0 and $resetTimer.time_left == 0 and $spikedtimer.time_left == 0 and entered:
		position.x -= 1
		$AnimationPlayer.play("walkleft")
	
	motion = move_and_slide(motion, UP)
	
		
		
func target_position(target_pos):
	origin = self.global_transform.origin
	pathfindingpoints = pathfinding.get_simple_path(origin, target_pos)
	line.points = pathfindingpoints

func _on_Area2D_area_shape_entered(_area_id, area, _area_shape, _local_shape):
	if area.name == "sword" or area.name == "sword2":
		health -= DAMAGE
		healthbar.value = health
		Dummy_Hit_By_Sword = true
		CONNECT_ONESHOT
		connect("hit", Player, "_on_Dummy_hit")
		emit_signal("hit")
		disconnect("hit", Player, "_on_Dummy_hit")

#func _launching_spikes(thespike):
#	if $spikedtimer.time_left >= 0 and spikeup == false:
#		print(thespike.position)
#		thespike.position.y = lerp(thespike.position.y, 200, 0.1)
#		if thespike.position.y == 200:
#			spikeup = true

func _on_attacktimer_timeout():
	armcannon = true
	spiking = true
	attacktype = randomnum.randi_range(1, 2)


func _on_missilelaunchtimer_timeout():
	emit_signal("launch_missile")
	$AnimationPlayer.play("armcannonrest")
	$resetTimer.start()

func _on_guardian_hit():
	health -= damage_dealt_to_boss
	healthbar.value = health

func _on_bossroom_entered():
	entered = true
	healthbar.visible = true
	thememusic.stop()
	bossmusicintro.play()
	$musictimer.start()
	attacktype = randomnum.randi_range(1, 2)
	


func _on_musictimer_timeout():
	bossmusicintro.stop()
	bossmusic.play()


func _on_decaytimer_timeout():
	connect("decaying", thespike, "_on_decaying")
	emit_signal("decaying")
