#using scripts\zm\_zm_perks;
#insert scripts\zm\_zm_perks.gsh;
 
function init()
{
    level.shootablesNeeded = 9;
    level.shootablesCollected = 0;
 
    level thread shootable_1();
    level thread shootable_2();
    level thread shootable_3();
    level thread shootable_4();
    level thread shootable_5();
    level thread shootable_6();
    level thread shootable_7();
    level thread shootable_8();
    level thread shootable_9();
}
 
function shootable_1()
{
    trig_1 = GetEnt("shootable_trig", "targetname");
    model_1 = GetEnt("shootable_model", "targetname");
 
    trig_1 SetHintString("");
    trig_1 SetCursorHint("HINT_NOICON");
 
    while(1)
    {
        trig_1 waittill("trigger", player);
 
        level.shootablesCollected++;
 
        IPrintLn("You found one!"); // Not Needed
 
        thread shootables_done(player);
 
        break;
    }
 
    trig_1 Delete();
    model_1 Delete();
}
 
function shootable_2()
{
    trig_2 = GetEnt("shootable_trig_2", "targetname");
    model_2 = GetEnt("shootable_model_2", "targetname");
 
    trig_2 SetHintString("");
    trig_2 SetCursorHint("HINT_NOICON");
 
    while(1)
    {
        trig_2 waittill("trigger", player);
 
        level.shootablesCollected++;
 
        IPrintLn("You found another one!"); // Not Needed
 
        thread shootables_done(player);
 
        break;
    }
 
    trig_2 Delete();
    model_2 Delete();
}
 
function shootable_3()
{
    trig_3 = GetEnt("shootable_trig_3", "targetname");
    model_3 = GetEnt("shootable_model_3", "targetname");
 
    trig_3 SetHintString("");
    trig_3 SetCursorHint("HINT_NOICON");
 
    while(1)
    {
        trig_3 waittill("trigger", player);
 
        level.shootablesCollected++;
 
        IPrintLn("You found another one!"); // Not Needed
 
        thread shootables_done(player);
 
        break;
    }
 
    trig_3 Delete();
    model_3 Delete();
}
 
 function shootable_4()
{
    trig_4 = GetEnt("shootable_trig_4", "targetname");
    model_4 = GetEnt("shootable_model_4", "targetname");
 
    trig_4 SetHintString("");
    trig_4 SetCursorHint("HINT_NOICON");
 
    while(1)
    {
        trig_4 waittill("trigger", player);
 
        level.shootablesCollected++;
 
        IPrintLn("You found another one!"); // Not Needed
 
        thread shootables_done(player);
 
        break;
    }
 
    trig_4 Delete();
    model_4 Delete();
}

function shootable_5()
{
    trig_5 = GetEnt("shootable_trig_5", "targetname");
    model_5 = GetEnt("shootable_model_5", "targetname");
 
    trig_5 SetHintString("");
    trig_5 SetCursorHint("HINT_NOICON");
 
    while(1)
    {
        trig_5 waittill("trigger", player);
 
        level.shootablesCollected++;
 
        IPrintLn("You found another one!"); // Not Needed
 
        thread shootables_done(player);
 
        break;
    }
 
    trig_5 Delete();
    model_5 Delete();
}

function shootable_6()
{
    trig_6 = GetEnt("shootable_trig_6", "targetname");
    model_6 = GetEnt("shootable_model_6", "targetname");
 
    trig_6 SetHintString("");
    trig_6 SetCursorHint("HINT_NOICON");
 
    while(1)
    {
        trig_6 waittill("trigger", player);
 
        level.shootablesCollected++;
 
        IPrintLn("You found another one!"); // Not Needed
 
        thread shootables_done(player);
 
        break;
    }
 
    trig_6 Delete();
    model_6 Delete();
}

function shootable_7()
{
    trig_7 = GetEnt("shootable_trig_7", "targetname");
    model_7 = GetEnt("shootable_model_7", "targetname");
 
    trig_7 SetHintString("");
    trig_7 SetCursorHint("HINT_NOICON");
 
    while(1)
    {
        trig_7 waittill("trigger", player);
 
        level.shootablesCollected++;
 
        IPrintLn("You found another one!"); // Not Needed
 
        thread shootables_done(player);
 
        break;
    }
 
    trig_7 Delete();
    model_7 Delete();
}

function shootable_8()
{
    trig_8 = GetEnt("shootable_trig_8", "targetname");
    model_8 = GetEnt("shootable_model_8", "targetname");
 
    trig_8 SetHintString("");
    trig_8 SetCursorHint("HINT_NOICON");
 
    while(1)
    {
        trig_8 waittill("trigger", player);
 
        level.shootablesCollected++;
 
        IPrintLn("You found another one!"); // Not Needed
 
        thread shootables_done(player);
 
        break;
    }
 
    trig_8 Delete();
    model_8 Delete();
}

function shootable_9()
{
    trig_9 = GetEnt("shootable_trig_9", "targetname");
    model_9 = GetEnt("shootable_model_9", "targetname");
 
    trig_9 SetHintString("");
    trig_9 SetCursorHint("HINT_NOICON");
 
    while(1)
    {
        trig_9 waittill("trigger", player);
 
        level.shootablesCollected++;
 
        IPrintLn("You found another one!"); // Not Needed
 
        thread shootables_done(player);
 
        break;
    }
 
    trig_9 Delete();
    model_9 Delete();
}

function shootables_done(player)
{
    while(1)
    {
        self waittill(level.shootablesCollected >= level.shootablesNeeded);
 
        if(level.shootablesCollected == level.shootablesNeeded)
        {
            // What ever code you want to execute once all shootables are collected
            IPrintLn("You found all perk bottle. enjoy your dickshot daiquiri perk");
            player zm_perks::give_perk( PERK_DEAD_SHOT, false );
        }
 
        break;
    }
}