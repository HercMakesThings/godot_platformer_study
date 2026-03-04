class_name AbilityManager extends Node

@export var body: CharacterBody2D

func _ready() -> void:
	if body == null:
		return
	for ability in get_children():
		if ability is Ability:
			print(str(body.name) + " has ability: " + str(ability.name))
			
func update_abilities(input: InputGameComponent, movement: MovementComponent) -> void:
	if body == null:
		return
	for ability in get_children():
		if ability is Ability:
			ability.tick_ability(input, movement)
