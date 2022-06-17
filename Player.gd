extends KinematicBody2D

const UP = Vector2(0, -1)
const GRAVITY = 20
const ACCELERATION = 50
const MAXSPEED = 200
const JUMPHEIGHT = -550
const DAMAGE_TAKEN = 10
const HEALTH_INCREASE = 50
var motion = Vector2()
var damage = false
var right = true
var health = 100
onready var healthbar = get_node("../CanvasLayer2/ProgressBar")
onready var healthbarcounter = get_node("../CanvasLayer2/ProgressBar/healthcounter")
onready var damagebar = get_node("../CanvasLayer2/damagebar")
onready var maxhealth = healthbar.max_value
onready var missile = get_node("../missile")
onready var dashbar = get_node("../CanvasLayer2/dashrefill")
var hasGravity = false
var knockback = 200
var gettingknockbacked = false
var invincibility = false
var sword_bounce = false
var dash = 200
var candash = false
var dashingRight = false
var dashingLeft = false
var flash = 0
var dummyonright = false
var new_pos = position.x + dash
var sword_timer_ended = true
var Dummy_Hit_By_Sword = false
var sword_bounce_timer_ended = true
var lever_pulled = false
var damaged = false
var healing = false
var climbing = false
var walljumpdelayright = false
var walljumpdelayleft = false
var hit = false
var dashingTimerAllowDash = true
export var coins = 0
var has_more_health = false
var parkourcheckpoint1 = false
var running = false
var attacking = false
var jumpingup = false
var jumpingdown = false
var dashing = false
var hurt = false
var wallsliding = false
var dying = false
signal explodeplease
onready var Dummy = get_node("../Dummy")
onready var border1 = get_node("../barriers/StaticBody2D")
onready var border2 = get_node("../barriers/StaticBody2D2")
onready var Door = get_node("../Door")
onready var ladder = get_node("../ladders/ladder")


func _ready():
#	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
#	if Input.is_action_just_pressed("ui_end"):
#		pass
	pass

func _physics_process(_delta):
	

	
	if motion.y == 0:
		jumpingdown = false
		jumpingup = false
	
	if jumpingup and attacking == false and dashing == false and hurt == false and wallsliding == false and dying == false:
		$Sprite.play("Jump")

	if jumpingdown and attacking == false and dashing == false and hurt == false and wallsliding == false and dying == false:
		$Sprite.play("Fall")
		

	if attacking:
		$Sprite.animation = "Attack"
		$sword2/CollisionShape2D2.disabled = false
		if $Sprite.flip_h == true:
			$AnimationPlayer.play("attackleft")
		if $Sprite.flip_h == false:
			$AnimationPlayer.play("attack")
	
	if attacking == false:
		$sword2/CollisionShape2D2.disabled = true

			

	if attacking == false and running == false and motion.y == 0 and dashing == false and hurt == false and wallsliding == false and dying == false:
		$Sprite.play("Idle")
		
	if running == true and jumpingdown == false and jumpingup == false and dashing == false and attacking == false and hurt == false and dying == false:
		$Sprite.play("Run")
		
	if dashing and hurt == false and dying == false:
		$Sprite.play("Dash")
	
	if hurt and dying == false:
		$Sprite.play("Hurt")
	
	if wallsliding and hurt == false and dying == false:
		$Sprite.play("WallSlide")

	if health <= maxhealth and healing:
		health += 1
		if health == maxhealth or hit:
			healing = false
	
	if dying:
		if $Sprite.frame == 10:
			get_tree().change_scene("res://GameOver.tscn")
	
	if hit:
		hit = false
	
#	if motion.x >= -1 and motion.x <= 1:
#		running = false
	
	get_tree().call_group("Theguardian", "targetposition", position)
	
	
	healthbar.value = health
	dashbar.value = $dashdelay.time_left
	if damagebar.value > healthbar.value:
		damagebar.value = lerp(damagebar.value, health, 0.05)
	else:
		damagebar.value = healthbar.value
	healthbarcounter.text = String(healthbar.value)
	motion.y += GRAVITY
	var friction = false
	var futurePosition = Vector2(position.x + 50, position.y - 50)
	var futurePosition2 = Vector2(position.x - 50, position.y - 50)
	if $dashHitbox.overlaps_body(border1) or $dashHitbox.overlaps_body(border2):
		candash = false
	else:
		candash = true
	if Input.is_action_pressed("ui_down") and Dummy_Hit_By_Sword:
		Dummy_Hit_By_Sword = false
		sword_bounce_timer_ended = false
		$sword/Sword_Bounce_Timer.start()
	
	if sword_bounce_timer_ended == false:
		position.y = lerp(position.y, position.y - 10, 0.5)
		motion.y = 0

	
	if Input.is_action_pressed("ui_right") and Input.is_action_pressed("ui_left"):
		motion.x = 0
	elif Input.is_action_pressed("ui_right"):
		$dashHitbox.position.x = 200
		motion.x = min(motion.x + ACCELERATION, MAXSPEED)
		running = true
		$Sprite.flip_h = false
		$CollisionShape2D.position.x = 3.671
#		$sword/sword.flip_h = false
#		$sword/sword.position.x = 0
#		$sword/CollisionShape2D.position.x = 0
		right = true
	elif Input.is_action_pressed("ui_left"):
		$dashHitbox.position.x = -200
		motion.x -= ACCELERATION
		motion.x = max(motion.x - ACCELERATION, -MAXSPEED)
		$Sprite.flip_h = true
		$CollisionShape2D.position.x = 32
		running = true
#		$sword/sword.flip_h = true
#		$sword/sword.position.x = -64
#		$sword/CollisionShape2D.position.x = -64
		right = false
	else:
		friction = true
		running = false
	if Input.is_action_just_pressed("ui_a"):
		if Input.is_action_pressed("ui_up") and Input.is_action_pressed("ui_down"):
			$sword/CollisionShape2D.disabled = false #attack forward
			attacking = true
		if !Input.is_action_pressed("ui_up") and !Input.is_action_pressed("ui_down"):
			$sword/CollisionShape2D.disabled = false #attack forward
			attacking = true
		
		$attacktimer.start()
			
		if !Input.is_action_pressed("ui_up") and Input.is_action_pressed("ui_down"):
			$sword/DownCollision.disabled = false #attack down
			$sword/DownSword.visible = true
			$sword/sword.visible = false
			$sword/SwordTime.start()
			sword_timer_ended = false
#		if Input.is_action_pressed("ui_up") and !Input.is_action_pressed("ui_down"):
#			$sword/UpCollision.disabled = false #attack up
#			$sword/UpSword.visible = true
#			$sword/sword.visible = false
#			$sword/SwordTime.start()
#			sword_timer_ended = false
	else:
		if sword_timer_ended == true:
#			$sword/CollisionShape2D.disabled = true
#			$sword/UpSword.visible = false
			$sword/DownSword.visible = false
#			$sword/sword.visible = true
			$sword/UpCollision.disabled = true
			$sword/DownCollision.disabled = true
	if Input.is_action_pressed("ui_up"):
		$climbArea/CollisionShape2D.disabled = false
		if climbing == true:
			position.y -= 10
	else:
		$climbArea/CollisionShape2D.disabled = true
	
	if motion.y > 0:
		jumpingdown = true
		jumpingup = false
		
	elif motion.y < 0:
		jumpingup = true
		jumpingdown = false
		
	
	if is_on_floor():
		if Input.is_action_just_pressed("ui_spacebar"):
			motion.y = JUMPHEIGHT
		if friction == true:
			motion.x = lerp(motion.x, 0, 0.2)
	else:
		if friction == true:
			motion.x = lerp(motion.x, 0, 0.02)
	if dashingRight == true:
		position.x = lerp(position.x, position.x + 100, 0.5)
	elif dashingLeft == true:
		position.x = lerp(position.x, position.x - 100, 0.5)
	
	if gettingknockbacked == true:
		if dummyonright:
			position = lerp(position, futurePosition, 0.5)
		else:
			position = lerp(position, futurePosition2, 0.5)
	if sword_bounce:
		position.y = lerp(position.y, position.y + 100, 0.5)
	if is_on_wall():
		if motion.x >= 0 and !is_on_floor() and motion.y >= 0:
			motion.y = lerp(motion.y, 50, 0.5)
			wallsliding = true
			$Sprite.position = Vector2(35, -24)
			if Input.is_action_just_pressed("ui_spacebar"):
				motion.x -= 1000
				motion.y += JUMPHEIGHT           #jump off left wall
				wallsliding = false
				$Sprite.position = Vector2(16, -24)
			$walljumptimer.start()
			walljumpdelayright = true
		elif motion.x <= 0 and !is_on_floor() and motion.y >= 0:
			wallsliding = true
			$Sprite.position = Vector2(-5, -24)
			motion.y = lerp(motion.y, 50, 0.5)
			if Input.is_action_just_pressed("ui_spacebar"):
				motion.x += 1000
				motion.y += JUMPHEIGHT                 #jump off right wall
				wallsliding = false
				$Sprite.position = Vector2(16, -24)
			$walljumptimer.start()
			walljumpdelayleft = true
	
	if !is_on_wall():
		wallsliding = false
		$Sprite.position = Vector2(16, -24)
	
#	if walljumpdelayright and !is_on_floor():
#		if Input.is_action_just_pressed("ui_spacebar"):
#			motion.x -= 100          #currently doesnt work
#			motion.y += JUMPHEIGHT   #wall jumping with a small window
#			print(motion.y)
#	if walljumpdelayleft and !is_on_floor():             #to jump if you let go early
#		if Input.is_action_just_pressed("ui_spacebar"):
#				motion.x += 100
#				motion.y += JUMPHEIGHT
	
#	if walljumpdelayright:
#		if Input.is_action_just_pressed("ui_spacebar"):
#			motion.x -= 10       #mash spacebar to become rocketship lol
#			motion.y += -100     # possible minigame
#	if walljumpdelayleft:        #you will need to set the timer to like 
#                                #30 seconds to do that
#		if Input.is_action_just_pressed("ui_spacebar"):
#				motion.x += 10
#				motion.y += -100
	
	if Input.is_action_just_pressed("ui_s"):
		if candash == true and dashingTimerAllowDash == true:       #candash is old code for detecting dash
			$dashdelay.start()
			dashingTimerAllowDash = false
			dashing = true
			if right == true:
				$CPUParticles2D.emitting = true
				$CPUParticles2D.gravity.x = -1000
				dashingRight = true
				$dashTimer.start()
				$CPUParticles2D/Particles_Timer.start()
			elif right == false:
				$CPUParticles2D.emitting = true
				$CPUParticles2D.gravity.x = 1000
				dashingLeft = true
				$dashTimer.start()
				$CPUParticles2D/Particles_Timer.start()
				
	if Input.is_action_just_pressed("ui_d"):
		$interact/CollisionShape2D.disabled = false
	else:
		$interact/CollisionShape2D.disabled = true
	
	if health <= 0:
		dying = true
		$deathtimer.start()
		$Sprite.play("Death")
		

	motion = move_and_slide(motion, UP)
	
	if invincibility == true:
#		$Sprite.visible = false
		collision_mask = 2

	if dying:
		motion.x = 0
		print($deathtimer.time_left)
		$Area2D/CollisionShape2D.disabled = true
		$dashHitbox/CollisionShape2D.disabled = true
		$sword2/CollisionShape2D2.disabled = true
	
	
#func _on_Dummy_body_entered(body):
#	if body.name == "Player": 
#		if invincibility == false:
#			health -= DAMAGE_TAKEN
#			healthbar.value = health
#			$Timer.start()
#			$Timer/Timer2.start()
#			damaged = true
#		invincibility = true
#		if Dummy.position.x >= position.x:
#			position.x += -knockback
#		elif Dummy.position.x <= position.x:
#			position.x += knockback
			

func _on_Timer_timeout():
	invincibility = false
	$Sprite.visible = true
	collision_mask = 1
	hurt = false



#func _on_Timer2_timeout():
#	flash += 1
#	if flash == 4 or flash == 2:
#		$Sprite.visible = true
#		$Timer/Timer2.start()
#	if flash == 1 or flash == 3:
#		$Sprite.visible = false
#		$Timer/Timer2.start()
#	if flash == 5:
#		flash = 0


func _on_Area2D_area_shape_entered(_area_id, area, _area_shape, _local_shape): # if you plan on using the other
	if area.name == "Area2D":   # area things, remember to remove the beggining underscore or else it wont work
		var The_dummy = area.get_parent()
		if invincibility == false:
			health -= 20
			healthbar.value = health    #this entire function codes           #for damage taken by the player
			$Timer.start()
			$Timer/Timer2.start()
		invincibility = true
		if The_dummy.position.x >= position.x:
			gettingknockbacked = true #right knockback
			$knockback.start()
			dummyonright = false
		elif The_dummy.position.x <= position.x:
			gettingknockbacked = true #left knockback
			$knockback.start()
			dummyonright = true
		position.y -= 10
		$Healingtimer.start()
		hit = true
		hurt = true
	if area.name == "missilearea":   # area things, remember to remove the beggining underscore or else it wont work
		var The_dummy = area.get_parent()
		if invincibility == false:
			health -= 30
			healthbar.value = health    #this entire function codes           #for damage taken by the player
			$Timer.start()
			$Timer/Timer2.start()
		invincibility = true
		if The_dummy.position.x >= position.x:
			gettingknockbacked = true #right knockback
			$knockback.start()
			dummyonright = false
		elif The_dummy.position.x <= position.x:
			gettingknockbacked = true #left knockback
			$knockback.start()
			dummyonright = true
		position.y -= 10
		$Healingtimer.start()
		hit = true
		hurt = true
		area.get_parent()._begin_to_explode()
	if area.name == "fallborder":
		if parkourcheckpoint1 == false:
			position.x = 2048
			position.y = -1056
		elif parkourcheckpoint1 == true:
			position.x = 6832
			position.y = 800
	
	if area.is_in_group("spikesToBounceOn"):   # area things, remember to remove the beggining underscore or else it wont work
		var The_dummy = area
		if invincibility == false:
			health -= 20
			healthbar.value = health    #this entire function codes           #for damage taken by the player
			$Timer.start()
			$Timer/Timer2.start()
		invincibility = true
		if The_dummy.global_position.x >= global_position.x:
			gettingknockbacked = true #right knockback
			$knockback.start()
			dummyonright = false
		elif The_dummy.global_position.x <= position.x:
			gettingknockbacked = true #left knockback
			$knockback.start()
			dummyonright = true
		position.y -= 10
		$Healingtimer.start()
		hit = true
		hurt = true
	
	if area.is_in_group("guardianhitbox") :   # area things, remember to remove the beggining underscore or else it wont work
		var The_dummy = area
		if invincibility == false:
			health -= 10
			healthbar.value = health    #this entire function codes           #for damage taken by the player
			$Timer.start()
			$Timer/Timer2.start()
		invincibility = true
		if The_dummy.position.x >= position.x:
			gettingknockbacked = true #right knockback
			$knockback.start()
			dummyonright = false
		elif The_dummy.position.x <= position.x:
			gettingknockbacked = true #left knockback
			$knockback.start()
			dummyonright = true
		position.y -= 10
		$Healingtimer.start()
		hit = true
		hurt = true



func _on_interact_area_shape_entered(_area_id, area, _area_shape, _local_shape):# if you plan on using the other
	if area.name == "more_health":   # area things, remember to remove the beggining underscore or else it wont work
		if has_more_health == false and coins >= 5:
			healthbar.max_value = 150
			damagebar.max_value = 150
			maxhealth += HEALTH_INCREASE
			health += HEALTH_INCREASE
			healthbar.value = health
			has_more_health = true
			coins -= 5
	if area.name == "Lever":
		if lever_pulled == false and coins >= 20:
			Door.queue_free()
			area.get_node("Sprite").visible = false
			area.get_node("Sprite2").visible = true
			lever_pulled = true
			coins -= 20
	if area.is_in_group("ladders"):
		print("wow its a ladder")

func _on_Dummy_dead():
	coins += 10

func _on_deathtimer_timeout():
	get_tree().change_scene("res://GameOver.tscn")


func _on_Particles_Timer_timeout():
	$CPUParticles2D.emitting = false


func _on_SwordTime_timeout():
	sword_timer_ended = true


func _on_dashTimer_timeout():
	dashingRight = false
	dashingLeft = false


func _on_knockback_timeout():
	gettingknockbacked = false

func _on_Dummy_hit():
	Dummy_Hit_By_Sword = true


func _on_Sword_Bounce_Timer_timeout():
	Dummy_Hit_By_Sword = false
	sword_bounce_timer_ended = true


func _on_Healing_timer_timeout():
	healing = true


func _on_climbArea_area_entered(area):
	if area.is_in_group("ladders"):
		climbing = true


func _on_climbArea_area_exited(area):
	if area.is_in_group("ladders"):
		climbing = false


func _on_walljumptimer_timeout():
	walljumpdelayright = false
	walljumpdelayleft = false


func _on_Area2D_body_entered(body):
	if body.name == "Theguardian":
		var The_dummy = body
		if invincibility == false:
			health -= 10
			healthbar.value = health   #this entire function codes           #for damage taken by the player
			$Timer.start()
			$Timer/Timer2.start()
		invincibility = true
		if The_dummy.position.x >= position.x:
			gettingknockbacked = true #right knockback
			$knockback.start()
			dummyonright = false
		elif The_dummy.position.x <= position.x:
			gettingknockbacked = true #left knockback
			$knockback.start()
			dummyonright = true
		position.y -= 10
		$Healingtimer.start()
		hit = true
		hurt = true


func _on_dashdelay_timeout():
	dashingTimerAllowDash = true
	dashing = false


func _on_sword_area_entered(area):
	if area.is_in_group("spikesToBounceOn"):
		Dummy_Hit_By_Sword = false
		sword_bounce_timer_ended = false
		$sword/Sword_Bounce_Timer.start()


func _on_checkpoint_area_entered(area):
	if area.name == "Area2D":   # area things, remember to remove the beggining underscore or else it wont work
		var The_dummy = area.get_parent()
		parkourcheckpoint1 = true


func _on_infinitedash_area_entered(area):
	if area.name == "Area2D":
		$dashdelay.wait_time = 0.0001


func _on_spike_area_entered(area):
		if area.name == "Area2D":   # area things, remember to remove the beggining underscore or else it wont work
			var The_dummy = area
			if invincibility == false:
				health -= 10
				healthbar.value = health    #this entire function codes           #for damage taken by the player
				$Timer.start()
				$Timer/Timer2.start()
			invincibility = true
			if The_dummy.position.x >= position.x:
				gettingknockbacked = true #right knockback
				$knockback.start()
				dummyonright = false
			elif The_dummy.position.x <= position.x:
				gettingknockbacked = true #left knockback
				$knockback.start()
				dummyonright = true
			position.y -= 10
			$Healingtimer.start()
			hit = true
			hurt = true



func _on_attacktimer_timeout():
	attacking = false
	$AnimationPlayer.stop()

