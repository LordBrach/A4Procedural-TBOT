class_name ClientData extends Resource


#@export var Testets = load("res://imports/kenney_rpg-urban-pack/Tiles/tile_0001.png")
@export var CustomerType: Globals.CUSTOMER_TYPE

@export var Visuals : customer_sprite_collection

## Options de difficultée de la quête générée par le pnj, si plusieurs => choix random basé sur le float attaché (proba)
@export var DifficultyOptions : Dictionary[Globals.DIFFICULTY_OPTIONS, float]
## Options de conditions de conduite de la quête générée par le pnj, si plusieurs => choix random basé sur le float attaché (proba)
@export var DrivingConditions : Dictionary[Globals.DRIVING_CONDITIONS, float]
# Options d'arrivées
@export var TargetDestinations : Dictionary[Globals.EXIT_TYPES, float] = {
	Globals.EXIT_TYPES.Random: 1
}

"res://imports/kenney_rpg-urban-pack/Tiles/tile_0050.png"

func GetDifficulty() -> Globals.DIFFICULTY_OPTIONS :
	var total : float = 0
	for value in  DifficultyOptions.values() :
		total += value
	
	var random : float = randf_range(0, total)
	for difficulty in DifficultyOptions :
		if (DifficultyOptions[difficulty] > random) :
			random -= DifficultyOptions[difficulty]
		else :
			return difficulty
	
	#for security
	if (DifficultyOptions != null) :
		return DifficultyOptions.keys().pick_random()
	else :
		print("Customer Data Error : '", Globals.CUSTOMER_TYPE, "' has no difficulty set, returned 'SameRoom' as default")
		return Globals.DIFFICULTY_OPTIONS.SameRoom

func GetCondition() -> Globals.DRIVING_CONDITIONS :
	var total : float = 0
	for value in  DrivingConditions.values() :
		total += value
	
	var random : float = randf_range(0, total)
	for difficulty in DrivingConditions :
		if (DrivingConditions[difficulty] > random) :
			random -= DrivingConditions[difficulty]
		else :
			return difficulty
	
	#for security
	if (DrivingConditions != null) :
		return DrivingConditions.keys().pick_random()
	else :
		print("Customer Data Error : '", Globals.CUSTOMER_TYPE, "' has no driving condition set, returned 'None' as default")
		return Globals.DRIVING_CONDITIONS.None

func GetDestination() -> Globals.EXIT_TYPES :
	var total : float = 0
	for value in  TargetDestinations.values() :
		total += value
	
	var random : float = randf_range(0, total)
	for difficulty in TargetDestinations :
		if (TargetDestinations[difficulty] > random) :
			random -= TargetDestinations[difficulty]
		else :
			return difficulty
	
	#for security
	if (TargetDestinations != null) :
		return TargetDestinations.keys().pick_random()
	else :
		print("Customer Data Error : '", Globals.CUSTOMER_TYPE, "' has no quest end set, returned 'Any' as default")
		return Globals.EXIT_TYPES.Any

#region deprecated
# didnt work as i wanted 
## Options de difficultée de la quête générée par le pnj, si plusieurs => choix random
#@export_flags("Short", "Medium", "Long", "ExtraLong") var DifficultyOptions : int = 0;
## Conditions de conduite
#@export_flags("None", "Quick", "Careful", "HurtPeople", "LawAbidingCitizen") var DrivingConditions : int = 0;

#@export var CustomerSpritesIdle : Dictionary[Globals.SPRITE_DIRECTION, Texture2D] = {
		#Globals.SPRITE_DIRECTION.UP: preload("res://imports/kenney_rpg-urban-pack/Tiles/tile_0052.png"),
		#Globals.SPRITE_DIRECTION.RIGHT:preload("res://imports/kenney_rpg-urban-pack/Tiles/tile_0053.png"),
		#Globals.SPRITE_DIRECTION.DOWN: preload("res://imports/kenney_rpg-urban-pack/Tiles/tile_0051.png"),
		#Globals.SPRITE_DIRECTION.LEFT: preload("res://imports/kenney_rpg-urban-pack/Tiles/tile_0050.png"),
		#}

#endregion
