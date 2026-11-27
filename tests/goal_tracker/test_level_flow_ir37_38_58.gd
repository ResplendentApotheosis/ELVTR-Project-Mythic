# GUT tests for IR-37 (continue offers), IR-38 (quitting is a fail) and IR-58 (a fragment is only banked on a win)
# as GoalTracker keeps them for one attempt. Banking and "first try" live in SaveService (not built): those are pending.
# API: tests/API_CONTRACT.md section 10. Check: run the GUT suite.
extends "res://tests/helpers/goal_test_base.gd"


func _attempt(goals: Array, level: int, lives: int, coins: int) -> Variant:
	var t: Variant = loose_tracker(goals, level)
	if t == null:
		return null
	t.lives = lives
	t.coins = coins
	return t


func _hit_zero(t: Variant, board: BoardModel) -> void:
	board.moves = 0
	t.moves_ran_out(board)


func _fragment_goals() -> Array:
	return [obstacle_goal("OB02", 3), obstacle_goal("OB07", 1, true)]


func _free_fragment(t: Variant) -> void:
	var e: BoardEvent = BoardEvent.new("collected")
	e.data = {"item": "fragment", "carrier": "OB07"}
	t.observe(e)


# ---------------------------------------------------------------- IR-37

func test_ir37_offer_shown_when_goal_cannot_be_reached_price_300() -> void:
	var t: Variant = _attempt([obstacle_goal("OB11", 5)], 34, 5, 500)
	if t == null:
		return
	var e: BoardEvent = BoardEvent.new("collected")
	e.data = {"item": "OB11"}
	t.observe(e)
	var board: BoardModel = BB.blank()
	board.set_drop_item(2, 2, "OB11")
	_hit_zero(t, board)
	assert_eq(int(t.offer_price()), 300, "offer shown whatever the state of the goal")


func test_ir37_five_accepted_offers_then_no_sixth() -> void:
	var t: Variant = _attempt([obstacle_goal("OB02", 5)], 12, 5, 3000)
	if t == null:
		return
	var board: BoardModel = BB.blank()
	var prices: Array = []
	var coins_after: Array = []
	for i in range(5):
		_hit_zero(t, board)
		prices.append(int(t.offer_price()))
		assert_true(t.accept_offer(board), "offer %d accepted" % (i + 1))
		coins_after.append(int(t.coins))
		assert_eq(board.moves, 5, "moves = 5 after accept %d" % (i + 1))
	assert_eq(prices, [300, 500, 500, 500, 500])
	assert_eq(coins_after, [2700, 2200, 1700, 1200, 700])
	_hit_zero(t, board)
	assert_eq(int(t.offer_price()), 0, "no 6th offer")
	assert_false(t.accept_offer(board), "nothing to accept")
	assert_eq(board.moves, 0)
	assert_eq(int(t.coins), 700)


func test_ir37_decline_ends_attempt_no_moves_no_second_offer() -> void:
	var t: Variant = _attempt([obstacle_goal("OB02", 5)], 12, 5, 1000)
	if t == null:
		return
	var board: BoardModel = BB.blank()
	_hit_zero(t, board)
	assert_eq(int(t.offer_price()), 300)
	t.decline_offer()
	assert_eq(int(t.offer_price()), 0, "no second offer for this fail")
	assert_false(t.accept_offer(board), "cannot accept after declining")
	assert_eq(int(t.coins), 1000)
	assert_eq(board.moves, 0, "moves not added")


func test_ir37_250_coins_offer_shown_only_decline_works() -> void:
	var t: Variant = _attempt([obstacle_goal("OB02", 5)], 12, 5, 250)
	if t == null:
		return
	var board: BoardModel = BB.blank()
	_hit_zero(t, board)
	assert_eq(int(t.offer_price()), 300, "shown, price 300")
	assert_false(t.accept_offer(board))
	assert_eq(int(t.coins), 250)
	assert_eq(board.moves, 0)
	t.decline_offer()
	assert_eq(int(t.offer_price()), 0, "retry screen: no offer")
	assert_eq(int(t.lives), 4)


func test_ir37_exactly_300_coins_can_accept() -> void:
	var t: Variant = _attempt([obstacle_goal("OB02", 5)], 12, 5, 300)
	if t == null:
		return
	var board: BoardModel = BB.blank()
	_hit_zero(t, board)
	assert_true(t.accept_offer(board))
	assert_eq(int(t.coins), 0)
	assert_eq(board.moves, 5)


func test_ir37_700_coins_second_offer_500_cannot_be_paid() -> void:
	var t: Variant = _attempt([obstacle_goal("OB02", 5)], 12, 5, 700)
	if t == null:
		return
	var board: BoardModel = BB.blank()
	_hit_zero(t, board)
	assert_true(t.accept_offer(board))
	assert_eq(int(t.coins), 400)
	assert_eq(board.moves, 5)
	_hit_zero(t, board)
	assert_eq(int(t.offer_price()), 500, "offer 2 shown, price 500")
	assert_false(t.accept_offer(board))
	assert_eq(int(t.coins), 400)
	assert_eq(board.moves, 0)
	t.decline_offer()
	assert_eq(int(t.coins), 400)
	assert_eq(int(t.offer_price()), 0)


func test_ir37_500_coins_offer_two_shown_only_decline() -> void:
	var t: Variant = _attempt([obstacle_goal("OB02", 5)], 12, 5, 500)
	if t == null:
		return
	var board: BoardModel = BB.blank()
	_hit_zero(t, board)
	assert_true(t.accept_offer(board))
	assert_eq(int(t.coins), 200)
	_hit_zero(t, board)
	assert_eq(int(t.offer_price()), 500)
	assert_false(t.accept_offer(board))
	t.decline_offer()
	assert_eq(int(t.coins), 200)


func test_ir37_800_coins_second_offer_can_be_accepted() -> void:
	var t: Variant = _attempt([obstacle_goal("OB02", 5)], 12, 5, 800)
	if t == null:
		return
	var board: BoardModel = BB.blank()
	_hit_zero(t, board)
	assert_true(t.accept_offer(board))
	assert_eq(int(t.coins), 500)
	_hit_zero(t, board)
	assert_eq(int(t.offer_price()), 500)
	assert_true(t.accept_offer(board))
	assert_eq(int(t.coins), 0)
	assert_eq(board.moves, 5)


func test_ir37_quit_shows_no_offer_coins_unchanged() -> void:
	var t: Variant = _attempt([obstacle_goal("OB02", 5)], 12, 5, 1000)
	if t == null:
		return
	var board: BoardModel = BB.blank()
	board.moves = 7
	t.quit()
	assert_eq(int(t.offer_price()), 0, "no offer on a quit")
	assert_eq(int(t.coins), 1000)
	assert_eq(board.moves, 7)


# ---------------------------------------------------------------- IR-38

func test_ir38_quit_on_level_12_costs_a_life() -> void:
	var t: Variant = _attempt([obstacle_goal("OB02", 5)], 12, 5, 0)
	if t == null:
		return
	t.quit()
	assert_eq(int(t.lives), 4)


func test_ir38_quit_on_finale_25_costs_no_life() -> void:
	var t: Variant = _attempt([obstacle_goal("OB02", 5)], 25, 3, 0)
	if t == null:
		return
	t.quit()
	assert_eq(int(t.lives), 3)
	assert_eq(int(t.offer_price()), 0)


func test_ir38_quit_with_coins_and_moves_left_no_offer_life_lost() -> void:
	var t: Variant = _attempt([obstacle_goal("OB02", 5)], 12, 5, 1000)
	if t == null:
		return
	var board: BoardModel = BB.blank()
	board.moves = 7
	t.quit()
	assert_eq(int(t.offer_price()), 0, "no continue offer")
	assert_eq(int(t.lives), 4)
	assert_eq(int(t.coins), 1000)


func test_ir38_quit_logged_as_fail_and_first_try() -> void:
	pending("Blocked by SaveService (attempt log: fail and first try) - not built yet")


# ---------------------------------------------------------------- IR-58

func test_ir58_fail_after_fragment_freed_is_not_a_win_and_retry_starts_clean() -> void:
	var t: Variant = _attempt(_fragment_goals(), 26, 5, 1000)
	if t == null:
		return
	_free_fragment(t)
	assert_true(t.is_goal_done(1), "fragment goal done in this attempt")
	var board: BoardModel = BB.blank()
	_hit_zero(t, board)
	t.decline_offer()
	assert_false(t.is_won(), "another goal not done: no win, so no banking")
	assert_eq(int(t.lives), 4)
	var retry: Variant = _attempt(_fragment_goals(), 26, int(t.lives), int(t.coins))
	assert_false(retry.is_goal_done(1), "retry: fragment goal not done")
	assert_eq(int(retry.goal_units_done(1)), 0)


func test_ir58_quit_after_fragment_collected_is_not_a_win() -> void:
	var goals: Array = [obstacle_goal("OB02", 3), obstacle_goal("OB11", 1, true)]
	var t: Variant = _attempt(goals, 30, 5, 0)
	if t == null:
		return
	var e: BoardEvent = BoardEvent.new("collected")
	e.data = {"item": "fragment", "carrier": "OB11"}
	t.observe(e)
	t.quit()
	assert_false(t.is_won())
	var retry: Variant = _attempt(goals, 30, 4, 0)
	assert_false(retry.is_goal_done(1), "retry: fragment goal not done")


func test_ir58_all_goals_done_is_a_win() -> void:
	var t: Variant = _attempt(_fragment_goals(), 26, 5, 0)
	if t == null:
		return
	_free_fragment(t)
	for i in range(3):
		var e: BoardEvent = BoardEvent.new("obstacle_cleared")
		e.data = {"id": "OB02"}
		t.observe(e)
	assert_true(t.is_won())


func test_ir58_fragments_rat_banked_only_on_win() -> void:
	pending("Blocked by SaveService (fragments.rat save value) - not built yet")


func test_ir58_retry_board_has_fragment_cocoon_back() -> void:
	pending("Needs LevelLoader: see tests/test_level_loader.gd (IR-58 retry cases)")
