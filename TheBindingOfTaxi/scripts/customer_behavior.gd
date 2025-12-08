class_name Customer extends CollectibleBase

#customer data
@export var CustomerData : Array[Resource]

var SelectedCustomer
var SelectedDifficulty
var SelectedDrivingCondition
var SelectedDestination

func _ready() -> void:
	print("Customer array size: ", CustomerData.size())
	if(CustomerData.size() == 1) :
		SelectedCustomer = CustomerData[0]
	elif (!CustomerData.is_empty()):
		var i : int = randi_range(0, CustomerData.size() -1)
		SelectedCustomer = CustomerData[i];
	else :
		self.queue_free()
		return
	randomizeCustomerValues()
	
func randomizeCustomerValues() -> void:
	#print("Customer type: ", SelectedCustomer.CustomerType);
	#print("DifficultyOptions: ", SelectedCustomer.DifficultyOptions);
	#print("DrivingConditions: ", SelectedCustomer.DrivingConditions);
	SelectedDifficulty = RandomWeightedDictionnary(SelectedCustomer.DifficultyOptions)
	SelectedDrivingCondition = RandomWeightedDictionnary(SelectedCustomer.DrivingConditions)
	SelectedDestination = RandomWeightedDictionnary(SelectedCustomer.TargetDestinations)

	print("Customer type: ", Globals.CUSTOMER_TYPE.keys()[SelectedCustomer.CustomerType]);
	print("Selected Difficulty Option: ", Globals.DIFFICULTY_OPTIONS.keys()[SelectedDifficulty]);
	print("Selected Driving Condition: ", Globals.DRIVING_CONDITIONS.keys()[SelectedDrivingCondition]);
	print("Selected Destination : ", Globals.EXIT_TYPES.keys()[SelectedDestination]);

func RandomWeightedDictionnary(dict):
	var sumWeights : float = 0.0;
	for element in dict :
		sumWeights += dict[element]
	print("Total weight difficultyoptions: ", sumWeights)
	var randSelectednum : float = randf_range(0, sumWeights);
	for element in dict :
		if(randSelectednum < dict[element]) :
			return element
		randSelectednum -= dict[element]
	return 0
		
func on_collect() -> void:
	super()
	 #add customer & quest data to the player here
	print("Customer type: ", SelectedCustomer.CustomerType);
	Player.Instance.add_customer(self)
	#TODO add attach to worldgenmanager
	
func pickup_result(result : bool) -> void:
	if(result == true) :
		print("Hello I am a customer, pls drive me to the ", Globals.EXIT_TYPES.keys()[SelectedDestination])
		queue_free()
	else :
		print("Cant pick me up, not enough space in your car !")
		pass 
	pass

func _on_body_entered(body:Node2D) -> void:
	if body is Player:
		on_collect()
		return
