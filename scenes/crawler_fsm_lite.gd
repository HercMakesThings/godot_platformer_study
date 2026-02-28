extends FSMLite
class_name CrawlerFSMLite

#@onready var npc = $CrawlerEnemy
@onready var npc = get_parent()

class IdleState extends StateLite:
	#var state_name = "IdleState"
	#func get_state_name():
		#return self.name
	signal is_idling
	#func Enter(_packet):
		#pass
	func Update(delta):
		super(delta)
		is_idling.emit()
		#if CrawlerFSMLite.npc.atk_range.is_colliding():
		#print(parent_class.npc)
		if self.parent_class.npc:
			if parent_class.npc.atk_range.is_colliding() and parent_class.npc.atk_range.get_collider() is Hurtbox:
				#print("colliding!")
				state_transition.emit(self, "AttackState")
	#func Exit():
		#pass
		
class AttackState extends StateLite:
	#var atk_frames := 0
	#var state_name = "AttackState"
	#func get_state_name():
		#return self.name
	#func Enter(_packet):
		#super(_packet)
		#atk_frames = 0
	func Update(delta):
		super(delta)
		#atk_frames = atk_frames+1
		#if atk_frames > 32:
		if frame > 32:
			state_transition.emit(self, "IdleState")
			return
	#func Exit():
		#super()
		#atk_frames = 0
		
class DamagedState extends StateLite:
	pass
	#var state_name = "DamagedState"
	#func get_state_name():
		#return self.name
	
class DeathState extends StateLite:
	pass
	#var state_name = "DeathState"
	#func get_state_name():
		#return self.name
		
func get_states():
	#var idle = IdleState.new().get_script() as Script
	#var atk = AttackState.new().get_script() as Script
	#var dmg = DamagedState.new().get_script() as Script
	#var dead = DeathState.new().get_script() as Script
	#var idleRef = Node.new()
	#idleRef.set_script(idle)
	#var atkRef = Node.new()
	#atkRef.set_script(atk)
	#var dmgRef = Node.new()
	#dmgRef.set_script(dmg)
	#var deadRef = Node.new()
	#deadRef.set_script(dead)
	#return {
		#"IdleState": CrawlerFSMLite.IdleState.new("IdleState"),
		#"AttackState": CrawlerFSMLite.AttackState.new("AttackState"),
		#"DamagedState": CrawlerFSMLite.DamagedState.new("DamagedState"),
		#"DeathState": CrawlerFSMLite.DeathState.new("DeathState")
	#}
	return [
		CrawlerFSMLite.IdleState.new("IdleState", self),
		CrawlerFSMLite.AttackState.new("AttackState", self),
		CrawlerFSMLite.DamagedState.new("DamagedState", self),
		CrawlerFSMLite.DeathState.new("DeathState", self)
	]
	#return {
		#"IdleState": idleRef,
		#"AttackState":atkRef,
		#"DamagedState": dmgRef,
		#"DeathState": deadRef
	#}
