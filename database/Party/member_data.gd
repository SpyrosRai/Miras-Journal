extends Resource

class_name Actor

@export var FirstName : String = "Name"
@export var LastName : String = ""

@export var IsEnemy : bool = true

@export var WeaponType : String
@export var Controllable : bool = false
@export var StatsVisible : bool = true

@export_category("Art")
@export var PartyIcon : Texture
@export var RenderArtwork : Texture
@export var RenderShadow : Texture
@export_range(1, 360) var AuraHue: int = 1
@export var PartyPage : Texture

@export_category("Color")
@export var MainColor : Color
@export var SecondaryColor : Color

@export var BoxProfile : TextProfile

@export_group("Stats")

@export var MaxHP : int
@export var MaxAura : int
@export_range(0, 2) var Attack : float
@export_range(0, 2) var Magic : float
@export_range(0, 2) var Defence : float
@export_range(0, 10) var Speed : float

@export_subgroup("Current")
@export_range(0, 9999) var Health : int
@export_range(0, 9999) var Aura : int

@export_subgroup("Skill points")
@export var SkillLevel : int
@export var SkillPoints : int
@export var SkillPointsFor : Array[int]


@export_group("Skills")
@export var Abilities: Array[Ability]
@export var StandardAttack: Ability

@export_group("Multipliers")
@export var AttackMultiplier : float = 1
@export var DefenceMultiplier : float = 1
@export var MagicMultiplier : float = 1
@export var SpeedMultiplier : float = 1

@export_group("Sprites")
@export var OV : SpriteFrames
@export var BT : SpriteFrames

@export var Offset: Vector2 = Vector2.ZERO
@export var Shadow: bool = false
@export var SoundSet: PackedScene = preload("res://sound/SFX/Battle/DefaultSet.tscn")
@export var Disappear: bool

@export_group("Battle params")
@export var NextAction: String = ""
@export var NextMove: Resource = null
@export var NextTarget: Actor = null
@export var node : AnimatedSprite2D
@export var States: Array[State]


func set_health(x):
	Health = x

func add_health(x):
	Health += x

func set_aura(x):
	Aura = x

func add_aura(x):
	Aura += x

func add_SP(x):
	SkillPoints += x

func damage(x, E_atk, E:Actor):
	Health -= calc_dmg(x, E_atk, E)
	if Health<0:
		Health = 0

func calc_dmg(x, AttackStat: float, E: Actor):
	#print(x, " *( ", DefenceMultiplier, " * " ,E.AttackMultiplier, " ) / (", Defence, " * ", DefenceMultiplier, ") = ", int(abs(((x * (AttackStat * E.AttackMultiplier)) / (Defence * DefenceMultiplier)))))
	return  int(abs(((x * (AttackStat * E.AttackMultiplier)) / (Defence * DefenceMultiplier))))

func add_state(x: String):
	States.push_back(load("res://database/States/"+ x +".tres").duplicate())

func remove_state(x: String):
	for i in States.size():
		if States[i-1].name == x:
			States.erase(States[i])


func has_state(x: String):
	for i in States.size():
		if States[i-1].name == x:
			return true
	return false