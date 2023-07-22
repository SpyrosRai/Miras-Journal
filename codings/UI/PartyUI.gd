extends Control
class_name PartyUI

@export var Party: PartyData
@export var Expanded: bool = false
@export var CursorPosition: Array[Vector2]
signal expand
signal shrink
var held = false
var focus : int = 0
#t : Tween
static var UIvisible = true 
var Tempvis = true
var visibly=false
@onready var t :Tween = get_tree().create_tween()

func _ready():
	$CanvasLayer/Fade.hide()
	_check_party()
	await get_tree().create_timer(0.00001).timeout
	if not Loader.InBattle:
		_on_shrink()
		UIvisible = true
#	else:
#		battle_state()

	Global.check_party.connect(_check_party)

func _process(delta):
	#print(Loader.InBattle)
	if Expanded:
		handle_ui()
	if Loader.InBattle and get_parent() is Control:
		if get_parent().Action:
			_check_party()
	pass
	if not Loader.InBattle:
		if Expanded and $CanvasLayer/Leader.scale.x==1:
			_on_expand()
		elif (not Expanded) and $CanvasLayer/Leader.scale.x==1.5:
			_on_shrink()
		if UIvisible and $CanvasLayer.visible==false:
			$CanvasLayer.show()
			t = create_tween()
			t.set_parallel(true)
			t.tween_property($CanvasLayer/Leader, "position", Vector2(0,$CanvasLayer/Leader.position.y), 0.2)
			t.tween_property($CanvasLayer/Member1, "position", Vector2(-70,$CanvasLayer/Member1.position.y), 0.2)
			visibly=true

		elif  UIvisible==false and visibly:
			visibly=false
			t = create_tween()
			t.set_parallel(true)
			t.tween_property($CanvasLayer/Leader, "position", Vector2(-300,$CanvasLayer/Leader.position.y), 0.2)
			t.tween_property($CanvasLayer/Member1, "position", Vector2(-300,$CanvasLayer/Member1.position.y), 0.2)
			await t.finished
			$CanvasLayer.hide()

func _check_party():
	t = create_tween()
	t.set_parallel(true)
	t.set_ease(Tween.EASE_OUT)
	t.set_trans(Tween.TRANS_QUAD)
	#Leader
	check_member(Party.Leader, $CanvasLayer/Leader, 0)
	#Member 1
	if Party.check_member(1):
		check_member(Party.Member1, $CanvasLayer/Member1, 1)
	else:
		$CanvasLayer/Member1.hide()

func _input(ev):
	if Input.is_key_pressed(KEY_E):
		Loader.travel_to("Debug", Global.get_dir_letter(Global.PlayerDir))
	if Input.is_key_pressed(KEY_T):
		DialogueManager.passive("testbush", "greetings")
	if Input.is_action_pressed("PartyMenu") and Loader.InBattle == false:
		if not held:
			if Expanded == true:
				Tempvis=true
				$Audio.stream = preload("res://sound/SFX/UI/shrink.ogg")
				$Audio.play()
				_on_shrink()
				Global.cancel_sound()
				
			elif Global.Controllable:
				_on_expand()
				$Audio.stream = preload("res://sound/SFX/UI/expand.ogg")
				$Audio.play()
				Global.confirm_sound()
		held=true
	else:
		held=false
	if Input.is_action_pressed(Global.cancel()) and Expanded:
		$Audio.stream = preload("res://sound/SFX/UI/shrink.ogg")
		$Audio.play()
		_on_shrink()
		Global.cancel_sound()

func _on_expand():
	t.kill()
	_check_party()
	Global.Controllable=false
	t = create_tween()
	t.set_parallel(true)
	t.set_ease(Tween.EASE_OUT)
	t.set_trans(Tween.TRANS_BACK)
	#Pages
	#t.tween_property($CanvasLayer/Page1, "position", Vector2(634,44), 0.3)
	$CanvasLayer/Page1.show()
	if Party.check_member(1):
		$CanvasLayer/Page2.show()
		#t.tween_property($CanvasLayer/Page2, "position", Vector2(634,44), 0.35)
	else:
		$CanvasLayer/Page2.hide()
	if Party.check_member(2):
		$CanvasLayer/Page3.show()
		
	else:
		#t.tween_property($CanvasLayer/Page3, "position", Vector2(634,44), 0.4)
		$CanvasLayer/Page3.hide()
	if Party.check_member(3):
		$CanvasLayer/Page4.show()
	else:
		$CanvasLayer/Page4.hide()
		#t.tween_property($CanvasLayer/Page4, "position", Vector2(634,44), 0.45)
	
	#Leader
	$CanvasLayer/Fade.show()
	t.tween_property($CanvasLayer/Cursor, "modulate", Color(1,1,1,1), 0.4)
	t.tween_property($CanvasLayer/Fade/Blur, "modulate", Color(1,1,1,1), 0.4)
	t.tween_property($CanvasLayer/Fade, "color", Color(0, 0, 0, 0.5), 0.4)
	t.tween_property($CanvasLayer/Leader, "scale", Vector2(1.5,1.5), 0.4)
	t.tween_property($CanvasLayer/Leader/Icon, "scale", Vector2(0.044,0.044), 0.4)
	t.tween_property($CanvasLayer/Leader/Icon, "position", Vector2(37,45), 0.4)
	$CanvasLayer/Leader/Health.size = Vector2(110,20)
	t.tween_property($CanvasLayer/Leader/Health, "position", Vector2(75,31), 0.4)
	$CanvasLayer/Leader/Aura.size = Vector2(110,27)
	t.tween_property($CanvasLayer/Leader/Aura, "position", Vector2(75,37), 0.4)
	$CanvasLayer/Leader/Name.show()
	$CanvasLayer/Leader/Level.show()
	t.tween_property($CanvasLayer/Leader/Health/HpText, "modulate", Color(1, 1, 1, 1), 0.4)
	t.tween_property($CanvasLayer/Leader/ExpBar, "modulate", Color(1, 1, 1, 1), 0.4)
	t.tween_property($CanvasLayer/Leader/Name, "modulate", Color(1, 1, 1, 1), 0.4)
	t.tween_property($CanvasLayer/Leader/Aura/AruaText, "modulate", Color(1, 1, 1, 1), 0.4)
	t.tween_property($CanvasLayer/Leader/Level, "position", Vector2(140,69), 0.4)
	#await get_tree().create_timer(0.1).timeout
	#Member1
	t.tween_property($CanvasLayer/Member1, "position", Vector2(0,189), 0.4)
	t.tween_property($CanvasLayer/Cursor, "modulate", Color(1,1,1,1), 0.4)
	t.tween_property($CanvasLayer/Fade/Blur, "modulate", Color(1,1,1,1), 0.4)
	t.tween_property($CanvasLayer/Fade, "color", Color(0, 0, 0, 0.5), 0.4)
	t.tween_property($CanvasLayer/Member1, "scale", Vector2(1.5,1.5), 0.4)
	t.tween_property($CanvasLayer/Member1/Icon, "scale", Vector2(0.044,0.044), 0.4)
	t.tween_property($CanvasLayer/Member1/Icon, "position", Vector2(37,50), 0.4)
	$CanvasLayer/Member1/Health.size = Vector2(110,20)
	t.tween_property($CanvasLayer/Member1/Health, "position", Vector2(75,41), 0.4)
	$CanvasLayer/Member1/Aura.size = Vector2(110,27)
	t.tween_property($CanvasLayer/Member1/Aura, "position", Vector2(75,46), 0.4)
	$CanvasLayer/Member1/Name.show()
	$CanvasLayer/Member1/Level.show()
	t.tween_property($CanvasLayer/Member1/Health/HpText, "modulate", Color(1, 1, 1, 1), 0.4)
	t.tween_property($CanvasLayer/Member1/ExpBar, "modulate", Color(1, 1, 1, 1), 0.4)
	t.tween_property($CanvasLayer/Member1/Name, "modulate", Color(1, 1, 1, 1), 0.4)
	t.tween_property($CanvasLayer/Member1/Aura/AruaText, "modulate", Color(1, 1, 1, 1), 0.4)
	t.tween_property($CanvasLayer/Member1/Level, "position", Vector2(140,79), 0.4)
	
	#Menu
	Expanded = true
	await t.finished
	$CanvasLayer/Cursor.show()
	focus_now()

func _on_shrink():
	t.kill()
	_check_party()
	Global.Controllable=true
	t = create_tween()
	t.set_parallel(true)
	t.set_ease(Tween.EASE_OUT)
	focus=0
	t.set_trans(Tween.TRANS_BACK)
	#Pages
	$CanvasLayer/Cursor.position=CursorPosition[0]
	t.tween_property($CanvasLayer/Page1, "position", Vector2(1300,44), 0.3)
	t.tween_property($CanvasLayer/Page2, "position", Vector2(1300,44), 0.3)
	t.tween_property($CanvasLayer/Page3, "position", Vector2(1366,44), 0.3)
	t.tween_property($CanvasLayer/Page4, "position", Vector2(1366,44), 0.3)
	t.tween_property($CanvasLayer/Page1/Render, "position", Vector2(179,44), 0.6)
	
	#Leader
	
	t.tween_property($CanvasLayer/Cursor, "modulate", Color(0,0,0,0), 0.4)
	t.tween_property($CanvasLayer/Fade, "color", Color(0,0,0,0), 0.4)
	t.tween_property($CanvasLayer/Fade/Blur, "modulate", Color.TRANSPARENT, 0.4)
	t.tween_property($CanvasLayer/Leader, "scale", Vector2(1,1), 0.4)
	t.tween_property($CanvasLayer/Leader/Icon, "scale", Vector2(0.05,0.05), 0.4)
	t.tween_property($CanvasLayer/Leader/Icon, "position", Vector2(44,44), 0.4)
	$CanvasLayer/Leader/Health.size = Vector2(124,22)
	t.tween_property($CanvasLayer/Leader/Health, "position", Vector2(89,16), 0.4)
	$CanvasLayer/Leader/Aura.size = Vector2(124,26)
	t.tween_property($CanvasLayer/Leader/Aura, "position", Vector2(89,26), 0.4)
	t.tween_property($CanvasLayer/Leader/Name, "modulate", Color.TRANSPARENT, 0.4)
	t.tween_property($CanvasLayer/Leader/ExpBar, "modulate", Color.TRANSPARENT, 0.4)
	t.tween_property($CanvasLayer/Leader/Level, "position", Vector2(90,61), 0.4)
	t.tween_property($CanvasLayer/Leader/Health/HpText, "modulate", Color.TRANSPARENT, 0.4)
	t.tween_property($CanvasLayer/Leader/Aura/AruaText, "modulate", Color.TRANSPARENT, 0.4)
	
	#Member1
	t.tween_property($CanvasLayer/Member1, "scale", Vector2(1,1), 0.4)
	t.tween_property($CanvasLayer/Member1/Icon, "scale", Vector2(0.05,0.05), 0.4)
	t.tween_property($CanvasLayer/Member1/Icon, "position", Vector2(114,54), 0.4)
	t.tween_property($CanvasLayer/Member1, "position", Vector2(-70,130), 0.4)
	t.tween_property($CanvasLayer/Member1/Health, "size", Vector2(54,22), 0.4)
	t.tween_property($CanvasLayer/Member1/Aura, "size", Vector2(54,22), 0.4)
	t.tween_property($CanvasLayer/Member1/Health, "position", Vector2(159,30), 0.4)
	$CanvasLayer/Member1/Aura.size = Vector2(124,26)
	t.tween_property($CanvasLayer/Member1/Aura, "position", Vector2(159,43), 0.4)
	t.tween_property($CanvasLayer/Member1/Name, "modulate", Color.TRANSPARENT, 0.4)
	t.tween_property($CanvasLayer/Member1/ExpBar, "modulate", Color.TRANSPARENT, 0.4)
	t.tween_property($CanvasLayer/Member1/Level, "position", Vector2(160,73), 0.4)
	t.tween_property($CanvasLayer/Member1/Health/HpText, "modulate", Color.TRANSPARENT, 0.4)
	t.tween_property($CanvasLayer/Member1/Aura/AruaText, "modulate", Color.TRANSPARENT, 0.4)
	
	t.tween_property($CanvasLayer/Leader, "position", Vector2(0,$CanvasLayer/Leader.position.y), 0.2)
	Expanded = false
	await t.finished
	$CanvasLayer/Page1.hide()
	$CanvasLayer/Page2.hide()
	$CanvasLayer/Page3.hide()
	$CanvasLayer/Page4.hide()

func handle_ui():
	if Input.is_action_just_pressed("ui_down"):
		if Party.check_member(focus+1):
			focus += 1
			Global.cursor_sound()
			focus_now()
			$Audio.stream = preload("res://sound/SFX/UI/page.ogg")
			$Audio.play()
		else:
			Global.buzzer_sound()
	if Input.is_action_just_pressed("ui_up"):
		if focus-1 != -1:
			focus -= 1
			Global.cursor_sound()
			focus_now()
			$Audio.stream = preload("res://sound/SFX/UI/Page2.ogg")
			$Audio.play()
		else:
			Global.buzzer_sound()
	
func focus_now():
	t.kill()
	t = create_tween()
	t.set_parallel(true)
	t.set_ease(Tween.EASE_OUT)
	t.set_trans(Tween.TRANS_CUBIC)
	t.tween_property($CanvasLayer/Cursor, "position", CursorPosition[focus], 0.1)
	#await get_tree().create_timer(0.3).timeout
	if focus == 0:
		t.tween_property($CanvasLayer/Page1,"position", Vector2(634, 44), 0.5).from(Vector2(1200,44))
		t.tween_property($CanvasLayer/Page2,"position", Vector2(634, 44), 0.4)
		t.tween_property($CanvasLayer/Page3,"position", Vector2(634, 44), 0.3)
		t.tween_property($CanvasLayer/Page4,"position", Vector2(634, 44), 0.2)
		t.tween_property($CanvasLayer/Page1/Render,"position", Vector2(220, 187), 0.5).from(Vector2(-15, 198))
		t.tween_property($CanvasLayer/Page2/Render,"position", Vector2(-15, 198), 0.3)
		t.tween_property($CanvasLayer/Page1/Render/Shadow,"modulate", Color(1,1,1,0.6), 0.5)
		t.tween_property($CanvasLayer/Page2/Render/Shadow,"modulate", Color(0,0,0,0), 0.3)
		t.tween_property($CanvasLayer/Page1/Render/Shadow,"position", Vector2(-78,-43), 0.5,).from(Vector2(120,80))
	if focus == 1:
		t.tween_property($CanvasLayer/Page1,"position", Vector2(1300, 44), 0.3)
		t.tween_property($CanvasLayer/Page3,"position", Vector2(634, 44), 0.3)
		t.tween_property($CanvasLayer/Page4,"position", Vector2(634, 44), 0.3)
		t.tween_property($CanvasLayer/Page1/Render/Shadow,"modulate", Color(0,0,0,0), 0.3)
		t.tween_property($CanvasLayer/Page2/Render/Shadow,"modulate", Color(1,1,1,0.6), 0.5)
		t.tween_property($CanvasLayer/Page2/Render/Shadow,"position", Vector2(-78,-43), 0.5).from(Vector2(120,80))
		t.tween_property($CanvasLayer/Page1/Render,"position", Vector2(-15, 198), 0.3)
		t.tween_property($CanvasLayer/Page2,"position", Vector2(634, 44), 0.3)
		t.tween_property($CanvasLayer/Page2/Render,"position", Vector2(220, 187), 0.5).from(Vector2(-15, 198))
		t.tween_property($CanvasLayer/Page1/Render/Shadow,"position", Vector2(0,0), 0.3)
		
	
func battle_state():
	if get_parent() is Control:
		$CanvasLayer.show()
		$CanvasLayer/Cursor.hide()
		t = create_tween()
		t.set_parallel(true)
		t.tween_property($CanvasLayer/Leader, "position", Vector2(0,0), 0.2)
		t.tween_property($CanvasLayer/Member1, "position", Vector2(-70,160), 0.2)
		visibly=true
		$CanvasLayer/Leader.scale = Vector2(1.25, 1.25)
		$CanvasLayer/Member1.scale = Vector2(1.25, 1.25)
		$CanvasLayer/Member1/ExpBar.hide()
		$CanvasLayer/Member1/Name.position = Vector2(140,13)
		$CanvasLayer/Member1/Health.size = Vector2(65,20)
		$CanvasLayer/Member1/Aura.size = Vector2(65,27)
		$CanvasLayer/Member1/Health.position = Vector2(130,40)
		$CanvasLayer/Member1/Aura.position = Vector2(130,46)
		$CanvasLayer/Member1/Health/HpText.position.x = 70
		$CanvasLayer/Member1/Aura/AruaText.position.x = 70
		$CanvasLayer/Member1/Icon.position.x = 93
	else:
		$CanvasLayer.hide()

func _on_battle_ui_root():
	battle_state()


func _on_battle_ui_ability():
	t = create_tween()
	t.set_parallel(true)
	if get_parent().CurrentChar == Party.Leader:
		t.tween_property($CanvasLayer/Member1, "position", Vector2(-400,$CanvasLayer/Member1.position.y), 0.2)
	elif get_parent().CurrentChar == Party.Member1:
		t.tween_property($CanvasLayer/Member1, "position", Vector2(-70,20), 0.2)
		t.tween_property($CanvasLayer/Leader, "position", Vector2(-400,$CanvasLayer/Leader.position.y), 0.2)

func check_member(mem:Actor, node:Panel, ind):
	node.get_node("Name").text = mem.FirstName
	var character_label = mem.FirstName
	get_node("CanvasLayer/Page"+str(ind+1)+"/Label").text = mem.FirstName + " " + mem.LastName
	get_node("CanvasLayer/Page"+str(ind+1)+"/Render").texture = mem.RenderArtwork
	get_node("CanvasLayer/Page"+str(ind+1)+"/Render/Shadow").texture = mem.RenderShadow
	t.tween_property(node.get_node("Health"), "value", mem.Health, 1)
	node.get_node("Health").max_value = mem.MaxHP
	draw_bar(mem, node)
	node.get_node("Aura").max_value = mem.MaxAura
	node.get_node("ExpBar").max_value = mem.SkillPointsFor[mem.SkillLevel]
	t.tween_property(node.get_node("ExpBar"), "value", mem.SkillPoints, 1)
	t.tween_property(node.get_node("Aura"), "value", mem.Aura, 1)
	node.get_node("Icon").texture = mem.PartyIcon
	node.get_node("Health/HpText").text = str(mem.Health)
	node.get_node("Aura/AruaText").text = str(mem.Aura)
	node.get_node("Level/Number").text = str(mem.SkillLevel)

func draw_bar(mem:Actor, node: Panel):
	var hbox:StyleBoxFlat = node.get_node("Health").get_theme_stylebox("fill")
	hbox.bg_color = mem.MainColor
	node.get_node("Health").add_theme_stylebox_override("fill", hbox.duplicate())
	var abox = node.get_node("Aura").get_theme_stylebox("fill")
	abox.bg_color = mem.SecondaryColor
	node.get_node("Aura").add_theme_stylebox_override("fill", abox.duplicate())
	var bord1:StyleBoxFlat = node.get_node("Border1").get_theme_stylebox("panel")
	bord1.border_color = mem.BoxProfile.Bord1
	node.get_node("Border1").add_theme_stylebox_override("panel", bord1.duplicate())
	var bord2:StyleBoxFlat = node.get_node("Border1/Border2").get_theme_stylebox("panel")
	bord2.border_color = mem.BoxProfile.Bord2
	node.get_node("Border1/Border2").add_theme_stylebox_override("panel", bord2.duplicate())
	var bord3:StyleBoxFlat = node.get_node("Border1/Border2/Border3").get_theme_stylebox("panel")
	bord3.border_color = mem.BoxProfile.Bord3
	node.get_node("Border1/Border2/Border3").add_theme_stylebox_override("panel", bord3.duplicate())