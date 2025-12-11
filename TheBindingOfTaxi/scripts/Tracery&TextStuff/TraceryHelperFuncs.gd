@tool 
class_name TraceryHelperFuncs extends Node

@export_group("Main Properties")
@export var outputbox : textbox
@export var CustomerDicts : Dictionary[Globals.CUSTOMER_TYPE, tracery_dict]

@export_group("Test Properties")
@export var test_json_dict : tracery_dict
@export var test_dialogue_type : Globals.CUSTOMER_DIALOGUE_TYPE

var ExitDialogueSnippets : Dictionary [Globals.EXIT_TYPES, String] = {
	Globals.EXIT_TYPES.Any : "[debug]",
	Globals.EXIT_TYPES.Parking : "au parking",
	Globals.EXIT_TYPES.Bench : "à mon banc",
	Globals.EXIT_TYPES.House : "chez moi",
	Globals.EXIT_TYPES.Park : "au parc",
	Globals.EXIT_TYPES.Lake : " au lac ",
	Globals.EXIT_TYPES.University : " à mon université ",
	Globals.EXIT_TYPES.Shop : "au magasin"
}
@export_group("Test Buttons")
@export_tool_button("TestDialogue *1")
var buttonLoad = _ready
@export_tool_button("TestDialogue *10")
var buttonLoad2 = _tenLiner
@export_tool_button("TestTextbox")
var buttonLoad3 = _testTextbox

func _tenLiner() ->void:
	var i = 0
	while (i < 10):
		print(_oneLinerDebug())
		i += 1;
	
func _testTextbox():
	_SendLineToTextbox(Globals.CUSTOMER_TYPE.Default, Globals.CUSTOMER_DIALOGUE_TYPE.INTRO)

func _SendLineToTextbox(customer_type : Globals.CUSTOMER_TYPE, dialogue_chosen : Globals.CUSTOMER_DIALOGUE_TYPE) -> void:
	if(is_instance_valid(outputbox)):
		var SelectedCustomerDict : tracery_dict = CustomerDicts.get(customer_type)
		var SelectedDialogueChosen = SelectedCustomerDict.values.get(dialogue_chosen)
		var content = SelectedDialogueChosen.data
		print(content)
		outputbox.EnableTextBox(_oneLiner(content))

	else:
		printerr("No textbox linked to the TraceryHelperFuncs")

func _oneLiner(json_content : Dictionary) -> String:
	var tracery_parsed : Tracery.Grammar =  Tracery.Grammar.new(json_content)
	var out_string : String  = tracery_parsed.flatten("#line#")
	
	out_string = _replaceBalise(out_string, ExitDialogueSnippets[randi_range(1, 5)], "$LOCATION$")
	return(out_string)
	
		
func _oneLinerDebug() -> String:
	var json_content = test_json_dict.values[test_dialogue_type].data
	var tracery_parsed : Tracery.Grammar =  Tracery.Grammar.new(json_content)
	var out_string : String  = tracery_parsed.flatten("#line#")
	
	out_string = _replaceBalise(out_string, ExitDialogueSnippets[randi_range(1, 5)], "$LOCATION$")
	return(out_string)
	
func _replaceBalise(inString : String,  inNewWord : String, Balise : String) -> String:
	inString = inString.replace(Balise, inNewWord)
	return inString


## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	#outputbox.EnableTextBox("")
	#print(_oneLinerDebug())
#
