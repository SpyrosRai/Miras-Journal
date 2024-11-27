extends Control

var here: String
var foc: Control = null
var inited:= false

func _ready() -> void:
	await Event.take_control()
	get_viewport().gui_focus_changed.connect(focus_change)
	for i in $Container/Scroller/LocationList.get_children(): 
		if i is Button: i.pressed.connect(location_selected)
		if not Event.f("VP"+i.name):
			if i is Button: i.hide()
	$Container/Scroller/LocationList/Gate.show()
	var label: Label
	for i in $Container/Scroller/LocationList.get_children():
		if i is Label: 
			label = i
			i.hide()
		if i is Button and i.visible: label.show()

func focus_place(place: String):
	if not inited:
		here = place
		Global.Player.camera_follow(false)
		Global.get_cam().position_smoothing_enabled = false
		Global.get_cam().position = $Map.get_node(here).global_position
		$Container.position.x = 1300
		var t = create_tween()
		t.set_ease(Tween.EASE_OUT)
		t.set_trans(Tween.TRANS_QUINT)
		t.set_parallel()
		show()
		t.tween_property(self, "modulate", Color.WHITE, 0.3).from(Color.TRANSPARENT)
		t.tween_property(Global.get_cam(), "zoom", Vector2.ONE, 0.5)
		t.tween_property(Global.get_cam(), "position", size/2, 0.5)
		t.tween_property($Container, "position:x", 898, 0.3).set_delay(0.3)
		inited = true
	else: Global.cursor_sound()
	foc = $Container/Scroller/LocationList.get_node(place)
	foc.show()
	foc.grab_focus()
	if $Map.get_node_or_null(place) != null and place != here:
		$Marker.position = $Map.get_node(place).global_position
		$Marker.show()
	else: $Marker.hide()
	if $Map.get_node_or_null(here) != null:
		$Here.position = $Map.get_node(here).global_position
	for i in $Container/Scroller/LocationList.get_children(): 
		if i is Button and i.name == here: i.icon = preload("res://UI/Map/here.png")

func focus_change(node: Control):
	if not inited: return
	foc = node
	for i in $Container/Scroller/LocationList.get_children(): 
		if i is Button: i.icon = preload("res://UI/MenuTextures/dot.png")
	if node.get_parent() == $Container/Scroller/LocationList:
		focus_place(node.name)
		node.icon = preload("res://UI/Map/marker.png")
	for i in $Container/Scroller/LocationList.get_children(): 
		if i is Button and i.name == here: i.icon = preload("res://UI/Map/here.png")

func location_selected():
	if not inited: return
	inited = false
	Global.confirm_sound()
	var map_point = $Map.get_node_or_null(str(foc.name))
	if map_point == null: OS.alert("You forgot to add the map point idiot"); return
	var t = create_tween()
	t.set_parallel()
	t.tween_property(Global.get_cam(), "zoom", Vector2(4, 4), 0.3)
	t.tween_property(Global.get_cam(), "position", map_point.global_position, 0.3)
	Loader.travel_to(foc.get_meta("Room"), Vector2.ZERO, foc.get_meta("CamID"), -1, "")
	await Global.area_initialized
	var VP = Global.Area.get_node_or_null("VP"+foc.name)
	if VP == null: OS.alert("No such vain point exists"); return
	Global.Player.position = VP.position + Vector2(0, 24)
	queue_free()

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		focus_place(here)
		