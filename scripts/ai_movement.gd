class_name AIMovementComponent
extends GridMovementComponent

const AI_COMPONENT_NAME := &"AIMovementComponent"

func get_component_name() -> StringName:
	return AI_COMPONENT_NAME

func get_component_names() -> Array[StringName]:
	var temp := super.get_component_names()
	temp.push_back(AI_COMPONENT_NAME)
	return temp

var path_cache: Array[Vector3i]
var path_goal: Vector3i = Vector3i(-1000, -1000, -1000)

func _possibleDirections(_from: Vector3i) -> Array[Vector3i]:
	return [Vector3i(1, 0, 0), Vector3i(0, 0, 1), Vector3i(-1, 0, 0), Vector3i(0, 0, -1)]

class LocationValue:
	var loc: Vector3i
	var value: int
	var start_distance: int
	var previous_location: LocationValue = null

	static func from_point(p: Vector3i, value: int = -1, start_disctance: int = 0) -> LocationValue:
		var temp := LocationValue.new()
		temp.loc = p
		temp.value = value
		temp.start_distance = start_disctance
		return temp

func _pathfindDistance(from: Vector3i, to: Vector3i) -> int:
	var temp := from - to
	return absi(temp.x) + absi(temp.z)

func _pathfindTo(pos: Vector3i, obstaclePred: Callable, maxDistance: int = 1000000) -> Array[Vector3i]:
	var candidatePoints: Array[LocationValue] = [LocationValue.from_point(pos, _pathfindDistance(pos, grid_coordinate))]
	var passedPoints: Array[LocationValue] = [LocationValue.from_point(pos, _pathfindDistance(pos, grid_coordinate))]
	var endLocation: LocationValue
	var pathFound = false
	while not pathFound:
		if candidatePoints.is_empty():
			break
		var currentPoint := candidatePoints.pop_front() as LocationValue
		var nextStartDistance := currentPoint.start_distance + 1
		if nextStartDistance >= maxDistance:
			continue
		for dir in _possibleDirections(currentPoint.loc):
			var nextCandidate := currentPoint.loc + dir
			var nextValue := _pathfindDistance(nextCandidate, grid_coordinate)
			var previousEnc := passedPoints.filter(func(e): return e.loc == nextCandidate)
			if not previousEnc.is_empty():
				# we were here before so skip
				continue
			if obstaclePred.call(nextCandidate):
				continue
			var newLocValue := LocationValue.from_point(nextCandidate, nextValue, nextStartDistance)
			newLocValue.previous_location = currentPoint
			passedPoints.push_back(newLocValue)
			if nextCandidate == grid_coordinate:
				pathFound = true
				endLocation = newLocValue
			
			var insPosition := candidatePoints.bsearch_custom(newLocValue, func(a, b): 
				return a.value + a.start_distance < b.value + b.start_distance, true)
			candidatePoints.insert(insPosition, newLocValue)
	
	if pathFound:
		var result: Array[Vector3i] = []
		endLocation = endLocation.previous_location
		while endLocation:
			result.push_back(endLocation.loc)
			endLocation = endLocation.previous_location
		return result
			
	return []

enum {POSITION_REACHED, NO_PATH, MOVING}
## returns one of the POSITION_REACHED, NO_PATH, MOVING
func move_to(pos: Vector3i) -> int:
	if pos != path_goal:
		path_cache = _pathfindTo(pos, func(p: Vector3i): 
			return Obstacles.is_an_obstacle(p) or Globals.get_current_level().is_a_wall(p))
		path_goal = pos
	print("Current path is ", path_cache)
	if grid_coordinate == pos:
		return POSITION_REACHED
	if path_cache.is_empty():
		return NO_PATH
	var next_cell := path_cache[0] as Vector3i

	if grid_direction + grid_coordinate == next_cell:
		# move me forward
		move_forward()
		path_cache.pop_front()
	elif grid_coordinate - grid_direction == next_cell:
		# do 180
		rotate_left()
	elif grid_coordinate + Vector3i(grid_direction.z, 0, grid_direction.x) == next_cell:
		rotate_left()
	elif grid_coordinate + Vector3i(grid_direction.z, 0, grid_direction.x) == next_cell:
		rotate_right()
	else:
		push_error("This cant happen lol")

	return MOVING

## returns one of the POSITION_REACHED, NO_PATH, MOVING
func approach(pos: Vector3i) -> int:
	if pos != path_goal:
		path_cache = _pathfindTo(pos, func(p: Vector3i): 
			return Obstacles.is_an_obstacle(p) or Globals.get_current_level().is_a_wall(p))
		path_goal = pos
	print("Current path is ", path_cache)
	if path_cache.is_empty():
		return NO_PATH
	var next_cell := path_cache[0] as Vector3i

	if next_cell == pos:
		return POSITION_REACHED

	if grid_direction + grid_coordinate == next_cell:
		# move me forward
		move_forward()
		path_cache.pop_front()
	elif grid_coordinate - grid_direction == next_cell:
		# do 180
		print("180 - rotating left")
		rotate_left()
	elif grid_coordinate + Vector3i(grid_direction.z, 0, -grid_direction.x) == next_cell:
		print("rotating left")
		rotate_left()
	elif grid_coordinate + Vector3i(-grid_direction.z, 0, grid_direction.x) == next_cell:
		print("rotating right")
		rotate_right()
	else:
		push_error("This cant happen lol")

	return MOVING
