extends Spatial

onready var dagger_sprite = load("res://Sprites/Dagger.png")

enum WEAPONS {
	DAGGER
}

export var weapon = WEAPONS.DAGGER

func _ready():
	match (weapon):
		WEAPONS.DAGGER:
			print("popo")
			$WeaponSprite.texture = dagger_sprite
		
	pass
