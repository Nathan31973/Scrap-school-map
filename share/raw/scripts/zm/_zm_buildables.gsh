
#define CLIENTFIELD_BUILDABLE_PIECE_NONE		0

// clientfield name
#define CLIENTFIELD_BUILDABLE				"buildable"


// whether or not the trigger passed to a buildable_trigger_think call is deleted 
#define DELETE_TRIGGER	1
#define KEEP_TRIGGER	0

// whether or not a buildable lives past being built
// instead of adding new values here, use bpstub_set_custom_think_callback to add new think routines
#define CUSTOM_BUILD_THINK    4   
#define UNBUILD			3
#define ONE_USE_AND_FLY	2
#define PERSISTENT    	1
#define ONE_TIME_BUILD  0   

// adding spript_forcespawn to managed spawn buildable pieces in radiant will cause those spawn points for be filled 
#define SCRIPT_FORCESPAWN_NONE 		0
// force piece to spawn here once then use it as a normal spawn point
#define SCRIPT_FORCESPAWN_ONCE 		1
// always spawn here if available
#define SCRIPT_FORCESPAWN_ALWAYS 	2
// force piece to spawn here once then never use it again
#define SCRIPT_FORCESPAWN_ONCE_ONLY	3
// never use this spawn point
#define SCRIPT_FORCESPAWN_NEVER 	4

#define BUILDABLE_SLOT_DEFAULT 0
	
#define CLIENTFIELD_BUILDABLE_PIECE_RIOTSHIELD_DOLLY		1
#define CLIENTFIELD_BUILDABLE_PIECE_RIOTSHIELD_DOOR			2
#define CLIENTFIELD_BUILDABLE_PIECE_CATTLECATCHER_PLOW		3
#define CLIENTFIELD_BUILDABLE_PIECE_TURBINE_FAN				4
#define CLIENTFIELD_BUILDABLE_PIECE_TURBINE_PANEL			5
#define CLIENTFIELD_BUILDABLE_PIECE_TURBINE_BODY			6
#define CLIENTFIELD_BUILDABLE_PIECE_TURRET_BARREL			7
#define CLIENTFIELD_BUILDABLE_PIECE_TURRET_BODY				8
#define CLIENTFIELD_BUILDABLE_PIECE_TURRET_AMMO				9
#define CLIENTFIELD_BUILDABLE_PIECE_ELECTRIC_TRAP_SPOOL		10
#define CLIENTFIELD_BUILDABLE_PIECE_ELECTRIC_TRAP_COIL		11
#define CLIENTFIELD_BUILDABLE_PIECE_ELECTRIC_TRAP_BATTERY	12
#define CLIENTFIELD_BUILDABLE_PIECE_SPRINGPAD_DOOR			13
#define CLIENTFIELD_BUILDABLE_PIECE_SPRINGPAD_FLAG			14
#define CLIENTFIELD_BUILDABLE_PIECE_SPRINGPAD_MOTOR			15
#define CLIENTFIELD_BUILDABLE_PIECE_SPRINGPAD_WHISTLE		16
#define CLIENTFIELD_BUILDABLE_PIECE_SUBWOOFER_SPEAKER		17
#define CLIENTFIELD_BUILDABLE_PIECE_SUBWOOFER_MOTOR			18
#define CLIENTFIELD_BUILDABLE_PIECE_SUBWOOFER_MOUNT			19
#define CLIENTFIELD_BUILDABLE_PIECE_SUBWOOFER_TABLE			20
#define CLIENTFIELD_BUILDABLE_PIECE_HEADCHOPPER_A			21
#define CLIENTFIELD_BUILDABLE_PIECE_HEADCHOPPER_B			22
#define CLIENTFIELD_BUILDABLE_PIECE_HEADCHOPPER_C			23
#define CLIENTFIELD_BUILDABLE_PIECE_HEADCHOPPER_D			24

#define CLIENTFIELD_BUILDABLE_PIECE_COUNT					24	
