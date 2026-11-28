# Says whether developer shortcuts (jump to a level, play again, debug moves) are allowed.
# They are on only in debug builds (running from the editor), never in an exported release build.
# Check: run the GUT suite (tests/greybox/test_debug_gate.gd); in the grey box the dev buttons show only from the editor.
class_name DebugGate
extends RefCounted


## True when developer shortcuts may be used. `is_debug` defaults to "is this a debug build?".
static func enabled(is_debug: bool = OS.is_debug_build()) -> bool:
	return is_debug
