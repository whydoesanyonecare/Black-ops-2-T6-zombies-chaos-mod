#include maps\mp\gametypes_zm\_hud_util;
#include maps\mp\zombies\_zm;
#include maps\mp\zombies\_zm_perks;
#include maps\mp\_visionset_mgr;
#include maps\mp\zombies\_zm_score;
#include maps\mp\_demo;
#include maps\mp\zombies\_zm_audio;
#include maps\mp\zombies\_zm_pers_upgrades_functions;
#include maps\mp\zombies\_zm_power;
#include maps\mp\zombies\_zm_laststand;
#include maps\mp\zombies\_zm_weapons;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_stats;
#include common_scripts\utility;
#include maps\mp\zombies\_zm_powerups;
#include maps\mp\zombies\_zm_chugabud;
#include maps\mp\zombies\_zm_afterlife;
#include maps\mp\zombies\_zm_unitrigger;
#include maps\mp\zombies\_zm_magicbox;
#include patch\animscripts;
#include maps\mp\gametypes\_globallogic_player;
#include maps\mp\zm_transit_utility;

main()
{
}

init() 
{
    precacheshader("specialty_doublepoints_zombies");
    setDvar( "ui_errorMessage", "^9Thank you for playing this Custom Gamemode \n\n^3More Mods ^7-> ^3https://discord.com/invite/mtAsvArAJD \n \nCreated by ^1Unknown Love" );
    setDvar( "ui_errorTitle", "^1Chaos" );
    setdvar( "cg_gun_y", "0" ); //resets left side gun if game ended while active
    setdvar( "bg_gravity", "800" ); //resets low gravity if game ended while active
    level thread onPlayerConnect();
    thread CheckForCurrentBox();
    level.get_player_perk_purchase_limit = ::get_player_perk_purchase_limit;
    flag_wait("initial_blackscreen_passed");
    maps\mp\zombies\_zm_spawner::register_zombie_death_event_callback( ::actor_killed_response );
    level.explosive_zombies = 0;
    level thread destroy_in_end();
}

destroy_in_end()
{
    level waittill("end_game");
    for(i=0;i<get_players().size;i++)
    {
        if(isdefined(get_players()[i].progress_bar))
        {
            get_players()[i].progress_bar destroy();
            get_players()[i].progress_bar.bar destroy();
            get_players()[i].progress_bar.barframe destroy();

            foreach(task_hud in get_players()[i].task_list)
                task_hud destroy();
        }
    }
}

get_player_perk_purchase_limit()
{
	if(isDefined( self.player_perk_purchase_limit ) )
	{
		return self.player_perk_purchase_limit;
	}
	return level.perk_purchase_limit;
}

onPlayerConnect()
{
	level endon("end_game");
    for(;;)
    {
        if(isDefined(level.player_too_many_weapons_monitor) && level.player_too_many_weapons_monitor)
			level.player_too_many_weapons_monitor = 0;
        level waittill("connected", player);
        player thread onPlayerSpawned();
    }
}

onPlayerSpawned()
{
    self endon("disconnect");
	level endon("end_game");
    self waittill("spawned_player");
    self.jump_active = 0;
    self.super_melee_on = 0;
    self.bar = 0;
    self.has_mp_perks = 0;
    self welcome_message();
    self thread PlayerDownedWatcher();
    for(;;)
    {
        self waittill("spawned_player");
        wait 3;
        if(!isdefined(self.timer_set))
        {
            self.task_timer = 2;
            self.timer_set = 600;
        }

        if(self.bar == 0)
            self thread progress_bar(1,0,0,self.timer_set);
        
        if(self.bar == 1)
            self thread progress_bar(0,1,0,self.timer_set);
        
        if(self.bar == 2)
            self thread progress_bar(0,0,1,self.timer_set);
        
    }
}

welcome_message()
{
    self endon("disconnect");
	level endon("end_game");
    self.is_connected = 1;
    flag_wait( "initial_blackscreen_passed" );
    wait 2;
    if( self.sessionstate == "spectator" )
    {
        self waittill("spawned_player");
        wait 1;
    }
    if(isDefined(self.e_afterlife_corpse))
    {
        while(isdefined(self.afterlife) && self.afterlife)
        {
            wait 1;
        }
        wait 2;
    }
    self.hud[0] = create_simple_hud( self );
	self.hud[0].alignX = "center"; 
	self.hud[0].alignY = "top";
	self.hud[0].horzAlign = "center"; 
	self.hud[0].vertAlign = "center";
	self.hud[0].hidewheninmenu = 1;
	self.hud[0].font = "default";
	self.hud[0].x = 0; 
	self.hud[0].y = 50; 
	self.hud[0].fontscale = 2;
    self.hud[0] setText("Welcome to Chaos Mod");
    self.hud[1] = create_simple_hud( self );
	self.hud[1].alignX = "center"; 
	self.hud[1].alignY = "top";
	self.hud[1].horzAlign = "center"; 
	self.hud[1].vertAlign = "center";
	self.hud[1].hidewheninmenu = 1;
	self.hud[1].font = "default";
	self.hud[1].x = 0; 
	self.hud[1].y = 75; 
	self.hud[1].fontscale = 2;
    self.hud[1] setText("Bar Location: ^1LEFT");
    self.hud[2] = create_simple_hud( self );
	self.hud[2].alignX = "center"; 
	self.hud[2].alignY = "top";
	self.hud[2].horzAlign = "center"; 
	self.hud[2].vertAlign = "center";
	self.hud[2].hidewheninmenu = 1;
	self.hud[2].font = "default";
	self.hud[2].x = 0; 
	self.hud[2].y = 100; 
	self.hud[2].fontscale = 1.8;
    self.hud[2] setText("Press ^3[{+actionslot 3}] ^7to change bar location ");
    self.hud[3] = create_simple_hud( self );
	self.hud[3].alignX = "center"; 
	self.hud[3].alignY = "top";
	self.hud[3].horzAlign = "center"; 
	self.hud[3].vertAlign = "center";
	self.hud[3].hidewheninmenu = 1;
	self.hud[3].font = "default";
	self.hud[3].x = 0; 
	self.hud[3].y = 125; 
	self.hud[3].fontscale = 1.8;
    self.hud[3].label = &"Press ^3[{+actionslot 2}] ^7to change timer ^1";
    self.hud[3] setvalue( 10 );
    self.hud[4] = create_simple_hud( self );
	self.hud[4].alignX = "center"; 
	self.hud[4].alignY = "top";
	self.hud[4].horzAlign = "center"; 
	self.hud[4].vertAlign = "center";
	self.hud[4].hidewheninmenu = 1;
	self.hud[4].font = "default";
	self.hud[4].x = 0; 
	self.hud[4].y = 150; 
	self.hud[4].fontscale = 1.8;
    self.hud[4].label = &"Press ^3[{+activate}] ^7to Start Game";
    self.bar = 0;
    self.task_timer = 0;
    while(self.is_connected)
    {
        if(self.bar == 0)
            self.hud[1] setText("Bar Location: ^1LEFT");
        
        if(self.bar == 1)
            self.hud[1] setText("Bar Location: ^1CENTER");
        
        if(self.bar == 2)
            self.hud[1] setText("Bar Location: ^1RIGHT");
        
        if(self actionslotthreebuttonpressed())
        {
            self.bar++;

            if(self.bar > 2)
                self.bar = 0;
            
        }
        if(self.task_timer == 0)
        {
            self.hud[3] setValue( 10 );
            self.time_set = 200;
        }
        if(self.task_timer == 1)
        {
            self.hud[3] setValue( 20 );
            self.time_set = 400;
        }
        if(self.task_timer == 2)
        {
            self.hud[3] setValue( 30 );
            self.time_set = 600;
        }
        if(self.task_timer == 3)
        {
            self.hud[3] setValue( 40 );
            self.time_set = 800;
        }
        if(self.task_timer == 4)
        {
            self.hud[3] setValue( 50 );
            self.time_set = 1000;
        }
        if(self.task_timer == 5)
        {
            self.hud[3] setValue( 60 );
            self.time_set = 1200;
        }
        if(self actionslottwobuttonpressed())
        {
            self.task_timer++;

            if(self.task_timer > 5)
                self.task_timer = 0;
            
        }
        if(self usebuttonpressed())
        {
            if(self.bar == 0)
                self thread progress_bar(1,0,0,self.time_set);
            
            if(self.bar == 1)
                self thread progress_bar(0,1,0,self.time_set);
            
            if(self.bar == 2)
                self thread progress_bar(0,0,1,self.time_set);
            
            break;
        }
        wait .05;
    }
    self.hud[0] destroy();
    self.hud[1] destroy();
    self.hud[2] destroy();
    self.hud[3] destroy();
    self.hud[4] destroy();
}

PlayerDownedWatcher()
{
    self endon("disconnect");
	level endon("end_game");
	for(;;)
	{
		self waittill_any_return( "fake_death", "player_downed", "death" );
        if(self maps\mp\zombies\_zm_laststand::player_is_in_laststand() || isdefined(self.afterlife) && self.afterlife)
            wait 1;
        else
        {
            if(isdefined(self))
            {
                self notify("end_task_progress");
                self allowcrouch( 1 );
                self allowsprint( 1 );
                self allowads( 1 );
                self unsetperk( "specialty_armorpiercing" );
                self unsetperk( "specialty_bulletaccuracy" );
                self unsetperk( "specialty_bulletdamage" );
                self unsetperk( "specialty_bulletflinch" );
                self unsetperk( "specialty_bulletpenetration" );
                self unsetperk( "specialty_delayexplosive" );
                self unsetperk( "specialty_detectexplosive" );
                self unsetperk( "specialty_disarmexplosive" );
                self unsetperk( "specialty_earnmoremomentum" );
                self unsetperk( "specialty_explosivedamage" );
                self unsetperk( "specialty_extraammo" );
                self unsetperk( "specialty_fastads" );
                self unsetperk( "specialty_fastequipmentuse" );
                self unsetperk( "specialty_fastladderclimb" );
                self unsetperk( "specialty_fastmantle" );
                self unsetperk( "specialty_fastmeleerecovery" );
                self unsetperk( "specialty_fasttoss" );
                self unsetperk( "specialty_fastweaponswitch" );
                self unsetperk( "specialty_fireproof" );
                self unsetperk( "specialty_flashprotection" );
                self unsetperk( "specialty_gpsjammer" );
                self unsetperk( "specialty_healthregen" );
                self unsetperk( "specialty_holdbreath" );
                self unsetperk( "specialty_immunecounteruav" );
                self unsetperk( "specialty_immunemms" );
                self unsetperk( "specialty_immunenvthermal" );
                self unsetperk( "specialty_immunerangefinder" );
                self unsetperk( "specialty_killstreak" );
                self unsetperk( "specialty_loudenemies" );
                self unsetperk( "specialty_marksman" );
                self unsetperk( "specialty_movefaster" );
                self unsetperk( "specialty_noname" );
                self unsetperk( "specialty_nottargetedbyairsupport" );
                self unsetperk( "specialty_nokillstreakreticle" );
                self unsetperk( "specialty_nottargettedbysentry" );
                self unsetperk( "specialty_pin_back" );
                self unsetperk( "specialty_pistoldeath" );
                self unsetperk( "specialty_proximityprotection" );
                self unsetperk( "specialty_quieter" );
                self unsetperk( "specialty_reconnaissance" );
                self unsetperk( "specialty_showenemyequipment" );
                self unsetperk( "specialty_stunprotection" );
                self unsetperk( "specialty_shellshock" );
                self unsetperk( "specialty_sprintrecovery" );
                self unsetperk( "specialty_showonradar" );
                self unsetperk( "specialty_stalker" );
                self unsetperk( "specialty_twogrenades" );
                self unsetperk( "specialty_twoprimaries" );
                self setclientdvar( "bg_gravity", "800" );
                self setclientdvar( "cg_gun_y", "0" );
                level.explosive_zombies = 0;
                self.is_connected = 0;
                self.jump_active = 0;
                self.super_melee_on = 0;
                self.progress_bar destroy();
                self.progress_bar.bar destroy();
                self.progress_bar.barframe destroy();
                for(i = 0; i < self.task_list.size; i++)
                {
                    self.task_list[i] destroy();
                }
            }
        }
	}
}

progress_bar(left, center, right, progress_timer)
{
    self endon("disconnect");
    self endon("end_task_progress");
    level endon("end_game");
    if(!isdefined(self.task_list))
        self.task_list = [];
    
    if(!isdefined(self.task_array))
        self.task_array = [];
    
    if(!isdefined(self.upgraded_box))
        self.upgraded_box = 0;
    
    if(!isdefined(level.perk_locations_array))
        level.perk_locations_array = [];
    
    if(!isdefined(self.player_perk_purchase_limit))
        self.player_perk_purchase_limit = 4;
    
    wait 2;
	self.progress_bar = self createprimaryprogressbar();
    
    if(center)
    {
        self.progress_bar.alignx = "center";
        self.progress_bar.aligny = "top";
        self.progress_bar.horzalign = "user_center";
        self.progress_bar.vertalign = "user_top";
        self.progress_bar.x = 0;
        self.progress_bar.y = 0;
        self.progress_bar.width = 122.5;
        self.progress_bar.color = (0,0,0);
        self.progress_bar.hidewheninmenu = 1;
        self.progress_bar.bar.aligny = "top";
        self.progress_bar.bar.vertalign = "user_top";
        self.progress_bar.bar.x = -61.5;
        self.progress_bar.bar.y = 2;
        self.progress_bar.bar.color = (0,0,1);
        self.progress_bar.bar.hidewheninmenu = 1;
        self.progress_bar.barframe.alignx = "center";
        self.progress_bar.barframe.aligny = "top";
        self.progress_bar.barframe.horzalign = "user_center";
        self.progress_bar.barframe.vertalign = "user_top";
        self.progress_bar.barframe.x = 0;
        self.progress_bar.barframe.y = 0;
        self.progress_bar.barframe.hidewheninmenu = 1;
    }
    if(right)
    {
        self.progress_bar.alignx = "right";
        self.progress_bar.aligny = "top";
        self.progress_bar.horzalign = "user_right";
        self.progress_bar.vertalign = "user_top";
        self.progress_bar.x = -2;
        self.progress_bar.y = 0;
        self.progress_bar.width = 122.5;
        self.progress_bar.color = (0,0,0);
        self.progress_bar.hidewheninmenu = 1;
        self.progress_bar.bar.aligny = "top";
        self.progress_bar.bar.horzalign = "user_right";
        self.progress_bar.bar.vertalign = "user_top";
        self.progress_bar.bar.x = -125.5;
        self.progress_bar.bar.y = 2;
        self.progress_bar.bar.color = (0,0,1);
        self.progress_bar.bar.hidewheninmenu = 1;
        self.progress_bar.barframe.alignx = "right";
        self.progress_bar.barframe.aligny = "top";
        self.progress_bar.barframe.horzalign = "user_right";
        self.progress_bar.barframe.vertalign = "user_top";
        self.progress_bar.barframe.x = -2;
        self.progress_bar.barframe.y = 0;
        self.progress_bar.barframe.hidewheninmenu = 1;
    }
    if(left)
    {
        self.progress_bar.alignx = "left";
        self.progress_bar.aligny = "top";
        self.progress_bar.horzalign = "user_left";
        self.progress_bar.vertalign = "user_top";
        self.progress_bar.x = 2;
        self.progress_bar.y = 0;
        self.progress_bar.width = 122.5;
        self.progress_bar.color = (0,0,0);
        self.progress_bar.hidewheninmenu = 1;
        self.progress_bar.bar.alignx = "left";
        self.progress_bar.bar.aligny = "top";
        self.progress_bar.bar.horzalign = "user_left";
        self.progress_bar.bar.vertalign = "user_top";
        self.progress_bar.bar.x = 2;
        self.progress_bar.bar.y = 2;
        self.progress_bar.bar.color = (0,0,1);
        self.progress_bar.bar.hidewheninmenu = 1;
        self.progress_bar.barframe.alignx = "left";
        self.progress_bar.barframe.aligny = "top";
        self.progress_bar.barframe.horzalign = "user_left";
        self.progress_bar.barframe.vertalign = "user_top";
        self.progress_bar.barframe.x = 2;
        self.progress_bar.barframe.y = 0;
        self.progress_bar.barframe.hidewheninmenu = 1;
    }
    time = 0;
	while(1)
	{
        if(self maps\mp\zombies\_zm_laststand::player_is_in_laststand())
        {
            while(self maps\mp\zombies\_zm_laststand::player_is_in_laststand())
            {
                wait 1;
            }
            wait .5;

            if(self.sessionstate == "spectator")
                break;

            self iprintln("continuing...");
            wait 2;
        }
		if(isDefined(self.e_afterlife_corpse))
		{
            while(isdefined(self.afterlife) && self.afterlife)
            {
                wait 1;
            }
            self iprintln("continuing...");
            wait 2;

		}
        time++;
        if(time >= progress_timer )
        {
            if(left)
                self randomize_task(1,0,0);
            
            if(center)
                self randomize_task(0,1,0);
            
            if(right)
                self randomize_task(0,0,1);
            
            time = 0;
        }
		self.progress_bar updatebar(time / progress_timer);
		wait .01;
	}
}

randomize_task(left, center, right)
{
    available_tasks = available_tasks();
    possiblelist = self tasks_done(available_tasks);
    task = possiblelist[randomInt(possiblelist.size)];
    self.task_array[self.task_array.size] = task;
    if(possiblelist.size < 20)
        self.task_array = [];
    
    if(left)
        self start_task(task,1,0,0);
    
    if(center)
        self start_task(task,0,1,0);
    
    if(right)
        self start_task(task,0,0,1);
    
}

tasks_done(task)
{
    possiblelist = [];
    for(i = 0; i < task.size; i++)
    {
        if(!self has_done_task(task[i]))
            possiblelist[possiblelist.size] = task[i];
        
    }
    return possiblelist;
}

has_done_task(task)
{
    for(i = 0; i < self.task_array.size; i++)
    {
        if(self.task_array[i] == task)
            return 1;
        
    }
    return 0;
}

wait_end()
{
    self endon("task_done");
    level waittill("end_game");
    self destroy();
}

timer(left, center, right)
{
    self endon("end_task_progress");
    self endon("disconnect");
	level endon("end_game");
    self endon("death");
    long_task_timer = create_simple_hud( self );
    long_task_timer thread wait_end();
    if(left)
    {
        long_task_timer.alignx = "left";
        long_task_timer.aligny = "top";
        long_task_timer.horzalign = "user_left";
        long_task_timer.vertalign = "user_top";
        long_task_timer.x = 150;
    }
    if(center)
    {
        long_task_timer.alignx = "center";
        long_task_timer.aligny = "top";
        long_task_timer.horzalign = "user_center";
        long_task_timer.vertalign = "user_top";
        long_task_timer.x = 90;
    }
    if(right)
    {
        long_task_timer.alignx = "right";
        long_task_timer.aligny = "top";
        long_task_timer.horzalign = "user_right";
        long_task_timer.vertalign = "user_top";
        long_task_timer.x = -150;
    }
    long_task_timer.y = 21;
    long_task_timer.hidewheninmenu = 1;
    for(i=30;i>0;i--)
    {
        while(self maps\mp\zombies\_zm_laststand::player_is_in_laststand() || isdefined(self.afterlife) && self.afterlife)
        {
            wait .05;
        }
        if(self.task_timer == 0)
        {
            if(i == 20)
                long_task_timer.y += 21;
            
            if(i == 10)
                long_task_timer.y += 21;
            
        }
        if(self.task_timer == 1)
            if(i == 10)
                long_task_timer.y += 21;
            
        long_task_timer setValue( i );
        wait 1;
    }
	long_task_timer destroy();
    long_task_timer notify("task_done");
}

is_timed_task(task)
{
    if(task == &"Problems to run?" || task == &"Disable aim!" || task == &"who didnt pay the electric bill?" || task == &"Zoom Zoom Camera" || task == &"Lets Party!" || task == &"Need Glasses?" || task == &"Tbag"  || task == &"I Am So Tired" || task == &"Random Zombie Models" || task == &"Origins Mud" || task == &"Upgraded Mystery Box" || task == &"Caffinated" || task == &"Invincibility" || task == &"Bonfire Sale" || task == &"Annoying guns" || task == &"Extra Crispy" || task == &"Zombies Walk" || task == &"Bottomless Clip" || task == &"Out of Body Experience" || task == &"Old Fashioned" || task == &"Explosive Zombies" || task == &"Random Fov" || task == &"Super Jump" || task == &"Super Zombies" || task == &"Disable Powerups" || task == &"Where's That Zombie" || task == &"Raygun Always" || task == &"Headshots Only" || task == &"Flashing Zombies" || task == &"Low Gravity" || task == &"Random Guns" || task == &"Left Gun")
        return true;

    return false;
}

change_hud(user)
{
    user endon("disconnect");
    level endon("end_game");

    user waittill("scam_weapon");
    if(self.label == "Pack a punch Weapon ")
        self.label = &"Pack a Punch Weapon! Oh wait..";
}

start_task(task, left, center, right)
{
    self endon("disconnect");
	level endon("end_game");
    task_hud = create_simple_hud( self );
    if(center)
    {
        task_hud.alignx = "center";
        task_hud.aligny = "top";
        task_hud.horzalign = "user_center";
        task_hud.vertalign = "user_top";
        task_hud.x = 0;

        if(is_timed_task(task))
            self thread timer(0,1,0);
        
    }
    if(right)
    {
        task_hud.alignx = "right";
        task_hud.aligny = "top";
        task_hud.horzalign = "user_right";
        task_hud.vertalign = "user_top";
        task_hud.x = -5; 

        if(is_timed_task(task))
            self thread timer(0,0,1);
        
    }
    if(left)
    {
        task_hud.alignx = "left";
        task_hud.aligny = "top";
        task_hud.horzalign = "user_left";
        task_hud.vertalign = "user_top";
        task_hud.x = 5; 

        if(is_timed_task(task))
            self thread timer(1,0,0);
        
    }
    task_hud.point = "center";
	task_hud.hidewheninmenu = 1;
	task_hud.font = "default";
	task_hud.y = 0; 
	task_hud.archived = 0; 
	task_hud.fontscale = 1.3;
	task_hud.label = task;
    
    if(task == "Pack a punch Weapon ")
        task_hud thread change_hud(self);

    self.task_list[self.task_list.size] = task_hud;
    foreach(task_hud in self.task_list)
    {
        task_hud.y += 20;
    }
    for(i = 0; i < self.task_list.size; i++)
    {
        if(i > 3)
        {
            x = i - 4;
            self.task_list[x] destroy();
        }
    }
    if(task == &"Pack a punch weapon")
    {
        currgun = self getcurrentweapon();
        if(!is_weapon_upgraded(currgun) && can_upgrade_weapon( currgun ))
        {
            self playsound("zmb_cha_ching");
            self takeweapon(currgun);
            gun = self maps\mp\zombies\_zm_weapons::get_upgrade_weapon( currgun, 0 );
            self giveweapon(self maps\mp\zombies\_zm_weapons::get_upgrade_weapon( currgun, 0 ), 0, self get_pack_a_punch_weapon_options(gun));
            self switchToWeapon(gun);
        }
    }
    if(task == &"Unpack a punch weapon")
    {
        if( !self maps\mp\zombies\_zm_laststand::player_is_in_laststand() )
        {
            weap = self getcurrentweapon();
            weapon = maps\mp\zombies\_zm_weapons::get_base_weapon_name( weap, 1 );
            if ( isDefined( weapon ) && is_weapon_upgraded(weap))
            {
                self playsound("zmb_cha_ching");
                self takeweapon( weap );
                self giveweapon( weapon, 0, self maps\mp\zombies\_zm_weapons::get_pack_a_punch_weapon_options( weapon ) );
                self givestartammo( weapon );
                self switchtoweapon( weapon );
            }
        }
    }
    if(task == &"Turn Around")
        self setplayerangles( self.angles + (0,180,0));
    if(task == &"disable crouch")
        self allowcrouch( 0 );
    if(task == &"allow crouch")
        self allowcrouch( 1 );
    if(task == &"who didnt pay the electric bill?")
        self thread power_off();
    if(task == &"Full Ammo")
    {
        stockcount = self getweaponammostock( self GetCurrentWeapon() );
        self setWeaponAmmostock( self GetCurrentWeapon(), stockcount + 999 );
    }
    if(task == &"Origins Mud")
        self thread mud();
    if(task == &"I'm Feeling Lucky")
    {
        power_up = [];
        power_up[0] = "nuke";
        power_up[1] = "insta_kill";
        power_up[2] = "double_points";
        power_up[3] = "full_ammo";
        power_up[4] = "carpenter";
        self specific_powerup_drop(power_up[ randomintrange( 0, 5 )], self.origin );
    }
    if(task == &"Give Random Perk")
        self thread give_random_perk();
    if(task == &"Upgraded Mystery Box")
        self thread upgrade_box();
    if(task == &"Caffinated")
        self thread caffinated();
    if(task == &"Invincibility")
        self thread enable_god();
    if(task == &"Bonfire Sale")
        level thread start_bonfire_sale( self );
    if(task == &"Disable Powerups")
        level thread powerups();
    if(task == &"Double Points")
        self.score *= 2;
    if(task == &"Minus Points")
    {
        self.score -= (500 * level.round_number); 
        if(self.score < 0)
        {
            self.score = 0;
        }
    }
    if(task == &"Annoying guns")
    {
        self notify("annoying_guns");
        self thread annoying_guns_wait();
        self thread annoying_guns();
    }
    if(task == &"Extra Crispy")
        self thread crispy();
    if(task == &"Zombies Walk")
        level thread walk();
    if(task == &"Can We Get Perk Jingle?")
    {
        jingle = [];
        jingle[0] = "mus_perks_speed_jingle";
        jingle[1] = "mus_perks_juggernog_jingle";
        self playsound( jingle[ randomintrange( 0, 2 )]);
    }
    if(task == &"Extra Perk Slot")
        self.player_perk_purchase_limit += 1;
    if(task == &"Remove Current Clip")
        self setWeaponAmmoclip( self GetCurrentWeapon(), 0 );
    if(task == &"Bottomless Clip")
        self thread clip();
    if(task == &"Crawlers!")
    {
        enemy = getAiArray(level.zombie_team);
        foreach(zombie in enemy)
        {
            if(!zombie.forcedCrawler)
            {
                zombie.forcedCrawler = true;
                zombie.force_gib=true;
                zombie.a.gib_ref="no_legs";
                zombie.has_legs=false;
                zombie allowedStances("crouch");
                zombie.deathanim = zombie maps\mp\animscripts\zm_utility::append_missing_legs_suffix("zm_death");
                zombie.run_combatanim=level.scr_anim["zombie"]["crawl1"];
                zombie thread maps\mp\animscripts\zm_run::needsupdate();
                zombie thread maps\mp\animscripts\zm_death::do_gib();
            }
        }
    }
    if(task == &"Spawn Every Powerup")
    {
        self maps\mp\zombies\_zm_powerups::specific_powerup_drop( "nuke", self.origin + (75,0,0) );
        self maps\mp\zombies\_zm_powerups::specific_powerup_drop( "insta_kill", self.origin + (-75,0,0) );
        self maps\mp\zombies\_zm_powerups::specific_powerup_drop( "full_ammo", self.origin + (0,75,0) );
        self maps\mp\zombies\_zm_powerups::specific_powerup_drop( "double_points", self.origin + (0,-75,0) );
        self maps\mp\zombies\_zm_powerups::specific_powerup_drop( "carpenter", self.origin + (50,50,0) );
        self maps\mp\zombies\_zm_powerups::specific_powerup_drop( "fire_sale", self.origin + (-50,-50,0) );
        self maps\mp\zombies\_zm_powerups::specific_powerup_drop( "random_perk", self.origin + (50,-50,0) );
        self maps\mp\zombies\_zm_powerups::specific_powerup_drop( "zombie_blood", self.origin + (-50,50,0) );
    }
    if(task == &"Out of Body Experience")
        self thread out_of_body();
    if(task == &"Disoriantated")
        self thread Disoriantated();
    if(task == &"Old Fashioned")
        self thread old_fashioned();
    if(task == &"Break Barricades")
        level thread maps\mp\zombies\_zm_blockers::open_all_zbarriers();
    if(task == &"Lose Perk")
    {
        if ( !self maps\mp\zombies\_zm_laststand::player_is_in_laststand() && self.sessionstate != "spectator" )
            self maps\mp\zombies\_zm_perks::lose_random_perk();
        
    }
    if(task == &"I Like This One More")
    {
        weapons = self getweaponslistprimaries();
        if(self getcurrentweapon() == weapons[ 0 ])
            self switchtoweapon( weapons[ 1 ] );
        else
            self switchtoweapon( weapons[ 0 ] );
    }
    if(task == &"Jump Scared")
    {
        if(level.script == "zm_prison")
        {
            self playsoundtoplayer( "zmb_easteregg_face", self );
            wth_elem = newclienthudelem( self );
            wth_elem.horzalign = "fullscreen";
            wth_elem.vertalign = "fullscreen";
            wth_elem.sort = 1000;
            wth_elem.foreground = 0;
            wth_elem setshader( "zm_al_wth_zombie", 640, 480 );
            wth_elem.hidewheninmenu = 1;
            j_time = 0;
            while ( j_time < 15 )
            {
                j_time++;
                wait 0.05;
            }
            wth_elem destroy();
        }
        else
        {  
            self playsoundtoplayer( "zmb_easteregg_scarydog", self );
            wth_elem = newclienthudelem( self );
            wth_elem.horzalign = "fullscreen";
            wth_elem.vertalign = "fullscreen";
            wth_elem.sort = 1000;
            wth_elem.foreground = 0;
            wth_elem setshader( "zm_tm_wth_dog", 640, 480 );
            wth_elem.hidewheninmenu = 1;
            j_time = 0;
            while ( j_time < 15 )
            {
                j_time++;
                wait 0.05;
            }
            wth_elem destroy();
        }
    }
    if(task == &"I Thought You Had The Zombie?")
    {
        level thread change_round();
        ai = getaiarray( level.zombie_team );
        _a2225 = ai;
        _k2225 = getFirstArrayKey( _a2225 );
        while ( isDefined( _k2225 ) )
        {
            zombie = _a2225[ _k2225 ];
            if ( isDefined( zombie ) )
            {
                zombie dodamage( zombie.maxhealth + 666, zombie.origin, zombie, zombie, "none", "MOD_SUICIDE" );
                wait 0.05;
            }
            _k2225 = getNextArrayKey( _a2225, _k2225 );
        }
    }
    if(task == &"Fake Nuke")
    {
        playfx(loadfx( "misc/fx_zombie_mini_nuke_hotness"), self.origin + ( 0, 0, 20) );
        self thread nuke_flash();
    }
    if(task == &"Lost It's Flavor")
        self takeweapon(self getcurrentweapon());
    if(task == &"Randomize Door Prices")
    {
        zombie_doors = getentarray( "zombie_door", "targetname" );
        for(i = 0; i < zombie_doors.size; i++)
        {
            if(zombie_doors[i].script_noteworthy != "electric_door" && zombie_doors[i].script_noteworthy != "local_electric_door" && zombie_doors[i].script_noteworthy != "afterlife_door" )
            {
                zombie_doors[i].zombie_cost = (100 * randomIntRange(1, 41));
                zombie_doors[i] maps\mp\zombies\_zm_utility::set_hint_string( zombie_doors[i], "default_buy_door", zombie_doors[i].zombie_cost );
            }
        }
        zombie_airlock = getentarray( "zombie_airlock_buy", "targetname" );
        for(i = 0; i < zombie_doors.size; i++)
        {
            zombie_airlock[i].zombie_cost = (100 * randomIntRange(6, 51));
            zombie_airlock[i] maps\mp\zombies\_zm_utility::set_hint_string( zombie_airlock[i], "default_buy_door", zombie_airlock[i].zombie_cost );
        }
        zombie_debris = getentarray( "zombie_debris", "targetname" );
        for(i = 0; i < zombie_doors.size; i++)
        {
            zombie_debris[i].zombie_cost = (100 * randomIntRange(6, 51));
            zombie_debris[i] maps\mp\zombies\_zm_utility::set_hint_string( zombie_debris[i], "default_buy_door", zombie_debris[i].zombie_cost );
        }
    }
    if(task == &"Half Points")
        self.score = int(self.score / 2 );
    if(task == &"Gift Points")
        self.score += (1000 * level.round_number); 
    if(task == &"Randomize Wallbuy Prices")
    {
        normal = getArrayKeys(level.zombie_weapons);
        for(i = 0; i < normal.size; i++)
        {
            level.zombie_weapons[ normal[i] ].cost = (100 * randomIntRange(6, 31));
            level.zombie_weapons[ normal[i] ].ammo_cost = (100 * randomIntRange(6, 31));
        }
    }
    if(task == &"Explosive Zombies")
        self thread explosive_zombies();
    if(task == &"Spawn Clone")
        self clonePlayer(1);
    if(task == &"Random Fov")
        self thread set_fov();
    if(task == &"Oops Did I Drop It?")
        self dropitem(self getcurrentweapon());
    if(task == &"Lets Jump")
        self thread Trampoline();
    if(task == &"Who's Singing?")
    {
        level.music_override = 1;
        ent = spawn( "script_origin", self.origin );
        ent playsound("mus_zmb_secret_song");
    }
    if(task == &"Boss Time")
    {
        if(level.script == "zm_prison")
            level notify( "spawn_brutus", 1 );
        else
        {
            level.mechz_left_to_spawn++;
            level notify( "spawn_mechz" );
        }
    }
    if(task == &"Super Jump")
    {
        self thread super_jump();
        self thread super_jump_wait();
    }
    if(task == &"Super Zombies")
    {
        self thread super_melee();
        self thread super_melee_wait();
    }
    if(task == &"Headshots Only")
        self thread headshots();
    if(task == &"Where's That Zombie")
        self thread zombie_sound_loop();
    if(task == &"Raygun Always")
        self thread raygun_always();
    if(task == &"I Found Jugg")
    {
        jugg_machine = getentarray( "vending_jugg", "targetname" );
        jugg_machine_trigger = getentarray( "vending_jugg", "target" );
        jugg_machine[0].origin = self.origin;
        jugg_machine_trigger[0].origin = jugg_machine[0].origin + (0, 0, 10);
    }
    if(task == &"Need Glasses?")
        self thread need_glasses();
    if(task == &"All MP Perks")
    {
        if(!self.has_mp_perks)
        {
            self setperk( "specialty_armorpiercing" );
            self setperk( "specialty_bulletaccuracy" );
            self setperk( "specialty_bulletdamage" );
            self setperk( "specialty_bulletflinch" );
            self setperk( "specialty_bulletpenetration" );
            self setperk( "specialty_delayexplosive" );
            self setperk( "specialty_detectexplosive" );
            self setperk( "specialty_disarmexplosive" );
            self setperk( "specialty_earnmoremomentum" );
            self setperk( "specialty_explosivedamage" );
            self setperk( "specialty_extraammo" );
            self setperk( "specialty_fastads" );
            self setperk( "specialty_fastequipmentuse" );
            self setperk( "specialty_fastladderclimb" );
            self setperk( "specialty_fastmantle" );
            self setperk( "specialty_fastmeleerecovery" );
            self setperk( "specialty_fasttoss" );
            self setperk( "specialty_fastweaponswitch" );
            self setperk( "specialty_fireproof" );
            self setperk( "specialty_flashprotection" );
            self setperk( "specialty_gpsjammer" );
            self setperk( "specialty_healthregen" );
            self setperk( "specialty_holdbreath" );
            self setperk( "specialty_immunecounteruav" );
            self setperk( "specialty_immunemms" );
            self setperk( "specialty_immunenvthermal" );
            self setperk( "specialty_immunerangefinder" );
            self setperk( "specialty_killstreak" );
            self setperk( "specialty_loudenemies" );
            self setperk( "specialty_marksman" );
            self setperk( "specialty_movefaster" );
            self setperk( "specialty_noname" );
            self setperk( "specialty_nottargetedbyairsupport" );
            self setperk( "specialty_nokillstreakreticle" );
            self setperk( "specialty_nottargettedbysentry" );
            self setperk( "specialty_pin_back" );
            self setperk( "specialty_pistoldeath" );
            self setperk( "specialty_proximityprotection" );
            self setperk( "specialty_quieter" );
            self setperk( "specialty_reconnaissance" );
            self setperk( "specialty_showenemyequipment" );
            self setperk( "specialty_stunprotection" );
            self setperk( "specialty_shellshock" );
            self setperk( "specialty_sprintrecovery" );
            self setperk( "specialty_showonradar" );
            self setperk( "specialty_stalker" );
            self setperk( "specialty_twogrenades" );
            self setperk( "specialty_twoprimaries" );
            self.has_mp_perks = 1;
        }
        else
        {
            self.has_mp_perks = 0;
            self unsetperk( "specialty_armorpiercing" );
            self unsetperk( "specialty_bulletaccuracy" );
            self unsetperk( "specialty_bulletdamage" );
            self unsetperk( "specialty_bulletflinch" );
            self unsetperk( "specialty_bulletpenetration" );
            self unsetperk( "specialty_delayexplosive" );
            self unsetperk( "specialty_detectexplosive" );
            self unsetperk( "specialty_disarmexplosive" );
            self unsetperk( "specialty_earnmoremomentum" );
            self unsetperk( "specialty_explosivedamage" );
            self unsetperk( "specialty_extraammo" );
            self unsetperk( "specialty_fastads" );
            self unsetperk( "specialty_fastequipmentuse" );
            self unsetperk( "specialty_fastladderclimb" );
            self unsetperk( "specialty_fastmantle" );
            self unsetperk( "specialty_fastmeleerecovery" );
            self unsetperk( "specialty_fasttoss" );
            self unsetperk( "specialty_fastweaponswitch" );
            self unsetperk( "specialty_fireproof" );
            self unsetperk( "specialty_flashprotection" );
            self unsetperk( "specialty_gpsjammer" );
            self unsetperk( "specialty_healthregen" );
            self unsetperk( "specialty_holdbreath" );
            self unsetperk( "specialty_immunecounteruav" );
            self unsetperk( "specialty_immunemms" );
            self unsetperk( "specialty_immunenvthermal" );
            self unsetperk( "specialty_immunerangefinder" );
            self unsetperk( "specialty_killstreak" );
            self unsetperk( "specialty_loudenemies" );
            self unsetperk( "specialty_marksman" );
            self unsetperk( "specialty_movefaster" );
            self unsetperk( "specialty_noname" );
            self unsetperk( "specialty_nottargetedbyairsupport" );
            self unsetperk( "specialty_nokillstreakreticle" );
            self unsetperk( "specialty_nottargettedbysentry" );
            self unsetperk( "specialty_pin_back" );
            self unsetperk( "specialty_pistoldeath" );
            self unsetperk( "specialty_proximityprotection" );
            self unsetperk( "specialty_quieter" );
            self unsetperk( "specialty_reconnaissance" );
            self unsetperk( "specialty_showenemyequipment" );
            self unsetperk( "specialty_stunprotection" );
            self unsetperk( "specialty_shellshock" );
            self unsetperk( "specialty_sprintrecovery" );
            self unsetperk( "specialty_showonradar" );
            self unsetperk( "specialty_stalker" );
            self unsetperk( "specialty_twogrenades" );
            self unsetperk( "specialty_twoprimaries" );
        }
    }
    if(task == &"Left Gun")
        self thread left_gun();
    if(task == &"Flashing Zombies")
        self thread flash_zombies();
    if(task == &"Low Gravity")
        self thread gravity();
    if(task == &"Random Guns")
        self thread gungame();
    if(task == &"Fake End Game")
        self thread fake_end_game();
    if(task == &"Earthquake")
        earthquake( 0.9, 15, self.origin, 100000 );
    if(task == &"Random Zombie Models")
        self thread randomize_zombies_models();
    if(task == &"I Am So Tired")
        self thread tired();
    if(task == &"Make Over")
        self thread makeover();
    if(task == &"Randomized Perk Locations")
        level thread Randomize_Perk_locations();
    if(task == &"Lets Party!")
		self thread Disco_sun();
	if(task == &"Tbag")
		self thread tbag();
    if(task == &"Zoom Zoom Camera")
		self thread zoom_camera();
    if(task == &"Randomize Perk Prices")
		thread randomize_perk_prices();
    if(task == &"I Found PAP")
		self thread i_found_pap();
    if(task == &"Lose Perk Slot")
        self.player_perk_purchase_limit -= 1;
    if(task == &"Pack a punch Weapon ")
        self thread pack_scam();
    if(task == &"Eww! SMR")
        self weapon_give("saritch_zm", 0);
    if(task == &"Take this ray gun!")
    {
        self weapon_give("ray_gun_zm", 0);
        self setweaponammoclip( "ray_gun_zm", 0 );
        self setweaponammostock( "ray_gun_zm", 0 );
    }
    if(task == &"Disable aim!")
        self thread disable_aim();
    if(task == &"Problems to run?")
        self thread sprinting_issues();
}

available_tasks()
{
	available_tasks = [];
    
    if(level.round_number > 5)
    {
        available_tasks[available_tasks.size] = &"Minus Points";
    	available_tasks[available_tasks.size] = &"Lose Perk";
        available_tasks[available_tasks.size] = &"Half Points";
    }
    if(level.round_number > 10)
    {
        available_tasks[available_tasks.size] = &"Random Guns";
        available_tasks[available_tasks.size] = &"Fake End Game";
    	available_tasks[available_tasks.size] = &"Lost It's Flavor";
	    available_tasks[available_tasks.size] = &"Unpack a punch weapon";
    }
    if(!self.crouch_disabled)
    {
        available_tasks[available_tasks.size] = &"disable crouch";
        self.crouch_disabled = 1;
    }
    else
    {
        self.crouch_disabled = 0;
        available_tasks[available_tasks.size] = &"allow crouch";
    }
    if ( flag( "power_on" ) )
        available_tasks[available_tasks.size] = &"who didnt pay the electric bill?";
    
    if(getdvar( "mapname" ) != "zm_prison")
	    available_tasks[available_tasks.size] = &"Annoying guns";
    
    if(getdvar( "mapname" ) == "zm_prison" || getdvar( "mapname" ) == "zm_tomb")
    {
    	available_tasks[available_tasks.size] = &"Jump Scared";
        
        if(level.round_number > 5)
            available_tasks[available_tasks.size] = &"Boss Time";
    }
    if(getdvar( "mapname" ) == "zm_transit")
	    available_tasks[available_tasks.size] = &"Extra Crispy";
    
    if(get_players().size == 1)
    {
        available_tasks[available_tasks.size] = &"Headshots Only";
        available_tasks[available_tasks.size] = &"Flashing Zombies";
        available_tasks[available_tasks.size] = &"Who's Singing?";
    }

    available_tasks[available_tasks.size] = &"Low Gravity";
    available_tasks[available_tasks.size] = &"Left Gun";
    available_tasks[available_tasks.size] = &"Raygun Always";
    available_tasks[available_tasks.size] = &"Need Glasses?";
	available_tasks[available_tasks.size] = &"Pack a punch weapon";
	available_tasks[available_tasks.size] = &"Turn Around";
	available_tasks[available_tasks.size] = &"Full Ammo";
    available_tasks[available_tasks.size] = &"Origins Mud";
	available_tasks[available_tasks.size] = &"I'm Feeling Lucky";
	available_tasks[available_tasks.size] = &"Give Random Perk";
    available_tasks[available_tasks.size] = &"Upgraded Mystery Box";
	available_tasks[available_tasks.size] = &"Caffinated";
    available_tasks[available_tasks.size] = &"Invincibility";
	available_tasks[available_tasks.size] = &"Bonfire Sale";
	available_tasks[available_tasks.size] = &"Double Points";
    available_tasks[available_tasks.size] = &"Disable Powerups";
    available_tasks[available_tasks.size] = &"Zombies Walk";
    available_tasks[available_tasks.size] = &"Can We Get Perk Jingle?";
	available_tasks[available_tasks.size] = &"Extra Perk Slot";
	available_tasks[available_tasks.size] = &"Remove Current Clip";
	available_tasks[available_tasks.size] = &"Bottomless Clip";
    available_tasks[available_tasks.size] = &"Crawlers!";
	available_tasks[available_tasks.size] = &"Spawn Every Powerup";
	available_tasks[available_tasks.size] = &"Out of Body Experience";
	available_tasks[available_tasks.size] = &"Old Fashioned";
    available_tasks[available_tasks.size] = &"Break Barricades";
	available_tasks[available_tasks.size] = &"I Like This One More";
    available_tasks[available_tasks.size] = &"I Thought You Had The Zombie?";
	available_tasks[available_tasks.size] = &"Fake Nuke";
	available_tasks[available_tasks.size] = &"Randomize Door Prices";
    available_tasks[available_tasks.size] = &"Gift Points";
    available_tasks[available_tasks.size] = &"Randomize Wallbuy Prices";
    available_tasks[available_tasks.size] = &"Explosive Zombies";
    available_tasks[available_tasks.size] = &"Spawn Clone";
    available_tasks[available_tasks.size] = &"Random Fov";
    available_tasks[available_tasks.size] = &"Oops Did I Drop It?";
    available_tasks[available_tasks.size] = &"Lets Jump";
    available_tasks[available_tasks.size] = &"Super Jump";
    available_tasks[available_tasks.size] = &"Super Zombies";
    available_tasks[available_tasks.size] = &"Where's That Zombie";
    available_tasks[available_tasks.size] = &"I Found Jugg";
    available_tasks[available_tasks.size] = &"All MP Perks";
    available_tasks[available_tasks.size] = &"Earthquake";
    available_tasks[available_tasks.size] = &"Random Zombie Models";
    available_tasks[available_tasks.size] = &"I Am So Tired";
    available_tasks[available_tasks.size] = &"Make Over";
    available_tasks[available_tasks.size] = &"Lose Perk Slot";
    available_tasks[available_tasks.size] = &"Zoom Zoom Camera";
    available_tasks[available_tasks.size] = &"Lets Party!";
    available_tasks[available_tasks.size] = &"Tbag";
    available_tasks[available_tasks.size] = &"Randomize Perk Prices";
    available_tasks[available_tasks.size] = &"Pack a punch Weapon ";

    if((getdvar( "mapname" ) == "zm_transit" && getdvar ( "g_gametype")  == "zclassic") || getdvar( "mapname" ) == "zm_tomb" || getdvar( "mapname" ) == "zm_buried") // *|| level.script == "zm_prison"
        available_tasks[available_tasks.size] = &"Randomized Perk Locations";
        
    if(getdvar( "mapname" ) == "zm_transit" && getdvar ( "g_gametype")  == "zclassic")
    {
        if(is_true(level.buildables_built[ "pap" ]))
            available_tasks[available_tasks.size] = &"I Found PAP";
    }    
    else if(getdvar( "mapname" ) != "zm_tomb")
        available_tasks[available_tasks.size] = &"I Found PAP";
    
    if(getdvar( "mapname" ) != "zm_tomb" && getdvar( "mapname" ) != "zm_prison")
        available_tasks[available_tasks.size] = &"Eww! SMR";

    available_tasks[available_tasks.size] = &"Take this ray gun!";
    available_tasks[available_tasks.size] = &"Disable aim!";
    available_tasks[available_tasks.size] = &"Problems to run?";

	return available_tasks;
}

power_off()
{
    if(flag("power_on"))
    {
        level.local_doors_stay_open = 0;
        level.power_local_doors_globally = 0;
        flag_clear( "power_on" );
        level setclientfield( "zombie_power_on", 0 );
        wait 30;
        level maps\mp\zombies\_zm_game_module::turn_power_on_and_open_doors();
    }
}

give_random_perk()
{
	random_perk = undefined;
	vending_triggers = getentarray( "zombie_vending", "targetname" );
	perks = [];
	if (getdvar("mapname") == "zm_tomb" && !self hasperk( "specialty_rof" ) && !self has_perk_paused( "specialty_rof" ))
		perks[perks.size] = "specialty_rof";
	
	if (getdvar("mapname") == "zm_tomb" && !self hasperk( "specialty_deadshot" ) && !self has_perk_paused( "specialty_deadshot" ))
		perks[perks.size] = "specialty_deadshot";
	
	if (getdvar("mapname") == "zm_tomb" && !self hasperk( "specialty_flakjacket" ) && !self has_perk_paused( "specialty_flakjacket" ))
		perks[perks.size] = "specialty_flakjacket";
	
	if (getdvar("mapname") == "zm_tomb" && !self hasperk( "specialty_grenadepulldeath" ) && !self has_perk_paused( "specialty_grenadepulldeath" ))
		perks[perks.size] = "specialty_grenadepulldeath";
	
	i = 0;
	while ( i < vending_triggers.size )
	{
		perk = vending_triggers[ i ].script_noteworthy;
		if( isDefined( self.perk_purchased ) && self.perk_purchased == perk )
		{
			i++;
			continue;
		}
		if( perk == "specialty_weapupgrade" )
		{
			i++;
			continue;
		}
		if( !self hasperk( perk ) && !self has_perk_paused( perk ) )
			perks[ perks.size ] = perk;
		
		i++;
	}
	if( perks.size > 0 )
	{
		perks = array_randomize( perks );
		random_perk = perks[ 0 ];
		self give_perk( random_perk );
	}
	else
	{
		self playsoundtoplayer( level.zmb_laugh_alias, self );
		self.score += 500;
	}
	return random_perk;
}

upgrade_box()
{
    self endon("disconnect");
	level endon("end_game");
    self endon("end_task_progress");
    self.upgraded_box = 1;
    for(i=0;i<60;i++)
    {
        while(self maps\mp\zombies\_zm_laststand::player_is_in_laststand() || isdefined(self.afterlife) && self.afterlife)
        {
            wait .05;
        }
        wait .5;
    }
    self.upgraded_box = 0;
}

CheckForCurrentBox()
{
	flag_wait( "initial_blackscreen_passed" );
    if( getdvar( "mapname" ) == "zm_nuked" || getdvar( "mapname" ) == "zm_tomb" )
    {
        wait 10;
    }
    for(i = 0; i < level.chests.size; i++)
    {
        level.chests[ i ] thread reset_box();
		if(level.chests[ i ].hidden)
			level.chests[ i ] get_chest_pieces();
    	
		if(!level.chests[ i ].hidden)
			level.chests[ i ].unitrigger_stub.prompt_and_visibility_func = ::boxtrigger_update_prompt;
		
	}
}

reset_box()
{
	self notify("kill_chest_think");
    wait .1;
	if(!self.hidden)
    {
		self.grab_weapon_hint = 0;
		self thread maps\mp\zombies\_zm_unitrigger::register_static_unitrigger( self.unitrigger_stub, ::magicbox_unitrigger_think );
    	self.unitrigger_stub run_visibility_function_for_all_triggers();
	}
	self thread custom_treasure_chest_think();
}

custom_treasure_chest_think()
{
	level endon("end_game");
	self endon( "kill_chest_think" );
	user = undefined;
	user_cost = undefined;
	self.box_rerespun = undefined;
	self.weapon_out = undefined;
	self thread unregister_unitrigger_on_kill_think();
	while ( 1 )
	{
		if ( !isdefined( self.forced_user ) )
		{
			self waittill( "trigger", user );
			if ( user == level )
			{
				wait 0.1;
				continue;
			}
		}
		else
		{
			user = self.forced_user;
		}
		if ( user in_revive_trigger() )
		{
			wait 0.1;
			continue;
		}
		if ( user.is_drinking > 0 )
		{
			wait 0.1;
			continue;
		}
		if ( isdefined( self.disabled ) && self.disabled )
		{
			wait 0.1;
			continue;
		}
		if ( user getcurrentweapon() == "none" )
		{
			wait 0.1;
			continue;
		}
		reduced_cost = undefined;
		if ( is_player_valid( user ) && user maps\mp\zombies\_zm_pers_upgrades_functions::is_pers_double_points_active() )
		{
			reduced_cost = int( self.zombie_cost / 2 );
		}
		if ( isdefined( level.using_locked_magicbox ) && level.using_locked_magicbox && isdefined( self.is_locked ) && self.is_locked ) 
		{
			if ( user.score >= level.locked_magic_box_cost )
			{
				user maps\mp\zombies\_zm_score::minus_to_player_score( level.locked_magic_box_cost );
				self.zbarrier set_magic_box_zbarrier_state( "unlocking" );
				self.unitrigger_stub run_visibility_function_for_all_triggers();
			}
			else
			{
				user maps\mp\zombies\_zm_audio::create_and_play_dialog( "general", "no_money_box" );
			}
			wait 0.1 ;
			continue;
		}
		else if ( isdefined( self.auto_open ) && is_player_valid( user ) )
		{
			if ( !isdefined( self.no_charge ) )
			{
				user maps\mp\zombies\_zm_score::minus_to_player_score( self.zombie_cost );
				user_cost = self.zombie_cost;
			}
			else
			{
				user_cost = 0;
			}
			self.chest_user = user;
			break;
		}
		else if ( is_player_valid( user ) && user.score >= self.zombie_cost )
		{
			user maps\mp\zombies\_zm_score::minus_to_player_score( self.zombie_cost );
			user_cost = self.zombie_cost;
			self.chest_user = user;
			break;
		}
		else if ( isdefined( reduced_cost ) && user.score >= reduced_cost )
		{
			user maps\mp\zombies\_zm_score::minus_to_player_score( reduced_cost );
			user_cost = reduced_cost;
			self.chest_user = user;
			break;
		}
		else if ( user.score < self.zombie_cost )
		{
			play_sound_at_pos( "no_purchase", self.origin );
			user maps\mp\zombies\_zm_audio::create_and_play_dialog( "general", "no_money_box" );
			wait 0.1;
			continue;
		}
		wait 0.05;
	}
	flag_set( "chest_has_been_used" );
	maps\mp\_demo::bookmark( "zm_player_use_magicbox", getTime(), user );
	user maps\mp\zombies\_zm_stats::increment_client_stat( "use_magicbox" );
	user maps\mp\zombies\_zm_stats::increment_player_stat( "use_magicbox" );
	if ( isDefined( level._magic_box_used_vo ) )
	{
		user thread [[ level._magic_box_used_vo ]]();
	}
	self thread watch_for_emp_close();
	if ( isDefined( level.using_locked_magicbox ) && level.using_locked_magicbox )
	{
		self thread custom_watch_for_lock();
	}
	self._box_open = 1;
	level.box_open = 1;
	self._box_opened_by_fire_sale = 0;
	if ( isDefined( level.zombie_vars[ "zombie_powerup_fire_sale_on" ] ) && level.zombie_vars[ "zombie_powerup_fire_sale_on" ] && !isDefined( self.auto_open ) && self [[ level._zombiemode_check_firesale_loc_valid_func ]]() )
	{
		self._box_opened_by_fire_sale = 1;
	}
	if ( isDefined( self.chest_lid ) )
	{
		self.chest_lid thread treasure_chest_lid_open();
	}
	if ( isDefined( self.zbarrier ) )
	{
		play_sound_at_pos( "open_chest", self.origin );
		play_sound_at_pos( "music_chest", self.origin );
		self.zbarrier set_magic_box_zbarrier_state( "open" );
	}
	self.timedout = 0;
	self.weapon_out = 1;
	self.zbarrier thread treasure_chest_weapon_spawn( self, user );
	self.zbarrier thread treasure_chest_glowfx();
	thread maps\mp\zombies\_zm_unitrigger::unregister_unitrigger( self.unitrigger_stub );
	self.zbarrier waittill_any( "randomization_done", "box_hacked_respin" );
	if ( flag( "moving_chest_now" ) && !self._box_opened_by_fire_sale && isDefined( user_cost ) )
	{
		user maps\mp\zombies\_zm_score::add_to_player_score( user_cost, 0 );
	}
	if ( flag( "moving_chest_now" ) && !level.zombie_vars[ "zombie_powerup_fire_sale_on" ] && !self._box_opened_by_fire_sale )
	{
		self thread treasure_chest_move( self.chest_user );
	}
	else
	{
		self.grab_weapon_hint = 1;
		self.grab_weapon_name = self.zbarrier.weapon_string;
		self.chest_user = user;
		thread maps\mp\zombies\_zm_unitrigger::register_static_unitrigger( self.unitrigger_stub, ::magicbox_unitrigger_think );
		if ( isDefined( self.zbarrier ) && !is_true( self.zbarrier.closed_by_emp ) )
		{
			self thread treasure_chest_timeout();
		}
		timeout_time = 105;
		grabber = user;
		for( i=0;i<105;i++ )
		{
            if(grabber usebuttonpressed() && isplayer( grabber ) && user == grabber && distance(self.origin, grabber.origin) <= 100 && isDefined( grabber.is_drinking ) && !grabber.is_drinking)
			{
                if(grabber.upgraded_box)
                {
                    if(maps\mp\zombies\_zm_weapons::can_upgrade_weapon( self.zbarrier.weapon_string ))
                    {
                        grabber thread treasure_chest_give_weapon( grabber maps\mp\zombies\_zm_weapons::get_upgrade_weapon( self.zbarrier.weapon_string ) );
                    }
                    else
                    {
                        grabber thread treasure_chest_give_weapon( self.zbarrier.weapon_string );
                    }
                }
                else
                {
                    grabber thread treasure_chest_give_weapon( self.zbarrier.weapon_string );
                }
                break;
            }
			wait 0.1;
		}
		self.weapon_out = undefined;
		self notify( "user_grabbed_weapon" );
		user notify( "user_grabbed_weapon" );
		self.grab_weapon_hint = 0;
		self.zbarrier notify( "weapon_grabbed" );
		if ( isDefined( self._box_opened_by_fire_sale ) && !self._box_opened_by_fire_sale )
		{
			level.chest_accessed += 1;
		}
		if ( level.chest_moves > 0 && isDefined( level.pulls_since_last_ray_gun ) )
		{
			level.pulls_since_last_ray_gun += 1;
		}
		if ( isDefined( level.pulls_since_last_tesla_gun ) )
		{
			level.pulls_since_last_tesla_gun += 1;
		}
		thread maps\mp\zombies\_zm_unitrigger::unregister_unitrigger( self.unitrigger_stub );
		if ( isDefined( self.chest_lid ) )
		{
			self.chest_lid thread treasure_chest_lid_close( self.timedout );
		}
		if ( isDefined( self.zbarrier ) )
		{
			self.zbarrier set_magic_box_zbarrier_state( "close" );
			play_sound_at_pos( "close_chest", self.origin );
			self.zbarrier waittill( "closed" );
			wait 1;
		}
		else
		{
			wait 3;
		}
		if ( isDefined( level.zombie_vars[ "zombie_powerup_fire_sale_on" ] ) && level.zombie_vars[ "zombie_powerup_fire_sale_on" ] || self [[ level._zombiemode_check_firesale_loc_valid_func ]]() || self == level.chests[ level.chest_index ] )
		{
			thread maps\mp\zombies\_zm_unitrigger::register_static_unitrigger( self.unitrigger_stub, ::magicbox_unitrigger_think );
		}
	}
	self._box_open = 0;
	level.box_open = 0;
	level.shared_box = 0;
	self._box_opened_by_fire_sale = 0;
	self.chest_user = undefined;
	self notify( "chest_accessed" );
	self thread custom_treasure_chest_think();
}

custom_watch_for_lock()
{
    self endon( "user_grabbed_weapon" );
    self endon( "chest_accessed" );
    self waittill( "box_locked" );
    self notify( "kill_chest_think" );
    self.grab_weapon_hint = 0;
    wait 0.1;
    self thread maps\mp\zombies\_zm_unitrigger::register_static_unitrigger( self.unitrigger_stub, ::magicbox_unitrigger_think );
    self.unitrigger_stub run_visibility_function_for_all_triggers();
    self thread custom_treasure_chest_think();
}

caffinated()
{
    self endon("end_task_progress");
    self endon("disconnect");
	level endon("end_game");
    self setmovespeedscale(3);
    for(i=0;i<60;i++)
    {
        while(self maps\mp\zombies\_zm_laststand::player_is_in_laststand() || isdefined(self.afterlife) && self.afterlife)
        {
            wait .05;
        }
        wait .5;
    }
    self setmovespeedscale(1);
}

Mud()
{
    self endon("end_task_progress");
    self endon("disconnect");
	level endon("end_game");
    self setmovespeedscale(0.5);
    for(i=0;i<60;i++)
    {
        while(self maps\mp\zombies\_zm_laststand::player_is_in_laststand() || isdefined(self.afterlife) && self.afterlife)
        {
            wait .05;
        }
        wait .5;
    }
    self setmovespeedscale(1);
}

enable_god()
{
    self endon("disconnect");
	level endon("end_game");
    self endon("end_task_progress");
    self enableInvulnerability();
    self.god_enabled = 1;
    for(i=0;i<60;i++)
    {
        while(self maps\mp\zombies\_zm_laststand::player_is_in_laststand() || isdefined(self.afterlife) && self.afterlife)
        {
            self.god_enabled = 0;
            wait .05;
        }
        if(isdefined(self.god_enabled) && !self.god_enabled)
        {
            self.god_enabled = 1;
            self enableInvulnerability();
        }
        wait .5;
    }
    self disableInvulnerability();
    self.god_enabled = 0;
}

powerups()
{
    self endon("disconnect");
	level endon("end_game");
    self endon("end_task_progress");
    if( flag( "zombie_drop_powerups" ) )
    {
        flag_clear( "zombie_drop_powerups" );
        for(i=0;i<60;i++)
        {
            while(self maps\mp\zombies\_zm_laststand::player_is_in_laststand() || isdefined(self.afterlife) && self.afterlife)
            {
                wait .05;
            }
            wait .5;
        }
        flag_set( "zombie_drop_powerups" );
    }
}

annoying_guns()
{
    self endon("disconnect");
	level endon("end_game");
    self endon("end_task_progress");
    self endon("annoying_guns");
    weapon = self getcurrentweapon();
    for( ;; )
    {
        while(self maps\mp\zombies\_zm_laststand::player_is_in_laststand() || isdefined(self.afterlife) && self.afterlife)
        {
            wait .05;
        }
        self waittill("weapon_fired", weapon);
        self playsound( "zmb_vox_monkey_scream" );
    }
}

annoying_guns_wait()
{
    self endon("disconnect");
	level endon("end_game");
    self endon("end_task_progress");
    for(i=0;i<60;i++)
    {
        while(self maps\mp\zombies\_zm_laststand::player_is_in_laststand() || isdefined(self.afterlife) && self.afterlife)
        {
            wait .05;
        }
        wait .5;
    }
    self notify("annoying_guns");
}

crispy()
{
    self endon("disconnect");
	level endon("end_game");
    self endon("end_task_progress");
    self.burning = 0;
    for(i=0;i<30;i++)
    {
        while(self maps\mp\zombies\_zm_laststand::player_is_in_laststand() || isdefined(self.afterlife) && self.afterlife)
        {
            wait .05;
        }
        maps\mp\_visionset_mgr::vsmgr_activate("overlay", "zm_transit_burn", self, 1, 1);

        if(isDefined(self.burning) && !self.burning)
            self thread player_burning_audio();

        self.burning = 1;
        wait 1;
    }
    self.burning = 0;
    self notify("stop_flame_sounds");
}

player_burning_audio()
{
    level endon("end_game");
	fire_ent = spawn( "script_model", self.origin );
	wait 1;
	fire_ent linkto( self );
	fire_ent playloopsound( "evt_plr_fire_loop" );
	self waittill_any( "stop_flame_damage", "stop_flame_sounds", "death", "disconnect" );
	fire_ent delete();
}

walk()
{
    self endon("disconnect");
	level endon("end_game");
    self endon("end_task_progress");
    for(i=0;i<30;i++)
    {
        while(self maps\mp\zombies\_zm_laststand::player_is_in_laststand() || isdefined(self.afterlife) && self.afterlife)
        {
            wait .05;
        }
        foreach(zombie in getaiarray(level.zombie_team))
        {
            if(!isDefined(zombie.done))
                zombie.done = 0;

            if(!zombie.done)
            {
                zombie.done = 1;
                zombie maps\mp\zombies\_zm_utility::set_zombie_run_cycle("walk");
            }
        }
        wait 1;
    }

    foreach(zombie in getaiarray(level.zombie_team))
        if(isDefined(zombie.done) && zombie.done) 
            zombie.done = 0;
}

clip()
{
    self endon("disconnect");
	level endon("end_game");
    self endon("end_task_progress");
    for(i=0;i<600;i++)
    {
        while(self maps\mp\zombies\_zm_laststand::player_is_in_laststand() || isdefined(self.afterlife) && self.afterlife)
        {
            wait .05;
        }
        self setWeaponAmmoclip( self GetCurrentWeapon(), 999 );
        wait .05;
    }
}

out_of_body()
{
    self endon("disconnect");
	level endon("end_game");
    self endon("end_task_progress");
    self set_third_person( 1 );
    for(i=0;i<60;i++)
    {
        while(self maps\mp\zombies\_zm_laststand::player_is_in_laststand() || isdefined(self.afterlife) && self.afterlife)
        {
            wait .05;
        }
        wait .5;
    }
    self set_third_person( 0 );
    wait .1;
    self resetfov();
}

Disoriantated()
{
    if(!isdefined(self.last_location))
        self.last_location = (0,0,0);
    
    locations = array((-6852.98,4944.63,-53.875), (5218.29,6870.22,-20.8699), (763.336,-482.006,-61.875), (10958.1,7579.58,-592.101), (-5306.84,-7328.29,-56.5403));
    self.next_location = array_randomize(locations);

	if( self.next_location[0] == self.last_location && distance(self.origin, self.next_location[0]) < 1500 )
		self thread Disoriantated();
	else
	{
		self.last_location = self.next_location[0];
		self setorigin(self.next_location[0]);
	}
}

old_fashioned()
{
    self endon("disconnect");
	level endon("end_game");
    self endon("end_task_progress");
    self useServerVisionSet(true);
	self setVisionSetforPlayer("zombie_last_stand", 0);
    for(i=0;i<60;i++)
    {
        while(self maps\mp\zombies\_zm_laststand::player_is_in_laststand() || isdefined(self.afterlife) && self.afterlife)
        {
            wait .05;
        }
        wait .5;
    }
    self useServerVisionSet(false);
}

nuke_flash( team )
{
	if ( isDefined( team ) )
		get_players()[ 0 ] playsoundtoteam( "evt_nuke_flash", team );
	else
		get_players()[ 0 ] playsound( "evt_nuke_flash" );
	
	fadetowhite = newhudelem();
	fadetowhite.x = 0;
	fadetowhite.y = 0;
	fadetowhite.alpha = 0;
	fadetowhite.horzalign = "fullscreen";
	fadetowhite.vertalign = "fullscreen";
	fadetowhite.foreground = 1;
	fadetowhite setshader( "white", 640, 480 );
	fadetowhite fadeovertime( 0.2 );
	fadetowhite.alpha = 0.8;
	wait 0.5;
	fadetowhite fadeovertime( 1 );
	fadetowhite.alpha = 0;
	wait 1.1;
	fadetowhite destroy();
}

explosive_zombies()
{
    self endon("disconnect");
	level endon("end_game");
    self endon("end_task_progress");
    level.explosive_zombies = 1;
    for(i=0;i<60;i++)
    {
        while(self maps\mp\zombies\_zm_laststand::player_is_in_laststand() || isdefined(self.afterlife) && self.afterlife)
        {
            wait .05;
        }
        zombies = getaiarray(level.zombie_team);
        for(x=0;x<zombies.size;x++) 
        {
            if(distance(zombies[x].origin, self.origin) < 50 && level.explosive_zombies)
            {
                zombies[x] radiusdamage(zombies[x].origin, 70, (self.maxhealth / 2), (self.maxhealth / 3));
                playfx(loadfx("explosions/fx_default_explosion"), zombies[x].origin );
            }
        }
        wait .5;
    }
    level.explosive_zombies = 0;
}

set_fov()
{
    self endon("disconnect");
	level endon("end_game");
    self endon("end_task_progress");
    self setclientfov(randomint(150)); 
    for(i=0;i<60;i++)
    {
        while(self maps\mp\zombies\_zm_laststand::player_is_in_laststand() || isdefined(self.afterlife) && self.afterlife)
        {
            wait .05;
        }
        wait .5;
    }
    self resetfov();
}

Trampoline()
{
    self endon("disconnect");
	level endon("end_game");
    self endon("end_task_progress");
	atf =  AnglesToForward(self getPlayerAngles());
    while(self maps\mp\zombies\_zm_laststand::player_is_in_laststand() || isdefined(self.afterlife) && self.afterlife)
    {
        wait .05;
    }
    if( self isOnGround())
    {
        atf = AnglesToForward(self getPlayerAngles());
        self setOrigin(self.origin);
        self setVelocity( ( self GetVelocity() + ( (atf[0] * 350), (atf[1] * 350), 1937 ) ) );
        self setVelocity( ( self GetVelocity() + ( 0, 0, 1937 ) ) );
        wait .05;
        self setVelocity( ( self GetVelocity() + ( 0, 0, 1937 ) ) );
        wait .05;
        self setVelocity( ( self GetVelocity() + ( 0, 0, 1937 ) ) );
        wait .05;
    }
}

super_jump()
{
    self endon("disconnect");
	level endon("end_game");
    self endon("end_task_progress");
    self.jump_active = 1;
    while(self.jump_active)
    {
        while(self maps\mp\zombies\_zm_laststand::player_is_in_laststand() || isdefined(self.afterlife) && self.afterlife)
        {
            wait .05;
        }
        if(self JumpButtonPressed())
        {
            for(i = 0; i < 5; i++)
            {
                self setVelocity(self getVelocity()+(0, 0, 999));
                wait .05;
            }
            while(!self isonground())
            {
                wait .1;
            } 
        }       

        wait .05;
    }
}

super_jump_wait()
{
    self endon("disconnect");
	level endon("end_game");
    self endon("end_task_progress");
    for(i=0;i<600;i++)
    {
        while(self maps\mp\zombies\_zm_laststand::player_is_in_laststand() || isdefined(self.afterlife) && self.afterlife)
        {
            wait .05;
        }
        wait .05;
    }
    self.jump_active = 0;
}

super_melee()
{
    self endon("super_zombies");
    self endon("death");
    self endon("end_task_progress");
    self.super_melee_on = 1;
	while(isdefined(self.super_melee_on) && self.super_melee_on )
	{
		self waittill( "damage", amount, attacker, dir, point, mod );
		if( isDefined(attacker.is_zombie) && attacker.is_zombie )
		{
			self setorigin( self.origin );
			self SetVelocity( ((AnglesToForward(VectorToAngles(self Getorigin() - attacker GetOrigin())) + (0,0,5)) * (1337,1337,350)) );
		}
        wait .5;
	}
}

super_melee_wait()
{
    self endon("disconnect");
	level endon("end_game");
    self endon("death");
    self endon("end_task_progress");
	for(i=0;i<60;i++)
	{
        while(self maps\mp\zombies\_zm_laststand::player_is_in_laststand() || isdefined(self.afterlife) && self.afterlife)
        {
            wait .05;
        }
        wait .5;
	}
    self.super_melee_on = 0;
    self notify("super_zombies");
}

change_round()
{
    level.time_bomb_round_change = 1;
    level.zombie_round_start_delay = 0;
    level.time_bomb_round_change = 0;
    level._time_bomb.round_initialized = 1;
    level notify( "end_of_round" );
    flag_set( "end_round_wait" );
    if ( level._time_bomb.round_initialized )
        level._time_bomb.restoring_initialized_round = 1;
    
    level waittill( "between_round_over" );
    level.zombie_round_start_delay = undefined;
    level.time_bomb_round_change = undefined;
    flag_clear( "end_round_wait" );
}

zombie_sound_loop()
{
    self endon("disconnect");
	level endon("end_game");
    self endon("death");
    self endon("end_task_progress");
    alias = level.zmb_vox[ "prefix" ] + level.zmb_vox[ "zombie" ][ "crawler" ];
    for(i=0;i<10;i++)
    {
        self playsound(alias);
        wait 3;
    }
}

headshots()
{
    self endon("disconnect");
	level endon("end_game");
    self endon("death");
    self endon("end_task_progress");
    level.headshots_only = 1;
    for(i=0;i<60;i++)
	{
        while(self maps\mp\zombies\_zm_laststand::player_is_in_laststand() || isdefined(self.afterlife) && self.afterlife)
        {
            wait .05;
        }
        wait .5;
	}
    level.headshots_only = 0;
}

raygun_always()
{
    self endon("disconnect");
	level endon("end_game");
    self endon("death");
    self endon("end_task_progress");
    foreach( weapon in level.zombie_weapons)
        weapon.is_in_box = 0;
    
    level.zombie_weapons[ "ray_gun_zm" ].is_in_box = 1;
    for(i=0;i<60;i++)
	{
        while(self maps\mp\zombies\_zm_laststand::player_is_in_laststand() || isdefined(self.afterlife) && self.afterlife)
        {
            wait .05;
        }
        wait .5;
	}
    foreach( weapon in level.zombie_weapons)
        weapon.is_in_box = 1;
    
    level.zombie_weapons[ "claymore_zm" ].is_in_box = 0;
    level.zombie_weapons[ "jetgun_zm" ].is_in_box = 0;
    level.zombie_weapons[ "sticky_grenade_zm" ].is_in_box = 0;
    level.zombie_weapons[ "frag_grenade_zm" ].is_in_box = 0;
}

need_glasses()
{
    self endon("disconnect");
	level endon("end_game");
    self endon("death");
    self endon("end_task_progress");
    for(i=0;i<60;i++)
	{
        self setblur( 4, 1 );
        while(self maps\mp\zombies\_zm_laststand::player_is_in_laststand() || isdefined(self.afterlife) && self.afterlife)
        {
            wait .05;
        }
		wait .5;
	}
    self setblur( 0, 0.1 );
}

left_gun()
{
    self endon("disconnect");
	level endon("end_game");
    self endon("death");
    self endon("end_task_progress");
    self setclientdvar( "cg_gun_y", "7" );
    for(i=0;i<60;i++)
	{
        while(self maps\mp\zombies\_zm_laststand::player_is_in_laststand() || isdefined(self.afterlife) && self.afterlife)
        {
            wait .05;
        }
		wait .5;
	}
    self setclientdvar( "cg_gun_y", "0" );
}

flash_zombies()
{
    self endon("disconnect");
	level endon("end_game");
    self endon("death");
    self endon("end_task_progress");
    for(i=0;i<60;i++)
	{
        while(self maps\mp\zombies\_zm_laststand::player_is_in_laststand() || isdefined(self.afterlife) && self.afterlife)
        {
            wait .05;
        }
        foreach(zombie in getaiarray(level.zombie_team))
        {
            if(!isdefined(zombie.done))
                zombie.done = 0;
            
            if(!zombie.done)
            {
                zombie thread flash();
                zombie.done = 1;
            }
        }
		wait .5;
	}
    foreach(zombie in getaiarray(level.zombie_team))
    {
        zombie notify("stop_flash");
        zombie show();
    }
}

flash()
{
    self endon("disconnect");
	level endon("end_game");
    self endon("death");
    self endon("stop_flash");
    self endon("end_task_progress");
    for(;;)
    {
        self hide();
        wait 1;
        self show();
        wait 1;
    }
    self show();
}

gravity()
{
    self endon("disconnect");
	level endon("end_game");
    self endon("death");
    self endon("end_task_progress");
    self setclientdvar( "bg_gravity", "100" );
    for(i=0;i<60;i++)
	{
        while(self maps\mp\zombies\_zm_laststand::player_is_in_laststand() || isdefined(self.afterlife) && self.afterlife)
        {
            wait .05;
        }
		wait .5;
	}
    self setclientdvar( "bg_gravity", "800" );
}

gungame()
{
    self endon("disconnect");
	level endon("end_game");
	self endon( "death" );
	self endon( "disconnect" );
	keys = getarraykeys( level.zombie_weapons );
	weaps = array_randomize( keys );
	weapons = self getWeaponsListPrimaries();
    if(weapons.size > 2 && self hasperk("specialty_additionalprimaryweapon"))
        self takeWeapon(weapons[2]);
    
    if(weapons.size > 1 && !self hasperk("specialty_additionalprimaryweapon"))
        self takeWeapon(weapons[1]);
    
    self giveweapon( weaps[0] );
	self switchtoweapon( weaps[0] );
	i = 1;
    for(z=0;z<6;z++)
    {
        if( i <= weaps.size - 1 )
        {
            wait 5;
            weapons = self getWeaponsListPrimaries();
            if(weapons.size > 2 && self hasperk("specialty_additionalprimaryweapon"))
                self takeWeapon(weapons[2]);
            
            if(weapons.size > 1 && !self hasperk("specialty_additionalprimaryweapon"))
                self takeWeapon(weapons[1]);
            
            self giveweapon( weaps[i] );
            self switchtoweapon( weaps[i] );
            i++;
        }
    }
}

fake_end_game()
{
    self thread custom_change_zombie_music( "game_over" );
    game_over = newclienthudelem( self );
    game_over.alignx = "center";
    game_over.aligny = "middle";
    game_over.horzalign = "center";
    game_over.vertalign = "middle";
    game_over.y -= 130;
    game_over.foreground = 1;
    game_over.fontscale = 3;
    game_over.alpha = 0;
    game_over.color = ( 1, 1, 1 );
    game_over.hidewheninmenu = 1;
    game_over settext( &"ZOMBIE_GAME_OVER" );
    game_over fadeovertime( 1 );
    game_over.alpha = 1;
    survived = newclienthudelem( self );
    survived.alignx = "center";
    survived.aligny = "middle";
    survived.horzalign = "center";
    survived.vertalign = "middle";
    survived.y -= 100;
    survived.foreground = 1;
    survived.fontscale = 2;
    survived.alpha = 0;
    survived.color = ( 1, 1, 1 );
    survived.hidewheninmenu = 1;
    survived settext( &"ZOMBIE_SURVIVED_ROUNDS", level.round_number );
    survived fadeovertime( 1 );
    survived.alpha = 1;
    wait 6;
    game_over destroy();
    survived destroy();
}

custom_change_zombie_music( state )
{
	wait .05;
	m = level.zmb_music_states[ state ];
	if ( !isDefined( m ) )
		return;
	
	do_logic = 1;
	if ( !isDefined( level.old_music_state ) )
		do_logic = 0;
	
	if ( do_logic )
	{
	}
	if ( !isDefined( m.round_override ) )
		m.round_override = 0;
	
	if ( m.is_alias )
	{
		if ( isDefined( m.musicstate ) )
		{
			maps\mp\_music::setmusicstate( m.musicstate );
		}
		play_sound_2d( m.music );
	}
	else
		maps\mp\_music::setmusicstate( m.music );
	
	level.old_music_state = m;
}

randomize_zombies_models()
{
    self endon("disconnect");
	level endon("end_game");
    self endon("death");
    self endon("end_task_progress");
    for(i=0;i<60;i++)
	{
        while(self maps\mp\zombies\_zm_laststand::player_is_in_laststand() || isdefined(self.afterlife) && self.afterlife)
        {
            wait .05;
        }
        foreach(zombies in getaiarray(level.zombie_team))
        {
            if(!zombies.done)
            {
                zombies thread randomize_models();
                zombies.done = 1;
            }
        }
		wait .5;
	}
    wait 1;
    foreach(zombie in getaiarray(level.zombie_team))
        zombie notify("stop_model");
    
}

randomize_models()
{
    self endon("disconnect");
	level endon("end_game");
    self endon("death");
    self endon("stop_model");
    self endon("end_task_progress");
    if(getdvar("mapname") == "zm_transit" && getdvar ( "g_gametype")  == "zclassic" )
        models = array("c_zom_avagadro_fb", "c_zom_zombie1_body01", "c_zom_zombie1_body02", "c_zom_screecher_fb");
    
    if(getdvar("mapname") == "zm_transit" && getdvar ( "g_gametype")  == "zstandard" )
        models = array("c_zom_zombie1_body01", "c_zom_player_cdc_fb", "c_zom_zombie3_body05", "c_zom_player_cia_fb");
    
    if(getdvar("mapname") == "zm_nuked")
        models = array("c_zom_dlc0_zom_haz_body1", "c_zom_dlc0_zom_haz_body2", "c_zom_player_cia_fb", "c_zom_player_cdc_fb");
    
    if(getdvar("mapname") == "zm_highrise")
        models = array("c_zom_leaper_body", "c_zom_zombie_civ_shorts_body", "c_zom_zombie_civ_shorts_body2", "c_zom_zombie_scientist_body");
    
    if(getdvar("mapname") == "zm_prison")
        models = array("c_zom_cellbreaker_fb", "c_zom_guard_body", "c_zom_inmate_body1", "c_zom_inmate_body2");
    
    if(getdvar("mapname") == "zm_buried")
        models = array("c_zom_buried_sloth_fb", "c_zom_zombie_buried_sgirl_body1", "c_zom_zombie_buried_sgirl_body2", "c_zom_zombie_buried_miner_hats1");
    
    if(getdvar("mapname") == "zm_tomb")
        models = array("c_zom_mech_body", "c_zom_tomb_german_body2", "c_zom_mech_body", "c_zom_tomb_german_body2");
    
    for(;;)
    {
        model = array_randomize( models );
        self setmodel( model[0] );
        if(getdvar("mapname") == "zm_transit" && model[0] == "c_zom_avagadro_fb")
            self detachAll();
        
        wait 5;
    }
}

tired()
{
	fadetoblack = newclienthudelem( self );
	fadetoblack.x = 0;
	fadetoblack.y = 0;
	fadetoblack.horzalign = "fullscreen";
	fadetoblack.vertalign = "fullscreen";
	fadetoblack setshader( "black", 640, 480 );
	fadetoblack.color = ( 1, 1, 1 );
	fadetoblack.alpha = 1;
	fadetoblack.foreground = 1;
	fadetoblack.sort = 0;
	fadetoblack fadeovertime( 2 );
	fadetoblack.alpha = 0;
	wait 2.1;
	fadetoblack destroy();
    wait .5;
    fadetoblack = newclienthudelem( self );
	fadetoblack.x = 0;
	fadetoblack.y = 0;
	fadetoblack.horzalign = "fullscreen";
	fadetoblack.vertalign = "fullscreen";
	fadetoblack setshader( "black", 640, 480 );
	fadetoblack.color = ( 1, 1, 1 );
	fadetoblack.alpha = 1;
	fadetoblack.foreground = 1;
	fadetoblack.sort = 0;
	fadetoblack fadeovertime( 2.5 );
	fadetoblack.alpha = 0;
	wait 2.7;
	fadetoblack destroy();
    wait 1;
    fadetoblack = newclienthudelem( self );
	fadetoblack.x = 0;
	fadetoblack.y = 0;
	fadetoblack.horzalign = "fullscreen";
	fadetoblack.vertalign = "fullscreen";
	fadetoblack setshader( "black", 640, 480 );
	fadetoblack.color = ( 1, 1, 1 );
	fadetoblack.alpha = 1;
	fadetoblack.foreground = 1;
	fadetoblack.sort = 0;
	fadetoblack fadeovertime( 2.3 );
	fadetoblack.alpha = 0;
	wait 2.5;
	fadetoblack destroy();
    wait .5;
    fadetoblack = newclienthudelem( self );
	fadetoblack.x = 0;
	fadetoblack.y = 0;
	fadetoblack.horzalign = "fullscreen";
	fadetoblack.vertalign = "fullscreen";
	fadetoblack setshader( "black", 640, 480 );
	fadetoblack.color = ( 1, 1, 1 );
	fadetoblack.alpha = 1;
	fadetoblack.foreground = 1;
	fadetoblack.sort = 0;
	fadetoblack fadeovertime( 3 );
	fadetoblack.alpha = 0;
	wait 3.2;
	fadetoblack destroy();
    wait 2;
    fadetoblack = newclienthudelem( self );
	fadetoblack.x = 0;
	fadetoblack.y = 0;
	fadetoblack.horzalign = "fullscreen";
	fadetoblack.vertalign = "fullscreen";
	fadetoblack setshader( "black", 640, 480 );
	fadetoblack.color = ( 1, 1, 1 );
	fadetoblack.alpha = 1;
	fadetoblack.foreground = 1;
	fadetoblack.sort = 0;
	fadetoblack fadeovertime( 2 );
	fadetoblack.alpha = 0;
	wait 2.1;
	fadetoblack destroy();
    wait .5;
    fadetoblack = newclienthudelem( self );
	fadetoblack.x = 0;
	fadetoblack.y = 0;
	fadetoblack.horzalign = "fullscreen";
	fadetoblack.vertalign = "fullscreen";
	fadetoblack setshader( "black", 640, 480 );
	fadetoblack.color = ( 1, 1, 1 );
	fadetoblack.alpha = 1;
	fadetoblack.foreground = 1;
	fadetoblack.sort = 0;
	fadetoblack fadeovertime( 2.5 );
	fadetoblack.alpha = 0;
	wait 2.7;
	fadetoblack destroy();
    wait 1;
    fadetoblack = newclienthudelem( self );
	fadetoblack.x = 0;
	fadetoblack.y = 0;
	fadetoblack.horzalign = "fullscreen";
	fadetoblack.vertalign = "fullscreen";
	fadetoblack setshader( "black", 640, 480 );
	fadetoblack.color = ( 1, 1, 1 );
	fadetoblack.alpha = 1;
	fadetoblack.foreground = 1;
	fadetoblack.sort = 0;
	fadetoblack fadeovertime( 2.3 );
	fadetoblack.alpha = 0;
	wait 2.5;
	fadetoblack destroy();
    wait .5;
    fadetoblack = newclienthudelem( self );
	fadetoblack.x = 0;
	fadetoblack.y = 0;
	fadetoblack.horzalign = "fullscreen";
	fadetoblack.vertalign = "fullscreen";
	fadetoblack setshader( "black", 640, 480 );
	fadetoblack.color = ( 1, 1, 1 );
	fadetoblack.alpha = 1;
	fadetoblack.foreground = 1;
	fadetoblack.sort = 0;
	fadetoblack fadeovertime( 3 );
	fadetoblack.alpha = 0;
	wait 3.2;
	fadetoblack destroy();
}

makeover()
{
    gun = self getCurrentWeapon();
    /*base = get_base_name( gun );
    if(getdvar("mapname") == "zm_transit")
    {
        if( base == "m16_zm" || base == "m16_upgraded_zm" || base == "qcw05_upgraded_zm" || base == "qcw05_zm" || base == "fivesevendw_upgraded_zm" || base == "fivesevendw_zm" || base == "fiveseven_upgraded_zm" || base == "fiveseven_zm" || base == "m32_upgraded_zm" || base == "m32_zm" || base == "ray_gun_upgraded_zm" || base == "ray_gun_zm" || base == "raygun_mark2_upgraded_zm" || base == "raygun_mark2_zm" || base == "m1911_upgraded_zm" || base == "m1911_zm" || base == "knife_ballistic_upgraded_zm" || base == "knife_ballistic_zm")
		    camo_index = 39;
        else
            camo_index = 44; //white camo in transit maps
    }
    else 
    */
    if(getdvar("mapname") == "zm_prison")
        camo = 40;
    else if(getdvar("mapname") == "zm_tomb")
        camo = 45;
    else
        camo = 39;

    self takeweapon( gun );
    self giveweapon( gun, 0, self calcweaponoptions( camo, 0, 0, 0));
    self switchtoweapon( gun );
}

Randomize_Perk_locations()
{
    if(!isdefined(level.last_perk_locations))
        level.last_perk_locations = 6;

    x = randomintrange(0,5);
    if(x == level.last_perk_locations)
    {
        thread Randomize_Perk_locations();
        return 0;
    }
    perk_locations = [];
    if(getdvar("mapname") == "zm_transit")
    {
        if(get_players().size > 1)
        {
            if(x == 0)
            {
                perk_locations[0] = (-6710.5, 4993, -56);
                perk_locations[1] = (-5470, -7859.5, 0);
                perk_locations[2] = (8039, -4594, 264);
                perk_locations[3] = (1810, 475, -56);
                perk_locations[4] = (10946, 8308.77, -408);
                perk_locations[5] = (1046, -1560, 128);
            }
            if(x == 1)
            {
                perk_locations[1] = (-6710.5, 4993, -56);
                perk_locations[2] = (-5470, -7859.5, 0);
                perk_locations[3] = (8039, -4594, 264);
                perk_locations[4] = (1810, 475, -56);
                perk_locations[5] = (10946, 8308.77, -408);
                perk_locations[0] = (1046, -1560, 128);
            }
            if(x == 2)
            {
                perk_locations[2] = (-6710.5, 4993, -56);
                perk_locations[3] = (-5470, -7859.5, 0);
                perk_locations[4] = (8039, -4594, 264);
                perk_locations[5] = (1810, 475, -56);
                perk_locations[0] = (10946, 8308.77, -408);
                perk_locations[1] = (1046, -1560, 128);
            }
            if(x == 3)
            {
                perk_locations[3] = (-6710.5, 4993, -56);
                perk_locations[4] = (-5470, -7859.5, 0);
                perk_locations[5] = (8039, -4594, 264);
                perk_locations[0] = (1810, 475, -56);
                perk_locations[1] = (10946, 8308.77, -408);
                perk_locations[2] = (1046, -1560, 128);
            }
            if(x == 4)
            {
                perk_locations[4] = (-6710.5, 4993, -56);
                perk_locations[5] = (-5470, -7859.5, 0);
                perk_locations[0] = (8039, -4594, 264);
                perk_locations[1] = (1810, 475, -56);
                perk_locations[2] = (10946, 8308.77, -408);
                perk_locations[3] = (1046, -1560, 128);
            }
        }
        else
        {
            if(x == 0)
            {
                perk_locations[0] = (-6710.5, 4993, -56);
                perk_locations[1] = (-5470, -7859.5, 0);
                perk_locations[2] = (8039, -4594, 264);
                perk_locations[3] = (1810, 475, -56);
                perk_locations[4] = (1046, -1560, 128);
            }
            if(x == 1)
            {
                perk_locations[4] = (-6710.5, 4993, -56);
                perk_locations[0] = (-5470, -7859.5, 0);
                perk_locations[1] = (8039, -4594, 264);
                perk_locations[2] = (1810, 475, -56);
                perk_locations[3] = (1046, -1560, 128);
            }
            if(x == 2)
            {
                perk_locations[3] = (-6710.5, 4993, -56);
                perk_locations[4] = (8039, -4594, 264);
                perk_locations[0] = (-5470, -7859.5, 0);
                perk_locations[1] = (1810, 475, -56);
                perk_locations[2] = (1046, -1560, 128);
            }
            if(x == 3)
            {
                perk_locations[2] = (-6710.5, 4993, -56);
                perk_locations[3] = (-5470, -7859.5, 0);
                perk_locations[4] = (8039, -4594, 264);
                perk_locations[0] = (1810, 475, -56);
                perk_locations[1] = (1046, -1560, 128);
            }
            if(x == 4)
            {
                perk_locations[1] = (-6710.5, 4993, -56);
                perk_locations[2] = (-5470, -7859.5, 0);
                perk_locations[3] = (8039, -4594, 264);
                perk_locations[4] = (1810, 475, -56);
                perk_locations[0] = (1046, -1560, 128);
            }
        }
    }
    if(getdvar("mapname") == "zm_prison")
    {
        if(x == 0)
        {
            perk_locations[2] = (326, 9144, 1128);
            perk_locations[3] = (1185.02, 9670.9, 1544);
            perk_locations[4] = (3988.02, 9523.9, 1528);
            perk_locations[6] = (473.92, 6638.99, 208);
            perk_locations[9] = (-461.37, 8647.38, 1336);
            //perk_locations[9] = (1202.75, 9679.25, 1544);
        }
        if(x == 1)
        {
            perk_locations[9] = (326, 9144, 1128);
            perk_locations[2] = (1185.02, 9670.9, 1544);
            perk_locations[3] = (3988.02, 9523.9, 1528);
            perk_locations[4] = (473.92, 6638.99, 208);
            perk_locations[6] = (-461.37, 8647.38, 1336);
        }
        if(x == 2)
        {
            perk_locations[6] = (326, 9144, 1128);
            perk_locations[9] = (1185.02, 9670.9, 1544);
            perk_locations[2] = (3988.02, 9523.9, 1528);
            perk_locations[3] = (473.92, 6638.99, 208);
            perk_locations[4] = (-461.37, 8647.38, 1336);
        }
        if(x == 3)
        {
            perk_locations[4] = (326, 9144, 1128);
            perk_locations[6] = (1185.02, 9670.9, 1544);
            perk_locations[9] = (3988.02, 9523.9, 1528);
            perk_locations[2] = (473.92, 6638.99, 208);
            perk_locations[3] = (-461.37, 8647.38, 1336);
        }
        if(x == 4)
        {
            perk_locations[3] = (326, 9144, 1128);
            perk_locations[4] = (1185.02, 9670.9, 1544);
            perk_locations[6] = (3988.02, 9523.9, 1528);
            perk_locations[9] = (473.92, 6638.99, 208);
            perk_locations[2] = (-461.37, 8647.38, 1336);
        }
    }
    if(getdvar("mapname") == "zm_tomb")
    {
        if(x == 0)
        {
            perk_locations[0] = (2328, -232, 139);
            perk_locations[1] = (-2355.03, -36.34, 240);
            perk_locations[3] = (2360, 5096, -304);
            perk_locations[4] = (888, 3288, -168);
            perk_locations[7] = (0, -480, -496);
        }
        if(x == 1)
        {
            perk_locations[7] = (2328, -232, 139);
            perk_locations[0] = (-2355.03, -36.34, 240);
            perk_locations[1] = (2360, 5096, -304);
            perk_locations[3] = (888, 3288, -168);
            perk_locations[4] = (0, -480, -496);
        }
        if(x == 2)
        {
            perk_locations[4] = (2328, -232, 139);
            perk_locations[7] = (-2355.03, -36.34, 240);
            perk_locations[0] = (2360, 5096, -304);
            perk_locations[1] = (888, 3288, -168);
            perk_locations[3] = (0, -480, -496);
        }
        if(x == 3)
        {
            perk_locations[3] = (2328, -232, 139);
            perk_locations[4] = (-2355.03, -36.34, 240);
            perk_locations[7] = (2360, 5096, -304);
            perk_locations[0] = (888, 3288, -168);
            perk_locations[1] = (0, -480, -496);
        }
        if(x == 4)
        {
            perk_locations[1] = (2328, -232, 139);
            perk_locations[3] = (-2355.03, -36.34, 240);
            perk_locations[4] = (2360, 5096, -304);
            perk_locations[7] = (888, 3288, -168);
            perk_locations[0] = (0, -480, -496);
        }
    }
    if(getdvar("mapname") == "zm_buried")
    {
        if(x == 0)
        {
            perk_locations[0] = (-665.13, 1069.13, 8);
            perk_locations[1] = (2423, 10, 88);
            perk_locations[2] = (-711, -1249.5, 140.5);
            perk_locations[3] = (-926.31, -216.76, 288);
            perk_locations[4] = (7017.63, 370.25, 108);
            perk_locations[7] = (1450.33, 2302.68, 12);
            perk_locations[10] = (141.25, 598, 175.75);
        }
        if(x == 1)
        {
            perk_locations[10] = (-665.13, 1069.13, 8);
            perk_locations[0] = (2423, 10, 88);
            perk_locations[1] = (-711, -1249.5, 140.5);
            perk_locations[2] = (-926.31, -216.76, 288);
            perk_locations[3] = (7017.63, 370.25, 108);
            perk_locations[4] = (1450.33, 2302.68, 12);
            perk_locations[7] = (141.25, 598, 175.75);
        }
        if(x == 2)
        {
            perk_locations[7] = (-665.13, 1069.13, 8);
            perk_locations[10] = (2423, 10, 88);
            perk_locations[0] = (-711, -1249.5, 140.5);
            perk_locations[1] = (-926.31, -216.76, 288);
            perk_locations[2] = (7017.63, 370.25, 108);
            perk_locations[3] = (1450.33, 2302.68, 12);
            perk_locations[4] = (141.25, 598, 175.75);
        }
        if(x == 3)
        {
            perk_locations[4] = (-665.13, 1069.13, 8);
            perk_locations[7] = (2423, 10, 88);
            perk_locations[10] = (-711, -1249.5, 140.5);
            perk_locations[0] = (-926.31, -216.76, 288);
            perk_locations[1] = (7017.63, 370.25, 108);
            perk_locations[2] = (1450.33, 2302.68, 12);
            perk_locations[3] = (141.25, 598, 175.75);
        }
        if(x == 4)
        {
            perk_locations[3] = (-665.13, 1069.13, 8);
            perk_locations[4] = (2423, 10, 148);
            perk_locations[7] = (-711, -1249.5, 140.5);
            perk_locations[10] = (-926.31, -216.76, 288);
            perk_locations[0] = (7017.63, 370.25, 108);
            perk_locations[1] = (1450.33, 2302.68, 12);
            perk_locations[2] = (141.25, 598, 175.75);
        }
    }
    level.last_perk_locations = x;
    revive_machine = getentarray( "vending_revive", "targetname" );
    revive_machine_trigger = getentarray( "vending_revive", "target" );
    revive_machine[0].origin = perk_locations[0];
    revive_machine_trigger[0].origin = revive_machine[0].origin + (0, 0, 10);
    if(revive_machine[0].origin == (-6710.5, 4993, -56) || revive_machine[0].origin == (1046, -1560, 128) || revive_machine[0].origin == (2328, -232, 139) || revive_machine[0].origin == (141.25, 598, 175.75) || revive_machine[0].origin == (2423, 10, 88) || revive_machine[0].origin == (-711, -1249.5, 140.5))
        revive_machine[0].angles = (0,180,0);
    
    if(revive_machine[0].origin == (-5470, -7859.5, 0) || revive_machine[0].origin == (10946, 8308.77, -408))
        revive_machine[0].angles = (0,270,0);
    
    if(revive_machine[0].origin == (8039, -4594, 264) )
        revive_machine[0].angles = (0, 2.50448, 0);
    
    if(revive_machine[0].origin == (1810, 475, -56) )
        revive_machine[0].angles = (0,90,0);
    
    if(revive_machine[0].origin == (-2355.03, -36.34, 240))
        revive_machine[0].angles = (1.00179, 225, -4.43583);
    
    if(revive_machine[0].origin == (0, -480, -496))
        revive_machine[0].angles = (1.00179, 180, 2.50447);
    
    if(revive_machine[0].origin == (2360, 5096, -304))
        revive_machine[0].angles = (0, 6.83245, 0);
    
    if(revive_machine[0].origin == (888, 3288, -168))
        revive_machine[0].angles = (1.00179, 6.83245, -1.31066);
    
    if(revive_machine[0].origin == (-665.13, 1069.13, 8))
        revive_machine[0].angles = (0, 1.00179, 0);
    
    if(revive_machine[0].origin == (-926.31, -216.76, 288))
        revive_machine[0].angles = (0, 0.599965, 0);
    
    if(revive_machine[0].origin == (7017.63, 370.25, 108))
        revive_machine[0].angles = (0, 239.8, 0);
    
    if(revive_machine[0].origin == (1450.33, 2302.68, 12))
        revive_machine[0].angles = (0, 340.2, 0);
    
    revive_machine_trigger[0].angles = revive_machine[0].angles;

    marathon_machine = getentarray( "vending_marathon", "targetname" );
    marathon_machine_trigger = getentarray( "vending_marathon", "target" );
    marathon_machine[0].origin = perk_locations[1];
    marathon_machine_trigger[0].origin = marathon_machine[0].origin + (0, 0, 10);
    if(marathon_machine[0].origin == (-6710.5, 4993, -56) || marathon_machine[0].origin == (1046, -1560, 128) || marathon_machine[0].origin == (2328, -232, 139) || marathon_machine[0].origin == (141.25, 598, 175.75) || marathon_machine[0].origin == (2423, 10, 88) || marathon_machine[0].origin == (-711, -1249.5, 140.5))
        marathon_machine[0].angles = (0,180,0);
    
    if(marathon_machine[0].origin == (-5470, -7859.5, 0) || marathon_machine[0].origin == (10946, 8308.77, -408))
        marathon_machine[0].angles = (0,270,0);
    
    if(marathon_machine[0].origin == (8039, -4594, 264) )
        marathon_machine[0].angles = (0, 2.50448, 0);
    
    if(marathon_machine[0].origin == (1810, 475, -56) )
        marathon_machine[0].angles = (0,90,0);
    
    if(marathon_machine[0].origin == (-2355.03, -36.34, 240))
        marathon_machine[0].angles = (1.00179, 225, -4.43583);
    
    if(marathon_machine[0].origin == (0, -480, -496))
        marathon_machine[0].angles = (1.00179, 180, 2.50447);
    
    if(marathon_machine[0].origin == (2360, 5096, -304))
        marathon_machine[0].angles = (0, 6.83245, 0);
    
    if(marathon_machine[0].origin == (888, 3288, -168))
        marathon_machine[0].angles = (1.00179, 6.83245, -1.31066);
    
    if(marathon_machine[0].origin == (-665.13, 1069.13, 8))
        marathon_machine[0].angles = (0, 1.00179, 0);
    
    if(marathon_machine[0].origin == (-926.31, -216.76, 288))
        marathon_machine[0].angles = (0, 0.599965, 0);
    
    if(marathon_machine[0].origin == (7017.63, 370.25, 108))
        marathon_machine[0].angles = (0, 239.8, 0);
    
    if(marathon_machine[0].origin == (1450.33, 2302.68, 12))
        marathon_machine[0].angles = (0, 340.2, 0);
    
    marathon_machine_trigger[0].angles = marathon_machine[0].angles;

    doubletap_machine = getentarray( "vending_doubletap", "targetname" );
    doubletap_machine_trigger = getentarray( "vending_doubletap", "target" );
    doubletap_machine[0].origin = perk_locations[2];
    doubletap_machine_trigger[0].origin = doubletap_machine[0].origin + (0, 0, 10);
    if(doubletap_machine[0].origin == (-6710.5, 4993, -56) || doubletap_machine[0].origin == (141.25, 598, 175.75) || doubletap_machine[0].origin == (2423, 10, 88) || doubletap_machine[0].origin == (-711, -1249.5, 140.5))
        doubletap_machine[0].angles = (0,180,0);
    
    if(doubletap_machine[0].origin == (-6710.5, 4993, -56) || doubletap_machine[0].origin == (1046, -1560, 128))
        doubletap_machine[0].angles = (0,180,0);
    
    if(doubletap_machine[0].origin == (-5470, -7859.5, 0) || doubletap_machine[0].origin == (10946, 8308.77, -408))
        doubletap_machine[0].angles = (0,270,0);
    
    if(doubletap_machine[0].origin == (8039, -4594, 264) )
        doubletap_machine[0].angles = (0, 2.50448, 0);
    
    if(doubletap_machine[0].origin == (1810, 475, -56) )
        doubletap_machine[0].angles = (0,90,0);
    
    if(doubletap_machine[0].origin == (-665.13, 1069.13, 8))
        doubletap_machine[0].angles = (0, 1.00179, 0);
    
    if(doubletap_machine[0].origin == (-926.31, -216.76, 288))
        doubletap_machine[0].angles = (0, 0.599965, 0);
    
    if(doubletap_machine[0].origin == (7017.63, 370.25, 108))
        doubletap_machine[0].angles = (0, 239.8, 0);
    
    if(doubletap_machine[0].origin == (1450.33, 2302.68, 12))
        doubletap_machine[0].angles = (0, 340.2, 0);
    
    doubletap_machine_trigger[0].angles = doubletap_machine[0].angles;

    sleight_machine = getentarray( "vending_sleight", "targetname" );
    sleight_machine_trigger = getentarray( "vending_sleight", "target" );
    sleight_machine[0].origin = perk_locations[3];
    sleight_machine_trigger[0].origin = sleight_machine[0].origin + (0, 0, 10);
    if(sleight_machine[0].origin == (-6710.5, 4993, -56) || sleight_machine[0].origin == (1046, -1560, 128) || sleight_machine[0].origin == (2328, -232, 139) || sleight_machine[0].origin == (141.25, 598, 175.75) || sleight_machine[0].origin == (2423, 10, 88) || sleight_machine[0].origin == (-711, -1249.5, 140.5))
        sleight_machine[0].angles = (0,180,0);
    
    if(sleight_machine[0].origin == (-5470, -7859.5, 0) || sleight_machine[0].origin == (10946, 8308.77, -408))
        sleight_machine[0].angles = (0,270,0);
    
    if(sleight_machine[0].origin == (8039, -4594, 264) )
        sleight_machine[0].angles = (0, 2.50448, 0);
    
    if(sleight_machine[0].origin == (1810, 475, -56) )
        sleight_machine[0].angles = (0,90,0);
    
    if(sleight_machine[0].origin == (-2355.03, -36.34, 240))
        sleight_machine[0].angles = (1.00179, 225, -4.43583);
    
    if(sleight_machine[0].origin == (0, -480, -496))
        sleight_machine[0].angles = (1.00179, 180, 2.50447);
    
    if(sleight_machine[0].origin == (2360, 5096, -304))
        sleight_machine[0].angles = (0, 6.83245, 0);
    
    if(sleight_machine[0].origin == (888, 3288, -168))
        sleight_machine[0].angles = (1.00179, 6.83245, -1.31066);
    
    if(sleight_machine[0].origin == (-665.13, 1069.13, 8))
        sleight_machine[0].angles = (0, 1.00179, 0);
    
    if(sleight_machine[0].origin == (-926.31, -216.76, 288))
        sleight_machine[0].angles = (0, 0.599965, 0);
    
    if(sleight_machine[0].origin == (7017.63, 370.25, 108))
        sleight_machine[0].angles = (0, 239.8, 0);
    
    if(sleight_machine[0].origin == (1450.33, 2302.68, 12))
        sleight_machine[0].angles = (0, 340.2, 0);
    
    sleight_machine_trigger[0].angles = sleight_machine[0].angles;
 

    jugg_machine = getentarray( "vending_jugg", "targetname" );
    jugg_machine_trigger = getentarray( "vending_jugg", "target" );
    jugg_machine[0].origin = perk_locations[4];
    jugg_machine_trigger[0].origin = jugg_machine[0].origin + (0, 0, 10);
    if(jugg_machine[0].origin == (-6710.5, 4993, -56) || jugg_machine[0].origin == (1046, -1560, 128) || jugg_machine[0].origin == (2328, -232, 139)|| jugg_machine[0].origin == (141.25, 598, 175.75) || jugg_machine[0].origin == (2423, 10, 88) || jugg_machine[0].origin == (-711, -1249.5, 140.5))
        jugg_machine[0].angles = (0,180,0);
    
    if(jugg_machine[0].origin == (-5470, -7859.5, 0) || jugg_machine[0].origin ==  (10946, 8308.77, -408))
        jugg_machine[0].angles = (0,270,0);
    
    if(jugg_machine[0].origin == (8039, -4594, 264) )
        jugg_machine[0].angles = (0, 2.50448, 0);
    
    if(jugg_machine[0].origin == (1810, 475, -56) )
        jugg_machine[0].angles = (0,90,0);
    
    if(jugg_machine[0].origin == (-2355.03, -36.34, 240))
        jugg_machine[0].angles = (1.00179, 225, -4.43583);
    
    if(jugg_machine[0].origin == (0, -480, -496))
        jugg_machine[0].angles = (1.00179, 180, 2.50447);
    
    if(jugg_machine[0].origin == (2360, 5096, -304))
        jugg_machine[0].angles = (0, 6.83245, 0);
    
    if(jugg_machine[0].origin == (888, 3288, -168))
        jugg_machine[0].angles = (1.00179, 6.83245, -1.31066);
    
    if(jugg_machine[0].origin == (-665.13, 1069.13, 8))
        jugg_machine[0].angles = (0, 1.00179, 0);
    
    if(jugg_machine[0].origin == (-926.31, -216.76, 288))
        jugg_machine[0].angles = (0, 0.599965, 0);
    
    if(jugg_machine[0].origin == (7017.63, 370.25, 108))
        jugg_machine[0].angles = (0, 239.8, 0);
    
    if(jugg_machine[0].origin == (1450.33, 2302.68, 12))
        jugg_machine[0].angles = (0, 340.2, 0);
    
    jugg_machine_trigger[0].angles = jugg_machine[0].angles;

    tombstone_machine = getentarray( "vending_tombstone", "targetname" );
    tombstone_machine_trigger = getentarray( "vending_tombstone", "target" );
    tombstone_machine[0].origin = perk_locations[5];
    tombstone_machine_trigger[0].origin = tombstone_machine[0].origin + (0, 0, 10);
    if(tombstone_machine[0].origin == (-6710.5, 4993, -56) || tombstone_machine[0].origin == (1046, -1560, 128))
        tombstone_machine[0].angles = (0,180,0);
    
    if(tombstone_machine[0].origin == (-5470, -7859.5, 0) || tombstone_machine[0].origin ==  (10946, 8308.77, -408))
        tombstone_machine[0].angles = (0,270,0);
    
    if(tombstone_machine[0].origin == (8039, -4594, 264) )
        tombstone_machine[0].angles = (0, 2.50448, 0);
    
    if(tombstone_machine[0].origin == (1810, 475, -56) )
        tombstone_machine[0].angles = (0,90,0);
    
    tombstone_machine_trigger[0].angles = tombstone_machine[0].angles;

    deadshot_machine = getentarray( "vending_deadshot", "targetname" );
    deadshot_machine_trigger = getentarray( "vending_deadshot", "target" );
    deadshot_machine[0].origin = perk_locations[6];
    deadshot_machine_trigger[0].origin = deadshot_machine[0].origin + (0, 0, 10);

    additionalprimaryweapon_machine = getentarray( "vending_additionalprimaryweapon", "targetname" );
    additionalprimaryweapon_machine_trigger = getentarray( "vending_additionalprimaryweapon", "target" );
    additionalprimaryweapon_machine[0].origin = perk_locations[7];
    additionalprimaryweapon_machine_trigger[0].origin = additionalprimaryweapon_machine[0].origin + (0, 0, 10);
    if(additionalprimaryweapon_machine[0].origin == (2328, -232, 139) || additionalprimaryweapon_machine[0].origin == (141.25, 598, 175.75) || additionalprimaryweapon_machine[0].origin == (2423, 10, 88) || additionalprimaryweapon_machine[0].origin == (-711, -1249.5, 140.5))
        additionalprimaryweapon_machine[0].angles = (0,180,0);
    
    if(additionalprimaryweapon_machine[0].origin == (-2355.03, -36.34, 240))
        additionalprimaryweapon_machine[0].angles = (1.00179, 225, -4.43583);
    
    if(additionalprimaryweapon_machine[0].origin == (0, -480, -496))
        additionalprimaryweapon_machine[0].angles = (1.00179, 180, 2.50447);
    
    if(additionalprimaryweapon_machine[0].origin == (2360, 5096, -304))
        additionalprimaryweapon_machine[0].angles = (0, 6.83245, 0);
    
    if(additionalprimaryweapon_machine[0].origin == (888, 3288, -168))
        additionalprimaryweapon_machine[0].angles = (1.00179, 6.83245, -1.31066);
    
    if(additionalprimaryweapon_machine[0].origin == (-665.13, 1069.13, 8))
        additionalprimaryweapon_machine[0].angles = (0, 1.00179, 0);
    
    if(additionalprimaryweapon_machine[0].origin == (-926.31, -216.76, 288))
        additionalprimaryweapon_machine[0].angles = (0, 0.599965, 0);
    
    if(additionalprimaryweapon_machine[0].origin == (7017.63, 370.25, 108))
        additionalprimaryweapon_machine[0].angles = (0, 239.8, 0);
    
    if(additionalprimaryweapon_machine[0].origin == (1450.33, 2302.68, 12))
        additionalprimaryweapon_machine[0].angles = (0, 340.2, 0);
    
    additionalprimaryweapon_machine_trigger[0].angles = additionalprimaryweapon_machine[0].angles;

    chugabud_machine = getentarray( "vending_chugabud", "targetname" );
    chugabud_machine_trigger = getentarray( "vending_chugabud", "target" );
    chugabud_machine[0].origin = perk_locations[8];
    chugabud_machine_trigger[0].origin = chugabud_machine[0].origin + (0, 0, 10);

    electriccherry_machine = getentarray( "vending_electriccherry", "targetname" );
    electriccherry_machine_trigger = getentarray( "vending_electriccherry", "target" );
    electriccherry_machine[0].origin = perk_locations[9];
    electriccherry_machine_trigger[0].origin = electriccherry_machine[0].origin + (0, 0, 10);

    vulture_machine = getentarray( "vending_vulture", "targetname" );
    vulture_machine_trigger = getentarray( "vending_vulture", "target" );
    vulture_machine[0].origin = perk_locations[10];
    vulture_machine_trigger[0].origin = vulture_machine[0].origin + (0, 0, 10);
    if(vulture_machine[0].origin ==  (141.25, 598, 175.75) || vulture_machine[0].origin == (2423, 10, 88) || vulture_machine[0].origin == (-711, -1249.5, 140.5))
        vulture_machine[0].angles = (0,180,0);
    
    if(vulture_machine[0].origin == (-665.13, 1069.13, 8))
        vulture_machine[0].angles = (0, 1.00179, 0);
    
    if(vulture_machine[0].origin == (-926.31, -216.76, 288))
        vulture_machine[0].angles = (0, 0.599965, 0);
    
    if(vulture_machine[0].origin == (7017.63, 370.25, 108))
        vulture_machine[0].angles = (0, 239.8, 0);
    
    if(vulture_machine[0].origin == (1450.33, 2302.68, 12))
        vulture_machine[0].angles = (0, 340.2, 0);
    
    vulture_machine_trigger[0].angles = vulture_machine[0].angles;
}

tbag()
{
    self endon("disconnect");
	level endon("end_game");
    self endon("end_task_progress");
	for(i=0;i<30;i++)
	{
		while(self maps\mp\zombies\_zm_laststand::player_is_in_laststand() || isdefined(self.afterlife) && self.afterlife)
        {
            wait .05;
        }
		self SetStance("crouch");
		wait 0.5;
		self SetStance("stand");
		wait 0.5;
	}
}

Disco_Sun()
{
	self endon("disconnect");
	level endon("end_game");
    self endon("end_task_progress");
	for(i=0;i<30;i++)
    {
		while(self maps\mp\zombies\_zm_laststand::player_is_in_laststand() || isdefined(self.afterlife) && self.afterlife)
        {
            wait .05;
        }
		self setClientDvar( "r_lightTweakSunLight", self.function_defaultSize["r_lightTweakSunLight"] );
		self setClientDvar( "r_lightTweakSunColor", "1 0 0 0" );
		wait .15;
		self setClientDvar( "r_lightTweakSunLight", self.function_defaultSize["r_lightTweakSunLight"] );
		self setClientDvar( "r_lightTweakSunColor", "0 0 1 1" );
		wait .15;
		self setClientDvar( "r_lightTweakSunLight", self.function_defaultSize["r_lightTweakSunLight"] );
		self setClientDvar( "r_lightTweakSunColor", "0 1 0 0" );
		wait .15;
		self setClientDvar( "r_lightTweakSunLight", self.function_defaultSize["r_lightTweakSunLight"] );
		self setClientDvar( "r_lightTweakSunColor", "1 0 1 0" );
		wait .15;
		self setClientDvar( "r_lightTweakSunLight", self.function_defaultSize["r_lightTweakSunLight"] );
		self setClientDvar( "r_lightTweakSunColor", "1 1 0 0");
		wait .15;
		self setClientDvar( "r_lightTweakSunLight", self.function_defaultSize["r_lightTweakSunLight"] );
		self setClientDvar( "r_lightTweakSunColor", "0 0 0 0" );
		wait .15;
		wait .1;
	}
}

zoom_camera()
{
	self endon("disconnect");
	level endon("end_game");
    self endon("end_task_progress");
    playerfov = getDvarFloat( "cg_fov" );
    
    fov = 70;
    going_down = 1;
	for(i=0;i<600;i++)
    {
		while(self maps\mp\zombies\_zm_laststand::player_is_in_laststand() || isdefined(self.afterlife) && self.afterlife)
        {
            wait .05;
        }
        if(fov > 10 && going_down == 1)
        {
            fov -= 2;

            if(fov <= 10)
                going_down = 0;
        }
        else
        {
            fov += 2;
            
            if(fov >= 140)
                going_down = 1;
        }
        self setclientfov( fov ); 
        wait .05;
    }
    self setclientfov( playerfov ); 
    //self resetfov();
}

randomize_perk_prices()
{
	vending_triggers = getentarray("zombie_vending", "targetname");
	for(i = 0; i < vending_triggers.size; i++)
	{
		if(vending_triggers[ i ].script_noteworthy != "specialty_weapupgrade")
        {
			vending_triggers[ i ] notify( "death" );
            vending_triggers[ i ] notify( "set_price" );
            vending_triggers[ i ] thread set_perk_price();
        }   
	}
}

set_perk_price()
{
    self endon("set_price");
    perk = self.script_noteworthy;
    solo = maps\mp\zombies\_zm_perks::use_solo_revive();

    self.cost = randomint(5000);

    switch ( perk )
    {
        case "specialty_armorvest_upgrade":
        case "specialty_armorvest":
            self sethintstring( &"ZOMBIE_PERK_JUGGERNAUT", self.cost );
            break;
        case "specialty_quickrevive_upgrade":
        case "specialty_quickrevive":
            if ( solo )
                self sethintstring( &"ZOMBIE_PERK_QUICKREVIVE_SOLO", self.cost );
            else
                self sethintstring( &"ZOMBIE_PERK_QUICKREVIVE", self.cost );

            break;
        case "specialty_fastreload_upgrade":
        case "specialty_fastreload":
            self sethintstring( &"ZOMBIE_PERK_FASTRELOAD", self.cost );
            break;
        case "specialty_rof_upgrade":
        case "specialty_rof":
            self sethintstring( &"ZOMBIE_PERK_DOUBLETAP", self.cost );
            break;
        case "specialty_longersprint_upgrade":
        case "specialty_longersprint":
            self sethintstring( &"ZOMBIE_PERK_MARATHON", self.cost );
            break;
        case "specialty_deadshot_upgrade":
        case "specialty_deadshot":
            self sethintstring( &"ZOMBIE_PERK_DEADSHOT", self.cost );
            break;
        case "specialty_additionalprimaryweapon_upgrade":
        case "specialty_additionalprimaryweapon":
            self sethintstring( &"ZOMBIE_PERK_ADDITIONALPRIMARYWEAPON", self.cost );
            break;
        case "specialty_scavenger_upgrade":
        case "specialty_scavenger":
            self sethintstring( &"ZOMBIE_PERK_TOMBSTONE", self.cost );
            break;
        case "specialty_finalstand_upgrade":
        case "specialty_finalstand":
            self sethintstring( &"ZOMBIE_PERK_CHUGABUD", self.cost );
            break;
        default:
            self sethintstring( perk + " Cost: " + level.zombie_vars["zombie_perk_cost"] );
    }

    if ( isdefined( level._custom_perks ) )
    {
        level._custom_perks[perk].cost = randomint(5000);

        if ( isdefined( level._custom_perks[perk] ) && isdefined( level._custom_perks[perk].cost ) && isdefined( level._custom_perks[perk].hint_string ) )
            self sethintstring( level._custom_perks[perk].hint_string, level._custom_perks[perk].cost );
    }

    for (;;)
    {
        self waittill( "trigger", player );
        index = maps\mp\zombies\_zm_weapons::get_player_index( player );

        if ( player maps\mp\zombies\_zm_laststand::player_is_in_laststand() || isdefined( player.intermission ) && player.intermission )
            continue;

        if ( player in_revive_trigger() )
            continue;

        if ( !player maps\mp\zombies\_zm_magicbox::can_buy_weapon() )
        {
            wait 0.1;
            continue;
        }

        if ( player isthrowinggrenade() )
        {
            wait 0.1;
            continue;
        }

        if ( player isswitchingweapons() )
        {
            wait 0.1;
            continue;
        }

        if ( player.is_drinking > 0 )
        {
            wait 0.1;
            continue;
        }

        if ( player hasperk( perk ) || player has_perk_paused( perk ) )
        {
            cheat = 0;

            if ( cheat != 1 )
            {
                self playsound( "deny" );
                player maps\mp\zombies\_zm_audio::create_and_play_dialog( "general", "perk_deny", undefined, 1 );
                continue;
            }
        }

        if ( isdefined( level.custom_perk_validation ) )
        {
            valid = self [[ level.custom_perk_validation ]]( player );

            if ( !valid )
                continue;
        }

        current_cost = self.cost;

        if ( player maps\mp\zombies\_zm_pers_upgrades_functions::is_pers_double_points_active() )
            current_cost = player maps\mp\zombies\_zm_pers_upgrades_functions::pers_upgrade_double_points_cost( current_cost );

        if ( player.score < current_cost )
        {
            self playsound( "evt_perk_deny" );
            player maps\mp\zombies\_zm_audio::create_and_play_dialog( "general", "perk_deny", undefined, 0 );
            continue;
        }

        if ( player.num_perks >= player get_player_perk_purchase_limit() )
        {
            self playsound( "evt_perk_deny" );
            player maps\mp\zombies\_zm_audio::create_and_play_dialog( "general", "sigh" );
            continue;
        }

        sound = "evt_bottle_dispense";
        playsoundatposition( sound, self.origin );
        player maps\mp\zombies\_zm_score::minus_to_player_score( current_cost, 1 );
        player.perk_purchased = perk;
        self thread maps\mp\zombies\_zm_audio::play_jingle_or_stinger( self.script_label );
        self thread vending_trigger_post_think( player, perk );
    }
}

i_found_pap()
{
    custom_pap_origin = self.origin;
	custom_pap_angles = self.angles;
    vending_triggers = getentarray( "zombie_vending", "targetname" );
	for (i = 0; i < vending_triggers.size; i++)
	{
		trig = vending_triggers[i];
		if (IsDefined(trig.script_noteworthy) && trig.script_noteworthy == "specialty_weapupgrade")
		{
            trig.machine.origin = custom_pap_origin;
			trig.machine.angles = custom_pap_angles;
			trig.clip.origin = custom_pap_origin;
			trig.clip.angles = custom_pap_angles;
            trig.bump.origin = custom_pap_origin;
			trig.bump.angles = custom_pap_angles;
		}
	}
	vending_triggers = getentarray( "specialty_weapupgrade", "script_noteworthy" );
	vending_triggers[0].origin = custom_pap_origin;
	vending_triggers[0].angles = custom_pap_angles;
}

actor_killed_response( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime, boneindex)
{
    level endon("end_game");
    if(is_true(level.explosive_zombies))
    {
        self radiusdamage(self.origin, 70, (eattacker.maxhealth / 2), (eattacker.maxhealth / 3));
        playfx(loadfx("explosions/fx_default_explosion"), self.origin );
    }
}

pack_scam()
{
    self endon("disconnect");
    level endon("end_game");

    currgun = self getcurrentweapon();
    if(!is_weapon_upgraded(currgun) && can_upgrade_weapon( currgun ))
    {
        self playsound("zmb_cha_ching");
        self takeweapon(currgun);
        gun = self maps\mp\zombies\_zm_weapons::get_upgrade_weapon( currgun, 0 );
        self giveweapon(self maps\mp\zombies\_zm_weapons::get_upgrade_weapon( currgun, 0 ), 0, self get_pack_a_punch_weapon_options(gun));
        self switchToWeapon(gun);
    }
    time = randomintrange(1,5);
    for(i=0;i<time;i++)
    {
        while(self maps\mp\zombies\_zm_laststand::player_is_in_laststand() || isdefined(self.afterlife) && self.afterlife)
        {
            wait .05;
        }
        wait 1;
    }
    self notify("scam_weapon");
    weap = self getcurrentweapon();
    weapon = maps\mp\zombies\_zm_weapons::get_base_weapon_name( weap, 1 );
    if ( isDefined( weapon ) && is_weapon_upgraded(weap))
    {
        self takeweapon( weap );
        self giveweapon( weapon, 0, self maps\mp\zombies\_zm_weapons::get_pack_a_punch_weapon_options( weapon ) );
        self givestartammo( weapon );
        self switchtoweapon( weapon );
    }
}

disable_aim()
{
    self endon("disconnect");
	level endon("end_game");
    self endon("end_task_progress");
    self allowads( 0 );
	for(i=0;i<30;i++)
	{
		while(self maps\mp\zombies\_zm_laststand::player_is_in_laststand() || isdefined(self.afterlife) && self.afterlife)
        {
            wait .05;
        }
		wait 1;
	}
    self allowads( 1 );
}

sprinting_issues()
{
    self endon("disconnect");
	level endon("end_game");
    self endon("end_task_progress");
    
	for(i=0;i<60;i++)
	{
		while(self maps\mp\zombies\_zm_laststand::player_is_in_laststand() || isdefined(self.afterlife) && self.afterlife)
        {
            wait .05;
        }
        self allowsprint( 0 );
		wait 0.25;
        self allowsprint( 1 );
        wait 0.25;
    }
    self allowsprint( 1 );
}
