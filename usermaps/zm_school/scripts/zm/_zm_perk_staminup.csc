#using scripts\codescripts\struct;

#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\shared\visionset_mgr_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#using scripts\zm\_zm_perks;

#insert scripts\zm\_zm_perk_staminup.gsh;
#insert scripts\zm\_zm_perks.gsh;
#insert scripts\zm\_zm_utility.gsh;
	
#precache( "client_fx", "zombie/fx_perk_stamin_up_factory_zmb" );

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
	zm_perks::register_perk_clientfields( 	PERK_STAMINUP, &staminup_client_field_func, &staminup_callback_func );
	zm_perks::register_perk_effects( 		PERK_STAMINUP, STAMINUP_MACHINE_LIGHT_FX );
	zm_perks::register_perk_init_thread( 	PERK_STAMINUP, &init_staminup );
}

function init_staminup()
{
	level._effect[ "marathon_light" ]	= "zombie/fx_perk_stamin_up_factory_zmb";	
}

function staminup_client_field_func() {}

function staminup_callback_func() {}