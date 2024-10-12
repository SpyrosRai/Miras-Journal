extends Resource
class_name SaveFile

@export var Name: String="Autosave"
@export var Datetime: Dictionary
@export var Party: Array[StringName] = [&"Mira", &"", &"", &""]
@export var RoomPath: String
@export var RoomName: String = "???"
@export var Position:Vector2
@export var Camera: int = 0
@export var Z: int = 1
@export var Members: Array[Actor]
@export var Defeated: Array
@export var StartTime: float
@export var SavedTime: float
@export var PlayTime: float
@export var Preview: Texture = preload("res://art/Previews/1.png")
@export_group("Items")
@export var Inventory: Array[ItemData]
@export var Flags: Array[StringName]
@export var Day: int
@export var TimeOfDay: int
@export var version = 3
