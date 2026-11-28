# Plays a move's events on screen, strictly in order, AFTER the game logic has already resolved them.
# It turns events into steps (AnimationSteps), hands each step to a "stage" (the board view, which owns the
# tweens) and waits that step's duration before the next one. Emits `finished` at the end.
# Check: F5 the greybox scene, make a match: pieces swap, pop, fall and drop in one after another.
class_name AnimationQueue
extends Node

signal finished
## Sent the moment a "goal_done" step is reached, so the HUD can show the goal as achieved while the rest plays.
signal goal_reached(step: Dictionary)

## Multiply every duration (1.0 = the GDD timings; 2.0 = half speed, handy when checking by eye).
@export var slow_motion: float = 1.0

## The node that draws steps. It must have `play_step(step: Dictionary) -> void`.
var stage: Node = null

var _playing: bool = false


func is_playing() -> bool:
	return _playing


## Builds the steps for these events and plays them. `before` = BoardSnapshot.piece_grid(board) taken
## before the move; `board` = the board after it.
func play(events: Array[BoardEvent], before: Dictionary, board: BoardModel) -> void:
	await play_steps(AnimationSteps.build(events, before, board))


## Plays ready-made steps one after another.
func play_steps(steps: Array[Dictionary]) -> void:
	_playing = true
	for step in steps:
		if String(step.get("type", "")) == "goal_done":
			goal_reached.emit(step)
		if stage != null:
			stage.play_step(step)
		var seconds: float = float(step.get("duration", 0.0)) * slow_motion
		if seconds > 0.0:
			await get_tree().create_timer(seconds).timeout
	_playing = false
	finished.emit()
