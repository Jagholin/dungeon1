extends Node

var obstacles: Array[Vector3i]

func register_obstacle(obs: Vector3i):
	print("register obstacle at, ", obs)
	obstacles.push_back(obs)

func unregister_obstacle(obs: Vector3i):
	print("unregister obstacle at, ", obs)
	obstacles.erase(obs)

func is_an_obstacle(q: Vector3i) -> bool:
	return q in obstacles
