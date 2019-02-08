#using scripts\codescripts\struct;

#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\shared\visionset_mgr_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#using scripts\zm\_zm_perks;

#insert scripts\zm\_zm_perk_tombstone.gsh;
#insert scripts\zm\_zm_perks.gsh;
#insert scripts\zm\_zm_utility.gsh;

#precache( "client_fx", "zombie/fx_perk_sleight_of_hand_factory_zmb" );
#precache( "client_fx", "zombie/fx_perk_sleight_of_hand_zmb" );

#namespace zm_perk_tombstone;

REGISTER_SYSTEM( "zm_perk_tombstone", &__init__, undefined )
	
//-----------------------------------------------------------------------------------
// SETUP
//-----------------------------------------------------------------------------------
function __init__()
{
	zm_perks::register_perk_clientfields( 	PERK_TOMBSTONE, &tombstone_client_field_func, &tombstone_code_callback_func );
	zm_perks::register_perk_effects( 		PERK_TOMBSTONE, TOMBSTONE_MACHINE_LIGHT_FX );
	zm_perks::register_perk_init_thread( 	PERK_TOMBSTONE, &init_tombstone );
}

function init_tombstone()
{
	if ( level.script == "zm_zod" || level.script == "zm_castle" || level.script == "zm_island" || level.script == "zm_stalingrad" || level.script == "zm_genesis" )
		level._effect[ TOMBSTONE_MACHINE_LIGHT_FX ]	= "zombie/fx_perk_sleight_of_hand_zmb";
	else
		level._effect[ TOMBSTONE_MACHINE_LIGHT_FX ]	= "zombie/fx_perk_sleight_of_hand_factory_zmb";
		
}

function tombstone_client_field_func() {}

function tombstone_code_callback_func() {}