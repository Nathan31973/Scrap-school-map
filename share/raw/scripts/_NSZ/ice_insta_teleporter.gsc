// Kino Teleporter by NSZ
#using scripts\zm\_zm_score;
#using scripts\codescripts\struct;
#using scripts\shared\flag_shared;

// Modified Shadows Teleporter by Ice_Grenade originally Kino Teleporter by NSZ.                        
#define KINO_SWIRL                                  "_NSZ/Kino_Tele/kino_swirl"
#precache( "fx", KINO_SWIRL );

function player_teleporter_init()
{
    level.black_spots = struct::get_array( "black_orgs", "targetname" );
    level.black_spots_targets = []; 
    for( i=0;i<level.black_spots.size;i++ )
        level.black_spots_targets[i] = struct::get( level.black_spots[i].target, "targetname" );
    player_tps = GetEntArray( "teleport_player_string", "targetname" );
    player_tp = GetEntArray( "teleport_player", "targetname" );
    for ( i = 0; i < player_tps.size; i++ )
    {
        player_tps[i] SetCursorHint( "HINT_NOICON" ); 
        player_tps[i] SetHintString( &"ZOMBIE_NEED_POWER" );
    }
    wait_for_power();
    for ( i = 0; i < player_tps.size; i++ )
    {
        player_tps[i] Delete();
    }
    for( i = 0; i < player_tp.size; i++ )
    {
        player_tp[i] thread player_teleport(i);
    }
    level.black_spots = struct::get_array( "black_orgs", "targetname" );
    level.black_spots_targets = []; 
    for( i=0;i<level.black_spots.size;i++ )
        level.black_spots_targets[i] = struct::get( level.black_spots[i].target, "targetname" );
}

function player_teleport(player_num)
{
    destination = GetEnt( self.target, "targetname" );
    while(1)
    {
        self waittill( "trigger", player );
        self setstance( "stand" );
        wait(0.1);
        player playlocalsound( "kino_teleport_2d" );
        player DisableWeapons();
        player DisableOffhandWeapons();
        player freezecontrols( true );
        player SetOrigin( level.black_spots[player_num].origin ); 
        player SetPlayerAngles( level.black_spots[player_num].angles );
        playfx( KINO_SWIRL, level.black_spots_targets[player_num].origin ); 
        wait(2);
        player EnableWeapons(); 
        player EnableOffhandWeapons(); 
        player freezecontrols( false );
        player SetOrigin( destination.origin );
        player SetPlayerAngles( destination.angles );
        wait(0.05); 
        self playsound( "kino_beam_fx" );
    }
}

function wait_for_power()
{
    level.teleport_trigger SetCursorHint( "HINT_NOICON" ); 
    level.link_pad_trigger SetCursorHint( "HINT_NOICON" ); 
    level.teleport_trigger SetHintString( &"ZOMBIE_NEED_POWER" );
    level.link_pad_trigger SetHintString( &"ZOMBIE_NEED_POWER" );
    level flag::wait_till( "power_on" ); 
}