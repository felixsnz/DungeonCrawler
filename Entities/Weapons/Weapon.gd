extends Spatial

onready var dagger_sprite = load("res://Sprites/Dagger.png")

enum WEAPONS {
	DAGGER
}

export var weapon = WEAPONS.DAGGER

func _ready():
	match (weapon):
		WEAPONS.DAGGER:
			$WeaponSprite.texture = dagger_sprite
