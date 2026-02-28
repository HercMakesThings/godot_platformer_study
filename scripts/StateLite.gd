extends State
class_name StateLite

var state_name: String
var parent_class: FSMLite
var frame: int

func _init(n: String, ParentClass=false):
	self.state_name = n
	self.parent_class = ParentClass
	
#func _physics_process(delta: float) -> void:
	#frame+=1
	#if frame > 999:
		#frame=0
		
func Enter(_packet):
	super(_packet)
	frame=0
	
func Update(delta: float):
	super(delta)
	frame+=1
	
func Exit():
	super()
	frame=0
