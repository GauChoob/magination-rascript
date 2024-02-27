// Magi-Nation (GBC)
// #ID = 4731
// md5: 1624f857098ca278b15629914f48352b

// At the moment, it seems like SRAM is perpetually mapped to Bank 0, and WRAM mapped to Bank 1
// Unfortunately the save file can be stored in either bank 0 or 1 so we can't reliably read SRAM
// Unfortunately the mGBA core doesn't mirror WRAM2-7 into address 0x10000-0x16000 
// so we cannot use this memory reliably
// Therefore the only useable memory for achievements is WRAM0, along with the MusyX data at $DF00

// The game has 4 different bytecode scripts run in lockstep:
wScript_Master = 0xC706
wScript_Scroll = 0xC70D
wScript_System = 0xC714
wScript_Text = 0xC71B

// Battle action source and targets
//wText_StringBuffer = 0xC949 TODO change the next two labels
wText_StringBuffer_BattleSource = 0xC949
wText_StringBuffer_BattleTarget = 0xC954


//////////////////////
// Helper Functions //
//////////////////////

// Only valid for ROM banks >= 1
function bank_address(address) => byte(address)*0x4000 - 0x4000 + word(address + 1)


////////////////////////////////
//  Bytecode Script Addresses //
////////////////////////////////

function i2_logo_displayed() =>
    repeated(89,bank_address(wScript_Master) == 0x0AB260) // hdnload01.mgi Line 19, Delay(90)

function great_furok() =>
    bank_address(wScript_Text) == 0x053A0A // nrmvash11_txt.mgi Line 281, TextClose()

function leaf_cut() =>
    bank_address(wScript_Text) == 0x0AC508 // nrmvash12_txt.mgi Line 109, TextClose()

function energy_band() =>
    bank_address(wScript_Text) == 0x052835 // nrmglade09A_txt.mgi Line 187, TextClose()


function _tony_summon() =>
    bank_address(wScript_Text) == 0x130AF4 // battle_txt.mgi Line 954, TextClose()
    
function _magi_summon() =>
    bank_address(wScript_Text) == 0x130B09 // battle_txt.mgi Line 964, TextClose()

function _wild_appear() =>
    bank_address(wScript_Text) == 0x130B19 // battle_txt.mgi Line 974, TextClose()


////////////
// Battle //
////////////

function battle_source(source) => ascii_string_equals(wText_StringBuffer_BattleSource, source)
function battle_target(target) => ascii_string_equals(wText_StringBuffer_BattleTarget, target)

function tony_summon(creature) => _tony_summon() && battle_target(creature)
function magi_summon(magi, creature) => _magi_summon() && battle_source(magi) && battle_target(creature)
function wild_appear(creature) => _wild_appear() && battle_target(creature)


///////////
// Logic //
///////////

// Prevents achievements trigger before game init
// TODO SKIP GAME INIT CHECK FOR DEBUGGING PURPOSES
function game_init() => always_true() //i2_logo_displayed()


//////////////////
// Achievements //
//////////////////


// Progression //

// Missable/Sidequests //
achievement(
    title = "Great Furok[m]", points = 5,
    description = "Obtain a Great Furok by almost escaping the Tavel Gorge caves.",
    id = 0, badge = "000000",
    trigger = game_init() && great_furok()
)

achievement(
    title = "Now THAT is a BIG Mushroom", points = 50,
    description = "Encounter Ormagon.",
    id = 0, badge = "000000",
    trigger = game_init() && wild_appear("Ormagon   ")
)


// Spells //
achievement(
    title = "Throw Leaves at Enemies", points = 1,
    description = "Obtain Leaf Cut.",
    id = 0, badge = "000000",
    trigger = game_init() && leaf_cut()
)

// Hero Abilities //
achievement(
    title = "You're the Best Around", points = 1,
    description = "Obtain the Energy Band.",
    id = 0, badge = "000000",
    trigger = game_init() && energy_band()
)

// Other //

// The Third Door - Unlock the third door.
// Step into the Dark Side - Visit the Core Ringsmith.
// Be the Very Best/Weebest - Defeat Salafy at her best.
// Savior - Cure Orwin.
// His Job is Done - 100% the game.
// Second Largest Screwdriver - Find the giant screwdriver.
// Truly a Wise Man - Listen to Oflardt's stories.
// Throw Healing at Friends - Obtain Grow.
// Rock and Roll - Obtain Cave In.
// Ready to Rumble - Obtain Thunderquake.
// Have Some Flame - Obtain Fireball.
// After the Flame, Only Ashes Remain - Obtain Flame Geyser.
// Abracadableeeerrrgh! - Obtain Entangle.
// Not What You Expect - Obtain Dispel X.
// Bend Water to Your Will - Obtain Tidal Wave.
// Zaptacular - Obtain Lightning.
// Winds of Protection - Obtain Updraft.
// Beast of the Deep - Obtain Megathan.
// Beast of the Sky - Obtain Orothan F.
// Guardian of the Region - Obtain any Hyren.
// Welcome to the Moonlands - Obtain the Translation Bracelet.
// You're the Best Around - Obtain the Energy Band.
// But Where Do My Pinkies Go? - Obtain the Digging Gloves.
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
// Mushroom intox
// Haggle the ferryman
// Talk to every cat photo
// Craft first Hyren