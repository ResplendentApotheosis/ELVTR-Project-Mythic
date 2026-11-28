# Grey-box playable level: loads LEVEL_PATH with the real LevelLoader, lets you click/drag to swap or click a
# special to tap, plays the events with AnimationQueue, and shows moves, goals, coins, lives and the
# win / continue-offer / retry panels. All rules come from LevelSession -> the real modules.
# Debug builds only (DebugGate): "Play again", jump-to-level, a "moves next attempt" box (keys 1-9) and a
# "Level" box: press L (or click it), type 1-50, press Enter or Load to play res://levels/level_NNN.json.
# Check: press F5 in the editor (this is the main scene) and make a match; press L, type 1, press Enter.
extends Control

## The level this scene starts with. The debug "Level" box (key L) switches to res://levels/level_NNN.json.
const LEVEL_PATH: String = "res://tests/level_loader/fixtures/level_fixture_012.json"
## A separate save file, so the grey box never touches the real player save.
const SAVE_PATH: String = "user://greybox_save.json"

@onready var board_view: GreyboxBoardView = $BoardView
@onready var queue: AnimationQueue = $AnimationQueue
@onready var level_label: Label = $Hud/LevelLabel
@onready var moves_label: Label = $Hud/MovesLabel
@onready var goals_label: Label = $Hud/GoalsLabel
@onready var wallet_label: Label = $Hud/WalletLabel
@onready var note_label: Label = $Hud/NoteLabel
@onready var win_panel: PanelContainer = $WinPanel
@onready var win_text: Label = $WinPanel/Box/Text
@onready var play_again_button: Button = $WinPanel/Box/PlayAgainButton
@onready var offer_panel: PanelContainer = $OfferPanel
@onready var offer_text: Label = $OfferPanel/Box/Text
@onready var offer_warning: Label = $OfferPanel/Box/Warning
@onready var accept_button: Button = $OfferPanel/Box/AcceptButton
@onready var decline_button: Button = $OfferPanel/Box/DeclineButton
@onready var retry_panel: PanelContainer = $RetryPanel
@onready var retry_text: Label = $RetryPanel/Box/Text
@onready var retry_button: Button = $RetryPanel/Box/RetryButton
@onready var buy_lives_button: Button = $RetryPanel/Box/BuyLivesButton
@onready var check_again_button: Button = $RetryPanel/Box/CheckAgainButton
@onready var debug_panel: VBoxContainer = $DebugPanel
@onready var debug_moves_box: SpinBox = $DebugPanel/Row/MovesBox
@onready var debug_status: Label = $DebugPanel/Status
@onready var debug_level_box: SpinBox = $DebugPanel/LevelRow/LevelBox
@onready var debug_load_button: Button = $DebugPanel/LevelRow/LoadButton

var save: SaveService
var session: LevelSession
var input: BoardInput = null
var _note: String = ""
var _level_path: String = LEVEL_PATH   # the level file being played now


func _ready() -> void:
	save = SaveService.new(SAVE_PATH, Callable(self, "_now"))
	session = LevelSession.new(LEVEL_PATH, save)
	queue.stage = board_view
	queue.finished.connect(_refresh)
	play_again_button.pressed.connect(_on_play_again)
	accept_button.pressed.connect(_on_accept)
	decline_button.pressed.connect(_on_decline)
	retry_button.pressed.connect(_on_retry)
	buy_lives_button.pressed.connect(_on_buy_lives)
	check_again_button.pressed.connect(_refresh)
	buy_lives_button.text = "Buy all 5 lives (%d coins)" % MetaRules.BUY_LIVES_PRICE
	# Debug-only controls are hidden (and do nothing) in a release build.
	play_again_button.visible = session.debug_enabled
	debug_panel.visible = session.debug_enabled
	debug_moves_box.value_changed.connect(_on_debug_moves_changed)
	debug_load_button.pressed.connect(_on_debug_load)
	debug_level_box.get_line_edit().text_submitted.connect(_on_debug_level_submitted)
	_show_debug_moves()
	_start_fresh()


## The save's clock: unix seconds (SaveService never reads the system clock itself).
func _now() -> int:
	return int(Time.get_unix_time_from_system())


func _start_fresh() -> void:
	_dev_make_level_playable()
	if not session.start():
		_note = _session_message()
	_show_board()
	_refresh()


## DEBUG BUILDS ONLY: SaveService only starts the next level in order (IR-79), and a won level can't be
## played again. So that this test level can always be played, the grey-box save is moved to it through
## LevelSession's debug shortcut. With the debug gate off (a release build) this does nothing.
func _dev_make_level_playable() -> void:
	var data: Variant = LevelLoader.read_level_file(_level_path)
	if not data is Dictionary:
		return
	var id: int = LevelLoader.as_int((data as Dictionary).get("id"), 0)
	if save.next_level() != id:
		session.debug_jump_to_level(id)


func _show_board() -> void:
	var board: BoardModel = session.board()
	if board == null:
		return
	board_view.setup(board)
	input = BoardInput.new(board.width, board.height, board_view.cell_size)


# ---------------------------------------------------------------- input

func _unhandled_input(event: InputEvent) -> void:
	if _debug_key(event):
		get_viewport().set_input_as_handled()
		return
	if not _can_play():
		return
	if event is InputEventMouseButton and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT:
		var button: InputEventMouseButton = event
		var local: Vector2 = board_view.to_local(button.position)
		if button.pressed:
			input.press(local)
		else:
			_do(input.release(local, session.board()))
	elif event is InputEventMouseMotion and ((event as InputEventMouseMotion).button_mask & MOUSE_BUTTON_MASK_LEFT) != 0:
		_do(input.move(board_view.to_local((event as InputEventMouseMotion).position)))


func _can_play() -> bool:
	return input != null and session.state == LevelSession.PLAYING and not queue.is_playing()


func _do(intent: Dictionary) -> void:
	match String(intent.get("action", "none")):
		"select":
			board_view.set_selected(intent.cell)
		"deselect":
			board_view.set_selected(GreyboxBoardView.NO_CELL)
		"swap":
			board_view.set_selected(GreyboxBoardView.NO_CELL)
			var before: Dictionary = BoardSnapshot.piece_grid(session.board())
			_play(session.swap(intent.from, intent.to), before)
		"tap":
			board_view.set_selected(GreyboxBoardView.NO_CELL)
			var before_tap: Dictionary = BoardSnapshot.piece_grid(session.board())
			_play(session.tap(intent.cell), before_tap)


## What the note label shows after a start or retry that didn't work: the player's message if there is one
## (IR-88: "This level couldn't be loaded"), else the technical reason.
func _session_message() -> String:
	return session.notice if session.notice != "" else session.last_error


## The logic has already resolved the move; now the queue plays it. The HUD updates when it finishes.
func _play(events: Array[BoardEvent], before: Dictionary) -> void:
	if events.is_empty():
		return
	_note = ""
	_hide_panels()
	queue.play(events, before, session.board())


# ---------------------------------------------------------------- buttons

func _on_accept() -> void:
	if session.accept_offer():
		_note = "+5 moves"
	_refresh()


func _on_decline() -> void:
	session.decline_offer()
	_refresh()


func _on_retry() -> void:
	if session.retry():
		_note = ""
		_show_board()
	else:
		_note = _session_message()
	_refresh()


func _on_buy_lives() -> void:
	var result: Dictionary = session.buy_lives()
	_note = "Lives refilled" if bool(result.get("ok", false)) else String(result.get("message", ""))
	_refresh()


## DEBUG BUILDS ONLY (the button is hidden otherwise): moves the save back to this level and starts it again.
func _on_play_again() -> void:
	_note = ""
	if not session.debug_play_again():
		_note = _session_message()
	_show_board()
	_refresh()


# ---------------------------------------------------------------- debug moves (debug builds only)

## Keys 1-9 set "moves next attempt"; L puts the cursor in the "Level" box. True if the key was used.
## Does nothing with the debug gate off. While a text box has the cursor, L is ignored (it is typing).
func _debug_key(event: InputEvent) -> bool:
	if not session.debug_enabled or not event is InputEventKey:
		return false
	var key: InputEventKey = event
	if not key.pressed or key.echo:
		return false
	if key.keycode == KEY_L:
		if get_viewport().gui_get_focus_owner() is LineEdit:
			return false
		var box: LineEdit = debug_level_box.get_line_edit()
		box.grab_focus()
		box.select_all()
		return true
	if key.keycode < KEY_1 or key.keycode > KEY_9:
		return false
	debug_moves_box.value = key.keycode - KEY_0   # this also calls _on_debug_moves_changed
	return true


# ---------------------------------------------------------------- debug level switch (debug builds only)

## Enter in the "Level" box. The SpinBox reads the typed text first, then we load.
func _on_debug_level_submitted(_text: String) -> void:
	debug_level_box.apply()
	_on_debug_load()


## Load button: plays res://levels/level_NNN.json. A missing file leaves the current level as it is.
func _on_debug_load() -> void:
	debug_level_box.get_line_edit().release_focus()   # so keys 1-9 and L work again
	if not session.debug_enabled:
		return
	if queue.is_playing():
		_note = "wait for the move to finish, then load"
		_refresh()
		return
	var n: int = int(debug_level_box.value)
	var path: String = LevelLoader.level_path(n)
	if not FileAccess.file_exists(path):
		_note = "levels/level_%03d.json not found" % n
		_refresh()
		return
	# An open attempt is cancelled with no penalty (IR-88's cancel, used here as a debug shortcut only).
	if session.state == LevelSession.PLAYING or session.state == LevelSession.OFFER:
		save.cancel_attempt()
	var next: LevelSession = LevelSession.new(path, save)
	next.set_debug_moves(session.debug_moves)
	session = next
	_level_path = path
	session.debug_jump_to_level(n)
	_hide_panels()
	_note = ""
	if not session.start():
		_note = _session_message()
	_show_board()
	_refresh()


func _on_debug_moves_changed(value: float) -> void:
	session.set_debug_moves(int(value))
	_show_debug_moves()


func _show_debug_moves() -> void:
	if session.debug_moves > 0:
		debug_status.text = "Debug moves: %d (next attempt)" % session.debug_moves
	else:
		debug_status.text = "Debug moves: off (the level file's moves)"


# ---------------------------------------------------------------- HUD and panels

func _refresh() -> void:
	level_label.text = "Level %d   (grey box)" % session.level_id()
	moves_label.text = "Moves left: %d" % session.moves_left()
	var lines: Array[String] = ["Goals:"]
	for g in session.goal_rows():
		var goal_name: String = String(g.id) + (" (fragment)" if bool(g.fragment) else "")
		lines.append("  %s  %d / %d" % [goal_name, int(g.done), int(g.total)])
	goals_label.text = "\n".join(lines)
	wallet_label.text = "Coins: %d     Lives: %d" % [session.coins(), session.lives()]
	note_label.text = _note
	if queue.is_playing():
		_hide_panels()
		return
	win_panel.visible = session.state == LevelSession.WON
	offer_panel.visible = session.state == LevelSession.OFFER
	retry_panel.visible = session.state == LevelSession.RETRY
	if win_panel.visible:
		win_text.text = "Level won!\n+%d coins (%d finale Rockets)" % [session.win_coins, session.finale_rockets]
	if offer_panel.visible:
		offer_text.text = "Out of moves.\nContinue: +5 moves for %d coins" % session.offer_price()
		offer_warning.text = session.offer_message()
		accept_button.disabled = not session.can_accept_offer()
	if retry_panel.visible:
		_refresh_retry_panel()
	if input != null and session.state != LevelSession.PLAYING:
		input.cancel()
		board_view.set_selected(GreyboxBoardView.NO_CELL)


func _refresh_retry_panel() -> void:
	var choices: Array = session.retry_choices()
	retry_button.visible = choices.has("retry")
	buy_lives_button.visible = choices.has("buy_lives")
	check_again_button.visible = choices.has("wait")
	if choices.has("retry"):
		retry_text.text = "Level failed.\nLives: %d" % session.lives()
	else:
		retry_text.text = "No lives left.\nWait for a life to come back, or buy all 5."


func _hide_panels() -> void:
	win_panel.visible = false
	offer_panel.visible = false
	retry_panel.visible = false
