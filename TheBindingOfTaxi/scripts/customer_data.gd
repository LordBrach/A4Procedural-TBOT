class_name ClientData extends Resource

enum CUSTOMER_TYPE { Default, Old , Gangster , Student , Balthazar } 
@export var CustomerType: CUSTOMER_TYPE

## Options de difficultée de la quête générée par le pnj, si plusieurs => choix random basé sur le float attaché (proba)
@export var DifficultyOptions : Dictionary[Globals.DIFFICULTY_OPTIONS, float]
## Options de conditions de conduite de la quête générée par le pnj, si plusieurs => choix random basé sur le float attaché (proba)
@export var DrivingConditions : Dictionary[Globals.DRIVING_CONDITIONS, float]



# didnt work as i wanted 
## Options de difficultée de la quête générée par le pnj, si plusieurs => choix random
#@export_flags("Short", "Medium", "Long", "ExtraLong") var DifficultyOptions : int = 0;
## Conditions de conduite
#@export_flags("None", "Quick", "Careful", "HurtPeople", "LawAbidingCitizen") var DrivingConditions : int = 0;
