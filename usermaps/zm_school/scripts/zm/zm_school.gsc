#using scripts\codescripts\struct;

#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\compass;
#using scripts\shared\exploder_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\math_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\util_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#insert scripts\zm\_zm_utility.gsh;

#using scripts\zm\_load;
#using scripts\zm\_zm;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_zonemgr;

#using scripts\shared\ai\zombie_utility;

//Perks
#using scripts\zm\_zm_pack_a_punch;
#using scripts\zm\_zm_pack_a_punch_util;
#using scripts\zm\_zm_perk_additionalprimaryweapon;
#using scripts\zm\_zm_perk_doubletap2;
#using scripts\zm\_zm_perk_deadshot;
#using scripts\zm\_zm_perk_juggernaut;
#using scripts\zm\_zm_perk_quick_revive;
#using scripts\zm\_zm_perk_sleight_of_hand;
#using scripts\zm\_zm_perk_staminup;

//Powerups
#using scripts\zm\_zm_powerup_double_points;
#using scripts\zm\_zm_powerup_carpenter;
#using scripts\zm\_zm_powerup_fire_sale;
#using scripts\zm\_zm_powerup_free_perk;
#using scripts\zm\_zm_powerup_full_ammo;
#using scripts\zm\_zm_powerup_insta_kill;
#using scripts\zm\_zm_powerup_nuke;
//#using scripts\zm\_zm_powerup_weapon_minigun;

//Traps
#using scripts\zm\_zm_trap_electric;

#using scripts\zm\zm_usermap;

// NSZ Zombie Blood Powerup
#using scripts\_NSZ\nsz_powerup_zombie_blood;
#using scripts\_NSZ\ice_insta_teleporter;
#using scripts\zm\zm_usermap;

#precache("fx", "custom_soe_box/fx_soe_magicbox");
//*****************************************************************************
// MAIN
//*****************************************************************************

function main()
{
	zm_usermap::main();
	
	callback::on_spawned( &bo2_deathhands );

	callback::on_spawned( &cinematic_downs ); //intermission

	level._zombie_custom_add_weapons =&custom_add_weapons;
	
	level thread intro_credits(); 

	thread video_display();
	
	//Setup the levels Zombie Zone Volumes
	level.zones = [];
	level.zone_manager_init_func =&usermap_test_zone_init;
	init_zones[0] = "start_zone";
	level thread zm_zonemgr::manage_zones( init_zones );

	level.pathdist_type = PATHDIST_ORIGINAL;

	//Bottom of the Main() function
   level.musicplay = false;
   thread musicplaying();



   //Place this under Main()
	// Instant Teleporter - Code based off NSZ Kino Teleporter
	level thread ice_insta_teleporter::player_teleporter_init(); 

	//level thread set_perk_limit (4);  
	// This sets the perk limit to 10

	level._zombie_custom_add_weapons =&custom_add_weapons;
	level.pack_a_punch_camo_index = 75;
    level.pack_a_punch_camo_index_number_variants = 5;
    //change pack a punch camo

    //staring Points
	level.player_starting_points = 50000000;
	//level.player_starting_point = enter number of points;

	//Starting Weapon
	startingWeapon = "pistol_revolver38";
	weapon = getWeapon(startingWeapon);
	level.start_weapon = (weapon); //Starting Weapon

	// Box FX
    level._effect["chest_light"] = "custom_soe_box/fx_soe_magicbox";
    //Box Teddy Model
    level.chest_joker_model = "p7_zm_zod_magic_box_tentacle_teddy"; //Change the teddy model here must match .zone file

	
}

function usermap_test_zone_init()
{
	//Zone per room
	zm_zonemgr::add_adjacent_zone("start_zone","lib_level1","enter_lib_level1");
	zm_zonemgr::add_adjacent_zone("lib_level1","lib_classroom1","enter_lib_classroom1");
	zm_zonemgr::add_adjacent_zone("lib_classroom1","outside","enter_outside");
	zm_zonemgr::add_adjacent_zone("outside","lib_movie","enter_lib_movie");
	zm_zonemgr::add_adjacent_zone("outside","outside2","enter_outside2");
	zm_zonemgr::add_adjacent_zone("outside","outside3","enter_outside3");
	zm_zonemgr::add_adjacent_zone("outside","outside4","enter_outside4");
	zm_zonemgr::add_adjacent_zone("outside","outside5","enter_outside5");
	zm_zonemgr::add_adjacent_zone("outside","outside6","enter_outside6");
	zm_zonemgr::add_adjacent_zone("outside","classroomblock1_room1","enter_classroomblock1_room1");
	zm_zonemgr::add_adjacent_zone("outside","classroomblock1_room2","enter_classroomblock1_room2");
	// zone e.g zm_zonemgr::add_adjacent_zone("start_zone","start_roomname_zone","enter_roomname_zone");

	level flag::init( "always_on" );
	level flag::set( "always_on" );
}	

//function
function custom_add_weapons()
{
	zm_weapons::load_weapon_spec_from_table("gamedata/weapons/zm/zm_levelcommon_weapons.csv", 1);
}

function intro_credits()
{
    thread creat_simple_intro_hud( "Thank you for playing School: pre Alpha Version 0.07", 50, 100, 3, 5 );
    thread creat_simple_intro_hud( "Mapping & scripting by Nathan3197", 50, 75, 2, 5 );
    thread creat_simple_intro_hud( "update video @youtube Nathan3197", 50, 50, 2, 5 );
    thread creat_simple_intro_hud( "Have fun with finding the easter egg", 50, 25, 2, 5 );
}
 
function creat_simple_intro_hud( text, align_x, align_y, font_scale, fade_time )
{
    hud = NewHudElem();
    hud.foreground = true;
    hud.fontScale = font_scale;
    hud.sort = 1;
    hud.hidewheninmenu = false;
    hud.alignX = "left";
    hud.alignY = "bottom";
    hud.horzAlign = "left";
    hud.vertAlign = "bottom";
    hud.x = align_x;
    hud.y = hud.y - align_y;
    hud.alpha = 1;
    hud SetText( text );
    wait( 8 );
    hud fadeOverTime( fade_time );
    hud.alpha = 0;
    wait( fade_time );
    hud Destroy();
}

//BO2 Deathhands Animation
function bo2_deathhands()
{
	self thread giveDeathHands();
}

function giveDeathHands()
{
	level waittill( "intermission" ); 

	self thread player1_deathhands();
	self thread player2_deathhands();
	self thread player3_deathhands();
	self thread player4_deathhands();
}

function func_giveWeapon(weapon)
{
    self TakeWeapon(self GetCurrentWeapon());
    weapon = getWeapon(weapon);
    self GiveWeapon(weapon);
    self GiveMaxAmmo(weapon);
    self SwitchToWeapon(weapon);
}

function player1_deathhands() //Dempsey
{
	players = GetPlayers();
	player_1 = players[0];
	if ( self.playername == ""+player_1.playername+"" )
	{
	self func_giveWeapon("bo2_deathhands");
	}
}

function player2_deathhands() //Nikolai
{
	players = GetPlayers();
	player_2 = players[1];
	if ( self.playername == ""+player_2.playername+"" )
	{
	self func_giveWeapon("bo2_deathhands");
	}
}

function player3_deathhands() //Richtofen
{
	players = GetPlayers();
	player_3 = players[2];
	if ( self.playername == ""+player_3.playername+"" )
	{
	self func_giveWeapon("bo2_deathhands");
	}
}

function player4_deathhands() //Takeo
{
	players = GetPlayers();
	player_4 = players[3];
	if ( self.playername == ""+player_4.playername+"" )
	{
	self func_giveWeapon("bo2_deathhands");
	}
}

function video_display()
{

	trig = GetEnt("switch","script_noteworthy");
	
	trig thread playing();

	
	
}

function playing()
{
	while(1)
	{

		while(1)
	    {
		 self SetHintString("Press &&1 to do something");
		 self SetCursorHint("HINT_NOICON");
		 self waittill("trigger", player);
		
		 VideoStart("cp_doa_bo3_titlescreen");// add your video name here

		 wait( 24 ); // add time of video in sec

		 VideoStop("cp_doa_bo3_titlescreen");// add yor video name here
		 
	    }

        }
	
}

function cinematic_downs()
{
	level endon( "intermission" ); 
	level.players_not_valid = 0; 
	
	while(1)
	{

		while( zm_utility::is_player_valid(self) )
			wait(0.05); 
		
		level.players_not_valid++; 
		self.player_not_valid = true; 
		players = GetPlayers(); 
		if( level.players_not_valid == players.size-1 )
			foreach( player in players )
				if( !isDefined(player.player_not_valid) )
				{
					player PlayLocalSound( "music4" );  // change to your song name
					player.playing_cinematic_down = true; 
				}
		
		while( !zm_utility::is_player_valid(self) )
			wait(0.05); 
		
		level.players_not_valid--; 
		self.player_not_valid = undefined; 
		
		players = getplayers(); 
		foreach( player in players )
			if( isDefined(player.playing_cinematic_down) )
			{
				player StopLocalSound( "music4" ); // change to your song name
				player.playing_cinematic_down = undefined; 
		}
		
		wait(0.05); 
	}
}

//Bottom of your Mapname.gsc
function musicplaying()
{
   //Wait till game starts
   level flag::wait_till( "initial_blackscreen_passed" );
   IPrintLn("Herro?");
   musicmulti = GetEntArray("musicmulti","targetname");
   IPrintLn("Found " + musicmulti.size + " Ents");
   foreach(musicpiece in musicmulti)
      musicpiece thread sound_logic();
}
 
function sound_logic()
{
   while(1)
   {
       self waittill("trigger", player);
       if(level.musicplay == false)
       {
            level.musicplay = true;
            IPrintLn("Music Activated: "+self.script_string);
            player PlaySoundWithNotify(self.script_string, "soundcomplete");
            player waittill("soundcomplete");
            IPrintLn("Music Over");
            level.musicplay = false;
       }
       else
       {
            IPrintLn("Music Already Playing");
       }
 
   }
}


