@tool 
extends Node2D

#@export var darulez : Dictionary
@export var test_json_dict : tracery_dict
@export var test_dialogue_type : Globals.CUSTOMER_DIALOGUE_TYPE

@export var outputbox : textbox


@export_tool_button("TestDialogue *1")
var buttonLoad = _ready

@export_tool_button("TestDialogue *10")
var buttonLoad2 = _tenLiner

@export_tool_button("TestTextbox")
var buttonLoad3 = _SendLineToTextbox

var ExitDialogueSnippets : Dictionary [Globals.EXIT_TYPES, String] = {
	Globals.EXIT_TYPES.Random : "[debug]",
	Globals.EXIT_TYPES.Parking : "au parking",
	Globals.EXIT_TYPES.Bench : "à mon banc",
	Globals.EXIT_TYPES.Park : "au parc",
	Globals.EXIT_TYPES.House : "chez moi",
	Globals.EXIT_TYPES.Shop : "au magasin"

}

func _SendLineToTextbox() -> void:
	if(is_instance_valid(outputbox)):
		outputbox.EnableTextBox(_oneLiner())
		
func _oneLiner() -> String:
	var json_content = test_json_dict.values[test_dialogue_type].data
	var tracery_parsed : Tracery.Grammar =  Tracery.Grammar.new(json_content)
	var out_string : String  = tracery_parsed.flatten("#line#")
	
	out_string = _replaceBalise(out_string, ExitDialogueSnippets[randi_range(1, 5)], "$LOCATION$")
	return(out_string)
	
func _replaceBalise(inString : String,  inNewWord : String, Balise : String) -> String:
	inString = inString.replace(Balise, inNewWord)
	return inString

func _tenLiner() ->void:
	var i = 0
	while (i < 10):
		print(_oneLiner())
		i += 1;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(_oneLiner())
#
