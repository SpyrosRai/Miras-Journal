extends Control

var index: int = 0
signal closed

func _ready() -> void:
	$ChooseUpgrade/Cursor/Cont/Button.hide()
	hide()

func levelup(chara: Actor):
	$Line1.position = Vector2(0, 243)
	$Line1.rotation_degrees = 0
	$LevelupText.position = Vector2(-52, 364)
	$Line1.color = chara.BoxProfile.Bord1
	$Line1/Line3.color = chara.BoxProfile.Bord1
	$Line1/Line2.color = chara.BoxProfile.Bord2
	$Line1/Line3/Line2.color = chara.BoxProfile.Bord2
	$Line1/Line2/Line3.color = chara.BoxProfile.Bord3
	$Line1/Line3/Line2/Line3.color = chara.BoxProfile.Bord3
	$Line1/Bg.size.y = 10
	$LevelupText.add_theme_color_override("default_color", chara.BoxProfile.Bord1)
	$ChooseUpgrade.modulate = Color.TRANSPARENT
	$ChooseUpgrade.position.y = 500
	$ChooseUpgrade/HPCont.modulate = Color.TRANSPARENT
	$ChooseUpgrade/APCont.modulate = Color.TRANSPARENT
	$ChooseUpgrade/NewAb.modulate = Color.TRANSPARENT
	$ChooseUpgrade/HPCont/HPBox/HPText.text = str(chara.MaxHP)
	$ChooseUpgrade/APCont/APBox/APText.text = str(chara.MaxAura)
	$ChooseUpgrade/Cursor.modulate = Color.TRANSPARENT
	var hbox:StyleBoxFlat = $ChooseUpgrade/HPCont/HPBox/Health.get_theme_stylebox("fill")
	hbox.bg_color = chara.MainColor
	$ChooseUpgrade/HPCont/HPBox/Health.add_theme_stylebox_override("fill", hbox.duplicate())
	var abox = $ChooseUpgrade/APCont/APBox/Aura.get_theme_stylebox("fill")
	abox.bg_color = chara.SecondaryColor
	$ChooseUpgrade/APCont/APBox/Aura.add_theme_stylebox_override("fill", abox.duplicate())
	$ChooseUpgrade/HPCont/HPBox/Health.value = chara.MaxHP
	$ChooseUpgrade/APCont/APBox/Aura.value = chara.MaxAura
	level_cutin(chara)
	await Event.wait(2, false)
	var t = create_tween()
	t.set_parallel()
	t.set_ease(Tween.EASE_IN)
	t.set_trans(Tween.TRANS_QUINT)
	t.tween_property($Line1, "position", Vector2(-32, -100), 0.5)
	t.tween_property($Line1, "rotation_degrees", -6.2, 0.5)
	t.tween_property($LevelupText, "position", Vector2(-240, 11), 0.5)
	t.tween_property($Line1/Bg, "size:y", 800, 0.5)
	t.tween_property($ChooseUpgrade, "modulate", Color.WHITE, 0.5)
	t.tween_property($ChooseUpgrade, "position:y", 0, 0.5)
	$ChooseUpgrade/Actor.play("Idle")
	await Event.wait(0.8, false)
	t = create_tween()
	t.set_parallel()
	t.set_trans(Tween.TRANS_BACK)
	t.tween_property($ChooseUpgrade/HPCont, "position:x", 70, 0.2).from(-100)
	t.tween_property($ChooseUpgrade/HPCont, "modulate", Color.WHITE, 0.2)
	await Event.wait(0.8, false)
	t = create_tween()
	t.set_parallel()
	t.set_trans(Tween.TRANS_BACK)
	t.tween_property($ChooseUpgrade/APCont, "position:x", 70, 0.2).from(-100)
	t.tween_property($ChooseUpgrade/APCont, "modulate", Color.WHITE, 0.2)
	await Event.wait(0.8, false)
	t = create_tween()
	t.set_parallel()
	t.set_trans(Tween.TRANS_BACK)
	t.tween_property($ChooseUpgrade/NewAb, "position:x", 70, 0.2).from(-100)
	t.tween_property($ChooseUpgrade/NewAb, "modulate", Color.WHITE, 0.2)
	await Event.wait(0.8, false)
	$ChooseUpgrade/Cursor/Cont/Button.show()
	$ChooseUpgrade/Cursor/Cont/Button.icon = Global.get_controller().ConfirmIcon
	t = create_tween()
	t.set_parallel()
	t.set_ease(Tween.EASE_OUT)
	t.set_trans(Tween.TRANS_QUINT)
	t.tween_property($ChooseUpgrade/Cursor/Cont,
		"size:x", 190, 0.3).from(1)
	t.tween_property($ChooseUpgrade/Cursor, "modulate", Color.WHITE, 0.2)
	index = 0

func level_cutin(chara: Actor):
	PartyUI.hide_all()
	scale.y = 0.1
	for i in $Line1/NameChain.get_children():
		i.text = (chara.FirstName + " " + chara.LastName + " ").to_upper()
		i.add_theme_color_override("font_color", chara.BoxProfile.Bord3)
	for i in $Line1/NameChain2.get_children():
		i.text = (chara.FirstName + " " + chara.LastName + " ").to_upper()
		i.add_theme_color_override("font_color", chara.BoxProfile.Bord3)
	var t = create_tween()
	show()
	t.set_parallel()
	t.set_ease(Tween.EASE_OUT)
	t.set_trans(Tween.TRANS_QUINT)
	t.tween_property(self, "scale:y", 1, 0.3)
	t.set_trans(Tween.TRANS_LINEAR)
	t.tween_property($Line1/NameChain, "position:x", -800, 10).from(0)
	t.tween_property($Line1/NameChain2, "position:x", 2300, 10).from(1400)

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_down"):
		index += 1
		if index == 3: index = 0
		move_menu()
	if Input.is_action_just_pressed("ui_up"):
		index -= 1
		if index == -1: index = 2
		move_menu()

func move_menu():
	Global.cursor_sound()
	var ypos: int
	match index:
		0:
			ypos = 375
			$ChooseUpgrade/Cursor/Cont/Button.text = "Upgrade Health"
		1:
			ypos = 515
			$ChooseUpgrade/Cursor/Cont/Button.text = "Upgrade Aura"
		2:
			ypos = 646
			$ChooseUpgrade/Cursor/Cont/Button.text = "Learn Ability"
	var t = create_tween()
	t.set_ease(Tween.EASE_OUT)
	t.set_trans(Tween.TRANS_QUINT)
	t.tween_property($ChooseUpgrade/Cursor, "position:y", ypos, 0.1)

func _confirm():
	$ChooseUpgrade/Cursor/Cont/Button.hide()
	close()

func close():
	var t = create_tween()
	t.set_ease(Tween.EASE_IN)
	t.set_trans(Tween.TRANS_QUINT)
	t.tween_property(self, "scale:y", 0, 0.3)
	await t.finished
	closed.emit()
