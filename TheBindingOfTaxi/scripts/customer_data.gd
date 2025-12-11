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
