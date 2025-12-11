@tool
class_name textbox extends Node
@onready var Visuals : CanvasItem = $BG
@onready var TextNode : Label = $BG/Text
@onready var AudioNode : AudioStreamPlayer2D = $AudioStreamPlayer2D
@export var DelayBetweenLetters: float = 0.1
@export var DelayBeforeKill: float = 5

@export var CorrectSounds : Array[AudioStreamWAV] = [ 
preload("res://TheBindingOfTaxi/Audio/BlaBlubla-1.wav"),
preload("res://TheBindingOfTaxi/Audio/BlaBlubla-2.wav" ), 
preload( "res://TheBindingOfTaxi/Audio/BlaBlubla-3.wav"), 
preload("res://TheBindingOfTaxi/Audio/BlaBlubla-4.wav" ), 
preload( "res://TheBindingOfTaxi/Audio/BlaBlubla-5.wav"), 
preload("res://TheBindingOfTaxi/Audio/BlaBlubla-6.wav" ), 
preload( "res://TheBindingOfTaxi/Audio/BlaBlubla-7.wav"), 
preload("res://TheBindingOfTaxi/Audio/BlaBlubla-8.wav")
]
var NewTaskId: int = 0

@export_tool_button("ActivateTextBox")
var buttonenable = EnableTextBox

@export_tool_button("DisableTextBox")
var buttondisable = DisableTextBox

func EnableTextBox(InText : String = "lorem ipsum"):
	NewTaskId += 1  
	Visuals.visible = true
	PrintText(InText, NewTaskId)
	pass
	
func PrintText(InText : String, TaskID : int):
	TextNode.text = InText
	TextNode.visible_characters = 0;
	
	while (TextNode.visible_characters < InText.length()) :
		if(TaskID != NewTaskId):
			return
		TextNode.visible_characters += 1;
		AudioNode.stream = CorrectSounds[randi_range(0, CorrectSounds.size() -1)]
		AudioNode.play()
		await get_tree().create_timer(DelayBetweenLetters).timeout
		 
	await get_tree().create_timer(DelayBeforeKill).timeout
	if TaskID == NewTaskId:
		DisableTextBox()

func DisableTextBox():
	TextNode.text = ""
	Visuals.visible = false
	AudioNode.stop()
	pass
