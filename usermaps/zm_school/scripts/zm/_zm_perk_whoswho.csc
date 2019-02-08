#using scripts\codescripts\struct;

#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\shared\visionset_mgr_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#using scripts\zm\_zm_perks;

#insert scripts\zm\_zm_perk_whoswho.gsh;
#insert scripts\zm\_zm_perks.gsh;
#insert scripts\zm\_zm_utility.gsh;

#precache( "client_fx", "zombie/fx_perk_sleight_of_hand_factory_zmb" );

#namespace zm_perk_whoswho;

REGISTER_SYSTEM( "zm_perk_whoswho", &__init__, undefined )

//-----------------------------------------------------------------------------------
// SETUP
//-----------------------------------------------------------------------------------
function __init__()
{
	zm_perks::register_perk_clientfields( 	PERK_WHOSWHO, &whoswho_client_field_func, &whoswho_code_callback_func );
	zm_perks::register_perk_effects( 		PERK_WHOSWHO, WHOSWHO_MACHINE_LIGHT_FX );
	zm_perks::register_perk_init_thread( 	PERK_WHOSWHO, &init_whoswho );
}

function init_whoswho()
{
	level._effect[ WHOSWHO_MACHINE_LIGHT_FX ]	= "zombie/fx_perk_sleight_of_hand_factory_zmb";
}

function whoswho_client_field_func()
{ 
	RegisterClientField( "toplayer", "perk_whoswho",	VERSION_SHIP, 2, "int", &whoswho_logic, false );
}

function whoswho_code_callback_func() {}

function whoswho_logic( localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump )
{
	if ( newVal == 1 )
	{
		self.soundEnt = spawn( localClientNum, self.origin, "script_origin" );
		self playSound( localClientNum, "zmb_perks_whoswho_begin" );
		self.soundEnt playLoopSound( "zmb_perks_whoswho_loop", 3 );
	}
	else if ( newVal == 0 )
	{
		self.soundEnt delete();
		self playSound( localClientNum, "zmb_perks_whoswho_deactivate" );
	}
}