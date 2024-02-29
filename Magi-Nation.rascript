// Magi-Nation (GBC)
// #ID = 4731
// md5: 1624f857098ca278b15629914f48352b

// At the moment, it seems like SRAM is perpetually mapped to Bank 0, and WRAM mapped to Bank 1
// Unfortunately the save file swaps between bank 0 or 2 so we can't reliably read SRAM
// Unfortunately the mGBA core doesn't mirror WRAM2-7 into address 0x10000-0x16000 
// so we cannot use this memory reliably
// Therefore the only useable memory for achievements is WRAM0, along with the MusyX data at $DF00

// The game has 4 different bytecode scripts running simultaneously, plus each Actor has 1-2 scripts
wScript_Master = 0xC706
wScript_Scroll = 0xC70D
wScript_System = 0xC714
wScript_Text = 0xC71B

// Build the wActor array
//wActorScriptA = []
//wActorScriptB = []
//wActor_00 = 0xC1BF
//wActor_Offset_ScriptA = 10
//wActor_Offset_ScriptB = 17
//for i in range(0, 0x2F) {
//    array_push(wActorScriptA, wActor_00 + wActor_Offset_ScriptA*i)
//    array_push(wActorScriptB, wActor_00 + wActor_Offset_ScriptB*i)
//}

// String buffer for text input
wText_StringBuffer = 0xC949
Battle_Source = wText_StringBuffer + 0 // Battle action source and targets
Battle_Target = wText_StringBuffer + 11
Treasure_Name = wText_StringBuffer + 1 // Starts at 0, but skip the (optional) item icon for simplicity


//////////////////////
// Helper Functions //
//////////////////////

// Only valid for ROM banks >= 1
function bank_address(address) => byte(address)*0x4000 - 0x4000 + word(address + 1)


////////////////////////////////
//  Bytecode Script Addresses //
////////////////////////////////

// Unique actions
function i2_logo_displayed() =>
    repeated(89,bank_address(wScript_Master) == 0x0AB260) // hdnload01.mgi Line 19, Delay(90)

function great_furok() =>
    bank_address(wScript_Text) == 0x053A0A // nrmvash11_txt.mgi Line 281, TextClose()

function leaf_cut() =>
    bank_address(wScript_Text) == 0x0AC508 // nrmvash12_txt.mgi Line 109, TextClose()
function blurry_scroll() =>
    bank_address(wScript_Text) == 0x066A01 // ororuins02_dr.mgi Line 22, TextClose()

function maelstrom() =>
    bank_address(wScript_Text) == 0x06B4D5 // cldlavatown14_txt.mgi Line 86, TextClose()

function energy_band() =>
    bank_address(wScript_Text) == 0x052835 // nrmglade09A_txt.mgi Line 187, TextClose()
function crystal_gloves() =>
    bank_address(wScript_Text) == 0x0746FC // wvegiashut01_txt.mgi Line 102, TextClose()
   
function geyser1() =>
    bank_address(wScript_Master) == 0x06A7F3 // nrmgeyser11.mgi Line 106, PalFade(0,15,32,0)
function geyser2() =>
    bank_address(wScript_Master) == 0x04ED51 // undgeyser09.mgi Line 136, PalFade(0,15,32,0)

function poop_gag() =>
    bank_address(wScript_System) == 0x0742C4 // wvegiashut01_dr.mgi Line 38, TextClose()

function morag_underneath_start() =>
    bank_address(wScript_Text) == 0x088DAE // undtown01_txt.mgi Line 380, TextClose()
function morag_underneath_end() =>
    bank_address(wScript_Text) == 0x088DB2 // undtown01_txt.mgi Line 386, TextIcon(ICON_MORAG)

// Repeatable actions

// Battle
function _tony_summon() =>
    bank_address(wScript_Text) == 0x130AF4 // battle_txt.mgi Line 954, TextClose()
function _magi_summon() =>
    bank_address(wScript_Text) == 0x130B09 // battle_txt.mgi Line 964, TextClose()
function _wild_appear() =>
    bank_address(wScript_Text) == 0x130B19 // battle_txt.mgi Line 974, TextClose()
function tony_wins() =>
    bank_address(wScript_Text) == 0x130B69 // battle_txt.mgi Line 1016, TextClose()

// Chests
function _get_treasure() =>
    bank_address(wScript_System) == 0x08805A // system.mgi Line 41, TextClose()

// Minigames
function _brub_points() =>
    bank_address(wScript_Text) == 0x0738E8 // undtown08.mgi Line 78, TextClose()
    // TODO undtown08_sct.mgi and also archery game
    // Need to differentiate between the two because same dialogue potentially

function mushroom_gag() =>
    bank_address(wScript_Text) == 0x0727E3 // undtown06.mgi Line 103, End()


///////////////////
// String Buffer //
///////////////////

function battle_source(source) => ascii_string_equals(Battle_Source, source)
function battle_target(target) => ascii_string_equals(Battle_Target, target)
function treasure_name(name) => ascii_string_equals(Treasure_Name, name)

// Convert 3-digit ascii to number
function number() =>
    (byte(wText_StringBuffer) - 0x30)*100 +
    (byte(wText_StringBuffer + 1) - 0x30)*10 +
    (byte(wText_StringBuffer + 2) - 0x30)

////////////
// Battle //
////////////


function tony_summon(creature) => _tony_summon() && battle_target(creature)
function magi_summon(magi, creature) => _magi_summon() && battle_source(magi) && battle_target(creature)
function wild_appear(creature) => _wild_appear() && battle_target(creature)


//////////
// Misc //
//////////

// Prevents achievements trigger before game init
// TODO SKIP GAME INIT CHECK FOR DEBUGGING PURPOSES
function game_init() => always_true() //i2_logo_displayed()

function get_treasure(name) => _get_treasure() && treasure_name(name)

//////////////////
// Achievements //
//////////////////

// Geysers //
achievement(
    title = "Hero of Naroom", points = 5,
    description = "Complete the first Shadow Geyser",
    id = 0, badge = "000000",
    trigger = game_init() && geyser1()
)
achievement(
    title = "Hero of the Underneath", points = 5,
    description = "Complete the second Shadow Geyser",
    id = 0, badge = "000000",
    trigger = game_init() && geyser2()
)

// Hero Abilities //
achievement(
    title = "You're the Best Around", points = 1,
    description = "Obtain the Energy Band.",
    id = 0, badge = "000000",
    trigger = game_init() && energy_band()
)
achievement(
    title = "But Where Do My Pinkies Go?", points = 1,
    description = "Obtain the Crystal Gloves.",
    id = 0, badge = "000000",
    trigger = game_init() && crystal_gloves()
)

// MiniGames //
achievement(
    title = "Brub Scrub", points = 10,
    description = "Score at least 50 points in Scrub the Brub.",
    id = 0, badge = "000000",
    trigger = game_init() && _brub_points() && (number() >= 50)
)


// Spells //
achievement(
    title = "Throw Leaves at Enemies", points = 1,
    description = "Obtain Leaf Cut.",
    id = 0, badge = "000000",
    trigger = game_init() && leaf_cut()
)
achievement(
    title = "Throw Healing at Friends", points = 1,
    description = "Obtain Grow.",
    id = 0, badge = "000000",
    trigger = game_init() && get_treasure("Grow        ")
)
achievement(
    title = "Rock and Roll[m]", points = 3,
    description = "Obtain Cave In.",
    id = 0, badge = "000000",
    trigger = game_init() && get_treasure("Cave In     ")
)
achievement(
    title = "Ready to Rumble[m]", points = 3,
    description = "Obtain Thunderquake.",
    id = 0, badge = "000000",
    trigger = game_init() && get_treasure("Thunderquake")
)
achievement(
    title = "Have Some Flame", points = 5,
    description = "Obtain Fireball.",
    id = 0, badge = "000000",
    trigger = game_init() && get_treasure("Fireball    ")
)
achievement(
    title = "After the Flame, Only Ashes Remain[m]", points = 3,
    description = "Obtain Flame Geyser.",
    id = 0, badge = "000000",
    trigger = game_init() && get_treasure("Flame Geyser")
)
achievement(
    title = "Abracadableeeerrrgh!", points = 3,
    description = "Obtain Entangle.",
    id = 0, badge = "000000",
    trigger = game_init() && get_treasure("Entangle    ")
)
achievement(
    title = "Not What You Expect", points = 1,
    description = "Obtain the Blurry Scroll.",
    id = 0, badge = "000000",
    trigger = game_init() && blurry_scroll()
)
achievement(
    title = "Bend Water to Your Will[m]", points = 3,
    description = "Obtain Tidal Wave.",
    id = 0, badge = "000000",
    trigger = game_init() && get_treasure("Tidal Wave  ")
)
achievement(
    title = "Zaptacular[m]", points = 3,
    description = "Obtain Lightning.",
    id = 0, badge = "000000",
    trigger = game_init() && get_treasure("Lightning   ")
)
achievement(
    title = "Winds of Protection[m]", points = 3,
    description = "Obtain Updraft.",
    id = 0, badge = "000000",
    trigger = game_init() && get_treasure("Updraft     ")
)

// Completionist //
achievement(
    title = "Great Furok[m]", points = 5,
    description = "Obtain a Great Furok by almost escaping the Tavel Gorge caves.",
    id = 0, badge = "000000",
    trigger = game_init() && great_furok()
)
achievement(
    title = "Solo Operative[m]", points = 10,
    description = "Obtain Maelstrom by defeating all the ShadowMagi without any help.",
    id = 0, badge = "000000",
    trigger = game_init() && maelstrom()
)

achievement(
    title = "Now THAT is a BIG Mushroom[m]", points = 50,
    description = "Encounter Ormagon.",
    id = 0, badge = "000000",
    trigger = game_init() && wild_appear("Ormagon   ")
)

// Fun //
achievement(
    title = "Outhouse[m]", points = 1,
    description = "Look inside Gia's 'storage shed'.",
    id = 0, badge = "000000",
    trigger = game_init() && poop_gag()
)

achievement(
    title = "Acquired Taste[m]", points = 1,
    description = "Eat 20 mushrooms.",
    id = 0, badge = "000000",
    trigger = game_init() && mushroom_gag()
)

// Battles //
achievement(
    title = "199 Borgors[m]", points = 100,
    description = "Defeat Morag at your first encounter.",
    id = 0, badge = "000000",
    trigger = game_init() && once(morag_underneath_start()) && never(morag_underneath_end()) && tony_wins()
)

// The Third Door - Unlock the third door.
// Step into the Dark Side - Visit the Core Ringsmith.
// Be the Very Best/Weebest - Defeat Salafy at her best.
// Savior - Cure Orwin.
// His Job is Done - 100% the game.
// Second Largest Screwdriver - Find the giant screwdriver.
// Truly a Wise Man - Listen to Oflardt's stories.

// Beast of the Deep - Obtain Megathan.
// Beast of the Sky - Obtain Orothan F.
// Guardian of the Region - Obtain any Hyren.
// Fancy Footwear - Obtain Agadon's Boots.
// Under the Sea - Obtain the Orothean Belt.
// Highway to Heaven - Obtain the Eye of the Storm.
// Hero of Naroom - Complete the first Shadow Geyser.
// Hero of the Underneath - Complete the second Shadow Geyser.
// Hero of Cald - Complete the third Shadow Geyser.
// Hero of Orothe - Complete the fourth Shadow Geyser.
// Hero of Arderial - Complete the fifth Shadow Geyser.
// Winners Never Lose - Defeat Agram.
// Scrub the Brub
// Avoid the Agovos
// Archery
// Haggle the ferryman
// Talk to every cat photo
// Craft first Hyren