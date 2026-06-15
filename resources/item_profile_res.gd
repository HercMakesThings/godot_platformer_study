class_name ItemProfile extends Resource

@export var model: Texture2D

@export var move_sprite_frames: Array[SpriteFrames]

## 0 is lowest priority
@export var pickup_priority: int = 0

enum ItemType{WEAPON, GADGET, EQUIPPABLE}
var type: ItemType = ItemType.WEAPON
