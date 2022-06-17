extends Node2D

onready var Dummy = preload("res://Dummy.tscn")
onready var player = get_node("Player")
onready var Theguardian = get_node("Theguardian")
var amount = 0
var randomnum = RandomNumberGenerator.new()
var mainspawns = [-786]
var mainspawnsup = [-192]
var can_spawn1 = false
var themissile
onready var playerAreaxRight = player.position.x + 5
onready var playerAreaxLeft = player.position.x - 5
onready var playerAreayUp = -player.position.y - 100
onready var playerAreayDown = player.position.y + 100
onready var spawn1 = get_node("Spawn1")
onready var spawn2 = get_node("Spawn2")
onready var missile = preload("res://missile.tscn")
var rand_value = null
var entered = false
var Theguardianalive = true
signal entered


func _ready():
	Dummy.resource_name = "Dummy"
	connect("entered", Theguardian, "_on_bossroom_entered")


func _physics_process(delta):
	playerAreaxRight = player.position.x + 500
	playerAreaxLeft = player.position.x - 500
	playerAreayUp = -player.position.y - 100
	playerAreayDown = player.position.y + 100
	if !is_instance_valid(Theguardian) and Theguardianalive == true:
		print("you are dead")
		Theguardianalive = false
		$Theguardianhealth/Healthbar.visible = false
		$youwintimer.start()
	if Input.is_action_just_pressed("ui_end"):
		get_tree().quit()
	
	

	

func _on_Timer_timeout():# randomized dummy spawn loacation
#	pass #remove pass afterwards
	if amount <= 10:#      at spawn points
		randomnum.randomize()
		var TheNumber = randomnum.randi_range(-1000, 700)
		while TheNumber in range(playerAreaxLeft, playerAreaxRight):
			TheNumber = randomnum.randi_range(-1000, 700) 
#			print("whoaaa")
		var TheDummy = Dummy.instance()
		add_child(TheDummy)
		if spawn1.position.x in range(playerAreaxLeft, playerAreaxRight):
			mainspawns.erase(spawn1.position.x)   #detects location on x axis
		else:
			mainspawns.append(spawn1.position.x)
#		if spawn1.position.y in range(playerAreayUp, playerAreayDown):
#			mainspawnsup.erase(spawn1.position.y)   #detects location on y axis
#		else:
#			mainspawnsup.append(spawn1.position.y)
		if spawn2.position.x in range(playerAreaxLeft, playerAreaxRight):
			mainspawns.erase(spawn2.position.x)   #detects location on x axis
		else:
			mainspawns.append(spawn2.position.x)
#		if spawn2.position.y in range(playerAreayUp, playerAreayDown):
#			mainspawnsup.erase(spawn2.position.y)   #detects location on y axis
#		else:
#			mainspawnsup.append(spawn2.position.y)
		if mainspawns.size() == 0:
			mainspawns.append(0)      #then uncomment this code
		if mainspawnsup.size() == 0:
			mainspawnsup.append(0)
		if TheDummy.position.x == spawn1.position.x:
			TheDummy.position.y = spawn1.position.y# position of dummy on y axis
		elif TheDummy.position.x == spawn2.position.x:
			TheDummy.position.y = spawn2.position.y# position of dummy on y axis
		amount += 1
		mainspawns.shuffle()
		mainspawns.resize(1)
#		mainspawnsup.shuffle()
#		mainspawnsup.resize(2)
		TheDummy.position.x = mainspawns[0]
#		TheDummy.position.y = mainspawnsup[0]

func _on_Dummy_dead():
	amount -= 1

func _on_missile_launch():
	themissile = missile.instance()
	add_child(themissile)


func _on_bossroom_body_entered(body):
	if body.name == "Player" and entered == false:
		$bossdoor/CollisionShape2D.set_deferred("disabled", false)
		$bossdoor/Sprite.visible = true
		emit_signal("entered")
		entered = true
		



func _on_youwintimer_timeout():
	get_tree().change_scene("res://youwin.tscn")
