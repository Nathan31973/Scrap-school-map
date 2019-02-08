#using scripts\codescripts\struct;

#using scripts\shared\array_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\math_shared;
#using scripts\shared\system_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\util_shared;
#using scripts\shared\visionset_mgr_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#using scripts\shared\ai\zombie_utility;

#using scripts\zm\_util;
#using scripts\zm\_zm;
#using scripts\zm\_zm_laststand;
#using scripts\zm\_zm_equipment;
#using scripts\zm\_zm_net;
#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_perks;
#using scripts\zm\_zm_pers_upgrades;
#using scripts\zm\_zm_pers_upgrades_functions;
#using scripts\zm\_zm_pers_upgrades_system;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_stats;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_clone;

#using scripts\zm\_zm_perk_utility;

#insert scripts\zm\_zm_perk_whoswho.gsh;
#insert scripts\zm\_zm_perks.gsh;
#insert scripts\zm\_zm_utility.gsh;

#precache( "model", WHOSWHO_MACHINE_DISABLED_MODEL );
#precache( "model", WHOSWHO_MACHINE_ACTIVE_MODEL );
#precache( "xanim", "pb_laststand_idle" );
#precache( "material", "mtl_waypoint_revive" );
#using_animtree( "zm_ally" );

#precache( "fx", "zombie/fx_perk_sleight_of_hand_factory_zmb" );

#namespace zm_perk_whoswho;

REGISTER_SYSTEM( "zm_perk_whoswho", &__init__, undefined )

//-----------------------------------------------------------------------------------
// SETUP
//-----------------------------------------------------------------------------------
function __init__()
{
	enable_whoswho_perk_for_level();
	
	if ( level.script == "zm_zod" )
		zm_perk_utility::place_perk_machine( ( 1087, -3784, 258 ), ( 0, 90, 0 ), PERK_WHOSWHO, WHOSWHO_MACHINE_DISABLED_MODEL );
	else if ( level.script == "zm_factory" )
		zm_perk_utility::place_perk_machine( ( 632, 144, 64 ), ( 0, 90, 0 ), PERK_WHOSWHO, WHOSWHO_MACHINE_DISABLED_MODEL );
	else if ( level.script == "zm_castle" )
		zm_perk_utility::place_perk_machine( ( -161, 2479, 912 ), ( 0, 0, 0 ), PERK_WHOSWHO, WHOSWHO_MACHINE_DISABLED_MODEL );
	else if ( level.script == "zm_island" )
		zm_perk_utility::place_perk_machine( ( 831, -985, -453 ), ( 0, 0, 0 ), PERK_WHOSWHO, WHOSWHO_MACHINE_DISABLED_MODEL );
	else if ( level.script == "zm_stalingrad" )
		zm_perk_utility::place_perk_machine( ( 1721, 3395, -117 ), ( 0, 0, 0 ), PERK_WHOSWHO, WHOSWHO_MACHINE_DISABLED_MODEL );
	else if ( level.script == "zm_genesis" )
		zm_perk_utility::place_perk_machine( ( 50, -9144, -1479 ), ( 0, 230, 0 ), PERK_WHOSWHO, WHOSWHO_MACHINE_DISABLED_MODEL );
	
}

function enable_whoswho_perk_for_level()
{	
	level.whos_who_client_setup = 1;
	
	zm_perks::register_perk_basic_info( 			PERK_WHOSWHO, "whoswho", 						WHOSWHO_PERK_COST, 			"Hold ^3[{+activate}]^7 for Who's Who [Cost: &&1]", getWeapon( WHOSWHO_PERK_BOTTLE_WEAPON ) );
	zm_perks::register_perk_precache_func( 			PERK_WHOSWHO, &whoswho_precache );
	zm_perks::register_perk_clientfields( 			PERK_WHOSWHO, &whoswho_register_clientfield, 	&whoswho_set_clientfield );
	zm_perks::register_perk_machine( 				PERK_WHOSWHO, &whoswho_perk_machine_setup );
	zm_perks::register_perk_threads( 				PERK_WHOSWHO, &whoswho_perk_give , 				&whoswho_perk_take  );
	zm_perks::register_perk_host_migration_params( 	PERK_WHOSWHO, WHOSWHO_RADIANT_MACHINE_NAME, 	WHOSWHO_MACHINE_LIGHT_FX );
	
	level.whoswho_laststand_func = &chugabud_laststand;
}

function whoswho_precache()
{
	level._effect[ WHOSWHO_MACHINE_LIGHT_FX ]		= "zombie/fx_perk_sleight_of_hand_factory_zmb";
	
	level.machine_assets[ PERK_WHOSWHO ] 			= spawnStruct();
	level.machine_assets[ PERK_WHOSWHO ].weapon 	= getWeapon( WHOSWHO_PERK_BOTTLE_WEAPON );
	level.machine_assets[ PERK_WHOSWHO ].off_model 	= WHOSWHO_MACHINE_DISABLED_MODEL;
	level.machine_assets[ PERK_WHOSWHO ].on_model 	= WHOSWHO_MACHINE_ACTIVE_MODEL;
}

function whoswho_register_clientfield()
{
	clientfield::register( "toplayer", 	"perk_whoswho",					VERSION_SHIP, 2, "int" );
}

function whoswho_set_clientfield( state ) {}

function whoswho_perk_machine_setup( use_trigger, perk_machine, bump_trigger, collision )
{
	use_trigger.script_sound = "mus_perks_whoswho_jingle";
	use_trigger.script_string = "whoswho_perk";
	use_trigger.script_label = "mus_perks_whoswho_sting";
	use_trigger.target = "vending_whoswho";
	perk_machine.script_string = "whoswho_perk";
	perk_machine.targetname = "vending_whoswho";
	if ( isDefined( bump_trigger ) )
		bump_trigger.script_string = "whoswho_perk";
	
}

function whoswho_perk_take( b_pause, str_perk, str_result )
{
	self zm_perk_utility::harrybo21_perks_hud_remove( PERK_WHOSWHO );
	self notify( PERK_WHOSWHO + "_stop" );
	self notify( "perk_lost", str_perk );
}

function whoswho_perk_give( b_pause, str_perk, str_result )
{
	self zm_perk_utility::create_perk_hud( PERK_WHOSWHO );
	self.lives = 1;
	self notify( PERK_WHOSWHO + "_start" );	
}

//-----------------------------------------------------------------------------------
// FUNCTIONALITY
//-----------------------------------------------------------------------------------
function chugabud_laststand()
{
	self endon( "player_suicide" );
	self endon( "disconnect" );
	self endon( "chugabud_bleedout" );
	zm_laststand::increment_downed_stat();
	self.ignore_insta_kill = 1;
	self.health = self.maxhealth;
	self chugabud_save_loadout();
	self chugabud_fake_death();
	wait 3;
	if ( isDefined( self.insta_killed ) || self.insta_killed && isDefined( self.disable_chugabud_corpse ) )
		create_corpse = 0;
	else
		create_corpse = 1;
	
	if ( create_corpse == 1 )
	{
		if ( isDefined( level._chugabug_reject_corpse_override_func ) )
		{
			reject_corpse = self [[ level._chugabug_reject_corpse_override_func ]]( self.origin );
			if ( reject_corpse )
				create_corpse = 0;
			
		}
	}
	if ( create_corpse == 1 )
	{
		self.model = self getCharacterBodyModel();
		self.headModel = self getCharacterHeadModel();
		self thread activate_chugabud_effects_and_audio();
		corpse = self chugabud_spawn_corpse();
		corpse thread chugabud_corpse_revive_icon( self );
		self.e_chugabud_corpse = corpse;
		corpse thread chugabud_corpse_cleanup_on_spectator( self );
	}
	
	self chugabud_fake_revive();
	wait .1;
	self.ignore_insta_kill = undefined;
	self.disable_chugabud_corpse = undefined;
	if ( create_corpse == 0 )
	{
		self notify( "chugabud_effects_cleanup" );
		return;
	}
	bleedout_time = getDvarFloat( "player_lastStandBleedoutTime" );
	self thread chugabud_bleed_timeout( bleedout_time, corpse );
	self thread chugabud_handle_multiple_instances( corpse );
	
	corpse waittill( "player_revived", e_reviver );	
	
	if ( isDefined( e_reviver ) && e_reviver == self )
		self notify( "whos_who_self_revive" );
	
	self zm_perks::perk_abort_drinking( .1 );
	self zm_perks::perk_set_max_health_if_jugg( "health_reboot", 1, 0 );
	self setorigin( corpse.origin );
	self setplayerangles( corpse.angles );
	if ( self laststand::player_is_in_laststand() )
	{
		self thread chugabud_laststand_cleanup( corpse, "player_revived" );
		self zm_laststand::auto_revive( self, 1 );
		return;
	}
	self chugabud_laststand_cleanup( corpse, undefined );
}

function chugabud_corpse_revive_icon( player )
{
	self endon( "death" );
	height_offset = 30;
	index = player.clientid;
	hud_elem = newhudelem();
	self.revive_hud_elem = hud_elem;
	hud_elem.x = self.origin[ 0 ];
	hud_elem.y = self.origin[ 1 ];
	hud_elem.z = self.origin[ 2 ] + height_offset;
	hud_elem.alpha = 1;
	hud_elem.archived = 1;
	hud_elem setshader( "waypoint_revive", 5, 5 );
	hud_elem setwaypoint( 1 );
	hud_elem.hidewheninmenu = 1;
	hud_elem.immunetodemogamehudsettings = 1;
	while ( 1 )
	{
		if ( !isDefined( self.revive_hud_elem ) )
			return;
		else
		{
			hud_elem.x = self.origin[ 0 ];
			hud_elem.y = self.origin[ 1 ];
			hud_elem.z = self.origin[ 2 ] + height_offset;
			wait .01;
		}
	}
}

function activate_chugabud_effects_and_audio()
{
	if ( isDefined( level.whos_who_client_setup ) )
	{
		if ( !isDefined( self.whos_who_effects_active ) )
		{
			if ( isDefined( level.chugabud_shellshock ) )
				self shellshock( "whoswho", 60 );

			self clientfield::set_to_player( "perk_whoswho", 1 );
			self.whos_who_effects_active = 1;
			self thread deactivate_chugabud_effects_and_audio();
		}
	}
}

function deactivate_chugabud_effects_and_audio()
{
	self util::waittill_any( "death", "chugabud_effects_cleanup" );
	if ( isDefined( level.whos_who_client_setup ) )
	{
		if ( isDefined( self.whos_who_effects_active ) && self.whos_who_effects_active == 1 )
		{
			if ( isDefined( level.chugabud_shellshock ) )
				self stopshellshock();

			self clientfield::set_to_player( "perk_whoswho", 0 );
		}
		self.whos_who_effects_active = undefined;
	}
}

function chugabud_corpse_cleanup_on_spectator( player )
{
	self endon( "death" );
	player endon( "disconnect" );
	while ( 1 )
	{
		if ( player.sessionstate == "spectator" )
			break;
		else
			wait .01;
		
	}
	player chugabud_corpse_cleanup( self, 0 );
}

function chugabud_fake_death()
{
	level notify( "fake_death" );
	self notify( "fake_death" );
	self takeAllWeapons();
	self allowStand( 0 );
	self allowCrouch( 0 );
	self allowProne( 1 );
	self.ignoreme = 1;
	self enableInvulnerability();
	wait .1;
	self freezeControls( 1 );
	wait .9;
}

function chugabud_fake_revive()
{
	level notify( "fake_revive" );
	self notify( "fake_revive" );
	// playsoundatposition( "evt_ww_disappear", self.origin );
	// playfx( level._effect[ "chugabud_revive_fx" ], self.origin );
	spawnpoint = chugabud_get_spawnpoint();

	self setorigin( spawnpoint.origin );
	self setplayerangles( spawnpoint.angles );
	// playsoundatposition( "evt_ww_appear", spawnpoint.origin );
	// playfx( level._effect[ "chugabud_revive_fx" ], spawnpoint.origin );
	self allowStand( 1 );
	self allowCrouch( 1 );
	self allowProne( 1 );
	self.ignoreme = 0;
	self setStance( "stand" );
	self freezeControls( 0 );
	self giveWeapon( getWeapon( "knife" ) );
	self zm_utility::give_start_weapon( 1 );
	self.score = self.loadout.score;
	self.pers[ "score" ] = self.loadout.score;
	self giveWeapon( getWeapon( "frag_grenade" ) );
	self setWeaponAmmoClip( getWeapon( "frag_grenade" ), 2 );
	wait 1;
	self disableInvulnerability();
}

function chugabud_bleed_timeout( delay, corpse )
{
	self endon( "player_suicide" );
	self endon( "disconnect" );
	corpse endon( "death" );
	wait delay;
	if ( isDefined( corpse.revivetrigger ) )
	{
		while ( corpse.revivetrigger.beingrevived )
			wait .01;
		
	}
	if ( isDefined( self.loadout.perks ) && flag::exists( "solo_game" ) && flag::exists( "solo_revive" ) && level flag::get( "solo_game" ) && level flag::get( "solo_revive" ) )
	{
		i = 0;
		while ( i < self.loadout.perks.size )
		{
			perk = self.loadout.perks[ i ];
			if ( perk == "specialty_quickrevive" )
			{
				arrayremovevalue( self.loadout.perks, self.loadout.perks[ i ] );
				corpse notify( "player_revived" );
				return;
			}
			i++;
		}
	}
	self chugabud_corpse_cleanup( corpse, 0 );
}

function chugabud_handle_multiple_instances( corpse )
{
	corpse endon( "death" );
	self waittill( "perk_chugabud_activated" );
	self chugabud_corpse_cleanup( corpse, 0 );
}

function chugabud_laststand_cleanup( corpse, str_notify )
{
	if ( isDefined( str_notify ) )
	{
		self waittill( str_notify );
	}
	self chugabud_give_loadout();
	self chugabud_corpse_cleanup( corpse, 1 );
}

function chugabud_corpse_cleanup( corpse, was_revived )
{
	self notify( "chugabud_effects_cleanup" );
	if ( was_revived )
	{
		// playsoundatposition( "evt_ww_appear", corpse.origin );
		// playfx( level._effect[ "chugabud_revive_fx" ], corpse.origin );
	}
	else
	{
		// playsoundatposition( "evt_ww_disappear", corpse.origin );
		// playfx( level._effect[ "chugabud_bleedout_fx" ], corpse.origin );
		self notify( "chugabud_bleedout" );
	}
	if ( isDefined( corpse.revivetrigger ) )
	{
		corpse notify( "stop_revive_trigger" );
		corpse.revivetrigger delete();
		corpse.revivetrigger = undefined;
	}
	if ( isDefined( corpse.revive_hud_elem ) )
	{
		corpse.revive_hud_elem destroy();
		corpse.revive_hud_elem = undefined;
	}
	wait .1;
	corpse delete();
	self.e_chugabud_corpse = undefined;
}

function chugabud_save_loadout()
{
	primaries = self getWeaponsListPrimaries();
	
	currentweapon = self getCurrentWeapon();
	self.loadout = spawnStruct();
	self.loadout.player = self;
	self.loadout.weapons = [];
	self.loadout.score = self.score;
	self.loadout.current_weapon = -1;
	_a366 = primaries;
	index = getFirstArrayKey( _a366 );
	while ( isDefined( index ) )
	{
		weapon = _a366[ index ];
		
		self.loadout.weapons[ index ] = zm_weapons::get_player_weapondata( self, weapon );
		
		if ( weapon.name == currentWeapon )
			self.loadout.current_weapon = index;
	 	
		index = getNextArrayKey( _a366, index );
	}
	self.loadout.equipment = self zm_equipment::get_player_equipment();
	if ( isDefined( self.loadout.equipment ) )
		self zm_equipment::take( self.loadout.equipment );
	
	self.loadout save_weapons_for_chugabud( self );
	if ( self hasWeapon( getWeapon( "claymore_zm" ) ) )
	{
		self.loadout.hasclaymore = 1;
		self.loadout.claymoreclip = self getWeaponAmmoClip( getWeapon( "claymore_zm" ) );
	}
	self.loadout.perks = chugabud_save_perks( self );
	self chugabud_save_grenades();
}

function chugabud_spawn_corpse()
{
	corpse = zm_clone::spawn_player_clone( self, self.origin, getWeapon( "pistol_standard" ), self getCharacterBodyModel() );
	corpse.angles = self.angles;
	corpse.revive_hud = self chugabud_revive_hud_create();
	corpse thread harrybo21_perks_whos_who_corpse_revive_icon( self, corpse );
	corpse useAnimTree( #animtree );
	corpse AnimScripted( "pb_laststand_idle", self.origin , self.angles, %pb_laststand_idle );
	corpse thread zm_laststand::revive_trigger_spawn();
	return corpse;
}

function chugabud_revive_hud_create()
{
	self.revive_hud = newclienthudelem( self );
	self.revive_hud.alignx = "center";
	self.revive_hud.aligny = "middle";
	self.revive_hud.horzalign = "center";
	self.revive_hud.vertalign = "bottom";
	self.revive_hud.y = -50;
	self.revive_hud.foreground = 1;
	self.revive_hud.font = "default";
	self.revive_hud.fontscale = 1.5;
	self.revive_hud.alpha = 0;
	self.revive_hud.color = ( 1, 1, 1 );
	self.revive_hud settext( "" );
	return self.revive_hud;
}

function save_weapons_for_chugabud( player )
{
	self.chugabud_melee_weapons = [];
	i = 0;
	while ( i < level._melee_weapons.size )
	{
		self save_weapon_for_chugabud( player, level._melee_weapons[ i ].weapon_name );
		i++;
	}
}

function save_weapon_for_chugabud( player, weapon_name )
{
	if ( player hasweapon( weapon_name ) )
		self.chugabud_melee_weapons[ weapon_name ] = 1;
	
}

function restore_weapons_for_chugabud( player )
{
	i = 0;
	while ( i < level._melee_weapons.size )
	{
		self restore_weapon_for_chugabud( player, level._melee_weapons[ i ].weapon_name );
		i++;
	}
	self.chugabud_melee_weapons = undefined;
}

function restore_weapon_for_chugabud( player, weapon_name )
{
	if ( isDefined( weapon_name ) || !isDefined( self.chugabud_melee_weapons ) && !isDefined( self.chugabud_melee_weapons[ weapon_name ] ) )
	{
		return;
	}
	if ( isDefined( self.chugabud_melee_weapons[ weapon_name ] ) && self.chugabud_melee_weapons[ weapon_name ] )
	{
		player giveweapon( weapon_name );
		player zm_utility::set_player_melee_weapon( weapon_name );
		self.chugabud_melee_weapons[ weapon_name ] = 0;
	}
}

function chugabud_save_perks( ent )
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

function chugabud_save_grenades()
{
	lethal_grenade = self zm_utility::get_player_lethal_grenade();
	if ( self hasweapon( lethal_grenade ) )
	{
		self.loadout.lethal_grenade = lethal_grenade;
		self.loadout.lethal_grenade_count = self getweaponammoclip( lethal_grenade );
	}
	else
	{
		self.loadout.lethal_grenade = undefined;
	}
	tactical_grenade = self zm_utility::get_player_tactical_grenade();
	if ( self hasweapon( tactical_grenade ) )
	{
		self.loadout.tactical_grenade = tactical_grenade;
		self.loadout.tactical_grenade_count = self getweaponammoclip( tactical_grenade );
	}
	else
	{
		self.loadout.tactical_grenade = undefined;
	}
	tomahawk = self.current_tomahawk_weapon;
	if ( isDefined( tomahawk ) )
		self.loadout.tomahawk = tomahawk;
}

function chugabud_restore_grenades()
{
	if ( isDefined( self.loadout.lethal_grenade ) )
	{
		self zm_utility::set_player_lethal_grenade( self.loadout.lethal_grenade );
		self giveweapon( self.loadout.lethal_grenade );
		self setweaponammoclip( self.loadout.lethal_grenade, self.loadout.lethal_grenade_count );
	}
	if ( isDefined( self.loadout.tactical_grenade ) && self.loadout.tactical_grenade )
	{
		self zm_utility::set_player_tactical_grenade( self.loadout.tactical_grenade );
		self giveweapon( self.loadout.tactical_grenade );
		self setweaponammoclip( self.loadout.tactical_grenade, self.loadout.tactical_grenade_count );
	}
	if ( isDefined( self.loadout.tomahawk ) )
		self.current_tomahawk_weapon = self.loadout.tomahawk;
}

function chugabud_give_loadout()
{
	self takeallweapons();
	loadout = self.loadout;
	primaries = self getweaponslistprimaries();
	if ( loadout.weapons.size > 1 || primaries.size > 1 )
	{
		_a449 = primaries;
		_k449 = getFirstArrayKey( _a449 );
		while ( isDefined( _k449 ) )
		{
			weapon = _a449[ _k449 ];
			self takeweapon( weapon );
			_k449 = getNextArrayKey( _a449, _k449 );
		}
	}
	i = 0;
	while ( i < loadout.weapons.size )
	{
		if ( !isDefined( loadout.weapons[ i ] ) )
		{
			i++;
			continue;
		}
		else if ( loadout.weapons[ i ] == "none" )
		{
			i++;
			continue;
		}
		else
		{
			weapon = getWeapon( loadout.weapons[ i ] );
			stock_amount = loadout.stockcount[ i ];
			clip_amount = loadout.clipcount[ i ];
			
			if ( !self hasweapon( weapon ) )
			{
				self zm_weapons::weapondata_give( loadout.weapons[ i ] );

				if ( i == loadout.current_weapon )
				{
					self switchtoweapon( weapon );
				}
			}
		}
		i++;
	}
	self giveweapon( getWeapon( "knife" ) );
	self zm_equipment::give( self.loadout.equipment );
	loadout restore_weapons_for_chugabud( self );
	self.score = loadout.score;
	self.pers[ "score" ] = loadout.score;
	
	perk_array = zm_perks::get_perk_array();
	
	i = 0;
	while ( i < perk_array.size )
	{
		perk = perk_array[ i ];
		self unsetperk( perk );
		self.num_perks--;

		self zm_perks::set_perk_clientfield( perk, 0 );
		i++;
	}
	wait .05;
	if ( isDefined( loadout.perks ) && loadout.perks.size > 0 )
	{
		i = 0;
		while ( i < loadout.perks.size )
		{
			if ( self hasperk( loadout.perks[ i ] ) )
			{
				i++;
				continue;
			}
			else if ( loadout.perks[ i ] == "specialty_quickrevive" && flag::exists( "solo_game" ) && flag::exists( "solo_revive" ) && level flag::get( "solo_game" ) && level flag::get( "solo_revive" ) )
			{
				level.solo_game_free_player_quickrevive = 1;
			}
			if ( loadout.perks[ i ] == "specialty_whoswho" )
			{
				i++;
				continue;
			}
			else
			{
				zm_perks::give_perk( loadout.perks[ i ] );
			}
			i++;
		}
	}
	self chugabud_restore_grenades();
}

function chugabud_get_spawnpoint()
{
	spawnpoint = undefined;
	/*
	if ( get_chugabug_spawn_point_from_nodes( self.origin, 500, 700, 64, 1 ) )
	{
		spawnpoint = level.chugabud_spawn_struct;
	}
	if ( !isDefined( spawnpoint ) )
	{
		if ( get_chugabug_spawn_point_from_nodes( self.origin, 100, 400, 64, 1 ) )
		{
			spawnpoint = level.chugabud_spawn_struct;
		}
	}
	if ( !isDefined( spawnpoint ) )
	{
		if ( get_chugabug_spawn_point_from_nodes( self.origin, 50, 400, 256, 0 ) )
		{
			spawnpoint = level.chugabud_spawn_struct;
		}
	}
	*/
	if ( !isDefined( spawnpoint ) )
	{
		spawnpoint = zm::check_for_valid_spawn_near_team( self, 1 );
	}
	if ( !isDefined( spawnpoint ) )
	{
		spawnpoints = [];
		/*
		match_string = "";
		location = level.scr_zm_map_start_location;
		if ( location != "default" && location == "" && isDefined( level.default_start_location ) )
		{
			location = level.default_start_location;
		}
		match_string = ( level.scr_zm_ui_gametype + "_" ) + location;
		spawnpoints = [];
		structs = struct::get_array( "initial_spawn", "script_noteworthy" );
		while ( isDefined( structs ) )
		{
			_a744 = structs;
			_k744 = getFirstArrayKey( _a744 );
			while ( isDefined( _k744 ) )
			{
				struct = _a744[ _k744 ];
				while ( isDefined( struct.script_string ) )
				{
					tokens = strtok( struct.script_string, " " );
					_a750 = tokens;
					_k750 = getFirstArrayKey( _a750 );
					while ( isDefined( _k750 ) )
					{
						token = _a750[ _k750 ];
						if ( token == match_string )
						{
							spawnpoints[ spawnpoints.size ] = struct;
						}
						_k750 = getNextArrayKey( _a750, _k750 );
					}
				}
				_k744 = getNextArrayKey( _a744, _k744 );
			}
		}
		*/
		if ( !isDefined( spawnpoints ) || spawnpoints.size == 0 )
		{
			spawnpoints = struct::get_array( "initial_spawn_points", "targetname" );
			
			secondary_points = struct::get_array( "player_respawn_point", "target" );
			if ( isDefined( secondary_points ) )
				spawnpoints = arrayCombine( spawnpoints, secondary_points, 1, 0 );
			
		}
		spawnpoint = zm::getfreespawnpoint( spawnpoints, self );
	}
	return spawnpoint;
}

function harrybo21_perks_whos_who_revive_colour_change_thread( player, corpse )
{
	player endon( "death" );
	self endon( "delete" );
	player endon( "chugabud_bleedout" );
	self endon( "colour_change_complete" );
	bleed_out_time = GetDvarFloat( "player_lastStandBleedoutTime" );
	remaining_bleed_out_time = GetDvarFloat( "player_lastStandBleedoutTime" );
	
	while( 1 )
	{
		fraction = remaining_bleed_out_time / bleed_out_time;
	
		self.color = ( 1, fraction, 0 );
		if ( isDefined( corpse.revivetrigger.beingrevived ) && corpse.revivetrigger.beingrevived )
			self.color = ( 1, 1, 1 );
			
		remaining_bleed_out_time -= .1;
		wait .1;
	}
	self notify( "colour_change_complete" );
}

function harrybo21_perks_whos_who_corpse_revive_icon( player, corpse )
{
	self endon( "death" );
	height_offset = 30;
	hud_elem = newHudElem();
	hud_elem.x = self.origin[ 0 ];
	hud_elem.y = self.origin[ 1 ];
	hud_elem.z = self.origin[ 2 ] + height_offset;
	hud_elem.color = ( 1, 1, 0 );
	hud_elem setWaypoint( false, "mtl_waypoint_revive" );
	hud_elem.hidewheninmenu = 1;
	hud_elem.immunetodemogamehudsettings = 1;
	hud_elem thread harrybo21_perks_whos_who_revive_colour_change_thread( player, corpse );
	corpse.revive_hud_elem = hud_elem;
	corpse waittill( "player_revived" );
	hud_elem destroy();
}