#using scripts\codescripts\struct;

#using scripts\shared\array_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\exploder_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\shared\visionset_mgr_shared;
#using scripts\shared\callbacks_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_utility.gsh;

#using scripts\zm\_util;
#using scripts\zm\_zm;
#using scripts\zm\_zm_laststand;
#using scripts\zm\_zm_perks;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_pers_upgrades;
#using scripts\zm\_zm_pers_upgrades_functions;
#using scripts\zm\_zm_pers_upgrades_system;
#using scripts\zm\_zm_stats;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_zonemgr;
#using scripts\zm\_zm_powerup_double_points;
#using scripts\zm\_zm_powerup_fire_sale;

#using scripts\zm\_zm_perk_utility;

#insert scripts\zm\_zm_perk_vulture_aid.gsh;
#insert scripts\zm\_zm_perks.gsh;

#using scripts\shared\ai\zombie_utility;

#precache( "fx", VULTUREAID_REVIVE_WAYPOINT );
#precache( "fx", VULTUREAID_JUGG_WAYPOINT );
#precache( "fx", VULTUREAID_DOUBLETAP2_WAYPOINT );
#precache( "fx", VULTUREAID_SPEED_WAYPOINT );
#precache( "fx", VULTUREAID_DEADSHOT_WAYPOINT );
#precache( "fx", VULTUREAID_FLOPPER_WAYPOINT );
#precache( "fx", VULTUREAID_STAMIN_WAYPOINT );
#precache( "fx", VULTUREAID_MULE_WAYPOINT );
#precache( "fx", VULTUREAID_TOMB_WAYPOINT );
#precache( "fx", VULTUREAID_WHOSWHO_WAYPOINT );
#precache( "fx", VULTUREAID_CHERRY_WAYPOINT );
#precache( "fx", VULTUREAID_VULTURE_WAYPOINT );
#precache( "fx", VULTUREAID_WIDOWS_WAYPOINT );
#precache( "fx", VULTUREAID_WUNDERFIZZ_WAYPOINT );
#precache( "fx", VULTUREAID_MAGIC_BOX_WAYPOINT );
#precache( "fx", VULTUREAID_PAP_WAYPOINT );
#precache( "fx", VULTUREAID_RIFLE_WAYPOINT );
#precache( "fx", VULTUREAID_SKULL_WAYPOINT );
#precache( "fx", VULTUREAID_GREEN_POWERUP_GLOW );
#precache( "fx", VULTUREAID_BLUE_POWERUP_GLOW );
#precache( "fx", VULTUREAID_DROPS_GLOW_FX );
#precache( "fx", VULTUREAID_GREEN_MIST_FX );
#precache( "fx", "zombie/fx_perk_juggernaut_factory_zmb" );
#precache( "fx", "zombie/fx_perk_juggernaut_zmb" );

#precache( "material", VULTUREAID_SHADER_GLOW );
#precache( "material", VULTUREAID_ANIMATED_STINK );

#precache( "model", VULTUREAID_AMMO_MODEL );
#precache( "model", VULTUREAID_POINTS_MODEL );
#precache( "model", VULTUREAID_MACHINE_DISABLED_MODEL );
#precache( "model", VULTUREAID_MACHINE_ACTIVE_MODEL );

#namespace zm_perk_vulture_aid;

REGISTER_SYSTEM( "zm_perk_vulture_aid", &__init__, undefined )

//-----------------------------------------------------------------------------------
// SETUP
//-----------------------------------------------------------------------------------
function __init__()
{	
	enable_vulture_aid_perk_for_level();
	
	if ( level.script == "zm_zod" )
		zm_perk_utility::place_perk_machine( ( 1992, -3417, -400 ), ( 0, 180, 0 ), PERK_VULTUREAID, VULTUREAID_MACHINE_DISABLED_MODEL );
	if ( level.script == "zm_factory" )
		zm_perk_utility::place_perk_machine( ( -704, -1048, 200 ), ( 0, 0, 0 ), PERK_VULTUREAID, VULTUREAID_MACHINE_DISABLED_MODEL );
	if ( level.script == "zm_castle" )
		zm_perk_utility::place_perk_machine( ( 833, 3772, 672 ), ( 0, 270, 0 ), PERK_VULTUREAID, VULTUREAID_MACHINE_DISABLED_MODEL );
	if ( level.script == "zm_island" )
		zm_perk_utility::place_perk_machine( ( 2091, 1070, -703 ), ( 0, 40, 0 ), PERK_VULTUREAID, VULTUREAID_MACHINE_DISABLED_MODEL );
	if ( level.script == "zm_stalingrad" )
		zm_perk_utility::place_perk_machine( ( 164, 1911, 336 ), ( 0, -34, 0 ), PERK_VULTUREAID, VULTUREAID_MACHINE_DISABLED_MODEL );
	if ( level.script == "zm_genesis" )
		zm_perk_utility::place_perk_machine( ( 1457, 4168, 1478 ), ( 0, 90, 0 ), PERK_VULTUREAID, VULTUREAID_MACHINE_DISABLED_MODEL );
		
}

function enable_vulture_aid_perk_for_level()
{		
	zm_perks::register_perk_basic_info( 			PERK_VULTUREAID, "vultureaid", 							VULTUREAID_PERK_COST, 			"Hold ^3[{+activate}]^7 for Vulture Aid [Cost: &&1]", GetWeapon( VULTUREAID_PERK_BOTTLE_WEAPON ) );
	zm_perks::register_perk_precache_func( 			PERK_VULTUREAID, &vulture_aid_precache );
	zm_perks::register_perk_clientfields( 			PERK_VULTUREAID, &vulture_aid_register_clientfield, 	&vulture_aid_set_clientfield );
	zm_perks::register_perk_machine( 				PERK_VULTUREAID, &vulture_aid_perk_machine_setup );
	zm_perks::register_perk_threads( 				PERK_VULTUREAID, &give_vulture_aid_perk, 				&take_vulture_aid_perk );
	zm_perks::register_perk_host_migration_params( 	PERK_VULTUREAID, VULTUREAID_RADIANT_MACHINE_NAME, 		VULTUREAID_MACHINE_LIGHT_FX );
	
	level.vulture_ids = [];
	level.vulture_ids[ "perk" ] = [];
	level.vulture_ids[ "wallbuy" ] = [];
	level.vulture_ids[ "box" ] = [];
	level.vulture_ids[ "bgb" ] = [];
	level.vulture_ids[ "pap" ] = [];
	level.vulture_ids[ "fizz" ] = [];
	
	level.no_target_override = &no_target_override;
	
	level thread vulture_watch_for_spawn();
	level thread vulture_watch_for_powerup();
	
	util::registerClientSys( "vulture_aid_notify" );
	
	callback::on_connect( &vulture_aid_player_connect );
	
	level thread vulture_initial_setup();
}

function vulture_aid_precache()
{
	if ( zm_perk_utility::is_stock_map() && level.script != "zm_factory" )
		level._effect[ VULTUREAID_MACHINE_LIGHT_FX ] = "zombie/fx_perk_juggernaut_zmb";
	else
		level._effect[ VULTUREAID_MACHINE_LIGHT_FX ] = "zombie/fx_perk_juggernaut_factory_zmb";
	
	level.machine_assets[ PERK_VULTUREAID ] 			= spawnStruct();
	level.machine_assets[ PERK_VULTUREAID ].weapon 		= getWeapon( VULTUREAID_PERK_BOTTLE_WEAPON );
	level.machine_assets[ PERK_VULTUREAID ].off_model 	= VULTUREAID_MACHINE_DISABLED_MODEL;
	level.machine_assets[ PERK_VULTUREAID ].on_model 	= VULTUREAID_MACHINE_ACTIVE_MODEL;	
}

function vulture_aid_register_clientfield() {}

function vulture_aid_set_clientfield( state ) {}

function vulture_aid_perk_machine_setup( use_trigger, perk_machine, bump_trigger, collision )
{
	use_trigger.script_sound 			= "mus_perks_vulture_jingle";
	use_trigger.script_string 			= "vulture_perk";
	use_trigger.script_label 			= "mus_perks_vulture_sting";
	use_trigger.target 					= VULTUREAID_RADIANT_MACHINE_NAME;
	perk_machine.script_string 			= "vulture_perk";
	perk_machine.targetname 			= VULTUREAID_RADIANT_MACHINE_NAME;
	if ( isDefined( bump_trigger ) )
		bump_trigger.script_string 		= "vulture_perk";
	
}

//-----------------------------------------------------------------------------------
// FUNCTIONALITY
//-----------------------------------------------------------------------------------
function vulture_initial_setup()
{
	wait .05;
	level flag::wait_till( "initial_blackscreen_passed" );
	
	update_vulture_clients();
	while( 1 )
	{		
		reason = level util::waittill_any_return( "update_vulture", "weapon_fly_away_start", "powerup fire sale" );
		
		if ( reason == "weapon_fly_away_start" )
			level thread box_watch();
		
		if ( reason == "powerup fire sale" )
			level thread firesale_watch();
		
		update_vulture_clients();
	}
}

function give_vulture_aid_perk()
{
	self zm_perk_utility::create_perk_hud( PERK_VULTUREAID );
	self.vulture_level = 0;
	
	self thread vulture_mist_watcher();
	thread update_vulture_clients();
}

function take_vulture_aid_perk( b_pause, str_perk, str_result )
{
	self zm_perk_utility::harrybo21_perks_hud_remove( PERK_VULTUREAID );
	self.vulture_level = 0;
	self setBlur( 0, 1 );
	
	self notify( "vulture_over" );
	self notify( "perk_lost", str_perk );
	update_vulture_clients();
}

function vulture_aid_notify_handler( notify_string )
{
	util::setClientSysState( "vulture_aid_notify", notify_string, self );
}

function vulture_aid_player_connect()
{
	self thread vulture_aid_player_spawned();
}

function vulture_aid_player_spawned()
{
	while( 1 )
	{
		self waittill( "spawned_player" );
		update_vulture_clients();
	}
}

function firesale_watch()
{
	while ( isDefined( level.zombie_vars[ "zombie_powerup_fire_sale_on" ] ) && level.zombie_vars[ "zombie_powerup_fire_sale_on" ] )
		wait .05;
	
	update_vulture_clients();
}

function box_watch()
{
	level flag::wait_till_clear( "moving_chest_now" );
	update_vulture_clients();
}

function create_vulture_element( array_reference, id, origin, script_noteworthy )
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
	
	players = getPlayers();
	for ( i = 0; i < players.size; i++ )
		util::setClientSysState( "vulture_aid_notify", "create_vulture_waypoint," + array_reference + "," + struct.id + "," + struct.origin + "," + struct.script_noteworthy, players[ i ] );
	
	if ( !isDefined( level.vulture_ids[ array_reference ][ id ] ) )
		level.vulture_ids[ array_reference ][ id ] = struct;
	
}

function stop_vulture_element( array_reference, id, origin, script_noteworthy )
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
	
	players = getPlayers();
	for ( i = 0; i < players.size; i++ )
		util::setClientSysState( "vulture_aid_notify", "stop_vulture_waypoint," + array_reference + "," + struct.id + "," + struct.origin + "," + struct.script_noteworthy, players[ i ] );
	
	if ( !isDefined( level.vulture_ids[ array_reference ][ id ] ) )
		level.vulture_ids[ array_reference ][ id ] = struct;
	
}

function update_vulture_clients()
{
	wait .5;
	perk_machines = getEntArray( "zombie_vending", "targetname" );
	if ( isDefined( perk_machines ) && perk_machines.size > 0 )
	{
		for ( i = 0; i < perk_machines.size; i++ )
		{
			origin = "" + int( perk_machines[ i ].origin[ 0 ] ) + "," + int( perk_machines[ i ].origin[ 1 ] ) + "," + int( perk_machines[ i ].origin[ 2 ] );
			
			if ( !isDefined( perk_machines[ i ].client_id ) )
				perk_machines[ i ].client_id = level.vulture_ids[ "perk" ].size;
		
			perk_machines[ i ] create_vulture_element( "perk", perk_machines[ i ].client_id, origin, perk_machines[ i ].script_noteworthy );
		}
	}
	
	weapon_spawns = struct::get_array( "weapon_upgrade", "targetname" );
	if ( isDefined( weapon_spawns ) && weapon_spawns.size > 0 )
	{
		for ( i = 0; i < weapon_spawns.size; i++ )
		{
			origin = "" + int( weapon_spawns[ i ].origin[ 0 ] ) + "," + int( weapon_spawns[ i ].origin[ 1 ] ) + "," + int( weapon_spawns[ i ].origin[ 2 ] );
			
			if ( !isDefined( weapon_spawns[ i ].client_id ) )
				weapon_spawns[ i ].client_id = level.vulture_ids[ "wallbuy" ].size;
		
			weapon_spawns[ i ] create_vulture_element( "wallbuy", weapon_spawns[ i ].client_id, origin, "rifle" );
		}
	}
	
	box_spawns = level.chests;
	if ( isDefined( box_spawns ) && box_spawns.size > 0 )
	{
		for ( i = 0; i < box_spawns.size; i++ )
		{
			origin = "" + int( box_spawns[ i ].origin[ 0 ] ) + "," + int( box_spawns[ i ].origin[ 1 ] ) + "," + int( box_spawns[ i ].origin[ 2 ] );
			
			if ( !isDefined( box_spawns[ i ].client_id ) )
				box_spawns[ i ].client_id = level.vulture_ids[ "box" ].size;
			
			if ( isDefined( level.zombie_vars[ "zombie_powerup_fire_sale_on" ] ) && level.zombie_vars[ "zombie_powerup_fire_sale_on" ] )
				box_spawns[ i ] create_vulture_element( "box", box_spawns[ i ].client_id, origin, "magic_box" );
			else if ( isDefined( level flag::get( "moving_chest_now" ) ) && level flag::get( "moving_chest_now" ) )
				box_spawns[ i ] stop_vulture_element( "box", box_spawns[ i ].client_id, origin, "magic_box" );
			else if ( level.chest_index == i )
				box_spawns[ i ] create_vulture_element( "box", box_spawns[ i ].client_id, origin, "magic_box" );
			else
				box_spawns[ i ] stop_vulture_element( "box", box_spawns[ i ].client_id, origin, "magic_box" );
			
		}
	}
	
	bgb_machines = getEntArray( "bgb_machine_use", "targetname" );
	if ( isDefined( bgb_machines ) && bgb_machines.size > 0 )
	{
		for ( i = 0; i < bgb_machines.size; i++ )
		{
			origin = "" + int( bgb_machines[ i ].origin[ 0 ] ) + "," + int( bgb_machines[ i ].origin[ 1 ] ) + "," + ( int( bgb_machines[ i ].origin[ 2 ] ) + 64 );
			
			if ( !isDefined( bgb_machines[ i ].client_id ) )
				bgb_machines[ i ].client_id = level.vulture_ids[ "bgb" ].size;
		
			bgb_machines[ i ] create_vulture_element( "bgb", bgb_machines[ i ].client_id, origin, "gobblegum" );
		}
	}
	
	pap_machines = getEntArray( "pack_a_punch", "script_noteworthy" );
	if ( isDefined( pap_machines ) && pap_machines.size > 0 )
	{
		for ( i = 0; i < pap_machines.size; i++ )
		{
			origin = "" + int( pap_machines[ i ].origin[ 0 ] ) + "," + int( pap_machines[ i ].origin[ 1 ] ) + "," + int( pap_machines[ i ].origin[ 2 ] );
			
			if ( !isDefined( pap_machines[ i ].client_id ) )
				pap_machines[ i ].client_id = level.vulture_ids[ "pap" ].size;
		
			pap_machines[ i ] create_vulture_element( "pap", pap_machines[ i ].client_id, origin, "pap" );
		}
	}
}

function vulture_watch_for_powerup()
{
	while( 1 )
	{
		level waittill( "powerup_dropped", powerup );
		
		vulture_powerup_glow = spawn( "script_model", powerup.origin, 1, 1, 1 );
		vulture_powerup_glow.linked = 1;
		vulture_powerup_glow.angles = powerup.angles;
		vulture_powerup_glow setModel( "tag_origin" );
		vulture_powerup_glow enableLinkTo();
		vulture_powerup_glow linkTo( powerup, "tag_origin" );
		
		if ( powerup.powerup_name == "minigun"  || powerup.powerup_name == "ww_grenade" )
			playFxOnTag( VULTUREAID_BLUE_POWERUP_GLOW, vulture_powerup_glow, "tag_origin" );
		else
			playFxOnTag( VULTUREAID_GREEN_POWERUP_GLOW, vulture_powerup_glow, "tag_origin" );
		
		vulture_powerup_glow thread vulture_powerup_glow_watcher( powerup );
	}
}

function vulture_powerup_glow_watcher( powerup )
{
	self endon( "delete" );
	while( 1 )
	{		
		if ( !isDefined( powerup ) )
			break;
		
		players = getPlayers();
		for ( i = 0; i < players.size; i++ )
		{
			if( players[ i ] hasPerk( PERK_VULTUREAID ) )
				self setVisibleToPlayer( players[ i ] );
			else
				self setInvisibleToPlayer( players[ i ] );
			
		}
		wait .05;
	}
	if ( isDefined( self ) )
		self delete();
	
}

function vulture_watch_for_spawn()
{
	while( 1 )
	{		
		zombies = getAiSpeciesArray( "axis", "all" );
		if ( isDefined( zombies ) && zombies.size > 0 )
		{
			for( i = 0; i < zombies.size; i++ )
			{
				if( !isDefined( zombies[ i ].spawn_functions_ran ) || !zombies[ i ].spawn_functions_ran )
				{
					zombies[ i ].spawn_functions_ran = 1;
					zombies[ i ] vulture_zombie_function();
				}
			}
		}
		wait .05;
	}
}

function vulture_zombie_function()
{		
	if ( randomInt( 100 ) > VULTUREAID_DROP_CHANCE )
		return;
	
	vulture_mists = vulture_get_mists();
	if ( !isDefined( vulture_mists ) || vulture_mists.size < VULTUREAID_MAX_STINK_ZOMBIES )
		n_total_weight = VULTUREAID_AMMO_CHANCE + VULTUREAID_POINTS_CHANCE + VULTUREAID_STINK_CHANCE;
	else
		n_total_weight = VULTUREAID_AMMO_CHANCE + VULTUREAID_POINTS_CHANCE;
	
	n_cutoff_ammo = VULTUREAID_AMMO_CHANCE;
	n_cutoff_points = VULTUREAID_AMMO_CHANCE + VULTUREAID_POINTS_CHANCE;
	n_roll = randomint( n_total_weight );
	
	if ( n_roll < n_cutoff_ammo )
		self thread vulture_zombie_drop( "ammo" );
	else if ( n_roll > n_cutoff_ammo && n_roll < n_cutoff_points )
		self thread vulture_zombie_drop( "points" );
	else
		self thread vulture_zombie_mist_watcher();
	
}

function vulture_get_drops( playername )
{
	return getEntArray( playername + "_vulture_drop", "targetname" );
}

function vulture_zombie_drop( type )
{
	self waittill( "death" );
	if( isDefined( self.attacker ) && isPlayer( self.attacker ) && self.attacker hasPerk( PERK_VULTUREAID ) )
	{
		player_drops = vulture_get_drops( self.attacker.playername );
		if ( isDefined( player_drops ) && player_drops.size > 0 && player_drops.size > VULTUREAID_MAX_DROPS )
			return;
		
		trace = playerPhysicsTrace( self.origin + ( 0, 0, 80 ), self.origin - ( 0, 0, 1000 ) );
		
		self.drop_model = spawn( "script_model", trace + ( 0, 0, 5 ) );
		
		playable_area = getEntArray( "player_volume", "script_noteworthy" );
		valid_drop = 0;
		for ( i = 0; i < playable_area.size; i++ )
		{
			if ( self.drop_model isTouching( playable_area[ i ] ) )
			{
				valid_drop = 1;
				break;
			}
		}
		
		if( !valid_drop )
		{
			self.drop_model delete();
			return;
		}
		
		self.drop_model.targetname = self.attacker.playername + "_vulture_drop";
		players = getPlayers();
		for( i = 0; i < players.size; i++ )
			self.drop_model SetInvisibleToPlayer( players[ i ] ); 
		
		self.drop_model SetVisibleToPlayer( self.attacker );
		
		if ( isDefined( self.drop_model ) )
		{
			self.drop_model playSound( "zmb_perks_vulture_drop" );
			self.drop_model playloopSound( "zmb_perks_vulture_loop", 1 );
			switch( type )
			{
				case "points":
				{
			 		self.drop_model setModel( VULTUREAID_POINTS_MODEL );
			 		self.drop_model thread vulture_points_watcher( self.attacker );
			 		break;
				}
				case "ammo":
				{
			 		self.drop_model setModel( VULTUREAID_AMMO_MODEL );
					self.drop_model thread vulture_ammo_watcher( self.attacker );
					break;
				}
			}
			
			self.drop_model thread vulture_lose_watcher( self.attacker );
			self.drop_model thread vulture_timeout( self.attacker );
			self.drop_model thread vulture_dissapear_on_death( self.attacker );
			if ( isDefined( self.drop_model ) )
				playFxOnTag( VULTUREAID_DROPS_GLOW_FX, self.drop_model, "tag_origin" );
		
		}
	}
}

function vulture_ammo_watcher( owner )
{
	self endon( "delete" );
	while( 1 )
	{
		if ( distance( owner.origin, self.origin ) < 48 && isAlive( owner ) && !owner laststand::player_is_in_laststand() )
		{
			owner playSound( "zmb_perks_vulture_pickup" );
			
			current_weapon = owner getCurrentWeapon();
				
			current_ammo = owner getWeaponAmmoStock( current_weapon );
			
			weapon_max = current_weapon.maxAmmo;
			clip = current_weapon.clipSize;
			
			clip_add = int( clip / 10 );
			if ( clip_add < 1 )
				clip_add = 1;
			
			new_ammo = int( current_ammo + clip_add );
			if ( new_ammo > weapon_max )
				new_ammo = weapon_max;
				
			owner setWeaponAmmoStock( current_weapon, new_ammo );
			
			self notify( "grabbed" );
			self delete();
			break;
		}
		wait .05;
	}
}

function vulture_points_watcher( owner )
{
	self endon( "delete" );
	while( 1 )
	{
		if ( distance( owner.origin, self.origin ) < 48 && isAlive( owner ) && !owner laststand::player_is_in_laststand() )
		{
			owner playSound( "zmb_perks_vulture_pickup" );
			owner playSound( "zmb_perks_vulture_money" );
			
			score = 10;
			rand = randomInt( 2 );
			if ( rand == 1 )
				score = 20;
						
			score = score * level.zombie_vars[ owner.team ][ "zombie_point_scalar" ];
			
			owner zm_score::add_to_player_score( score );			
			break;
		}
		wait .05;
	}
	self delete();
}

function vulture_lose_watcher( player )
{
	self endon( "delete" );
	player endon( "disconnect" );
	player waittill( "vulture_over" );
	self delete();
}

function vulture_timeout( player )
{
	self endon ( "delete" );
	
	wait 10;
	for ( i = 0; i < 40; i++ )
	{
		if ( i % 2 )
			self hide();
		else
		{
			self show();
			playFxOnTag( VULTUREAID_DROPS_GLOW_FX, self, "tag_origin" );
		}

		if ( i < 15 )
			wait .5;
		else if ( i < 25 )
			wait .25;
		else
			wait .1;
		
	}
	self delete();
}

function vulture_dissapear_on_death( player )
{
	self endon( "delete" );
	while( 1 )
	{
		player waittill( "lost_vulture" );
		break;
	}
	self delete();
}

function vulture_zombie_mist_watcher()
{
	vulture_mist = spawn( "script_model", self getTagOrigin( "j_spine4" ), 1, 1, 1 );
	vulture_mist.linked = 1;
	vulture_mist.targetname = "vulture_mist";
	vulture_mist.angles = self.angles;
	vulture_mist setModel( "tag_origin" );
	vulture_mist enableLinkTo();
	vulture_mist linkTo( self, "j_spine4" );
	vulture_mist thread vulture_visibility_check();
	self playLoopSound( "zmb_perks_vulture_stink_loop" );
	while( 1 )
	{
		if ( !isAlive( self ) )
			break;
		
		playFxOnTag( VULTUREAID_GREEN_MIST_FX, vulture_mist, "tag_origin" );
		wait 1;
	}
	vulture_mist unlink();
	if ( !zm_utility::check_point_in_playable_area( self getTagOrigin( "j_spine4" ) ) )
	{
		vulture_mist delete();
		return;
	}
	vulture_mist.linked = 0;
	for ( i = 0; i < VULTUREAID_MIST_TIME; i++ )
	{
		playFxOnTag( VULTUREAID_GREEN_MIST_FX, vulture_mist, "tag_origin" );
		wait 1;
	}
	vulture_mist stopLoopSound( 1 );
	vulture_mist delete();
}

function vulture_visibility_check()
{
	self endon( "delete" );
	while ( 1 )
	{
		players = getPlayers();
		for ( p = 0; p < players.size; p++ )
		{
			if ( players[ p ] hasPerk( PERK_VULTUREAID ) )
				self setVisibleToPlayer( players[ p ] );
			else
				self setInvisibleToPlayer( players[ p ] );
			
		}
		wait .05;
	}
}

function vulture_get_mists()
{
	return getEntArray( "vulture_mist", "targetname" );
}

function vulture_mist_watcher()
{
	self endon( "vulture_over" );
	self.touching_mist = undefined;
	self.vulture_level = 0;
	while( 1 )
	{
		hud = undefined;
		for ( i = 0; i < self.perk_hud.size; i++ )
		{
			if ( self.perk_hud[ i ].perk == PERK_VULTUREAID )
			{
				hud = self.perk_hud[ i ];
				break;
			}
		}
		touching_mist = 0;
		vulture_mists = vulture_get_mists();
		
		if ( isDefined( vulture_mists ) && vulture_mists.size > 0 )
		{
			for ( i = 0; i < vulture_mists.size; i++ )
			{
				if ( isDefined( vulture_mists[ i ].linked ) && vulture_mists[ i ].linked )
					continue;
				if ( distance( self.origin, vulture_mists[ i ].origin ) < 64 )
				{
					touching_mist = 1;
					break;
				}
			}
		}
		if ( touching_mist )
		{
			if ( !isDefined( self.touching_mist ) )
			{
				self.touching_mist = 1;
				self playSoundToPlayer( "zmb_perks_vulture_stink_start", self );
			}
			
			if ( self.vulture_level < 1 )
			{
				if ( isDefined( hud ) )
				{
					hud.mist_hud.alpha += .02;
					hud.glow_hud.alpha += .02;
				}
				self.vulture_level += .02;
			}
			if ( self.vulture_level >= 1 )
			{
				if ( isDefined( hud ) )
				{
					hud.mist_hud.alpha = 1;
					hud.glow_hud.alpha = 1;
				}
				self.vulture_level = 1;
				self.ignoreme = 1;
			}
		}
		else
		{
			if ( isDefined( self.touching_mist ) && self.touching_mist )
			{
				self.touching_mist = undefined;
				self playSoundToPlayer( "zmb_perks_vulture_stink_stop", self );
			}
			
			if ( self.vulture_level > 0 )
			{
				hud.mist_hud.alpha -= .02;
				hud.glow_hud.alpha -= .02;
				self.vulture_level -= .02;
			}
			if ( self.vulture_level <= 0 )
			{
				hud.mist_hud.alpha = 0;
				hud.glow_hud.alpha = 0;
				self.vulture_level = 0;
				self.ignoreme = 0;
			}
		}
		wait .05;
	}
}

// --------------------------------
//	NO TARGET OVERRIDE
// --------------------------------
function validate_and_set_no_target_position( position )
{
	if( isDefined( position ) )
	{
		goal_point = getClosestPointOnNavMesh( position.origin, 100 );
		if( isDefined( goal_point ) )
		{
			self setGoal( goal_point );
			self.has_exit_point = 1;
			return 1;
		}
	}
	
	return 0;
}

function no_target_override( zombie )
{
	if( isDefined( zombie.has_exit_point ) )
		return;
	
	players = level.players;
	
	dist_zombie = 0;
	dist_player = 0;
	dest = 0;

	if ( isDefined( level.zm_loc_types[ "dog_location" ] ) )
	{
		locs = array::randomize( level.zm_loc_types[ "dog_location" ] );
		
		for ( i = 0; i < locs.size; i++ )
		{
			found_point = 0;
			foreach( player in players )
			{
				if( player laststand::player_is_in_laststand() )
					continue;
				
				away = vectorNormalize( self.origin - player.origin );
				endPos = self.origin + VectorScale( away, 600 );
				dist_zombie = distanceSquared( locs[ i ].origin, endPos );
				dist_player = distanceSquared( locs[ i ].origin, player.origin );
		
				if ( dist_zombie < dist_player )
				{
					dest = i;
					found_point = 1;
				}
				else
					found_point = 0;
				
			}
			if( found_point )
			{
				if( zombie validate_and_set_no_target_position( locs[ i ] ) )
					return;
				
			}
		}
	}
	
	escape_position = zombie get_escape_position_in_current_zone();
			
	if( zombie validate_and_set_no_target_position( escape_position ) )
		return;
	
	escape_position = zombie get_escape_position();
	
	if( zombie validate_and_set_no_target_position( escape_position ) )
		return;
	
	zombie.has_exit_point = 1;
	
	zombie setGoal( zombie.origin );
}

function get_escape_position()
{
	self endon( "death" );
	
	str_zone = self.zone_name;
	
	if( !isDefined( str_zone ) )
		str_zone = self.zone_name;

	if ( isDefined( str_zone ) )
	{
		a_zones = get_adjacencies_to_zone( str_zone );
		a_wait_locations = get_wait_locations_in_zones( a_zones );
		s_farthest = self get_farthest_wait_location( a_wait_locations );
	}
	return s_farthest;
}

function get_wait_locations_in_zones( a_zones )
{
	a_wait_locations = [];
	
	foreach ( zone in a_zones )
		a_wait_locations = combine_array( a_wait_locations, level.zones[ zone ].a_loc_types[ "dog_location" ] );

	return a_wait_locations;
}

function get_adjacencies_to_zone( str_zone )
{
	a_adjacencies = [];
	a_adjacencies[ 0 ] = str_zone;
	
	a_adjacent_zones = getArrayKeys( level.zones[ str_zone ].adjacent_zones );
	for ( i = 0; i < a_adjacent_zones.size; i++ )
	{
		if ( level.zones[ str_zone ].adjacent_zones[ a_adjacent_zones[ i ] ].is_connected )
			ARRAY_ADD( a_adjacencies, a_adjacent_zones[ i ] );
		
	}
	return a_adjacencies;
}

function get_escape_position_in_current_zone()
{
	self endon( "death" );
	
	str_zone = self.zone_name; 
	
	if( !isDefined( str_zone ) )
		str_zone = self.zone_name;

	if ( isDefined( str_zone ) )
	{
		a_wait_locations = get_wait_locations_in_zone( str_zone );

		if( isDefined( a_wait_locations ) )
			s_farthest = self get_farthest_wait_location( a_wait_locations );
		
	}
	return s_farthest;
}

function combine_array( array_1, array_2 )
{
	temp_array = [];
	for ( i = 0; i < array_1.size; i++ )
		array::add( temp_array , array_1[ i ] );
	for ( i = 0; i < array_2.size; i++ )
		array::add( temp_array , array_2[ i ] );
	
	return temp_array;
}

function get_wait_locations_in_zone( zone )
{
	if( isDefined( level.zones[ zone ].a_loc_types[ "dog_location" ] ) )
	{
		a_wait_locations = [];
		a_wait_locations = combine_array( a_wait_locations, level.zones[ zone ].a_loc_types[ "dog_location" ] );
		return a_wait_locations;
	}
	return undefined;
}

function get_farthest_wait_location( a_wait_locations )
{
	if ( !isDefined( a_wait_locations ) || a_wait_locations.size == 0 )
		return undefined;
	
	n_farthest_index = 0;
	n_distance_farthest = 0;
	for ( i = 0; i < a_wait_locations.size; i++ )
	{
		n_distance_sq = distanceSquared( self.origin, a_wait_locations[ i ].origin );
		
		if ( n_distance_sq > n_distance_farthest )
		{
			n_distance_farthest = n_distance_sq;
			n_farthest_index = i;
		}
	}
	
	return a_wait_locations[ n_farthest_index ];
}