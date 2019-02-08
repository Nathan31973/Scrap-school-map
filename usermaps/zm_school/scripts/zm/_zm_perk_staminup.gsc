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

#insert scripts\zm\_zm_perk_staminup.gsh;
#insert scripts\zm\_zm_perks.gsh;
#insert scripts\zm\_zm_utility.gsh;

#precache( "fx", "zombie/fx_perk_stamin_up_factory_zmb" );
#precache( "material", STAMINUP_SHADER );
#precache( "string", "ZOMBIE_PERK_MARATHON" );

#namespace zm_perk_staminup;

REGISTER_SYSTEM( "zm_perk_staminup", &__init__, undefined )

//-----------------------------------------------------------------------------------
// SETUP
//-----------------------------------------------------------------------------------
function __init__()
{
	enable_staminup_perk_for_level();
}

function enable_staminup_perk_for_level()
{	
	zm_perks::register_perk_basic_info( 			PERK_STAMINUP, "marathon", 						STAMINUP_PERK_COST, 			&"ZOMBIE_PERK_MARATHON", getWeapon( STAMINUP_PERK_BOTTLE_WEAPON ) );
	zm_perks::register_perk_precache_func( 			PERK_STAMINUP, &staminup_precache );
	zm_perks::register_perk_clientfields( 			PERK_STAMINUP, &staminup_register_clientfield, 	&staminup_set_clientfield );
	zm_perks::register_perk_machine( 				PERK_STAMINUP, &staminup_perk_machine_setup );
	zm_perks::register_perk_threads( 				PERK_STAMINUP, &give_staminup_perk, 			&take_staminup_perk );
	zm_perks::register_perk_host_migration_params( 	PERK_STAMINUP, STAMINUP_RADIANT_MACHINE_NAME, 	STAMINUP_MACHINE_LIGHT_FX );
}

function staminup_precache()
{
	level._effect[ STAMINUP_MACHINE_LIGHT_FX ] 		= "zombie/fx_perk_stamin_up_factory_zmb";
	
	level.machine_assets[ PERK_STAMINUP ] 			= spawnStruct();
	level.machine_assets[ PERK_STAMINUP ].weapon 	= getWeapon( STAMINUP_PERK_BOTTLE_WEAPON );
	level.machine_assets[ PERK_STAMINUP ].off_model = STAMINUP_MACHINE_DISABLED_MODEL;
	level.machine_assets[ PERK_STAMINUP ].on_model 	= STAMINUP_MACHINE_ACTIVE_MODEL;	
}

function staminup_register_clientfield() {}

function staminup_set_clientfield( state ) {}

function staminup_perk_machine_setup( use_trigger, perk_machine, bump_trigger, collision )
{
	use_trigger.script_sound = "mus_perks_stamin_jingle";
	use_trigger.script_string = "marathon_perk";
	use_trigger.script_label = "mus_perks_stamin_sting";
	use_trigger.target = "vending_marathon";
	perk_machine.script_string = "marathon_perk";
	perk_machine.targetname = "vending_marathon";
	if( isDefined( bump_trigger ) )
		bump_trigger.script_string = "marathon_perk";
	
}

//-----------------------------------------------------------------------------------
// FUNCTIONALITY
//-----------------------------------------------------------------------------------
function give_staminup_perk()
{
	self zm_perk_utility::create_perk_hud( PERK_STAMINUP );
}

function take_staminup_perk( b_pause, str_perk, str_result )
{
	self zm_perk_utility::harrybo21_perks_hud_remove( PERK_STAMINUP );
	self notify( "perk_lost", str_perk );
}