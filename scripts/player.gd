class_name Player extends CharacterBase

static var Instance : Player
# Base
@export_group("Input")
@export_range (0.0, 1.0) var controller_dead_zone : float = 0.3
@export var PlayerSprite : AnimatedSprite2D
# Customer related stuff
@export var MaxCustomerCount : int = 1;
@export var  CustomerList : Dictionary[int, Customer]
@export var SavedExits : Array[QuestEnd]

@onready var TraceryFuncs : TraceryHelperFuncs = $PlayerUI/TraceryHelper
@onready var PlayerQuestComplete : AudioStreamPlayer = $Sounds/SFXQuestComplete
@onready var PlayerQuestAccepted : AudioStreamPlayer = $Sounds/SFXQuestAccepted
@onready var PlayerQuestRefused : AudioStreamPlayer = $Sounds/SFXQuestRefused
var idCustomer : int = 0;
var customerDestination : Vector2

var hasDestination : bool = false
@export var arrowSprite : Node2D
var SavedCustomerType : Globals.CUSTOMER_TYPE
var tryPlayBlabla: bool = false
var isAwaitingBlabla: bool = false

# Collectible
var key_count : int
# Signals
var OnPickupCustomer : Signal
var OnPickupCustomerFailed : Signal
var OnQuestFinished : Signal
func _init() -> void:
	Instance = self


func _ready() -> void:
	_set_state(STATE.IDLE)
	hasDestination = false
	arrowSprite.modulate.a = 0


func _process(delta: float) -> void:
	super(delta)
	_update_inputs()
	#_update_room()
	if(tryPlayBlabla == true):
		tryPlayBlabla = false
		isAwaitingBlabla = true
		await get_tree().create_timer(10).timeout
		if(isAwaitingBlabla == true) :
			isAwaitingBlabla = false
			TraceryFuncs._SendLineToTextbox(SavedCustomerType,Globals.CUSTOMER_DIALOGUE_TYPE.COMMENT)
			
		
	
	if (hasDestination) :
		if (arrowSprite.modulate.a == 0) :
			arrowSprite.modulate.a = 1
		arrowSprite.look_at(customerDestination)

#region prototype
func enter_room(room : Room) -> void:
	var previous = _room
	_room = room
	_room.on_enter_room(previous)


func _update_room() -> void:
	var room_bounds : Rect2 = _room.get_world_bounds()
	var next_room : Room = null
	if position.x > room_bounds.end.x:
		next_room = _room.get_adjacent_room(Utils.ORIENTATION.EAST, position)
	elif position.x < room_bounds.position.x:
		next_room = _room.get_adjacent_room(Utils.ORIENTATION.WEST, position)
	elif position.y < room_bounds.position.y:
		next_room = _room.get_adjacent_room(Utils.ORIENTATION.NORTH, position)
	elif position.y > room_bounds.end.y:
		next_room = _room.get_adjacent_room(Utils.ORIENTATION.SOUTH, position)

	if next_room != null:
		enter_room(next_room)
func _update_inputs() -> void:
	var savedFrame = PlayerSprite.frame;
	if _can_move():
		_direction = Vector2(Input.get_axis("Left", "Right"), Input.get_axis("Up", "Down"))
		#print(_direction)
		if(abs(_direction.x) > abs(_direction.y)):
			if(_direction.x >= 0):
				PlayerSprite.set_frame(2);
			else:
				PlayerSprite.set_frame(0);
		elif(abs(_direction.x) < abs(_direction.y)):
			if(_direction.y > 0):
				PlayerSprite.set_frame(1);
			else:
				PlayerSprite.set_frame(3);
		if _direction.length() < controller_dead_zone:
			_direction = Vector2.ZERO
			PlayerSprite.set_frame(savedFrame)
		else:
			_direction = _direction.normalized()

		if Input.is_action_pressed("Attack"):
			_attack()
	else:
		_direction = Vector2.ZERO
		PlayerSprite.set_frame(savedFrame)

func _set_state(state : STATE) -> void:
	super(state)
	match _state:
		STATE.STUNNED:
			_current_movement = stunned_movemement
		STATE.DEAD:
			_end_blink()
			_set_color(dead_color)
		_:
			_current_movement = default_movement

	if !_can_move():
		_direction = Vector2.ZERO

func _update_state(_delta : float) -> void:
	match _state:
		STATE.ATTACKING:
			_spawn_attack_scene()
			_set_state(STATE.IDLE)
#endregion
#region customerHandling
## Try picking up a customer
func add_customer(data : Customer) -> void:
	print("Current num of customers: ", CustomerList.size())
	if(CustomerList.size() < MaxCustomerCount) :
		print(data.SelectedCustomer)
		if (!link_to_quest(data)) :
			CustomerList.erase(idCustomer)
			OnPickupCustomerFailed.emit()
			data.pickup_result(false)
		else :
			SavedCustomerType = data.SelectedCustomer.CustomerType
			OnPickupCustomer.emit()
			TraceryFuncs._SendLineToTextbox(data.SelectedCustomer.CustomerType, Globals.CUSTOMER_DIALOGUE_TYPE.INTRO)
			CustomerList[idCustomer] = data
			idCustomer += 1
			data.pickup_result(true)
			PlayerQuestAccepted.play()
			tryPlayBlabla = true
	else :
		OnPickupCustomerFailed.emit()
		data.pickup_result(false)
		PlayerQuestRefused.play()
		pass

func link_to_quest(customer : Customer) -> bool:
	if (WorldGen != null) :
		customerDestination = WorldGen.GetQuestEnd(customer, idCustomer)
		if (customerDestination == Vector2.ZERO) :
			hasDestination = false
			arrowSprite.modulate.a = 0
			printerr("Customer Pickup Error : Couldnt find suitable exit for client...")
			return false
		else :
			hasDestination = true
			arrowSprite.modulate.a = 1
			print("OK")
			return true
	else :
		printerr("Customer Pickup Error : WorldGenManager instance not found")
		return false

## When a quest is completed, removes the client linked to the quest from the car
func complete_quest(LinkedClientId : int) ->void:
	tryPlayBlabla = false
	isAwaitingBlabla = false
	PlayerQuestComplete.play()
	CustomerList.erase(LinkedClientId)
	TraceryFuncs._SendLineToTextbox(
		SavedCustomerType,
		 Globals.CUSTOMER_DIALOGUE_TYPE.OUTRO)
	hasDestination = false
	arrowSprite.modulate.a = 0
	customerDestination = Vector2.ZERO
	
	OnQuestFinished.emit()
	pass
#endregion

func on_runoverclient():
		TraceryFuncs._SendLineToTextbox(
		SavedCustomerType,
		 Globals.CUSTOMER_DIALOGUE_TYPE.REACT)
		
func on_blabla():
		TraceryFuncs._SendLineToTextbox(
		SavedCustomerType,
		 Globals.CUSTOMER_DIALOGUE_TYPE.COMMENT)
