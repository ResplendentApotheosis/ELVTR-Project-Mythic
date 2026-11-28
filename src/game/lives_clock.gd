# The life refill clock (IR-81): one life back per full 20 minutes of real time, never above 5, never taken away
# when the device clock goes backwards. No countdown runs during unlimited lives; when they end with lives < 5 a
# fresh 20 minutes starts at their end time. Works on the save Dictionary; no IO.
# Check: tests/save_service/test_lives_refill_ir81.gd and test_lives_start_rules_ir81.gd.
class_name LivesClock
extends RefCounted


## Brings lives up to date for the time `now` (unix seconds). Returns true if the data changed.
static func refresh(data: Dictionary, now: int) -> bool:
	var lives: int = int(data.lives)
	var started_at: int = int(data.refill_started_at)
	var unlimited_until: int = int(data.unlimited_until)
	if lives >= MetaRules.MAX_LIVES:
		if started_at != 0:
			data.refill_started_at = 0   # at 5 lives no countdown runs
			return true
		return false
	if now < unlimited_until:
		return false                     # unlimited lives: no countdown runs, no life comes back
	var changed: bool = false
	if started_at <= 0:
		# no countdown yet: after unlimited lives a fresh one starts at their end time (game open or closed);
		# otherwise (should not happen) it starts now so lives still come back
		started_at = unlimited_until if unlimited_until > 0 else now
		data.refill_started_at = started_at
		changed = true
	if now < started_at:
		return changed                   # clock set back: nothing comes back, nothing is taken away
	var gained: int = (now - started_at) / MetaRules.REFILL_SECONDS
	if gained == 0:
		return changed
	lives = mini(MetaRules.MAX_LIVES, lives + gained)
	data.lives = lives
	if lives >= MetaRules.MAX_LIVES:
		data.refill_started_at = 0
	else:
		data.refill_started_at = started_at + gained * MetaRules.REFILL_SECONDS
	return true


## Unlimited lives start at `now` and end at `until`: lives already due are given, then a running countdown
## is dropped (not resumed); refresh() starts a fresh one at `until` if lives are below 5 by then.
static func start_unlimited(data: Dictionary, now: int, until: int) -> void:
	refresh(data, now)
	data.refill_started_at = 0
	data.unlimited_until = until


## Takes one life at `now`. A loss at 5 lives starts the countdown; a loss while it runs leaves it alone.
## Returns true when this loss took lives to 0. Never goes below 0.
static func lose_one(data: Dictionary, now: int) -> bool:
	refresh(data, now)
	var lives: int = int(data.lives)
	if lives <= 0:
		return false
	if lives >= MetaRules.MAX_LIVES:
		data.refill_started_at = now
	data.lives = lives - 1
	return lives - 1 == 0


## All 5 lives back (bought); the countdown stops.
static func fill(data: Dictionary) -> void:
	data.lives = MetaRules.MAX_LIVES
	data.refill_started_at = 0
