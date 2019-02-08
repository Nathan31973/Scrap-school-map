#using scripts\codescripts\struct;

#using scripts\shared\array_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\shared\visionset_mgr_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#using scripts\zm\_util;
#using scripts\zm\_zm_perks;
#using scripts\zm\_zm_pers_upgrades;
#using scripts\zm\_zm_pers_upgrades_functions;
#using scripts\zm\_zm_pers_upgrades_system;
#using scripts\zm\_zm_stats;
#using scripts\zm\_zm_utility;

#using scripts\zm\_zm_perk_utility;

#insert scripts\zm\_zm_perk_sleight_of_hand.gsh;
#insert scripts\zm\_zm_perks.gsh;
#insert scripts\zm\_zm_utility.gsh;

#precache( "material", SLEIGHT_OF_HAND_SHADER );
#precache( "string", "ZOMBIE_PERK_FASTRELOAD" );
#precache( "fx", "zombie/fx_perk_sleight_of_hand_factory_zmb" );

#namespace zm_perk_sleight_of_hand;

REGISTER_SYSTEM( "zm_perk_sleight_of_hand", &__init__, undefined )

//-----------------------------------------------------------------------------------
// SETUP
//-----------------------------------------------------------------------------------
function __init__()
{
	enable_sleight_of_hand_perk_for_level();
}

function enable_sleight_of_hand_perk_for_level()
{	
	zm_perks::register_perk_basic_info( 			PERK_SLEIGHT_OF_HAND, "sleight", 								SLEIGHT_OF_HAND_PERK_COST, 			&"ZOMBIE_PERK_FASTRELOAD", getWeapon( SLEIGHT_OF_HAND_PERK_BOTTLE_WEAPON ) );
	zm_perks::register_perk_precache_func( 			PERK_SLEIGHT_OF_HAND, &sleight_of_hand_precache );
	zm_perks::register_perk_clientfields( 			PERK_SLEIGHT_OF_HAND, &sleight_of_hand_register_clientfield, 	&sleight_of_hand_set_clientfield );
	zm_perks::register_perk_machine( 				PERK_SLEIGHT_OF_HAND, &sleight_of_hand_perk_machine_setup );
	zm_perks::register_perk_threads( 				PERK_SLEIGHT_OF_HAND, &give_sleight_of_hand_perk, 				&take_sleight_of_hand_perk );
	zm_perks::register_perk_host_migration_params( 	PERK_SLEIGHT_OF_HAND, SLEIGHT_OF_HAND_RADIANT_MACHINE_NAME, 	SLEIGHT_OF_HAND_MACHINE_LIGHT_FX );
}

function sleight_of_hand_precache()
{
	level._effect[ SLEIGHT_OF_HAND_MACHINE_LIGHT_FX ]		= "zombie/fx_perk_sleight_of_hand_factory_zmb";
	
	level.machine_assets[ PERK_SLEIGHT_OF_HAND ] 			= spawnStruct();
	level.machine_assets[ PERK_SLEIGHT_OF_HAND ].weapon 	= getWeapon( SLEIGHT_OF_HAND_PERK_BOTTLE_WEAPON );
	level.machine_assets[ PERK_SLEIGHT_OF_HAND ].off_model 	= SLEIGHT_OF_HAND_MACHINE_DISABLED_MODEL;
	level.machine_assets[ PERK_SLEIGHT_OF_HAND ].on_model 	= SLEIGHT_OF_HAND_MACHINE_ACTIVE_MODEL;	
}

function sleight_of_hand_register_clientfield() {}

function sleight_of_hand_set_clientfield( state ) {}

function sleight_of_hand_perk_machine_setup( use_trigger, perk_machine, bump_trigger, collision )
{
	use_trigger.script_sound = "mus_perks_speed_jingle";
	use_trigger.script_string = "speedcola_perk";
	use_trigger.script_label = "mus_perks_speed_sting";
	use_trigger.target = "vending_sleight";
	perk_machine.script_string = "speedcola_perk";
	perk_machine.targetname = "vending_sleight";
	if ( isDefined( bump_trigger ) )
		bump_trigger.script_string = "speedcola_perk";
	
}

//-----------------------------------------------------------------------------------
// FUNCTIONALITY
//-----------------------------------------------------------------------------------
function give_sleight_of_hand_perk()
{
	self zm_perk_utility::create_perk_hud( PERK_SLEIGHT_OF_HAND );
}

function take_sleight_of_hand_perk( b_pause, str_perk, str_result )
{
	self zm_perk_utility::harrybo21_perks_hud_remove( PERK_SLEIGHT_OF_HAND );
	self notify( "perk_lost", str_perk );
}