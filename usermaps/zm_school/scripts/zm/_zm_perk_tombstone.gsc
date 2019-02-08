#using scripts\codescripts\struct;

#using scripts\shared\array_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\math_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\shared\visionset_mgr_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\laststand_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#using scripts\shared\ai\zombie_utility;

#using scripts\zm\_util;
#using scripts\zm\_zm;
#using scripts\zm\_zm_net;
#using scripts\zm\_zm_perks;
#using scripts\zm\_zm_pers_upgrades;
#using scripts\zm\_zm_pers_upgrades_functions;
#using scripts\zm\_zm_pers_upgrades_system;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_stats;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_equipment;

#using scripts\zm\_zm_perk_utility;

#insert scripts\zm\_zm_perk_tombstone.gsh;
#insert scripts\zm\_zm_perks.gsh;
#insert scripts\zm\_zm_utility.gsh;

#precache( "model", TOMBSTONE_DROP_MODEL );
#precache( "fx", "zombie/fx_perk_sleight_of_hand_factory_zmb" );
#precache( "fx", "zombie/fx_perk_sleight_of_hand_zmb" );

#namespace zm_perk_tombstone;

REGISTER_SYSTEM( "zm_perk_tombstone", &__init__, undefined )

//-----------------------------------------------------------------------------------
// SETUP
//-----------------------------------------------------------------------------------
function __init__()
{
	enable_tombstone_perk_for_level();
	
	if ( level.script == "zm_zod" )
		zm_perk_utility::place_perk_machine( ( 848, -5631, 384 ), ( 0, 90, 0 ), "specialty_tombstone", TOMBSTONE_MACHINE_DISABLED_MODEL );
	if ( level.script == "zm_factory" )
		zm_perk_utility::place_perk_machine( ( -584, 536, -6 ), ( 0, 90, 0 ), "specialty_tombstone", TOMBSTONE_MACHINE_DISABLED_MODEL );
	if ( level.script == "zm_castle" )
		zm_perk_utility::place_perk_machine( ( 792, 2447, 640 ), ( 0, 180, 0 ), "specialty_tombstone", TOMBSTONE_MACHINE_DISABLED_MODEL );
	if ( level.script == "zm_island" )
		zm_perk_utility::place_perk_machine( ( 490, 1840, -345 ), ( 0, 0, 0 ), "specialty_tombstone", TOMBSTONE_MACHINE_DISABLED_MODEL );
	if ( level.script == "zm_stalingrad" )
		zm_perk_utility::place_perk_machine( ( -521, 5135, 304 ), ( 0, 180, 0 ), "specialty_tombstone", TOMBSTONE_MACHINE_DISABLED_MODEL );
	if ( level.script == "zm_genesis" )
		zm_perk_utility::place_perk_machine( ( -92, -7161, -1311 ), ( 0, 180, 0 ), "specialty_tombstone", TOMBSTONE_MACHINE_DISABLED_MODEL );
}

function enable_tombstone_perk_for_level()
{	
	zm_perks::register_perk_basic_info( 			"specialty_tombstone", 				"tombstone", 						TOMBSTONE_PERK_COST, 			"Hold ^3[{+activate}]^7 for Tombstone [Cost: &&1]", getWeapon( TOMBSTONE_PERK_BOTTLE_WEAPON ) );
	zm_perks::register_perk_precache_func( 			"specialty_tombstone", 				&tombstone_precache );
	zm_perks::register_perk_clientfields( 			"specialty_tombstone", 				&tombstone_register_clientfield, 	&tombstone_set_clientfield );
	zm_perks::register_perk_machine( 				"specialty_tombstone", 				&tombstone_perk_machine_setup );
	zm_perks::register_perk_threads( 				"specialty_tombstone", 				&tombstone_perk_give, 				&tombstone_perk_lost );
	zm_perks::register_perk_host_migration_params( 	"specialty_tombstone", 				TOMBSTONE_RADIANT_MACHINE_NAME, 	TOMBSTONE_MACHINE_LIGHT_FX );
	zm_perks::register_perk_threads( 				"specialty_tombstone", 				&tombstone_perk_give, 				&tombstone_perk_lost );
	
	level.playerSuicideAllowed = 1;
	level.canPlayerSuicide = &tombstone_valid;
	callback::on_spawned( &tombstone_grenade_tracking );
	level thread init_tombstone();
	// level thread delay_remove_test(); // FOR TESTING CLIENT DISCONNECTS
	
	callback::on_disconnect( &tombstone_player_disconnect );
	callback::on_connect( &tombstone_player_connect );
	
	level thread tombstone_solo_remove_check();
}

function disable_tombstone_perk_for_level()
{
	players = getPlayers();
	for ( i = 0; i < players.size; i++ )
	{
		if ( players[ i ] hasPerk( "specialty_tombstone" ) )
			players[ i ] tombstone_perk_lost();
		
	}
	
	machines = getEntArray( "zombie_vending", "targetname" );
	if ( isDefined( machines ) && machines.size > 0 )
	{
		for ( i = 0; i < machines.size; i++ )
		{
			if ( machines[ i ].script_noteworthy == "specialty_tombstone" )
			{
				machines[ i ] hide();
				machines[ i ] triggerEnable( 0 );
				machines[ i ].machine hide();
				// machines[ i ] zm_perks::perk_fx( undefined, 1 );
				playFX( level._effect[ "poltergeist" ], machines[ i ].origin );
				playSoundAtPosition( "zmb_box_poof", machines[ i ].origin );
			}
		}
	}
	
	// level._custom_perks = array::remove_index( level._custom_perks, "specialty_tombstone" );
	level.tombstone_active = undefined;
	level.playerSuicideAllowed = 0;
	level.canPlayerSuicide = undefined;
	level notify( "tombstone_disabled" );
}

function reenable_tombstone_perk_for_level()
{	
	zm_perks::register_perk_basic_info( "specialty_tombstone", "tombstone", TOMBSTONE_PERK_COST, "Hold ^3[{+activate}]^7 for Tombstone [Cost: &&1]", getWeapon( TOMBSTONE_PERK_BOTTLE_WEAPON ) );
	zm_perks::register_perk_precache_func( "specialty_tombstone", &tombstone_precache );
	zm_perks::register_perk_clientfields( "specialty_tombstone", &tombstone_register_clientfield, &tombstone_set_clientfield );
	zm_perks::register_perk_machine( "specialty_tombstone", &tombstone_perk_machine_setup );
	zm_perks::register_perk_threads( PERK_ADDITIONAL_PRIMARY_WEAPON, &tombstone_perk_give, &tombstone_perk_lost );
	zm_perks::register_perk_host_migration_params( "specialty_tombstone", TOMBSTONE_RADIANT_MACHINE_NAME, TOMBSTONE_MACHINE_LIGHT_FX );
	zm_perks::register_perk_threads( "specialty_tombstone", &tombstone_perk_give, &tombstone_perk_lost );
	
	machines = getEntArray( "zombie_vending", "targetname" );
	if ( isDefined( machines ) && machines.size > 0 )
	{
		for ( i = 0; i < machines.size; i++ )
		{
			if ( machines[ i ].script_noteworthy == "specialty_tombstone" )
			{
				machines[ i ] show();
				machines[ i ] triggerEnable( 1 );
				machines[ i ].machine show();
				machines[ i ] zm_perks::perk_fx( level._effect[ TOMBSTONE_MACHINE_LIGHT_FX ] );
				playFX( level._effect[ "poltergeist" ], machines[ i ].origin );
				playSoundAtPosition ( "zmb_box_poof", machines[ i ].origin );
			}
		}
	}
	
	level.playerSuicideAllowed = 1;
	level.canPlayerSuicide = &tombstone_valid;
	callback::on_spawned( &tombstone_grenade_tracking );
	level thread init_tombstone();
	
	players = getPlayers();
	for ( i = 0; i < players.size; i++ )
		players[ i ] thread tombstone_grenade_tracking();
	
}

function tombstone_precache()
{
	if ( zm_perk_utility::is_stock_map() && level.script != "zm_factory" )
		level._effect[ TOMBSTONE_MACHINE_LIGHT_FX ] = "zombie/fx_perk_sleight_of_hand_zmb";
	else
		level._effect[ TOMBSTONE_MACHINE_LIGHT_FX ] = "zombie/fx_perk_sleight_of_hand_factory_zmb";
	
	level.machine_assets[ "specialty_tombstone" ] = spawnStruct();
	level.machine_assets[ "specialty_tombstone" ].weapon = getWeapon( TOMBSTONE_PERK_BOTTLE_WEAPON );
	level.machine_assets[ "specialty_tombstone" ].off_model = TOMBSTONE_MACHINE_DISABLED_MODEL;
	level.machine_assets[ "specialty_tombstone" ].on_model = TOMBSTONE_MACHINE_ACTIVE_MODEL;
}

function tombstone_register_clientfield() {}

function tombstone_set_clientfield( state ) {}

function tombstone_perk_machine_setup( use_trigger, perk_machine, bump_trigger, collision )
{
	use_trigger.script_sound = "mus_perks_tombstone_jingle";
	use_trigger.script_string = "tombstone_perk";
	use_trigger.script_label = "mus_perks_tombstone_sting";
	use_trigger.target = "vending_tombstone";
	perk_machine.script_string = "tombstone_perk";
	perk_machine.targetname = "vending_tombstone";
	
	if ( isDefined( bump_trigger ) )
		bump_trigger.script_string = "tombstone_perk";
	
}

function tombstone_perk_lost( b_pause, str_perk, str_result )
{
	self zm_perk_utility::harrybo21_perks_hud_remove( "specialty_tombstone" );
	self notify( "specialty_tombstone" + "_stop" );
	self notify( "perk_lost", str_perk );
}

function tombstone_perk_give( b_pause, str_perk, str_result )
{
	self zm_perk_utility::create_perk_hud( "specialty_tombstone" );
	self notify( "specialty_tombstone" + "_start" );
}

function tombstone_host_migration_func()
{
	a_tombstone_perk_machines = getEntArray( "vending_tombstone", "targetname" );
	
	foreach( perk_machine in a_tombstone_perk_machines )
	{
		if( isDefined( perk_machine.model ) && perk_machine.model == TOMBSTONE_MACHINE_ACTIVE_MODEL )
		{
			perk_machine zm_perks::perk_fx( undefined, 1 );
			perk_machine thread zm_perks::perk_fx( "tombstone" );
		}
	}
}

//-----------------------------------------------------------------------------------
// FUNCTIONALITY
//-----------------------------------------------------------------------------------
function init_tombstone()
{	
	wait .05;
	level flag::wait_till( "initial_blackscreen_passed" );
	level.tombstone_active = 1;
	level.playerSuicideAllowed = 1;
	level.canPlayerSuicide = &tombstone_valid;
}

function tombstone_grenade_tracking()
{
	self endon( "death" );
	level endon( "tombstone_disabled" );
	
	self.track_lethal = undefined;
	self.track_tactical = undefined;
	self.track_lethal_ammo = undefined;
	self.track_tactical_ammo = undefined;
	self.track_current_tomahawk_weapon = undefined;
	while( 1 )
	{
		if ( self laststand::player_is_in_laststand() )
		{
			wait .05;
			continue;
		}
		
		lethal_grenade = self zm_utility::get_player_lethal_grenade();
		if ( isDefined( lethal_grenade ) )
		{
			lethal_grenade_ammo = self getweaponammoclip( lethal_grenade );
			
			if ( !isDefined( self.track_lethal ) || self.track_lethal != lethal_grenade )
				self.track_lethal = lethal_grenade;
			
			if ( !isDefined( self.track_lethal_ammo ) || self.track_lethal_ammo != lethal_grenade_ammo )
				self.track_lethal_ammo = lethal_grenade_ammo;
			
		}
		
		tactical_grenade = self zm_utility::get_player_tactical_grenade();
		if ( isDefined( tactical_grenade ) )
		{
			tactical_grenade_ammo = self getweaponammoclip( tactical_grenade );
			
			if ( !isDefined( self.track_tactical ) || self.track_tactical != tactical_grenade )
				self.track_tactical = tactical_grenade;
			
			if ( !isDefined( self.track_tactical_ammo ) || self.track_tactical_ammo != tactical_grenade_ammo )
				self.track_tactical_ammo = tactical_grenade_ammo;
			
		}
		
		tomahawk = self.current_tomahawk_weapon;
		if ( isDefined( tomahawk ) )
		{
			if ( !isDefined( self.track_current_tomahawk_weapon ) || self.track_current_tomahawk_weapon != tomahawk )
				self.track_current_tomahawk_weapon = tomahawk;	
		}
			
		wait .05;
	}
}

function tombstone_valid()
{
	if ( self hasPerk( "specialty_tombstone" ) )
	{
		self thread tombstone_spawn();
		return 1;
	}
	return 0;
}

function tombstone_spawn()
{
	dc = spawn( "script_model", self.origin + vectorScale( ( 0, 0, 1 ), 40 ) );
	dc.angles = self.angles;
	dc setModel( "tag_origin" );
	dc_icon = spawn( "script_model", self.origin + vectorScale( ( 0, 0, 1 ), 40 ) );
	dc_icon.angles = self.angles;
	dc_icon setModel( "ch_tombstone1" );
	dc_icon linkto( dc );
	dc.icon = dc_icon;
	dc.script_noteworthy = "player_tombstone_model";
	dc.player = self;
	dc thread tombstone_wobble();
	dc thread tombstone_revived( self );
	dc.loadout = self get_tombstone_loadout();
	result = self util::waittill_any_return( "player_revived", "spawned_player", "disconnect" );
	if ( result == "player_revived" || result == "disconnect" )
	{
		dc notify( "tombstone_timedout" );
		dc_icon unlink();
		dc_icon delete();
		dc delete();
		return;
	}
	dc thread tombstone_timeout();
	dc thread tombstone_grab();
}

function tombstone_revived( player )
{
	self endon( "tombstone_timedout" );
	player endon( "disconnect" );
	shown = 1;
	while ( isDefined( self ) && isDefined( player ) )
	{
		if ( isDefined( player.revivetrigger ) && isDefined( player.revivetrigger.beingrevived ) && player.revivetrigger.beingrevived )
		{
			if ( shown )
			{
				shown = 0;
				self.icon hide();
			}
		}
		else
		{
			if ( !shown )
			{
				shown = 1;
				self.icon show();
			}
		}
		wait .05;
	}
}

function get_tombstone_loadout()
{
	loadout = SpawnStruct();
	loadout.weapons = self zm_weapons::player_get_loadout();
	loadout.perks = self zm_perks::get_perk_array();
	
	loadout.equipment = self zm_equipment::get_player_equipment();
	if ( isDefined( loadout.equipment ) )
		self zm_equipment::take( loadout.equipment );
	
	loadout save_weapons_for_tombstone( self );
	self tombstone_save_grenades( loadout );
	
	return loadout;
}

function tombstone_save_perks( ent )
{
	perk_array = ent zm_perks::get_perk_array();
	_a941 = perk_array;
	_k941 = getFirstArrayKey( _a941 );
	while ( isDefined( _k941 ) )
	{
		perk = _a941[ _k941 ];
		ent unsetperk( perk );
		_k941 = getNextArrayKey( _a941, _k941 );
	}
	
	return perk_array;
}

function tombstone_grab()
{
	self endon( "tombstone_timedout" );
	wait 1;
	while ( isDefined( self ) )
	{
		players = getPlayers();
		i = 0;
		while ( i < players.size )
		{
			if ( players[ i ].is_zombie )
			{
				i++;
				continue;
			}
			else
			{
				if ( isDefined( self.player ) && players[ i ] == self.player )
				{
					dist = distance( players[ i ].origin, self.origin );
					if ( dist < 64 )
					{
						playFx( level._effect[ "powerup_grabbed" ], self.origin );
						playFx( level._effect[ "powerup_grabbed_wave" ], self.origin );
						players[ i ] tombstone_give( self.loadout );
						wait .1;
						playSoundAtPosition( "zmb_powerup_grabbed", self.origin );
						self stoploopsound();
						self.icon unlink();
						self.icon delete();
						self delete();
						self notify( "tombstone_grabbed" );
						players[ i ] notify( "dance_on_my_grave" );
					}
				}
			}
			i++;
		}
		util::wait_network_frame();
	}
}

function tombstone_give( loadout )
{
	self zm_weapons::player_give_loadout( loadout.weapons, 1, 1 );

	foreach( perk in loadout.perks )
	{
		if( perk == "specialty_tombstone" )
			continue;
		if( self hasPerk( perk ) )
			continue;
		
		self zm_perks::give_perk( perk, 0 );
	}
	loadout restore_weapons_for_tombstone( self );
	self tombstone_restore_grenades( loadout );
}

function tombstone_wobble()
{
	self endon( "tombstone_grabbed" );
	self endon( "tombstone_timedout" );
	if ( isDefined( self ) )
	{
		wait 1;
		playFxOnTag( level._effect[ "powerup_on" ], self, "tag_origin" );
		playSoundAtPosition( "zmb_spawn_powerup", self.origin );
		self PlayLoopSound( "zmb_spawn_powerup_loop" );
	}
	while ( isDefined( self ) )
	{
		self rotateYaw( 360, 3 );
		wait 2.9;
	}
}

function tombstone_timeout()
{
	self endon( "tombstone_grabbed" );
	self thread play_tombstone_timer_audio();
	wait 48.5;
	i = 0;
	while ( i < 40 )
	{
		if ( i % 2 )
			self.icon ghost();
		else
			self.icon show();
		
		if ( i < 15 )
		{
			wait .5;
			i++;
			continue;
		}
		else if ( i < 25 )
		{
			wait .25;
			i++;
			continue;
		}
		else
			wait .1;
		
		i++;
	}
	self notify( "tombstone_timedout" );
	self.icon unlink();
	self.icon delete();
	self delete();
}

function play_tombstone_timer_audio()
{
	self endon( "tombstone_grabbed" );
	self endon( "tombstone_timedout" );
	player = self.player;
	self thread play_tombstone_timer_out( player );
	while ( 1 )
	{
		player playSoundToPlayer( "zmb_tombstone_timer_count", player );
		wait 1;
	}
}

function play_tombstone_timer_out( player )
{
	self endon( "tombstone_grabbed" );
	self waittill( "tombstone_timedout" );
	player playSoundToPlayer( "zmb_tombstone_timer_out", player );
}

function save_weapons_for_tombstone( player )
{
	self.tombstone_melee_weapons = [];
	i = 0;
	while ( i < level._melee_weapons.size )
	{
		self save_weapon_for_tombstone( player, level._melee_weapons[ i ].weapon_name );
		i++;
	}
}

function save_weapon_for_tombstone( player, weapon_name )
{
	if ( player hasWeapon( getWeapon( weapon_name ) ) )
		self.tombstone_melee_weapons[ weapon_name ] = 1;
}

function restore_weapons_for_tombstone( player )
{
	i = 0;
	while ( i < level._melee_weapons.size )
	{
		self restore_weapon_for_tombstone( player, level._melee_weapons[ i ].weapon_name );
		i++;
	}
	self.tombstone_melee_weapons = undefined;
}

function restore_weapon_for_tombstone( player, weapon_name )
{
	if ( isDefined( weapon_name ) || !isDefined( self.tombstone_melee_weapons ) && !isDefined( self.tombstone_melee_weapons[ weapon_name ] ) )
	{
		return;
	}
	if ( isDefined( self.tombstone_melee_weapons[ weapon_name ] ) && self.tombstone_melee_weapons[ weapon_name ] )
	{
		player giveweapon( getWeapon( weapon_name ) );
		player zm_utility::set_player_melee_weapon( weapon_name );
		self.tombstone_melee_weapons[ weapon_name ] = 0;
	}
}

function tombstone_save_grenades( loadout )
{
	lethal_grenade = self.track_lethal;
	if ( isDefined( lethal_grenade ) && isDefined( self.track_lethal_ammo ) )
	{
		loadout.lethal_grenade = lethal_grenade;
		loadout.lethal_grenade_count = self.track_lethal_ammo;
	}
	else
		loadout.lethal_grenade = undefined;
	
	tactical_grenade = self.track_tactical;
	if ( isDefined( tactical_grenade ) && isDefined( self.track_tactical_ammo ) )
	{
		loadout.tactical_grenade = tactical_grenade;
		loadout.tactical_grenade_count = self.track_tactical_ammo;
	}
	else
		loadout.tactical_grenade = undefined;
	
	tomahawk = self.track_current_tomahawk_weapon;
	if ( isDefined( tomahawk ) )
		loadout.tomahawk = tomahawk;
	
}

function tombstone_restore_grenades( loadout )
{
	if ( isDefined( loadout.lethal_grenade ) )
	{
		self zm_utility::set_player_lethal_grenade( loadout.lethal_grenade );
		self giveWeapon( loadout.lethal_grenade );
		self setWeaponAmmoClip( loadout.lethal_grenade, loadout.lethal_grenade_count );
	}
	if ( isDefined( loadout.tactical_grenade ) )
	{
		self zm_utility::set_player_tactical_grenade( loadout.tactical_grenade );
		self giveWeapon( loadout.tactical_grenade );
		self setWeaponAmmoClip( loadout.tactical_grenade, loadout.tactical_grenade_count );
	}
	if ( isDefined( loadout.tomahawk ) )
		self.current_tomahawk_weapon = loadout.tomahawk;
	
}

function tombstone_hostmigration()
{
	level endon( "end_game" );
	level notify( "tombstone_hostmigration" );
	level endon( "tombstone_hostmigration" );
	while ( 1 )
	{
		level waittill( "host_migration_end" );
		tombstones = getEntArray( "player_tombstone_model", "script_noteworthy" );
		_a564 = tombstones;
		_k564 = getFirstArrayKey( _a564 );
		while ( isDefined( _k564 ) )
		{
			model = _a564[ _k564 ];
			playFxOnTag( level._effect[ "powerup_on" ], model, "tag_origin" );
			_k564 = getNextArrayKey( _a564, _k564 );
		}
	}
}

function tombstone_solo_remove_check()
{
	wait .05;
	level flag::wait_till( "initial_blackscreen_passed" );
	wait 2;
	players = getPlayers();
	if ( players.size < 2 )
		disable_tombstone_perk_for_level();
	
}

function tombstone_player_disconnect()
{
	players = getPlayers();
	
	if ( players.size > 1 && isDefined( level.tombstone_active ) && level.tombstone_active )
		return;
	
	disable_tombstone_perk_for_level();
}

function tombstone_player_connect()
{
	if ( isDefined( level.tombstone_active ) && level.tombstone_active )
		return;
	
	reenable_tombstone_perk_for_level();
}

function delay_remove_test()
{
	wait .05;
	level flag::wait_till( "initial_blackscreen_passed" );
	
	while( 1 )
	{
		wait 10;
		iPrintLnBold( "TOMBSTONE OFF" );
	
		disable_tombstone_perk_for_level();
		
		wait 10;
		iPrintLnBold( "TOMBSTONE ON" );
	
		reenable_tombstone_perk_for_level();
	}
}