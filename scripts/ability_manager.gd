class_name AbilityManager extends Node

@export var body: CharacterBody2D

func _ready() -> void:
	if body == null:
		return
	for ability in get_children():
		if ability is Ability:
			#print(str(body.name) + " has ability: " + str(ability.name))
			pass
			
#func update_abilities(input: InputGameComponent, movement: MovementComponent, delta: float) -> void:
#func update_abilities(movement: MovementManager, delta: float) -> void:
#func update_abilities(movement: MovementRes, delta: float) -> void:
func update_abilities(entity: Entity, delta: float) -> void:
	if body == null:
		return
	for ability in get_children():
		if ability is Ability:
			#ability.tick_ability(input, movement, delta)
			#ability.tick_ability(movement, delta)
			ability.tick_ability(entity, delta)
