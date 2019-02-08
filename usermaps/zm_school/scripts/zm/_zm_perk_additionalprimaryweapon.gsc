#using scripts\codescripts\struct;

#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
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
#using scripts\zm\_zm_weapons;

#using scripts\zm\_zm_perk_utility;

#insert scripts\zm\_zm_perk_additionalprimaryweapon.gsh;
#insert scripts\zm\_zm_perks.gsh;
#insert scripts\zm\_zm_utility.gsh;

#precache( "material", "specialty_extraprimaryweapon_zombies" );
#precache( "string", "ZOMBIE_PERK_ADDITIONALPRIMARYWEAPON" );
#precache( "fx", "zombie/fx_perk_mule_kick_factory_zmb" );

#namespace zm_perk_additionalprimaryweapon;

REGISTER_SYSTEM( "zm_perk_additionalprimaryweapon", &__init__, undefined )

//-----------------------------------------------------------------------------------
// SETUP
//-----------------------------------------------------------------------------------
function __init__()
{
	enable_additional_primary_weapon_perk_for_level();
}

function enable_additional_primary_weapon_perk_for_level()
{	
	level.additionalprimaryweapon_limit = 3;
	
	zm_perks::register_perk_basic_info( 			PERK_ADDITIONAL_PRIMARY_WEAPON, "additionalprimaryweapon", 							ADDITIONAL_PRIMARY_WEAPON_PERK_COST, 		&"ZOMBIE_PERK_ADDITIONALPRIMARYWEAPON", getWeapon( ADDITIONAL_PRIMARY_WEAPON_PERK_BOTTLE_WEAPON ) );
	zm_perks::register_perk_precache_func( 			PERK_ADDITIONAL_PRIMARY_WEAPON, &additional_primary_weapon_precache );
	zm_perks::register_perk_clientfields( 			PERK_ADDITIONAL_PRIMARY_WEAPON, &additional_primary_weapon_register_clientfield, 	&additional_primary_weapon_set_clientfield );
	zm_perks::register_perk_machine( 				PERK_ADDITIONAL_PRIMARY_WEAPON, &additional_primary_weapon_perk_machine_setup );
	zm_perks::register_perk_threads( 				PERK_ADDITIONAL_PRIMARY_WEAPON, &give_additional_primary_weapon_perk, 				&take_additional_primary_weapon_perk );
	zm_perks::register_perk_host_migration_params( 	PERK_ADDITIONAL_PRIMARY_WEAPON, ADDITIONAL_PRIMARY_WEAPON_RADIANT_MACHINE_NAME, 	ADDITIONAL_PRIMARY_WEAPON_MACHINE_LIGHT_FX );
	
	callback::on_laststand( &on_laststand );
}

function additional_primary_weapon_precache()
{
	level._effect[ ADDITIONAL_PRIMARY_WEAPON_MACHINE_LIGHT_FX ] 		= "zombie/fx_perk_mule_kick_factory_zmb";
	
	level.machine_assets[ PERK_ADDITIONAL_PRIMARY_WEAPON ] 				= spawnStruct();
	level.machine_assets[ PERK_ADDITIONAL_PRIMARY_WEAPON ].weapon 		= getWeapon( ADDITIONAL_PRIMARY_WEAPON_PERK_BOTTLE_WEAPON );
	level.machine_assets[ PERK_ADDITIONAL_PRIMARY_WEAPON ].off_model 	= ADDITIONAL_PRIMARY_WEAPON_MACHINE_DISABLED_MODEL;
	level.machine_assets[ PERK_ADDITIONAL_PRIMARY_WEAPON ].on_model 	= ADDITIONAL_PRIMARY_WEAPON_MACHINE_ACTIVE_MODEL;
}

function additional_primary_weapon_register_clientfield() {}

function additional_primary_weapon_set_clientfield( state ) {}

function additional_primary_weapon_perk_machine_setup( use_trigger, perk_machine, bump_trigger, collision )
{
	use_trigger.script_sound = "mus_perks_mulekick_jingle";
	use_trigger.script_string = "tap_perk";
	use_trigger.script_label = "mus_perks_mulekick_sting";
	use_trigger.target = ADDITIONAL_PRIMARY_WEAPON_RADIANT_MACHINE_NAME;
	perk_machine.script_string = "tap_perk";
	perk_machine.targetname = ADDITIONAL_PRIMARY_WEAPON_RADIANT_MACHINE_NAME;
	if( isDefined( bump_trigger ) )
		bump_trigger.script_string = "tap_perk";
	
}

//-----------------------------------------------------------------------------------
// FUNCTIONALITY
//-----------------------------------------------------------------------------------
function give_additional_primary_weapon_perk()
{
	self zm_perk_utility::create_perk_hud( PERK_ADDITIONAL_PRIMARY_WEAPON );
}

function take_additional_primary_weapon_perk( b_pause, str_perk, str_result )
{
	self zm_perk_utility::harrybo21_perks_hud_remove( PERK_ADDITIONAL_PRIMARY_WEAPON );
	
	if ( b_pause || str_result == str_perk )
		self take_additionalprimaryweapon();
	
	self notify( "perk_lost", str_perk );
}

function take_additionalprimaryweapon()
{
	weapon_to_take = level.weaponNone;

	if ( IS_TRUE( self._retain_perks ) || ( isDefined( self._retain_perks_array ) && IS_TRUE( self._retain_perks_array[ PERK_ADDITIONAL_PRIMARY_WEAPON ] ) ) )
		return weapon_to_take;

	primary_weapons_that_can_be_taken = [];

	primaryWeapons = self getWeaponsListPrimaries();
	for ( i = 0; i < primaryWeapons.size; i++ )
	{
		if ( zm_weapons::is_weapon_included( primaryWeapons[ i ] ) || zm_weapons::is_weapon_upgraded( primaryWeapons[ i ] ) )
			primary_weapons_that_can_be_taken[ primary_weapons_that_can_be_taken.size ] = primaryWeapons[ i ];
		
	}

	pwtcbt = primary_weapons_that_can_be_taken.size;
	while ( pwtcbt >= 3 )
	{
		weapon_to_take = primary_weapons_that_can_be_taken[ pwtcbt - 1 ];
		pwtcbt--;
		if ( weapon_to_take == self getCurrentWeapon() )
			self SwitchToWeapon( primary_weapons_that_can_be_taken[ 0 ] );
		
		self takeWeapon( weapon_to_take );
	}

	return weapon_to_take;
}

function on_laststand()
{
 	if ( self hasPerk( PERK_ADDITIONAL_PRIMARY_WEAPON ) )
		self.weapon_taken_by_losing_specialty_additionalprimaryweapon = take_additionalprimaryweapon();
 	
}
