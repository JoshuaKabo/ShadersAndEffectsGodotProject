extends Node2D

export var radius = 1.0


func _draw():
	draw_circle(Vector2.ZERO, radius, Color(0.0, 0.0, 0.0))
