# GUT tests for IR-60 (a fail costs a life, except on chapter finales) as GoalTracker keeps it for one attempt.
# The tracker holds `lives` and `coins` (SaveService loads and saves them) and the continue-offer state (IR-37:
# 300 coins first, 500 for offers 2 to 5, none for a 6th). API: tests/API_CONTRACT.md section 10.
extends "res://tests/helpers/goal_test_base.gd"


func _attempt(level: int, lives: int, coins: int) -> Variant:
	var t: Variant = loose_tracker([obstacle_goal("OB07", 1)], level)
	if t == null:
		return null
	t.lives = lives
	t.coins = coins
	return t


func _out_of_moves(t: Variant, board: BoardModel) -> void:
	board.moves = 0
	t.moves_ran_out(board)


func test_ir60_declined_offer_costs_one_life() -> void:
	var t: Variant = _attempt(12, 5, 1000)
	if t == null:
		return
	var board: BoardModel = BB.blank()
	_out_of_moves(t, board)
	assert_eq(int(t.offer_price()), 300)
	t.decline_offer()
	assert_eq(int(t.lives), 4)


func test_ir60_finale_fail_costs_no_life() -> void:
	var t: Variant = _attempt(25, 3, 0)
	if t == null:
		return
	var board: BoardModel = BB.blank()
	_out_of_moves(t, board)
	t.decline_offer()
	assert_eq(int(t.lives), 3)


func test_ir60_quit_on_the_level_50_finale_costs_no_life() -> void:
	var t: Variant = _attempt(50, 2, 0)
	if t == null:
		return
	t.quit()
	assert_eq(int(t.lives), 2)


func test_ir60_accepted_offer_costs_no_life_and_a_win_after_it_costs_none() -> void:
	var t: Variant = _attempt(12, 5, 1000)
	if t == null:
		return
	var board: BoardModel = BB.blank()
	_out_of_moves(t, board)
	assert_true(t.accept_offer(board), "the offer is accepted")
	assert_eq(int(t.lives), 5, "no life lost by accepting")
	assert_eq(int(t.coins), 700)
	assert_eq(board.moves, 5, "+5 moves")
	var cleared: BoardEvent = BoardEvent.new("obstacle_cleared")
	cleared.data = {"id": "OB07"}
	t.observe(cleared)
	assert_true(t.is_won(), "the level is won")
	assert_eq(int(t.lives), 5, "a win after continues costs no life")


func test_ir60_one_life_per_attempt_even_after_an_accepted_offer() -> void:
	var t: Variant = _attempt(12, 5, 1000)
	if t == null:
		return
	var board: BoardModel = BB.blank()
	_out_of_moves(t, board)
	assert_true(t.accept_offer(board))
	assert_eq(int(t.lives), 5)
	_out_of_moves(t, board)
	assert_eq(int(t.offer_price()), 500, "offer 2 costs 500")
	t.decline_offer()
	assert_eq(int(t.lives), 4, "one life, not two")


func test_ir60_six_runs_out_of_moves_cost_one_life_and_the_sixth_has_no_offer() -> void:
	var t: Variant = _attempt(12, 5, 3000)
	if t == null:
		return
	var board: BoardModel = BB.blank()
	var prices: Array = []
	for i in range(5):
		_out_of_moves(t, board)
		prices.append(int(t.offer_price()))
		assert_true(t.accept_offer(board), "offer %d accepted" % (i + 1))
		assert_eq(int(t.lives), 5, "lives still 5 after offer %d" % (i + 1))
	assert_eq(prices, [300, 500, 500, 500, 500])
	assert_eq(int(t.coins), 700)
	_out_of_moves(t, board)
	assert_eq(int(t.offer_price()), 0, "no 6th offer")
	assert_eq(int(t.lives), 4, "the attempt ends in a fail: one life")
	assert_eq(int(t.coins), 700)


func test_ir60_quit_after_an_accepted_offer_costs_one_life() -> void:
	var t: Variant = _attempt(12, 5, 1000)
	if t == null:
		return
	var board: BoardModel = BB.blank()
	_out_of_moves(t, board)
	assert_true(t.accept_offer(board))
	t.quit()
	assert_eq(int(t.lives), 4)


func test_ir60_finale_with_an_accepted_offer_then_a_declined_one_costs_no_life() -> void:
	var t: Variant = _attempt(25, 3, 1000)
	if t == null:
		return
	var board: BoardModel = BB.blank()
	_out_of_moves(t, board)
	assert_true(t.accept_offer(board))
	_out_of_moves(t, board)
	t.decline_offer()
	assert_eq(int(t.lives), 3)


func test_ir60_a_player_who_cannot_pay_can_only_decline() -> void:
	var t: Variant = _attempt(12, 5, 250)
	if t == null:
		return
	var board: BoardModel = BB.blank()
	_out_of_moves(t, board)
	assert_eq(int(t.offer_price()), 300, "the offer is still shown")
	assert_false(t.accept_offer(board), "accepting is not possible")
	assert_eq(int(t.coins), 250)
	assert_eq(board.moves, 0)
	assert_eq(int(t.lives), 5, "no life lost until the attempt ends")
	t.decline_offer()
	assert_eq(int(t.lives), 4)
