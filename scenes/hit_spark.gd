extends Node2D

func _ready():
	print("SPARK SPAWNED")
	queue_redraw()

func _draw():
	draw_rect(Rect2(-20, -20, 40, 40), Color.RED)
