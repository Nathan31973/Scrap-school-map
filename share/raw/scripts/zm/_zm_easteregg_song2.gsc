#namespace zm_easteregg_song2;

function init()
{
	/*	Editable Variables - change the values in here */
	level.easterEggSong = "song2";							// sound alias name for the song
	level.easterEggTriggerSound = "ee_trigger";				// sound alias name for the sound played when activating a trigger
	level.easterEggTriggerLoopSound = "ee_loop_trigger";	// sound alias name for the loop sound when you are near a trigger
	level.multipleActivations = true;						// whether or not the song can be activated multiple times (true means it can, false means just once)
	/*	End of Editable Variables - don't touch anything below here */

	setupMusic();
}

function setupMusic()
{
	level.triggersActive = 0;
	triggers = GetEntArray("song_trigger2", "targetname");

	foreach(trigger in triggers)
	{
		trigger SetCursorHint("HINT_NOICON");
		trigger UseTriggerRequireLookAt();
		trigger thread registerTriggers(triggers.size);
	}
}

function registerTriggers(numTriggers)
{
	ent = self play_2D_loop_sound(level.easterEggTriggerLoopSound);

	self waittill("trigger");
	ent delete();
	self PlaySound(level.easterEggTriggerSound);
	level.triggersActive++;

	if(level.triggersActive >= numTriggers)
		playMusic();
}

function playMusic()
{
	play_2D_sound(level.easterEggSong);

	if(level.multipleActivations)
		setupMusic();
}

function play_2D_sound(sound)
{
	temp_ent = spawn("script_origin", (0,0,0));
	temp_ent PlaySoundWithNotify(sound, sound + "wait");
	temp_ent waittill (sound + "wait");
	wait(0.05);
	temp_ent delete();	
}

function play_2D_loop_sound(sound)
{
	temp_ent = spawn("script_origin", self.origin);
	temp_ent PlayLoopSound(sound);
	return temp_ent;
}