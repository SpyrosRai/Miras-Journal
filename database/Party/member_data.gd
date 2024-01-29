extends Resource

class_name Actor

##Displayed name of the character
@export var FirstName: String = "Name"
##Used for AI decisions
@export_enum("Unknown", "Attacker", "Mage", "Support", "Tank", "Boss") var ActorClass: String
##Used to check if the character is an enemy internally
@export var IsEnemy: bool = true
##Material item that the enemy drops at the end of battle
@export var DroppedItem: MaterialItem = null
##Skill Points the party recives for defeating the enemy at the end of battle
@export_range(0, 999, 1, "suffix:SP") var RecivedSP: int = 0
##Used for refrencing the character in code
@export var codename: StringName = &"Actor"
##Used in system text, 0: subjective, 1: objective, 2: possessive, 3: -self
var Pronouns: Array[String] = ["They", "Them", "Their", "Themself"]
##If true, the character cannot die unless in very low hp
@export var ClutchDmg:= false
##If true, the character cannot die, and will always stay at low hp
@export var CantDie:= false

@export_category("Art")
@export var PartyIcon: Texture

@export_category("Color")
@export var MainColor: Color = Color.WHITE

@export_group("Party specific")
@export var SecondaryColor: Color = Color.BLACK

@export var BoxProfile: TextProfile

@export var LastName: String = ""
@export var Weapon: String
@export var Controllable: bool = false
@export var StatsVisible: bool = true

@export_subgroup("Party menu")
@export var RenderArtwork: Texture
@export var RenderShadow: Texture
@export var PartyPage: Texture

@export_category("Details")
@export_group("Stats")

@export_range(1, 9999, 1, "suffix:HP") var MaxHP: int = 99
@export_range(1, 9999, 1, "suffix:AP") var MaxAura: int = 99

@export_range(0, 2) var Attack: float = 1
@export_range(0, 2) var Magic: float = 1
@export_range(0, 2) var Defence: float = 1
@export_range(0, 10) var Speed: float = 5

@export_subgroup("Current")
@export_range(0, 9999) var Health: int
@export_range(0, 9999) var Aura: int

@export_subgroup("Multipliers")
@export var AttackMultiplier: float = 1
@export var DefenceMultiplier: float = 1
@export var MagicMultiplier: float = 1
@export var SpeedBoost: int = 0

@export_subgroup("Skill points")
@export var SkillLevel: int
@export var SkillPoints: int
@export var SkillPointsFor: Array[int]


@export_group("Skills")
@export var Abilities: Array[Ability]
@export var StandardAttack: Ability

@export_group("Sprites")
@export var OV: SpriteFrames
@export var BT: SpriteFrames

@export var Offset: Vector2 = Vector2.ZERO
@export var Shadow: bool = false
@export var SoundSet: PackedScene = preload("res://sound/SFX/Battle/DefaultSet.tscn")
@export var Disappear: bool
@export var GlowDef: float = 0.3
@export var GlowSpecial: float = 0.0
@export var GlowAnims: Array[String] = []

@export_group("Party specific")

#@export_group("Battle params")
var NextAction: String = ""
var NextMove: Resource = null
var NextTarget: Actor = null
var node: AnimatedSprite2D
var States: Array[State]


func set_health(x):
	Health = x
	if Health > MaxHP: Health = MaxHP
	Global.check_party.emit()

func add_health(x):
	Health += x
	if Health > MaxHP: Health = MaxHP
	Global.check_party.emit()

func set_aura(x):
	Aura = x
	if Aura > MaxAura: Aura = MaxAura
	Global.check_party.emit()

func add_aura(x):
	Aura += x
	if Aura < 0: Aura = 0
	if Aura > MaxAura: Aura = MaxAura
	Global.check_party.emit()

func add_SP(x):
	SkillPoints += x

func damage(dmg: int, limiter:= false):
	var hp = Health - dmg
	if hp < 0:
		if limiter or CantDie or (ClutchDmg and Health > 15):
			hp = min(Health, randf_range(1, 5))
		else: hp = 0
	Health = hp

func calc_dmg(pow, is_magic: bool, E: Actor) -> int:
	var atk_stat: float
	if is_magic:
		print("Magic stat: ", E.Magic, " * ", E.MagicMultiplier)
		atk_stat = E.Magic * E.MagicMultiplier
	else:
		atk_stat = E.Attack * E.AttackMultiplier
		print("Attack stat: ", E.Attack, " * ", E.AttackMultiplier, " = ", atk_stat)
	print("(Power(%.2f) * AttackerStat(%.2f)) / ((Defence(%.2f * %.2f)) + 0.5)"% [pow, atk_stat, Defence, DefenceMultiplier])
	return int(max(((pow * atk_stat) / ((Defence * DefenceMultiplier) + 0.5)), 1))

func add_state(x, turns = -1):
	if Health == 0: return
	var state: State
	if x is State:
		state = x
	else:
		state = (await Loader.load_res("res://database/States/"+ x +".tres")).duplicate()
	if turns != -1:
		state.RemovedAfterTurns = turns
	States.push_back(state)
	if node != null:
		Global.Bt.on_state_add(state, self)
		if Global.Bt.get_node("Act/Effects").sprite_frames.has_animation(state.name):
			await Global.Bt.play_effect(state.name, self)
		#if node.get_node("State").sprite_frames.has_animation(state.name):
			#node.get_node("State").play(state.name)

func remove_state(x):
	var state: State
	if x is State:
		state = x
	else: state = await Global.get_state(x)
	States.erase(state)
	Global.Bt.remove_state_effect(state, self)

func has_state(x: String) -> bool:
	for i in States.size():
		if States[i-1].name == x:
			return true
	return false

func full_heal():
	Health = MaxHP
	Aura = MaxAura
