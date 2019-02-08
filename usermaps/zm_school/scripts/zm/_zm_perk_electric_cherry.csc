#using scripts\codescripts\struct;

#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\shared\visionset_mgr_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#using scripts\zm\_zm_perks;

#insert scripts\zm\_zm_perks.gsh;
#insert scripts\zm\_zm_utility.gsh;
#insert scripts\zm\_zm_perk_electric_cherry.gsh;

#precache( "client_fx", "zombie/fx_perk_quick_revive_zmb" );
#precache( "client_fx", "zombie/fx_perk_quick_revive_factory_zmb" );
#precache( "client_fx", "dlc1/castle/fx_castle_electric_cherry_down" );
#precache( "client_fx", "dlc1/castle/fx_castle_electric_cherry_trail" );
#precache( "client_fx", "zombie/fx_tesla_shock_zmb" );
#precache( "client_fx", "zombie/fx_tesla_shock_eyes_zmb" );

#namespace zm_perk_electric_cherry;

REGISTER_SYSTEM( "zm_perk_electric_cherry", &__init__, undefined )

//-----------------------------------------------------------------------------------
// SETUP
//-----------------------------------------------------------------------------------
function __init__()
{
	script = tolower( GetDvarString( "mapname" ) );
	if ( script == "zm_factory" || script == "zm_zod" )
		return;
		
	zm_perks::register_perk_clientfields( 	PERK_ELECTRIC_CHERRY, &electric_cherry_client_field_func, &electric_cherry_code_callback_func );
	zm_perks::register_perk_effects( 		PERK_ELECTRIC_CHERRY, ELECTRIC_CHERRY_MACHINE_LIGHT_FX );
	zm_perks::register_perk_init_thread( 	PERK_ELECTRIC_CHERRY, &init_electric_cherry );
}

function init_electric_cherry()
{
	if ( level.script == "zm_zod" || level.script == "zm_castle" || level.script == "zm_island" || level.script == "zm_stalingrad" || level.script == "zm_genesis" )
		level._effect[ ELECTRIC_CHERRY_MACHINE_LIGHT_FX ]	= "zombie/fx_perk_quick_revive_zmb";
	else
		level._effect[ ELECTRIC_CHERRY_MACHINE_LIGHT_FX ]	= "zombie/fx_perk_quick_revive_factory_zmb";
	
	RegisterClientField( "allplayers", "electric_cherry_reload_fx",	VERSION_SHIP, 2, "int", &electric_cherry_reload_attack_fx, 0 );
	clientfield::register( "actor", "tesla_death_fx", VERSION_SHIP, 1, "int", &tesla_death_fx_callback, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "vehicle", "tesla_death_fx_veh", VERSION_TU10, 1, "int", &tesla_death_fx_callback, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "actor", "tesla_shock_eyes_fx", VERSION_SHIP, 1, "int", &tesla_shock_eyes_fx_callback, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "vehicle", "tesla_shock_eyes_fx_veh", VERSION_TU10, 1, "int", &tesla_shock_eyes_fx_callback, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	
	level._effect[ "electric_cherry_explode" ]			= "dlc1/castle/fx_castle_electric_cherry_down";
	level._effect[ "electric_cherry_trail" ]			= "dlc1/castle/fx_castle_electric_cherry_trail";
	level._effect[ "tesla_death_cherry" ]				= "zombie/fx_tesla_shock_zmb";
	level._effect[ "tesla_shock_eyes_cherry" ]			= "zombie/fx_tesla_shock_eyes_zmb";
	level._effect[ "tesla_shock_cherry" ]				= "zombie/fx_bmode_shock_os_zod_zmb";
}

function electric_cherry_client_field_func() {}

function electric_cherry_code_callback_func() {}

//-----------------------------------------------------------------------------------
// FUNCTIONALITY
//-----------------------------------------------------------------------------------
function electric_cherry_reload_attack_fx( localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump )
{	
	if ( isDefined( self.electric_cherry_reload_fx ) )
		stopFX( localClientNum, self.electric_cherry_reload_fx );			
	
	if ( newVal == 1 )
		self.electric_cherry_reload_fx = playFXOnTag( localClientNum, level._effect[ "electric_cherry_explode" ], self, "tag_origin" );
	else if ( newVal == 2 )
		self.electric_cherry_reload_fx = PlayFXOnTag( localClientNum, level._effect[ "electric_cherry_explode" ], self, "tag_origin" );
	else if ( newVal == 3 )
		self.electric_cherry_reload_fx = PlayFXOnTag( localClientNum, level._effect[ "electric_cherry_explode" ], self, "tag_origin" );
	else
	{
		if ( isDefined( self.electric_cherry_reload_fx ) )
			stopFX( localClientNum, self.electric_cherry_reload_fx );			
		
		self.electric_cherry_reload_fx = undefined;
	}
}

function tesla_death_fx_callback(localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump) // self = zombie
{
	if( newVal == 1 )
	{
		str_tag = "j_spineupper";

		if( isDefined( self.str_tag_tesla_death_fx ) )
			str_tag = self.str_tag_tesla_death_fx;
		else if ( IS_TRUE( self.isdog ) )
			str_tag = "j_spine1";
		
		self.n_death_fx = playFXOnTag( localClientNum, level._effect[ "tesla_death_cherry" ], self, str_tag );
		setFXIgnorePause( localClientNum, self.n_death_fx, 1 );
	}
	else
	{
		if ( isDefined( self.n_death_fx ) )
			deleteFx( localClientNum, self.n_death_fx, 1 );
		
		self.n_death_fx = undefined;
	}		
}

function tesla_shock_eyes_fx_callback( localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump )
{
	if( newVal == 1 )
	{
		str_tag = "j_spineupper";

		if( isDefined( self.str_tag_tesla_shock_eyes_fx ) )
			str_tag = self.str_tag_tesla_shock_eyes_fx;
		else if ( IS_TRUE( self.isdog ) )
			str_tag = "j_spine1";
		
		self.n_shock_eyes_fx = playFXOnTag( localClientNum, level._effect[ "tesla_shock_eyes_cherry" ], self, "j_eyeball_le" );
		SetFXIgnorePause( localClientNum, self.n_shock_eyes_fx, 1 );
		
		self.n_shock_fx = playFXOnTag( localClientNum, level._effect[ "tesla_death_cherry" ], self, str_tag );
		setFXIgnorePause( localClientNum, self.n_shock_fx, 1 );
	}
	else
	{
		if ( isDefined( self.n_shock_eyes_fx ) )
		{
			deleteFx( localClientNum, self.n_shock_eyes_fx, 1 );
			self.n_shock_eyes_fx = undefined;		
		}
		
		if ( isDefined( self.n_shock_fx ) )
		{
			deleteFx( localClientNum, self.n_shock_fx, 1 );
			self.n_shock_fx = undefined;
		}
	}		
}