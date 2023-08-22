extends Node

var Controllable : bool = true
var Type
var Audio = AudioStreamPlayer.new()
var Sprite = Sprite2D.new()
var Party:PartyData = load("res://database/Party/CurrentParty.tres")
var hasPortrait = false
var portraitimg : Texture
var portrait_redraw = true
var PlayerDir : Vector2
var PlayerPos : Vector2
signal check_party
signal anim_done
var device: String = "Keyboard"
var ProcessFrame=0
var LastInput=0
var AltConfirm
var StartTime =0
var PlayTime =0
var SaveTime =0
var Player = null
var Settings:Setting
var Bt: Battle = null
var CameraInd = 0
var Tilemap:TileMap

func _ready():
	StartTime=Time.get_unix_time_from_system()
	add_child(Audio)
	add_child(Sprite)
	Audio.volume_db = -5
	process_mode = Node.PROCESS_MODE_ALWAYS
	await get_tree().create_timer(0.01).timeout
	get_window().grab_focus()
	init_settings()
	

func _physics_process(delta):
	Engine.set_physics_ticks_per_second(int(DisplayServer.screen_get_refresh_rate()))
	ProcessFrame+=1

func get_playtime():
	PlayTime = SaveTime + Time.get_unix_time_from_system() - StartTime
	return PlayTime

func get_controller() -> ControlScheme:
	if Settings == null: return preload("res://UI/Input/Keyboard.tres")
	if not Settings.ControlSchemeAuto:
		return Settings.ControlSchemeOverride
	if device == "Keyboard":
		return preload("res://UI/Input/Keyboard.tres")
	if "Nintendo" in device or "Pro Controller" in device or  "GameCube" in device:
		return preload("res://UI/Input/Nintendo.tres")
	elif "XInput" in device or "360" in device:
		return preload("res://UI/Input/Generic.tres")
	elif "Series" in device or "Xbox" in device or "XBox" in device:
		return preload("res://UI/Input/Xbox.tres")
	elif "PS4" in device or "DualShock 4" in device or "PS5" in device or "DualSense" in device:
		return preload("res://UI/Input/PlayStation.tres")
	elif "PS3" in device or "DualShock" in device or "PS2" in device or "Sony" in device or "PlayStation" in device:
		return preload("res://UI/Input/PlayStationOld.tres")
	elif "Steam Virtual Gamepad" in device:
		return preload("res://UI/Input/SteamDeck.tres")
	else:
		return preload("res://UI/Input/Generic.tres")

func _input(event):
	if not event.is_pressed(): return
	if LastInput==ProcessFrame: return
	if event is InputEventMouseMotion: return
	if event is InputEventJoypadMotion  and event.axis_value < 0.5: return
	if event is InputEventKey:
		device = "Keyboard"
	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		device = Input.get_joy_name(event.device)
		AltConfirm = get_controller().AltConfirm
		if get_controller().AltConfirm:
			InputMap.action_erase_event("ui_accept", InputMap.action_get_events("MainConfirm")[1])
			InputMap.action_add_event("ui_accept", InputMap.action_get_events("AltConfirm")[1])
			InputMap.action_erase_event("ui_cancel", InputMap.action_get_events("MainCancel")[1])
			InputMap.action_add_event("ui_cancel", InputMap.action_get_events("AltCancel")[1])
		else:
			InputMap.action_erase_event("ui_accept", InputMap.action_get_events("AltConfirm")[1])
			InputMap.action_add_event("ui_accept", InputMap.action_get_events("MainConfirm")[1])
			InputMap.action_erase_event("ui_cancel", InputMap.action_get_events("AltCancel")[1])
			InputMap.action_add_event("ui_cancel", InputMap.action_get_events("MainCancel")[1])
	LastInput=ProcessFrame
	#print(device)

func _unhandled_input(event):
	if Input.is_action_just_pressed("Fullscreen"):
		fullscreen()
	if Input.is_action_just_pressed("Save"):
		Loader.save()
	if Input.is_action_just_pressed("SaveManagment"):
		Loader.load_game()

func fullscreen():
	if get_window().mode != 3:
			get_window().mode = Window.MODE_FULLSCREEN
			await get_tree().create_timer(0.1).timeout
			get_window().grab_focus()
			Settings.Fullscreen = true
	else:
			get_window().mode = Window.MODE_WINDOWED
			get_window().size = Vector2i(1280,800)
			await get_tree().create_timer(0.03).timeout
			get_window().position = DisplayServer.screen_get_size()/2 - Vector2i(1280,800)/2
			await get_tree().create_timer(0.15).timeout
			get_window().grab_focus()
			Settings.Fullscreen = false
	save_settings()

func save_settings():
	ResourceSaver.save(Settings, "user://Settings.tres")

func cancel():
	return "ui_cancel"
		
func confirm():
	return "ui_accept"

func cursor_sound():
	Audio.stream = preload("res://sound/SFX/UI/cursor.wav")
	Audio.play()
func buzzer_sound():
	Audio.stream = preload("res://sound/SFX/UI/buzzer.ogg")
	Audio.play()
func confirm_sound():
	Audio.stream = preload("res://sound/SFX/UI/confirm.ogg")
	Audio.play()
func cancel_sound():
	Audio.stream = preload("res://sound/SFX/UI/Quit.ogg")
	Audio.play()
func item_sound():
	Audio.stream = preload("res://sound/SFX/UI/item.ogg")
	Audio.play()
func ui_sound(string:String):
	Audio.stream = await Loader.load_res("res://sound/SFX/UI/"+string+".ogg")
	Audio.play()

func get_party():
	return preload("res://database/Party/CurrentParty.tres")
	
func check_member(n):
	return Party.check_member(n)
	#Sprite.texture = preload("res://art/Placeholder.png")

func get_member_name(n):
	if Party.check_member(0) and n==0:
		return Party.Leader.FirstName
	elif Party.check_member(1) and n==1:
		return Party.Member1.FirstName
	elif Party.check_member(2) and n==2:
		return Party.Member2.FirstName
	elif Party.check_member(3) and n==2:
		return Party.Member3.FirstName
	else:
		return "Null"

func number_of_party_members():
	var num= 1
	if check_member(1):
		num+=1
	if check_member(2):
		num+=1
	if check_member(3):
		num+=1
	return num

func is_in_party(n):
	if Party.Leader.FirstName == n:
		return true
	if Party.check_member(1):
		if Party.Member1.FirstName == n:
			return true
	if Party.check_member(2):
		if Party.Member2.FirstName == n:
			return true
	if Party.check_member(3):
		if Party.Member3.FirstName == n:
			return true
	else:
		return false

func portrait(img, redraw=true):
	portrait_redraw = redraw
	hasPortrait=true
	portraitimg = await Loader.load_res("res://art/Portraits/" + img + ".png")

func portrait_clear():
	hasPortrait=false
	
#Match profile
func match_profile(named):
	if not ResourceLoader.exists("res://database/Text/Profiles/" + named + ".tres"):
		return preload("res://database/Text/Profiles/Default.tres")
	else:
		return await Loader.load_res("res://database/Text/Profiles/" + named + ".tres")

func get_direction(v=PlayerDir):
	if abs(v.x) > abs(v.y):
		if v.x >0:
			return Vector2.RIGHT
		else:
			return Vector2.LEFT
	else:
		if v.y >0:
			return Vector2.DOWN
		else:
			return Vector2.UP
	
func get_dir_letter(d=PlayerDir):
	if get_direction(d) == Vector2.RIGHT:
		return "R"
	elif get_direction(d) == Vector2.LEFT:
		return "L"
	elif get_direction(d) == Vector2.UP:
		return "U"
	elif get_direction(d) == Vector2.DOWN:
		return "D"

func get_dir_name(d=PlayerDir):
	if get_direction(d) == Vector2.RIGHT:
		return "Right"
	elif get_direction(d) == Vector2.LEFT:
		return "Left"
	elif get_direction(d) == Vector2.UP:
		return "Up"
	elif get_direction(d) == Vector2.DOWN:
		return "Down"

func toggle(boo):
	if boo: return false
	else: return true
	
func _quad_bezier(ti : float, p0 : Vector2, p1 : Vector2, p2: Vector2, target : Node2D) -> void:
	var q0 = p0.lerp(p1, ti)
	var q1 = p1.lerp(p2, ti)
	var r = q0.lerp(q1, ti)
	
	target.global_position = r

func jump_to(character:Node, position:Vector2, time:float, height: float =0.1):
	var t:Tween = create_tween()
	var start = character.global_position
	var jump_distance : float = start.distance_to(position)
	var jump_height : float = jump_distance * height #will need tweaking
	var midpoint = start.lerp(position, 0.5) + Vector2.UP * jump_height
	var jump_time = jump_distance * (time * 0.001) #will also need tweaking, this controls how fast the jump is
	t.tween_method(Global._quad_bezier.bind(start, midpoint, position, character), 0.0, 1.0, jump_time)
	await t.finished
	anim_done.emit()

func get_preview():
	if Party.Leader.FirstName == "Mira" and not Party.check_member(1):
		return preload("res://art/Previews/1.png")
	if Party.Leader.FirstName == "Mira" and Party.Member1.FirstName == "Alcine":
		return preload("res://art/Previews/2.png")
	return preload("res://art/Previews/1.png")

func reset_settings():
	ResourceSaver.save(Setting.new(), "user://Settings.tres")

func init_settings():
	if not ResourceLoader.exists("user://Settings.tres"):
		reset_settings()
		await get_tree().create_timer(1).timeout
	Settings = load("user://Settings.tres")
	if Settings.Fullscreen:
		fullscreen()
	AudioServer.set_bus_volume_db(0, Global.Settings.MasterVolume)
	
func get_cam() -> Camera2D:
	return get_tree().root.get_node("Area/Camera"+str(CameraInd))