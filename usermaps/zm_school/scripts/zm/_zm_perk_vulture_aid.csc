#using scripts\codescripts\struct;

#using scripts\shared\clientfield_shared;
#using scripts\shared\util_shared;
#using scripts\shared\system_shared;
#using scripts\shared\visionset_mgr_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#using scripts\zm\_zm_perks;

#insert scripts\zm\_zm_perk_vulture_aid.gsh;
#insert scripts\zm\_zm_perks.gsh;
#insert scripts\zm\_zm_utility.gsh;

#precache( "client_fx", VULTUREAID_REVIVE_WAYPOINT );
#precache( "client_fx", VULTUREAID_JUGG_WAYPOINT );
#precache( "client_fx", VULTUREAID_DOUBLETAP2_WAYPOINT );
#precache( "client_fx", VULTUREAID_SPEED_WAYPOINT );
#precache( "client_fx", VULTUREAID_DEADSHOT_WAYPOINT );
#precache( "client_fx", VULTUREAID_FLOPPER_WAYPOINT );
#precache( "client_fx", VULTUREAID_STAMIN_WAYPOINT );
#precache( "client_fx", VULTUREAID_MULE_WAYPOINT );
#precache( "client_fx", VULTUREAID_TOMB_WAYPOINT );
#precache( "client_fx", VULTUREAID_WHOSWHO_WAYPOINT );
#precache( "client_fx", VULTUREAID_CHERRY_WAYPOINT );
#precache( "client_fx", VULTUREAID_VULTURE_WAYPOINT );
#precache( "client_fx", VULTUREAID_WIDOWS_WAYPOINT );
#precache( "client_fx", VULTUREAID_WUNDERFIZZ_WAYPOINT );
#precache( "client_fx", VULTUREAID_MAGIC_BOX_WAYPOINT );
#precache( "client_fx", VULTUREAID_PAP_WAYPOINT );
#precache( "client_fx", VULTUREAID_RIFLE_WAYPOINT );
#precache( "client_fx", VULTUREAID_SKULL_WAYPOINT );
#precache( "client_fx", VULTUREAID_BGB_WAYPOINT );
#precache( "client_fx", VULTUREAID_MACHINE_GLOW );
#precache( "client_fx", "zombie/fx_perk_juggernaut_factory_zmb" );
#precache( "client_fx", "zombie/fx_perk_juggernaut_zmb" );

#namespace zm_perk_vulture_aid;

REGISTER_SYSTEM( "zm_perk_vulture_aid", &__init__, undefined )

//-----------------------------------------------------------------------------------
// SETUP
//-----------------------------------------------------------------------------------
function __init__()
{
	level._custom_perks[ PERK_VULTUREAID ] = spawnStruct();
	enable_vulture_aid_perk_for_level();
}

function enable_vulture_aid_perk_for_level()
{
	zm_perks::register_perk_clientfields( 	PERK_VULTUREAID, &vulture_aid_client_field_func, &vulture_aid_callback_func );
	zm_perks::register_perk_effects( 		PERK_VULTUREAID, VULTUREAID_MACHINE_LIGHT_FX );
	zm_perks::register_perk_init_thread( 	PERK_VULTUREAID, &init_vulture_aid );
	
	if ( !isDefined( level.vulture_ids ) )
		level.vulture_ids = [];
	
	if ( !isDefined( level.vulture_ids[ "perk" ] ) )
		level.vulture_ids[ "perk" ] = [];
	
	if ( !isDefined( level.vulture_ids[ "wallbuy" ] ) )
		level.vulture_ids[ "wallbuy" ] = [];
	
	if ( !isDefined( level.vulture_ids[ "box" ] ) )
		level.vulture_ids[ "box" ] = [];
	
	if ( !isDefined( level.vulture_ids[ "bgb" ] ) )
		level.vulture_ids[ "bgb" ] = [];
	
	if ( !isDefined( level.vulture_ids[ "pap" ] ) )
		level.vulture_ids[ "pap" ] = [];
	
	if ( !isDefined( level.vulture_ids[ "fizz" ] ) )
		level.vulture_ids[ "fizz" ] = [];
	
	level.vulture_waypoints[ "specialty_quickrevive" ]						= VULTUREAID_REVIVE_WAYPOINT;
	level.vulture_waypoints[ "specialty_armorvest" ] 						= VULTUREAID_JUGG_WAYPOINT;
	level.vulture_waypoints[ "specialty_doubletap2" ]	 					= VULTUREAID_DOUBLETAP2_WAYPOINT;
	level.vulture_waypoints[ "specialty_fastreload" ] 						= VULTUREAID_SPEED_WAYPOINT;
	level.vulture_waypoints[ "specialty_deadshot" ] 						= VULTUREAID_DEADSHOT_WAYPOINT;
	level.vulture_waypoints[ "specialty_phdflopper" ] 						= VULTUREAID_FLOPPER_WAYPOINT;
	level.vulture_waypoints[ "specialty_staminup" ] 						= VULTUREAID_STAMIN_WAYPOINT;
	level.vulture_waypoints[ "specialty_additionalprimaryweapon" ] 			= VULTUREAID_MULE_WAYPOINT;
	level.vulture_waypoints[ "specialty_tombstone" ] 						= VULTUREAID_TOMB_WAYPOINT;
	level.vulture_waypoints[ "specialty_whoswho" ] 							= VULTUREAID_WHOSWHO_WAYPOINT;
	level.vulture_waypoints[ "specialty_electriccherry" ] 					= VULTUREAID_CHERRY_WAYPOINT;
	level.vulture_waypoints[ "specialty_vultureaid" ] 						= VULTUREAID_VULTURE_WAYPOINT;
	level.vulture_waypoints[ "specialty_widowswine" ] 						= VULTUREAID_WIDOWS_WAYPOINT;
	
	level.vulture_waypoints[ "rifle" ] 										= VULTUREAID_RIFLE_WAYPOINT;
	level.vulture_waypoints[ "magic_box" ] 									= VULTUREAID_MAGIC_BOX_WAYPOINT;
	level.vulture_waypoints[ "gobblegum" ] 									= VULTUREAID_BGB_WAYPOINT;
	level.vulture_waypoints[ "pap" ] 										= VULTUREAID_PAP_WAYPOINT;
	level.vulture_waypoints[ "fizz" ] 										= VULTUREAID_WUNDERFIZZ_WAYPOINT;
	
	util::register_system( "vulture_aid_notify", &vulture_aid_notify_handler );
}

function init_vulture_aid()
{
	if ( level.script == "zm_zod" || level.script == "zm_castle" || level.script == "zm_island" || level.script == "zm_stalingrad" || level.script == "zm_genesis" )
		level._effect[ VULTUREAID_MACHINE_LIGHT_FX ]	= "zombie/fx_perk_juggernaut_zmb";
	else
		level._effect[ VULTUREAID_MACHINE_LIGHT_FX ]	= "zombie/fx_perk_juggernaut_factory_zmb";
	
}

function vulture_aid_client_field_func() {}

function vulture_aid_callback_func() {}

function vulture_aid_notify_handler( local_client_number, state, oldState )
{
	if ( state != "" )
	{
		players = getLocalPlayers();
		players[ local_client_number ] vulture_aid_logic( state, local_client_number );
	}	
}

function vulture_aid_logic( state, local_client_number )
{	
	array = seperate_string_to_array( state );
	
	command = array[ 0 ];
	type = array[ 1 ];
	id = string_to_float( array[ 2 ] );
	origin = ( string_to_float( array[ 3 ] ), string_to_float( array[ 4 ] ), string_to_float( array[ 5 ] ) );
	script_noteworthy = array[ 6 ];
	
	switch( command )
	{
		case "create_vulture_waypoint":
		{		
			create_vulture_element( local_client_number, type, id, origin, script_noteworthy );
			break;
		}
		case "stop_vulture_waypoint":
		{
			stop_vulture_element( local_client_number, type, id, origin, script_noteworthy );
			break;
		}
		case "change_vulture_waypoint":
		{		
			create_vulture_element( local_client_number, type, id, origin, script_noteworthy );
			break;
		}
	}
}

function create_vulture_element( local_client_number, array_reference, id, origin, script_noteworthy )
{
	struct = undefined;
	
	if ( isDefined( level.vulture_ids[ array_reference ][ id ] ) )
		struct = level.vulture_ids[ array_reference ][ id ];
	else
		struct = spawnStruct();
	
	if ( !isDefined( struct.id ) )
		struct.id = id;
	
	if ( !isDefined( struct.origin ) || ( isDefined( struct.origin ) && struct.origin != origin ) )
		struct.origin = origin;
	
	if ( !isDefined( struct.script_noteworthy ) || ( isDefined( struct.script_noteworthy ) && struct.script_noteworthy != script_noteworthy ) )
		struct.script_noteworthy = script_noteworthy;
	
	players = getLocalPlayers();
	if ( players[ local_client_number ] hasPerk( local_client_number, PERK_VULTUREAID ) )
		struct.fx = playFx( local_client_number, level.vulture_waypoints[ script_noteworthy ], origin );
	else
	{
		if ( isDefined( struct.fx ) )
			stopFX( local_client_number, level.vulture_ids[ array_reference ][ id ].fx );
		
	}
	
	if ( !isDefined( level.vulture_ids[ array_reference ][ id ] ) )
		level.vulture_ids[ array_reference ][ id ] = struct;
	
}

function stop_vulture_element( local_client_number, array_reference, id, origin, script_noteworthy )
{
	struct = undefined;
	
	if ( isDefined( level.vulture_ids[ array_reference ][ id ] ) )
		struct = level.vulture_ids[ array_reference ][ id ];
	else
		struct = spawnStruct();
	
	if ( !isDefined( struct.id ) )
		struct.id = id;
	
	if ( !isDefined( struct.origin ) || ( isDefined( struct.origin ) && struct.origin != origin ) )
		struct.origin = origin;
	
	if ( !isDefined( struct.script_noteworthy ) || ( isDefined( struct.script_noteworthy ) && struct.script_noteworthy != script_noteworthy ) )
		struct.script_noteworthy = script_noteworthy;
	
	if ( isDefined( struct.fx ) )
		stopFX( local_client_number, level.vulture_ids[ array_reference ][ id ].fx );
	
	if ( !isDefined( level.vulture_ids[ array_reference ][ id ] ) )
		level.vulture_ids[ array_reference ][ id ] = struct;
	
}

function string_to_float( string )
{
	float_parts = seperate_string_to_array( string );
	if ( float_parts.size == 1 )
		return int( float_parts[ 0 ] );

	whole = int( float_parts[ 0 ] );
	decimal = 0;
	for ( i = float_parts[ 1 ].size - 1; i >= 0; i-- )
		decimal = decimal / 10 + int( float_parts[ 1 ][ i ] ) / 10;

	if ( whole >= 0 )
		return ( whole + decimal );
	else
		return ( whole - decimal );
}

function seperate_string_to_array( string )
{
	array = [];
	contents = "";
	for ( i = 0; i < string.size; i++ )
	{
		if ( string[ i ] == "," || string[ i ] == "." || string[ i ] == "|" )
		{
			array[ array.size ] = contents;
			contents = "";
		}
		else
			contents += string[ i ];
	}
	
	if ( contents != "" )
		array[ array.size ] = contents;
	
	
	return array;
}
