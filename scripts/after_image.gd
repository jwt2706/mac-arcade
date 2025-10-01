extends StaticBody2D

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	animated_sprite.play("idle")
	
	#collision_shape.disabled = true
	#await get_tree().create_timer(1.0).timeout
	#collision_shape.disabled = false
