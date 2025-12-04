class_name Customer extends CollectibleBase

#customer data
@export var CustomerData : Array[Resource]

var SelectedCustomer
var SelectedDifficulty
var SelectedDrivingCondition

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
    print("Customer type: ", SelectedCustomer.CustomerType);
    print("Selected Difficulty Option: ", SelectedDifficulty);
    print("Selected Driving Condition: ", SelectedDrivingCondition);

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
        
func on_collect() -> void:
    super()
     #add customer & quest data to the player here
    print("Customer type: ", SelectedCustomer.CustomerType);
    print("I am customer, drive me to: ")
    #TODO replace with attach to worldgenmanager

func _on_body_entered(body:Node2D) -> void:
    super(body)
