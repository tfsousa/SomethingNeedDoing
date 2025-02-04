--[[
  Description: Updated Deliver and clean up script for using deliveroo and visland.
  Author: McVaxius
  Link: https://discord.com/channels/1162031769403543643/1162799234874093661/1190858719546835065

for the below table templates,.. the 2nd (last var)
0 return home to fc entrance, 1 return home to a bell, 2 don't return home, 3 is gridania inn, 4 limsa bell near aetheryte
]]

--enter in names of chars that can edit emblems are in same GC as the FC otherwise it will update the GC for 15k gil
--warning it will attempt to change the free company allegiance just in case. make sure the char has 15k gil
--3rd var here is the tag if you aroe changing it
local chars_EMBLEM = {
  {"First Last@Server", 0, "WHEEA"},
  {"First Last@Server", 0, "WHEEB"},
  {"First Last@Server", 0, "WHEEC"},
  {"First Last@Server", 0, "WHEED"},
  {"First Last@Server", 0, "WHEEE"}
}

--enter in names of characters that will be responsible for triggering FC Buffs
local chars_FCBUFF = {
  {"First Last@Server", 0},
  {"First Last@Server", 0},
  {"First Last@Server", 0},
  {"First Last@Server", 0},
  {"First Last@Server", 0}
}

--names of chars to do turnins
local chars_fn = {
 {"First Last@Server", 0},
 {"First Last@Server", 0},
 {"First Last@Server", 0},
 {"First Last@Server", 0},
 {"First Last@Server", 0},
 {"First Last@Server", 0},
 {"First Last@Server", 0},
 {"First Last@Server", 0}
}

-------------------------
--SCRIPT CONFIGURATION --
-------------------------
--Please read these, you could use this script to go randomize fc emblems for example instead of doing the full script
----------------------
--Behaviour Configs --
----------------------
rcuck_count   = 1	--0..n starting the counter at 1, this is in case your manually resuming or want to start at later index value instead of just commenting out parts of it
gachi_jumpy   = 0 	--0=no jump, 1=yes jump.  jump or not. sometimes navmesh goes through the shortcut in uldah and sometimes gets stuck getting to bells in housing districts
auto_eqweep   = 0	--0=no, 1=yes + job change.  Basically this will check to see if your on a DOH or DOL, if you are then it will scan your DOW/DOM and switch you to the highest level one you have, auto equip and save gearset. niche feature i like for myself . off by default
config_sell   = 0	--0=dont do anything,1=change char setting to not give dailog for non tradeables etc selling to npc, 2=reset setting back to yes check for non tradeables etc selling to npc. usecase for 1 and 2 are one time things for a cleaning run so that they can subsequently handle selling or not selling. this feature will be stripped out once limiana updaptes AR
nnl			  = 1   --leave the novicenetwork
----------------------
--Refueling Configs --
----------------------
restock_fuel  = 11111 --0=don't do anything, n>0 -> if we have less ceruleum fuel than this amount on a character that has repair materials, restock up to at least the restock_amt value on next line
restock_amt   = 66666 --n>0 minimum amount of total fuel to reach, when restocking
--------------------
--Process Configs --
--------------------
process_fc_buffs = 1	--0=no,1=yes. do we bother with fc buffs? turning this on will run the chars from chars_FCBUFF to turn on FC buffs
buy_fc_buffs     = 1 	--0=no,1=yes. do we refresh the buffs on this run?  turning this on will run the chars from chars_FCBUFF to buy FC buffs and it will attempt to buy "Seal Sweetener II" 15 times
process_players  = 1	--0=no,1=yes. do we run the actual GC turnins? turning this on will run the chars from chars_fn to go do seal turnins and process whatever deliveroo rules you setup
process_emblem   = 0	--0=no,1=yes. do we randomize the emblem on this run? turning this on will process the chars from chars_EMBLEM and go randomize their FC emblems. btw rank 7 FC gets additional crest unlocks. remember this has to be the FC leader
process_tags	 = 0	--0=no, 1=full randomize, 2=lowercase only, 3=uppercase only, 4=randomly full upper OR lowercase, 5=pick from emblem configuration list. remember this has to be the FC leader
--[[
------------------------
--SCRIPT REQUIREMENTS --
------------------------
Required Plogons:
Autoretainer
YesAlready
TextAdvance
Deliveroo
Visland
Vnavmesh
Simpletweaks
Something Need Doing (Croizat version)
-----------------
-SUPER IMPORTANT-
-----------------
Make sure _functions.lua exist in the snd folder. which should look something like this path %AppData%\\XIVLauncher\\pluginConfigs\\SomethingNeedDoing\\
get _functions.lua from same place as this script came from

-------------------------
--PLUGIN CONFIGURATIONS--
-------------------------
FFXIV itself -> make sure all login notifications are off. like help, achievements etc. this is unfortunately super annoying. you may need to login/out a few times to ensure no weird popups are appearing.
Simpletweaks -> Setup autoequip command, "/equipguud" or just use the default "/equiprecommended"
Simpletweaks -> Setup equipjob command, "/equipjob"
Simpletweaks -> targeting fix on
SND -> Turn off SND targeting
YesAlready -> Lists -> Edit company crest design.
YesAlready -> Lists -> Retire to an inn room.
YesAlready -> Lists -> Move to the company workshop
YesAlready -> Lists -> Change free company allegiance.
YesAlready -> YesNo -> /Pay the 15,000-gil fee to switch your company's allegiance to the.*/
YesAlready -> YesNo -> /Execute.*/
YesAlready -> YesNo -> /of ceruleum for.*/
YesAlready -> YesNo -> /Enter the estate.*/
YesAlready -> YesNo -> Save changes to crest design?

Optional:
YesAlready -> YesNo -> /Purchase the action .*/ 
(if you add above. remove the wait 2 and the line for yesno pcall for buying buffs)

--some ideas for next version
--https://discord.com/channels/1001823907193552978/1196163718216679514/1215227696607531078
--stop repeating code for returning home.. introduces danger of errors popping up

--FC TAG Randomizer?!?!
--FC Tag re-writer?!?!
]]


yield("/ays multi d")

loadfiyel = os.getenv("appdata").."\\XIVLauncher\\pluginConfigs\\SomethingNeedDoing\\_functions.lua"
functionsToLoad = loadfile(loadfiyel)
functionsToLoad()
DidWeLoadcorrectly()

--debug new stuff
--yield("FC Tag hehehe -> "..generateFiveDigitText(process_tags))
--yield("/pcraft stop")

-- Specify the path to your text file
--[[
	--some vestigial junk i may remove if not needed once i update script properly
	tempchar = GetCharacterName()
	tempchar = tempchar:match("%s*(.-)%s*") --remove spaces at start and end only
	tempchar = tempchar:gsub("%s", "")  --remove all spaces
	tempchar = tempchar:gsub("'", "")   --remove all apostrophes
]]

function Final_GC_Cleaning()
	--turn around in case we aren't facing the correct way
	--this attempts to target serpent or flame personnel or even storm.  assuming you have a separate line in a hotkey for each type.
	--the purpose of this section is to get your char to face the npcs and orient the camera properly. otherwise the rest of the script might die

	--no targeting needed with deliveroo
	--yield("/send KEY_3")
	--yield("/wait 1")
	--yield("/lockon on")
	--yield("/automove on")
	--yield("/wait 1")

	visland_stop_moving() --just in case we want to auto equip rq before dumping gear
	--deliveroo i choose you
	yield("/deliveroo enable")
	yield("/wait 1")

	--loop until deliveroo done
	dellyroo = true
	dellyroo = DeliverooIsTurnInRunning()
	dellycount = 0
	while dellyroo do
		yield("/wait 5")
		dellyroo = DeliverooIsTurnInRunning()
		dellycount = dellycount + 1
		yield("/echo Processing Retainer Abuser "..rcuck_count.."/"..#chars_fn)
		if dellycount > 100 then
			--this will solve getting stuck on deliveroo doing nothing while its enabled
			yield("/deliveroo disable")
			yield("/wait 2")
			ungabunga()
			yield("/deliveroo enable")
			yield("/wait 3")
			dellycount = 0
		end
	end

	--added 5 second wait here because sometimes they get stuck.
	yield("/wait 5")
	
	if nnl == 1 then
		yield("/novicenetworkleave")
	end
	
	--limsa aetheryte
	if chars_fn[rcuck_count][2] == 4 then
		return_to_limsa_bell()
		yield("/wait 8")
	end
	
	--if we are tp to inn. we will go to gridania yo
	if chars_fn[rcuck_count][2] == 3 then
		return_to_inn()
		yield("/wait 8")
	end
	
	--options 1 and 2 are fc estate entrance or fc state bell so thats only time we will tp to fc estate
	if chars_fn[rcuck_count][2] == 0 or chars_fn[rcuck_count][2] == 1 then
		return_to_fc()
	end

	--normal small house shenanigans
	if chars_fn[rcuck_count][2] == 0 then
		return_fc_entrance()
	end

	--retainer bell nearby shenanigans
	if chars_fn[rcuck_count][2] == 1 then
		return_fc_near_bell()
	end	
	
--[[ dumping out this part. opening venture coffers is kind of annoying waste of time. maybe we make it optional later -->TODO<--
	--Code for opening venture coffers
	yield("/wait 3")
	yield("/echo Number of Venture Coffers to open: "..GetItemCount(32161))
	VCnum = GetItemCount(32161)
	while (VCnum > 0) do
		--this is no longer reliable
		--yield("/item Venture Coffer")
		yield("/send X")
		yield("/wait 6")
		VCnum = GetItemCount(32161)
		yield("/echo Number of Venture Coffers left: "..GetItemCount(32161))
	end
	]]
	--yield("/autorun off")
	--Code for opening FC menu so allagan tools can pull the FC points
	yield("/freecompanycmd")
	yield("/wait 3")
end

--0th randomize the emblems if need be
--[[
[[notes for later
GetPlayerGC(), 1 = Maelstrom, 2 = Adder?, 3 = ImmortalFlames
GetFCGrandCompany(), text instead of enum of above
]]
if process_emblem == 1 or process_tags > 0 then
	for i=1, #chars_EMBLEM do
		yield("/echo "..chars_EMBLEM[i][1])
		yield("/ays relog " ..chars_EMBLEM[i][1])
   	    yield("/echo 15 second wait")
	    yield("/wait 15")
		yield("/waitaddon NamePlate <maxwait.600><wait.10>")
		--check if we are doing buy_fc_buffs or not
		yield("/wait 2")
		CharacterSafeWait()
		yield("/echo Processing Emblem randomizer -> "..i.."/"..#chars_EMBLEM)
		TeleportToGCTown()
		ZoneTransition()
		WalkToGC()

		--quickly change the GC for the FC
		yield("<wait.5>")
		yield("/target \"OIC Administrator\"")
		yield("/wait 0.5")
		yield("/lockon")
		yield("/wait 0.5")
		yield("/automove")
		yield("<wait.2>")
		yield("/interact")
		yield("<wait.4>")
		--all set
		ungabunga()	--quick escape in case we got stuck in menu

		 --now we get to the emblematizer
		if process_emblem == 1 then
			yield("<wait.5>")
			yield("/target \"OIC Officer of Arms\"")
			yield("/wait 0.5")
			yield("/lockon")
			yield("/wait 0.5")
			yield("/automove")
			yield("<wait.2>")
			yield("/interact")
			yield("<wait.3>")
			yield("/pcall FreeCompanyCrestEditor true 5 0 0")
			yield("<wait.2>")
			yield("/pcall FreeCompanyCrestEditor false 0")
			yield("<wait.2>")
		end

		--process tag changing
		--0=no, 1=full randomize, 2=lowercase only, 3=uppercase only, 4=randomly full upper OR lowercase, 5=pick from emblem configuration list. remember this has to be the FC leader
		if process_tags > 0 then
			tagnem = "Wheee"
			--random tag generator
			if process_tags < 5 then
				tagnem = generateFiveDigitText(process_tags)
			end
			if process_tags == 5 then
				tagnem = chars_EMBLEM[i][3]
			end
			--* do the actual tag assignment now
		end

		--if we are tp to inn. we will go to gridania yo
		if chars_EMBLEM[i][2] ~= 2 then
			if chars_EMBLEM[i][2] == 3 then
				return_to_inn()
				yield("/wait 8")
			end
			--options 1 and 2 are fc estate entrance or fc state bell so thats only time we will tp to fc estate
			if chars_EMBLEM[i][2] == 0 or chars_fn[rcuck_count][2] == 1 then
				return_to_fc()
			end
			--normal small house shenanigans
			if chars_EMBLEM[i][2] == 0 then
				return_fc_entrance()
			end
			--retainer bell nearby shenanigans
			if chars_EMBLEM[i][2] == 1 then
				return_fc_near_bell()
			end
		end
	 end
	yield("/wait 3")
end

--first turn on FC buffs
if process_fc_buffs == 1 then
	for i=1, #chars_FCBUFF do
		yield("/echo "..chars_FCBUFF[i][1])
		yield("/ays relog " ..chars_FCBUFF[i][1])
   	    yield("/echo 15 second wait")
	    yield("/wait 15")
		yield("/waitaddon NamePlate <maxwait.600><wait.10>")
		--check if we are doing buy_fc_buffs or not
		if buy_fc_buffs == 1 then
			yield("/wait 2")
			CharacterSafeWait()
			yield("/echo Processing FC Buff Manager "..i.."/"..#chars_FCBUFF)
			TeleportToGCTown()
			ZoneTransition()
			WalkToGC()
			 --now we buy the buff
			yield("<wait.5>")
			yield("/target \"OIC Quartermaster\"")
			yield("/wait 0.5")
			yield("/lockon")
			yield("/wait 0.5")
			yield("/automove")
			yield("<wait.2>")
			--yield("/send NUMPAD0")
			yield("/interact")
			yield("/pcall SelectString true 0 <wait.1>")
			yield("/pcall SelectString true 0 <wait.1>")

			buycount = 0
			while (buycount < 15) do
				yield("/pcall FreeCompanyExchange false 2 22u")
				yield("<wait.1>")
				yield("/pcall SelectYesno true 0")
				yield("<wait.1>")
				buycount = buycount + 1
			end
			ungabunga()	--quick escape in case we got stuck in menu

		end
		yield("/echo FC Seal Buff II")
		yield("/freecompanycmd <wait.1>")
		yield("/pcall FreeCompany false 0 4u <wait.1>")
		yield("/pcall FreeCompanyAction false 1 0u <wait.1>")
		yield("/pcall ContextMenu true 0 0 1u 0 0 <wait.1>")
		yield("/pcall SelectYesno true 0 <wait.1>")
			--if we are tp to inn. we will go to gridania yo
		if chars_FCBUFF[i][2] ~= 2 then
			if chars_FCBUFF[i][2] == 3 then
				return_to_inn()
				yield("/wait 8")
			end
			--options 1 and 2 are fc estate entrance or fc state bell so thats only time we will tp to fc estate
			if chars_FCBUFF[i][2] == 0 or chars_fn[rcuck_count][2] == 1 then
				return_to_fc()
			end
			--normal small house shenanigans
			if chars_FCBUFF[i][2] == 0 then
				return_fc_entrance()
			end
			--retainer bell nearby shenanigans
			if chars_FCBUFF[i][2] == 1 then
				return_fc_near_bell()
			end
		end
	 end
	yield("/wait 3")
end

--gc turn in
if process_players == 1 then
	for i=1, #chars_fn do
		yield("/echo Loading Characters for GC TURNIN -> "..chars_fn[i][1])
		yield("/echo Processing Retainer Abuser "..i.."/"..#chars_fn)
		yield("/ays relog " ..chars_fn[i][1])
		--yield("/echo 15 second wait")
		yield("/wait 2")
		CharacterSafeWait()
		 yield("/echo Processing Retainer Abuser "..i.."/"..#chars_fn)
		--before we dump gear lets check to see if we are on the right job or if we care about it.
		if config_sell == 1 then
			yield("/maincommand Item Settings")
			yield("/wait 0.5")
			yield("/pcall ConfigCharaItem true 18 288 0 u0")
			yield("/pcall ConfigCharaItem true 0")
			yield("/wait 0.5")
			yield("/pcall ConfigCharacter true 1")
		end
		if config_sell == 2 then
			yield("/maincommand Item Settings")
			yield("/wait 0.5")
			yield("/pcall ConfigCharaItem true 18 288 1 u0")
			yield("/pcall ConfigCharaItem true 0")
			yield("/wait 0.5")
			yield("/pcall ConfigCharacter true 1")
		end
		if auto_eqweep == 1 then
			if are_we_dol() then
				yield("/equipjob "..job_short(which_cj()))
				yield("/echo Switching to "..job_short(which_cj()))
				yield("/wait 3")
			end
		end
		TeleportToGCTown()
		ZoneTransition()
		yield("/echo Walk to GC attempt 1")
		yield("/wait 2")
		WalkToGC()
		yield("/echo Walk to GC attempt 2")
		yield("/wait 2")
		WalkToGC()
		yield("/echo Walk to GC attempt 3?")
		yield("/wait 2")
		WalkToGC()
		rcuck_count = i
		yield("/wait 2")
		Final_GC_Cleaning()
		if restock_fuel > 0 and GetItemCount(10373) > 0 and GetItemCount(10155) <= restock_fuel then
			try_to_buy_fuel(restock_amt)
		end
	end
end
--last one out turn off the lights
yield("/ays multi e")
yield("/pcraft stop")