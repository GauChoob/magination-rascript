// Magi-Nation (GBC)
// #ID = 4731
// md5: 1624f857098ca278b15629914f48352b

// Mapping reference: https://github.com/RetroAchievements/rcheevos/blob/cc854ad75b6533e73cff5eb7a92429c5750c01a3/src/rcheevos/consoleinfo.c#L422
// Unfortunately, only the first SRAM is mapped, and since the save file swaps between bank 0 and 2, we can't reliably read SRAM at the moment.
// WRAM0 and 1 are mapped.
// Gambatte, GearBoy, VGA-M, SameBoy and GBHawk all support WRAM2-7 at 0x10000-0x16000
// However, mGBA does not, meaning this memory location is core-dependant
// Therefore the only useable memory for achievements is WRAM0, along with WRAM1 (which only contains MusyX vars)
// This means that magi and creature stats and count, chests, spells, relics, glyph status, hero abilities are all locked out
// Even with access to WRAM2-7, we don't really gain much. We can read the scene map tiles and also read the battle state

// So basically we are mostly left with a few pointers to data tables and pointers to bytecode scripts
// For the majority of the achievements, we read the pointer address and don't read the actual text contents
// With the exception of item names in treasure chests and dream creature names, because we don't have any reliable alternative way of reading them
// without creating a patch, but in that case we are dropping support for the large majority of players who would play without a patch

// Reference source code: https://github.com/GauChoob/magination

//////////////////////
// Helper Functions //
//////////////////////

// Converts a ROM address from raw location to a bank_address. Only valid for ROM banks >= 1
// e.g. 0x047327 -> ROMX[0x11] 0x7327 -> 0x732711
function bank_address(raw_address) =>
    0x100*(raw_address - (raw_address / 0x4000 - 1)*0x4000) + (raw_address / 0x4000)

function changes_from(address, value) => (prev(address) == value) && (address != value)

//////////
// WRAM //
//////////

// The game has 4 different bytecode scripts running simultaneously,
// plus each Actor (up to 10 simultaneously) has 1-2 scripts, up to a maximum of 24 simultaneous threads
function wScript_Master() => tbyte(0xC706)
function wScript_Scroll() => tbyte(0xC70D)
function wScript_System() => tbyte(0xC714)
function wScript_Text() => tbyte(0xC71B)

// Build the wActor array
wActorState = []
wActorX = []
wActorY = []
wActorScriptA = []
wActorScriptB = []
wActor_00 = 0xC1BF
wActor_Offset_State = 1
wActor_Offset_X = 5
wActor_Offset_Y = 6
wActor_Offset_ScriptA = 10
wActor_Offset_ScriptB = 17
wActor_Size = 27
for i in range(0, 0x2F) {
    array_push(wActorState, word(wActor_00 + wActor_Size*i + wActor_Offset_State))
    array_push(wActorX, byte(wActor_00 + wActor_Size*i + wActor_Offset_X))
    array_push(wActorY, byte(wActor_00 + wActor_Size*i + wActor_Offset_Y))
    array_push(wActorScriptA, tbyte(wActor_00 + wActor_Size*i + wActor_Offset_ScriptA))
    array_push(wActorScriptB, tbyte(wActor_00 + wActor_Size*i + wActor_Offset_ScriptB))
}

wActorTony = 0xC189
function wActorTonyState() => word(wActorTony + wActor_Offset_State)
function wActorTonyX() => byte(wActorTony + wActor_Offset_X)
function wActorTonyY() => byte(wActorTony + wActor_Offset_Y)
function wActorTonyScriptA() => tbyte(wActorTony + wActor_Offset_ScriptA)
function wActorTonyScriptB() => tbyte(wActorTony + wActor_Offset_ScriptB)

// String buffer for text input
wText_StringBuffer = 0xC949
Creature_Name = wText_StringBuffer + 0 // Forging creature name
Battle_Source = wText_StringBuffer + 0 // Battle action source and targets
Battle_Target = wText_StringBuffer + 11
Treasure_Name = wText_StringBuffer + 1 // Starts at 0, but skip the first char which usually is an item icon, for simplicity

// Sound is initialized right after WRAM is wiped on reset
function wSound_SoundInit() => byte(0xC91D)
Sound_Init_MagicNumber = 0x55
// Requested SFX
function wSound_Control_SFX0() => byte(0xC921)
SFXID_CriticalAttack = 14


////////////////////////////////
//  Bytecode Script Addresses //
////////////////////////////////

// Unique Actions //
////////////////////


// Spells
function leaf_cut() =>
    wScript_Text() == bank_address(0x0AC508) // nrmvash12_txt.mgi Line 109, TextClose()
function blurry_scroll() =>
    wScript_System() == bank_address(0x066A01) // ororuins02_dr.mgi Line 22, TextClose()

// Relics
function maelstrom() =>
    wScript_Text() == bank_address(0x06B4D5) // cldlavatown14_txt.mgi Line 86, TextClose()

// Hero Abilities
function energy_band() =>
    wScript_Text() == bank_address(0x052835) // nrmglade09A_txt.mgi Line 187, TextClose()
function crystal_gloves() =>
    wScript_Text() == bank_address(0x0746FC) // wvegiashut01_txt.mgi Line 102, TextClose()
function agadons_boots() =>
    wScript_System() == bank_address(0x067B62) // orotunnel10_dr.mgi Line 29 TextClose()
function orothean_belt() =>
    wScript_Text() == bank_address(0x070E4C) // hldcell06.mgi Line 422, TextClose()
function eye_of_the_storm() =>
    wScript_Text() == bank_address(0x065746) // ardpalace01_txt.mgi Line 65, TextClose()

// Geyser completions
function geyser1() =>
    wScript_Master() == bank_address(0x06A7F3) // nrmgeyser11.mgi Line 106, PalFade(0,15,32,0)
function geyser2() =>
    wScript_Master() == bank_address(0x04ED51) // undgeyser09.mgi Line 136, PalFade(0,15,32,0)
function geyser3() =>
    wScript_Master() == bank_address(0x07FB09) // cldgeyser05.mgi Line 93, PalFade(0,15,32,0)
_geyser4 = bank_address(0x0612BC) // orogeyser12.mgi Line 34, PalFade(0,15,32,0)
function geyser4_nofight() =>
    wScript_Master() ==_geyser4
function geyser4_fight() =>
    wActorScriptA[0] ==_geyser4
function geyser5() =>
    wScript_Master() == bank_address(0x093F53) // ardgeyser28.mgi Line 50, PalFade(0,15,32,0)

// Boss fights
function morag_underneath_start() =>
    wScript_Text() == bank_address(0x088DAE) // undtown01_txt.mgi Line 380, TextClose()
function morag_underneath_end() =>
    wScript_Text() == bank_address(0x088DB2) // undtown01_txt.mgi Line 386, TextIcon(ICON_MORAG)
function zet_end() =>
    wScript_Text() == bank_address(0x09AD56) // cregate01_txt.mgi Line 66, TextClose()
function agram_end() =>
    wScript_Text() == bank_address(0x0568AC) // throne01_txt.mgi Line 66, TextIcon(ICON_AGRAM)

// Gags
function poop_gag() =>
    wScript_System() == bank_address(0x0742C4) // wvegiashut01_dr.mgi Line 38, TextClose()
function soap_gag() =>
    wScript_Text() == bank_address(0x074FE5) // wvegiashut01.mgi Line 463, TextClose()
function haggle() =>
    wScript_Text() == bank_address(0x0A97CD) // ferry01_txt.mgi Line 241, TextIcon(ICON_TONY)

// Misc
function i2_logo_displayed() =>
    wScript_Master() == bank_address(0x0AB260) // hdnload01.mgi Line 19, Delay(90)
function great_furok() =>
    wScript_Text() == bank_address(0x053A0A) // nrmvash11_txt.mgi Line 281, TextClose()
function cure_orwin() =>
    wScript_Text() == bank_address(0x08E2BA) // nrmvash15_sicko.mgi Line 521, TextIcon(ICON_ORWIN)
function party() =>
    wScript_Text() == bank_address(0x05A2DD) // nrmvash02_party.mgi Line 639, TextClose()
function evu_secret() =>
    wScript_Text() == bank_address(0x05A2DD) // nrmvash02_party.mgi Line 639, TextClose()
function new_game_plus() =>
    wScript_Text() == bank_address(0x0AAF63) // hdnload01_sct.mgi Line 63, TextClose()


// Repeatable Actions //
////////////////////////

// Battle
function _tony_summon() =>
    wScript_Text() == bank_address(0x130AF4) // battle_txt.mgi Line 954, TextClose()
function _magi_summon() =>
    wScript_Text() == bank_address(0x130B09) // battle_txt.mgi Line 964, TextClose()
function _wild_appear() =>
    wScript_Text() == bank_address(0x130B19) // battle_txt.mgi Line 974, TextClose()
function tony_wins() =>
    wScript_Text() == bank_address(0x130B69) // battle_txt.mgi Line 1016, TextClose()

function salafy_level4_start() =>
    wScript_System() == bank_address(0x0589DD) // vash_bat.mgi Line 23, TextIcon(ICON_SALAFY)
function salafy_win() =>
    wScript_Text() == bank_address(0x04D58F) // vash13.mgi Line 139, TextIcon(ICON_SALAFY)

// Chests
function _get_treasure() =>
    wScript_System() == bank_address(0x08805A) // system.mgi Line 41, TextClose()

// Minigames
function minigame_underneath_points() =>
    wScript_Text() == bank_address(0x0738E8) // undtown08.mgi Line 74, TextClose()
function minigame_cald_points() =>
    wScript_Text() == bank_address(0x073488) // undtown08_sct.mgi Line 68, TextClose()
function minigame_brub() =>
    wScript_Master() == bank_address(0x073A21) // undtown09.mgi Line 31, Sync(2,0)
function minigame_archery() =>
    wScript_Master() == bank_address(0x09A710) // nrmvash24.mgi Line 49, PalFade(0,15,32,0)

function archery_target_animite() =>
    wScript_Scroll() == bank_address(0x09A7EF) // nrmvash24.mgi Line 117, ScrollMap(2,2,0), (Frame-perfect)
function archery_target_slow() =>
    changes_from(wScript_Scroll(), bank_address(0x9A877)) // nrmvash24.mgi Line 161, Delay(10) (end, Frame-perfect)
function archery_target_medium() =>
    changes_from(wScript_Scroll(), bank_address(0x9A8B5)) // nrmvash24.mgi Line 176, Delay(10) (end, Frame-perfect)
function archery_target_fast() =>
    changes_from(wScript_Scroll(), bank_address(0x9A8F3)) // nrmvash24.mgi Line 191, Delay(10) (end, Frame-perfect)

function agovo_start() =>
    wScript_Master() == bank_address(0x05A7A3) // nrmvash02.mgi Line 379, TextClose()
function agovo_win() =>
    wScript_Master() == bank_address(0x05A393) // nrmvash02.mgi Line 77, TextWrite("You win!")
function agovo_lose() =>
    wScript_Master() == bank_address(0x05A381) // nrmvash02.mgi Line 67, TextWrite("You lose!")

// Forging Dream Creatures
function forge_naroom() =>
    wScript_Text() == bank_address(0x053CC1) // nrmvash11_txt.mgi Line 415, TextIcon(ICON_PRUITT)
function forge_underneath() =>
    wScript_Text() == bank_address(0x055495) // undcave08_txt.mgi Line 207, TextIcon(ICON_FOSSIK)
function forge_cald() =>
    wScript_Text() == bank_address(0x07B5CE) // caldlavatown12_txt.mgi Line 72, TextIcon(ICON_MAGAM)
function forge_orothe_city() =>
    wScript_Text() == bank_address(0x063053) // orocity04_txt.mgi Line 373, TextIcon(ICON_ORLON)
function forge_orothe_island() =>
    wScript_Text() == bank_address(0x06CC66) // oroislands04_txt.mgi Line 184, TextIcon(ICON_ORLON)
function forge_arderial() =>
    wScript_Text() == bank_address(0x069380) // ardgarden08_txt.mgi Line 373, TextIcon(ICON_LASADA)
function forge_core() =>
    wScript_Text() == bank_address(0x096525) // hdnroom01.mgi Line 207, TextIcon(ICON_CLOAK)

// Misc
function mushroom_gag() =>
    wScript_Text() == bank_address(0x0727E3) // undtown06.mgi Line 103, End()
function close_training_door() =>
    wScript_System() == bank_address(0x04C159) // nrmvash13_dr.mgi Line 241, TextClose()
function large_screwdriver() =>
    wScript_System() == bank_address(0x06DFF0) // hldmaze08_dr.mgi Line 67, TextClose()
function greet_coresmith() =>
    wScript_Text() == bank_address(0x0963C9) // hdnroom01.mgi Line 110, TextIcon(ICON_CLOAK)

// Actor //
///////////

// AI Frames (Bank 1 ROM)
AI_Anim = 0x4A6B
function tony_frozen() =>
    wActorTonyState() == AI_Anim

// Graphics Scripts
Brub_Squished_Anim = bank_address(0x0472C6) // objects_anim.mgi Line 383, Frame(32,0,0,?Brub_Splat)
RedBrub_Squished_Anim = bank_address(0x0047327) // objects_anim.mgi Line 422, Frame(32,0,0,?RedBrub_Splat)


///////////////////
// String Buffer //
///////////////////

function battle_source(source) => ascii_string_equals(Battle_Source, source)
function battle_target(target) => ascii_string_equals(Battle_Target, target)
function treasure_name(name) => ascii_string_equals(Treasure_Name, name)
function creature_name(name) => ascii_string_equals(Creature_Name, name)

// Convert 3-digit ascii to number
function number() =>
    (byte(wText_StringBuffer) - 0x30)*100 +
    (byte(wText_StringBuffer + 1) - 0x30)*10 +
    (byte(wText_StringBuffer + 2) - 0x30)


////////////
// Battle //
////////////

function tony_summon(creature) => _tony_summon() && battle_target(creature)
function magi_summon(magi, creature) => _magi_summon() && battle_source(magi) && battle_target(creature) // TODO unused and untested
function wild_appear(creature) => _wild_appear() && battle_target(creature)


//////////
// Misc //
//////////

// WRAM has been initialized
// Reset if i2 logo is displayed on soft reset (Select-Start-A-B, formatting game pak)
function game_init() =>
    (wSound_SoundInit() == Sound_Init_MagicNumber) &&
    never(i2_logo_displayed())

// Treasure chest item
function get_treasure(name) => _get_treasure() && treasure_name(name)

// Scrub the Brub and Aim for Animite
function brub_start() => once(minigame_brub()) && never(minigame_archery())
function archery_start() => once(minigame_archery()) && never(minigame_brub())
function brub_end() => minigame_underneath_points() || minigame_cald_points()
function archery_end() => minigame_cald_points()
// Actor00, 01, 02 are left, middle and right columns respectively
function brub_squish_blue(actorid) =>
    (wSound_Control_SFX0() == SFXID_CriticalAttack) && (wActorScriptB[actorid] == Brub_Squished_Anim) && (wActorTonyX() == 4 + 5*actorid)
function brub_squish_red(actorid) =>
    (wSound_Control_SFX0() == SFXID_CriticalAttack) && (wActorScriptB[actorid] == RedBrub_Squished_Anim) && (wActorTonyX() == 4 + 5*actorid)
function brub_count() => measured(tally(0, [
    brub_squish_blue(0),
    brub_squish_red(0),
    brub_squish_red(0),
    brub_squish_red(0),
    brub_squish_red(0),
    brub_squish_red(0),
    brub_squish_blue(1),
    brub_squish_red(1),
    brub_squish_red(1),
    brub_squish_red(1),
    brub_squish_red(1),
    brub_squish_red(1),
    brub_squish_blue(2),
    brub_squish_red(2),
    brub_squish_red(2),
    brub_squish_red(2),
    brub_squish_red(2),
    brub_squish_red(2),
]))
// Perhaps there's a chance of giving an unecessary point for a slow/medium/fast target hit within 10 frames of the scene ending, but I don't think it is possible.
function archery_count() => measured(tally(0, [
    archery_target_slow(),
    archery_target_medium(),
    archery_target_medium(),
    archery_target_fast(),
    archery_target_fast(),
    archery_target_fast(),
    archery_target_animite(),
    archery_target_animite(),
    archery_target_animite(),
    archery_target_animite(),
    archery_target_animite(),
]))

// Forging a dream creature
forge_location = {
    "Naroom": forge_naroom(),
    "Underneath": forge_underneath(),
    "Cald": forge_cald(),
    "Orothe": (forge_orothe_city() || forge_orothe_island()),
    "Arderial": forge_arderial(),
    "Core": forge_core()
}
function forge(location, creature) =>
    forge_location[location] && creature_name(creature)



//////////////////
// Achievements //
//////////////////

// The achievement covers pretty much all possible progression and all secrets, except for:
// Blast urn rooms (requires SRAM ideally so not currently doable in a smart fashion)
// Saving the 8 Shadowhold prisoners and obtaining their gifts (requires SRAM so not currently doable)
// Opening all chests in all locations (requires SRAM so not currently doable, and not sure if actually a good achievement idea)
// Refusing to fight Agadon (bad ending)
// Orwin's funeral (normal bonus ending)
// Taking the easy vs hard way with Warrada (not sure if actually a good achievement idea)
// Note that the Arderial and Core hyrens are unobtainable in the game

// Geysers //
/////////////
achievement(
    title = "Hero of Naroom", points = 5,
    description = "Complete the first Shadow Geyser.",
    id = 404343, badge = "000000",
    trigger = game_init() && geyser1()
)
achievement(
    title = "Hero of the Underneath", points = 5,
    description = "Complete the second Shadow Geyser.",
    id = 404344, badge = "000000",
    trigger = game_init() && geyser2()
)
achievement(
    title = "Hero of the Cald", points = 5,
    description = "Complete the third Shadow Geyser.",
    id = 404345, badge = "000000",
    trigger = game_init() && geyser3()
)
achievement(
    title = "Hero of Orothe", points = 10,
    description = "Complete the fourth Shadow Geyser.",
    id = 404346, badge = "000000",
    trigger = game_init() && (geyser4_fight() || geyser4_nofight())
)
achievement(
    title = "Hero of Arderial", points = 10,
    description = "Defeat Morag.",  // Avoid spoilers
    id = 404347, badge = "000000",
    trigger = game_init() && geyser5()
)
achievement(
    title = "Hero of Magi-Nation", points = 25,
    description = "Defeat Agram.",
    id = 404348, badge = "000000",
    trigger = game_init() && agram_end()
)

// Hero Abilities //
////////////////////
achievement(
    title = "You're the Best Around", points = 1,
    description = "Obtain the Energy Band.",
    id = 404349, badge = "000000",
    trigger = game_init() && energy_band()
)
achievement(
    title = "But Where Do My Pinkies Go?", points = 1,
    description = "Obtain the Crystal Gloves.",
    id = 404350, badge = "000000",
    trigger = game_init() && crystal_gloves()
)
achievement(
    title = "Fancy Footwear", points = 2,
    description = "Obtain Agadon's Boots.",
    id = 404351, badge = "000000",
    trigger = game_init() && agadons_boots()
)
achievement(
    title = "Under the Sea", points = 2,
    description = "Obtain the Orothean Belt.",
    id = 404352, badge = "000000",
    trigger = game_init() && orothean_belt()
)
achievement(
    title = "Highway to Heaven", points = 3,
    description = "Meet the Queen.",  // Avoid spoilers
    id = 404353, badge = "000000",
    trigger = game_init() && eye_of_the_storm()
)

// MiniGames //
///////////////
achievement(
    title = "Brub Scrub", points = 10,
    description = "Score at least 50 points in Scrub the Brub.",
    id = 404354, badge = "000000",
    trigger = game_init() && brub_start() && brub_end() && (number() >= 50) // use number() instead of brub_count() since we only need to check the total score at the end
)
achievement(
    title = "Brub Elite", points = 25,
    description = "Score at least 60 points in Scrub the Brub.",
    id = 404355, badge = "000000",
    trigger = game_init() && brub_start() && brub_end() && (number() >= 60) // use number() instead of brub_count() since we only need to check the total score at the end
)
leaderboard(
    title = "Scrub the Brub",
    description = "Highest points in Scrub the Brub.",
    start = game_init() && brub_start() && never(brub_end()),
    cancel = always_false(),
    submit = brub_end(),
    value = brub_count(), // use brub_count() instead of number() so we can keep track of score during the minigame
    format = "VALUE",
    lower_is_better = false,
    id = 300
)

achievement(
    title = "Aim for Tickets", points = 10,
    description = "Score at least 50 points in Aim for Animite.",
    id = 404356, badge = "000000",
    trigger = game_init() && archery_start() && archery_end() && (number() >= 50) // use number() instead of archery_count() since we only need to check the total score at the end
)
achievement(
    title = "Bullseye", points = 25,
    description = "Score at least 60 points in Aim for Animite.",
    id = 404357, badge = "000000",
    trigger = game_init() && archery_start() && archery_end() && (number() >= 60) // use number() instead of archery_count() since we only need to check the total score at the end
)
leaderboard(
    title = "Aim for Animite",
    description = "Highest points in Aim for Animite.",
    start = game_init() && archery_start() && never(archery_end()),
    cancel = always_false(),
    submit = archery_end(),
    value = archery_count(), // use archery_count() instead of number() so we can keep track of score during the minigame
    format = "VALUE",
    lower_is_better = false,
    id = 310
)

achievement(
    title = "Speedy Tony", points = 10,
    description = "Beat Avoid the Agovos in under 7.7 seconds.", // 7.7*60 = 462
    id = 404358, badge = "000000",
    trigger = game_init() && disable_when(repeated(462, !tony_frozen()), until=agovo_start()) && agovo_win()
)
achievement(
    title = "Flash Tony", points = 25,
    description = "Beat Avoid the Agovos in under 7.4 seconds.", // 7.4*60 = 444
    id = 404359, badge = "000000",
    trigger = game_init() && disable_when(repeated(444, !tony_frozen()), until=agovo_start()) && agovo_win()
)
leaderboard(
    title = "Avoid the Agovos",
    description = "Fastest time in Avoid the Agovos.",
    start = game_init() && once(agovo_start()) && never(agovo_lose()) && never(agovo_win()),
    cancel = agovo_lose(),
    submit = agovo_win(),
    value = always_true(),
    format = "FRAMES",
    lower_is_better = true,
    id = 320
)

// Spells //
////////////
achievement(
    title = "Throw Leaves at Enemies", points = 1,
    description = "Obtain Leaf Cut in Naroom.",
    id = 404360, badge = "000000",
    trigger = game_init() && leaf_cut()
)
achievement(
    title = "Throw Healing at Friends", points = 1,
    description = "Obtain Grow in Naroom.",
    id = 404361, badge = "000000",
    trigger = game_init() && get_treasure("Grow        ")
)
achievement(
    title = "Rock and Roll [m]", points = 3,
    description = "Obtain Cave In in the second Shadow Geyser.",
    id = 404362, badge = "000000",
    trigger = game_init() && get_treasure("Cave In     ")
)
achievement(
    title = "Ready to Rumble [m]", points = 3,
    description = "Obtain Thunderquake in the second Shadow Geyser.",
    id = 404363, badge = "000000",
    trigger = game_init() && get_treasure("Thunderquake")
)
achievement(
    title = "Have Some Flame", points = 5,
    description = "Obtain Fireball in the Cald.",
    id = 404364, badge = "000000",
    trigger = game_init() && get_treasure("Fireball    ")
)
achievement(
    title = "After the Flame, Only Ashes Remain [m]", points = 2,
    description = "Obtain Flame Geyser in the third Shadow Geyser.",
    id = 404365, badge = "000000",
    trigger = game_init() && get_treasure("Flame Geyser")
)
achievement(
    title = "Abracadableeeerrrgh!", points = 1,
    description = "Obtain Entangle in Orothe.",
    id = 404366, badge = "000000",
    trigger = game_init() && get_treasure("Entangle    ")
)
achievement(
    title = "Not What You Expect", points = 1,
    description = "Obtain the Blurry Scroll in Orothe.",
    id = 404367, badge = "000000",
    trigger = game_init() && blurry_scroll()
)
achievement(
    title = "Bend Water to Your Will [m]", points = 3,
    description = "Obtain Tidal Wave in the fourth Shadow Geyser.",
    id = 404368, badge = "000000",
    trigger = game_init() && get_treasure("Tidal Wave  ")
)
achievement(
    title = "Zaptacular [m]", points = 3,
    description = "Obtain Lightning before facing Morag.", // Avoid spoilers
    id = 404369, badge = "000000",
    trigger = game_init() && get_treasure("Lightning   ")
)
achievement(
    title = "Winds of Protection [m]", points = 3,
    description = "Obtain Updraft before facing Morag.", // Avoid spoilers
    id = 404370, badge = "000000",
    trigger = game_init() && get_treasure("Updraft     ")
)

// Completionist //
///////////////////
achievement(
    title = "Great Furok [m]", points = 5,
    description = "Obtain a Great Furok by almost escaping the Tavel Gorge caves.",
    id = 404371, badge = "000000",
    trigger = game_init() && great_furok()
)
achievement(
    title = "Solo Operative [m]", points = 10,
    description = "Obtain Maelstrom by defeating all the ShadowMagi without any help.",
    id = 404372, badge = "000000",
    trigger = game_init() && maelstrom()
)
achievement(
    title = "Skeleton Key [m]", points = 5,
    description = "Find the Channeled Gem using Ashgar's Key.",
    id = 404373, badge = "000000",
    trigger = game_init() && get_treasure("ChanneledGem")
)
achievement(
    title = "Second Largest Screwdriver [m]", points = 25,
    description = "Examine the large screwdriver near some Jingjacks.", // No spoilers
    id = 404374, badge = "000000",
    trigger = game_init() && large_screwdriver()
)
achievement(
    title = "Savior [m]", points = 50,
    description = "Cure Orwin.",
    id = 404375, badge = "000000",
    trigger = game_init() && cure_orwin()
)
achievement(
    title = "Celebration [m]", points = 10,
    description = "After defeating Agram, attend the party instead of going home.",
    id = 404376, badge = "000000",
    trigger = game_init() && party()
)
achievement(
    title = "Simpsons Homage [m]", points = 10,
    description = "Do everything at the Naroom party before leaving.",
    id = 404377, badge = "000000",
    trigger = game_init() && evu_secret()
)
achievement(
    title = "The Third Door [m]", points = 5,
    description = "Unlock New Game Plus.",
    id = 404378, badge = "000000",
    trigger = game_init() && new_game_plus()
)
achievement(
    title = "Dark Side [m]", points = 50,
    description = "Visit the Core Ringsmith.",
    id = 404379, badge = "000000",
    trigger = game_init() && greet_coresmith()
)

// Dream Creatures //
/////////////////////
achievement(
    title = "Leaves that Cut", points = 10,
    description = "Forge Leaf Hyren.",
    id = 404380, badge = "000000",
    trigger = game_init() && forge("Naroom", "Leaf Hyren")
)
achievement(
    title = "Tree Power", points = 10,
    description = "Forge Timber Hyren.",
    id = 404394, badge = "000000",
    trigger = game_init() && forge("Naroom", "TimberHyrn")
)
achievement(
    title = "Pummel Party", points = 10,
    description = "Forge Mush Hyren.",
    id = 404381, badge = "000000",
    trigger = game_init() && forge("Underneath", "Mush Hyren")
)
achievement(
    title = "Bury Your Foes", points = 10,
    description = "Forge Cave Hyren.",
    id = 404382, badge = "000000",
    trigger = game_init() && forge("Underneath", "Cave Hyren")
)
achievement(
    title = "Flightless Wings [m]", points = 10,
    description = "Forge Magma Hyren.",
    id = 404383, badge = "000000",
    trigger = game_init() && forge("Cald", "MagmaHyren")
)
achievement(
    title = "Purifying Flame [m]", points = 10,
    description = "Forge Flame Hyren.",
    id = 404384, badge = "000000",
    trigger = game_init() && forge("Cald", "FlameHyren")
)
achievement(
    title = "Sitting Pretty", points = 10,
    description = "Forge Coral Hyren.",
    id = 404385, badge = "000000",
    trigger = game_init() && forge("Orothe", "CoralHyren")
)
achievement(
    title = "Ruler of the Depths", points = 10,
    description = "Forge Deep Hyren.",
    id = 404395, badge = "000000",
    trigger = game_init() && forge("Orothe", "Deep Hyren")
)
achievement(
    title = "Beast of the Sea", points = 10,
    description = "Forge Megathan.",
    id = 404386, badge = "000000",
    trigger = game_init() && forge("Orothe", "Megathan  ")
)
achievement(
    title = "Wind Fish", points = 10,
    description = "Forge Orathan F.",
    id = 404387, badge = "000000",
    trigger = game_init() && forge("Arderial", "Orathan F ")
)
achievement(
    title = "Now THAT is a BIG Mushroom [m]", points = 100,
    description = "Encounter Ormagon.",
    id = 404388, badge = "000000",
    trigger = game_init() && wild_appear("Ormagon   ")
)

// Fun //
/////////
achievement(
    title = "Outhouse [m]", points = 1,
    description = "Look inside Gia's 'storage shed'.",
    id = 404396, badge = "000000",
    trigger = game_init() && poop_gag()
)
achievement(
    title = "Acquired Taste [m]", points = 3,
    description = "Eat 20 mushrooms.",
    id = 404389, badge = "000000",
    trigger = game_init() && mushroom_gag()
)
achievement(
    title = "So That's Where Soap Comes From [m]", points = 1,
    description = "Tell Eidon about Oflardt's stories.",
    id = 404390, badge = "000000",
    trigger = game_init() && soap_gag()
)
achievement(
    title = "Bargainer [m]", points = 3,
    description = "Haggle the ferryman down to his lowest price.",
    id = 404391, badge = "000000",
    trigger = game_init() && haggle()
)
achievement(
    title = "Gentleman Thief [m]", points = 5,
    description = "Close the training equipment door after opening it.",
    id = 404397, badge = "000000",
    trigger = game_init() && close_training_door()
)


// Battles //
/////////////
achievement(
    title = "199 Borgors [m]", points = 100,
    description = "Defeat Morag at your first encounter.",
    id = 404392, badge = "000000",
    trigger = game_init() && once(morag_underneath_start()) && never(morag_underneath_end()) && tony_wins()
)
achievement(
    title = "Two Stooges", points = 10,
    description = "Meet Korg and Zet for the last time.",
    id = 404393, badge = "000000",
    trigger = game_init() && zet_end()
)
achievement(
    title = "Weebest", points = 25,
    description = "Defeat Salafy at her hardest difficulty.",
    id = 404398, badge = "000000",
    trigger = game_init() && once(salafy_level4_start()) && salafy_win()
)


///////////////////
// Rich Presence //
///////////////////

// The scene id/menu/battle status isn't directly kept track in any variable but we can reasonably guess it using the loaded hotspots
// One scene can have multiple different hotspot tables depending on how you get to the specific scene and the game progress
// Some scenes don't load any hotspots at all, but this is rare and limite
// Hotspot tables are located in bank 0x21
function wHotspot_Table() => word(0xC6DF)
// Autogenerated from hotspot_parser.py
hotspot_lookup = {
    0x0000: "Splash Screen",
    0x4001: "Naroom Grove",   // HS_NRMGLADE01
    0x400A: "Naroom Grove",   // HS_NRMGLADE01F
    0x4018: "Naroom Grove",   // HS_NRMGLADE02
    0x4021: "Naroom Grove",   // HS_NRMGLADE02F
    0x402A: "Naroom Grove",   // HS_NRMGLADE02FA
    0x4033: "Vash Naroom",   // HS_NRMGLADE03
    0x4040: "Naroom Glade",   // HS_NRMGLADE04
    0x404E: "Naroom Glade",   // HS_NRMGLADE05
    0x405C: "Naroom Glade",   // HS_NRMGLADE06
    0x4069: "Naroom Glade",   // HS_NRMGLADE07
    0x4073: "Naroom Glade",   // HS_NRMGLADE08
    0x407C: "Naroom Geyser",   // HS_NRMGLADE09A
    0x4085: "Naroom Cave",   // HS_NRMGLADE10
    0x408E: "Naroom Forest",   // HS_NRMGLADE11
    0x4097: "Naroom Forest",   // HS_NRMGLADE11B
    0x40AD: "Naroom Forest",   // HS_NRMGLADE11C
    0x40BF: "Naroom Forest",   // HS_NRMGLADE11RET
    0x40CC: "Naroom Geyser",   // HS_NRMGEYSER01
    0x40D9: "Naroom Geyser",   // HS_NRMGEYSER02
    0x40EB: "Naroom Geyser",   // HS_NRMGEYSER03
    0x40F9: "Naroom Geyser",   // HS_NRMGEYSER04
    0x410B: "Naroom Geyser",   // HS_NRMGEYSER05
    0x4121: "Naroom Geyser",   // HS_NRMGEYSER06
    0x413F: "Naroom Geyser",   // HS_NRMGEYSER07
    0x414D: "Naroom Geyser",   // HS_NRMGEYSER08
    0x415B: "Naroom Geyser",   // HS_NRMGEYSER09
    0x416D: "Naroom Geyser",   // HS_NRMGEYSER10
    0x4176: "Naroom Geyser",   // HS_NRMGEYSER11
    0x417B: "Naroom Geyser",   // HS_NRMGEYSER12
    0x4189: "Naroom Forest",   // HS_NRMFOREST01
    0x4196: "Naroom Forest",   // HS_NRMFOREST02
    0x419F: "Naroom Forest",   // HS_NRMFOREST03
    0x41A8: "Naroom Forest",   // HS_NRMFOREST04
    0x41BA: "Naroom Forest",   // HS_NRMFOREST05
    0x41C4: "Wence's House",   // HS_NRMFOREST06
    0x41D2: "Wence's House",   // HS_NRMFOREST07
    0x41E0: "Seer's House",   // HS_NRMLAKE01
    0x41FA: "Seer's House",   // HS_NRMLAKE02
    0x4204: "Seer's House",   // HS_NRMLAKE03
    0x420D: "Under the Seer's House",   // HS_NRMLAKE04
    0x421B: "Under the Seer's House",   // HS_NRMLAKE05
    0x4224: "Under the Seer's House",   // HS_NRMLAKE06
    0x4229: "Naroom Grove",   // HS_NRMRIVER01
    0x4232: "Naroom Grove",   // HS_NRMRIVER01_OPENING
    0x423B: "Naroom Grove",   // HS_NRMRIVER02
    0x4249: "Hacking! Developer's Secret Room",   // HS_NRMRIVER03
    0x4272: "Vash Naroom",   // HS_NRMVASH01
    0x427F: "Vash Naroom",   // HS_NRMVASH02
    0x4299: "Avoid the Agovos",   // HS_NRMVASH02_SCT
    0x42AB: "Avoid the Agovos",   // HS_HDNROOM05
    0x42B5: "Vash Naroom",   // HS_NRMVASH03
    0x42C7: "Vash Naroom",   // HS_NRMVASH04
    0x42E5: "Vash Naroom",   // HS_NRMVASH04B
    0x42EE: "Vash Naroom",   // HS_NRMVASH04C
    0x42F7: "Vash Naroom",   // HS_NRMVASH05
    0x431D: "Vash Naroom",   // HS_NRMVASH06
    0x432A: "Vash Naroom",   // HS_NRMVASH06B
    0x433C: "Vash Naroom",   // HS_NRMVASH07
    0x4345: "Vash Naroom",   // HS_NRMVASH08
    0x4352: "Vash Naroom",   // HS_NRMVASH09
    0x435B: "Vash Naroom",   // HS_NRMVASH09B
    0x4364: "Vash Naroom",   // HS_NRMVASH09C
    0x436D: "Vash Naroom",   // HS_NRMVASH09D
    0x4393: "Vash Naroom",   // HS_NRMVASH10
    0x43B1: "Vash Naroom",   // HS_NRMVASH11
    0x43C7: "Vash Naroom",   // HS_NRMVASH12
    0x43ED: "Training Grounds",   // HS_NRMVASH13_INTRO
    0x4402: "Training Grounds",   // HS_NRMVASH13
    0x4424: "Vash Naroom",   // HS_NRMVASH14
    0x443A: "Vash Naroom",   // HS_NRMVASH15
    0x444C: "Vash Naroom",   // HS_NRMVASH16
    0x4456: "Vash Naroom",   // HS_NRMVASH17
    0x4470: "Vash Naroom",   // HS_NRMVASH18
    0x448A: "Vash Naroom",   // HS_NRMVASH19
    0x44A4: "Vash Naroom",   // HS_NRMVASH20
    0x44C7: "Vash Naroom",   // HS_NRMVASH22
    0x44D1: "Vash Naroom",   // HS_NRMVASH23
    0x44F3: "Aim for Animite",   // HS_NRMVASH24
    0x44FD: "Naroom Forest",   // HS_NRMTOWEAVE01
    0x4506: "Bogrom",   // HS_UNDTOWN01
    0x453C: "Bogrom",   // HS_UNDTOWN01B
    0x456D: "Bogrom",   // HS_UNDTOWN02
    0x4587: "Bogrom",   // HS_UNDTOWN03
    0x45A9: "Bogrom",   // HS_UNDTOWN04
    0x45BF: "Bogrom",   // HS_UNDTOWN05
    0x45D1: "Bogrom",   // HS_UNDTOWN06
    0x45F3: "Bogrom",   // HS_UNDTOWN07
    0x4611: "Brub House",   // HS_UNDTOWN08
    0x4616: "Brub House",   // HS_UNDTOWN08B
    0x4645: "Scrub the Brub",   // HS_UNDTOWN09
    0x4646: "Underneath Tunnels",   // HS_UNDTUNNEL01
    0x4653: "Underneath Tunnels",   // HS_UNDTUNNEL02
    0x4660: "Underneath Tunnels",   // HS_UNDTUNNEL03
    0x4669: "Underneath Tunnels",   // HS_UNDTUNNEL04
    0x4672: "Underneath Tunnels",   // HS_UNDTUNNEL05
    0x467F: "Underneath Tunnels",   // HS_UNDTUNNEL06
    0x4691: "Underneath Tunnels",   // HS_UNDTUNNEL07
    0x469A: "Underneath Tunnels",   // HS_UNDTUNNEL08
    0x46A3: "Underneath Tunnels",   // HS_UNDTUNNEL09
    0x46AC: "Underneath Tunnels",   // HS_UNDTUNNEL10
    0x46B5: "Underneath Tunnels",   // HS_UNDTUNNEL11
    0x46BE: "Underneath Tunnels",   // HS_UNDTUNNEL12
    0x46C8: "Underneath Tunnels",   // HS_UNDTUNNEL13
    0x46D1: "Underneath Tunnels",   // HS_UNDTUNNEL14
    0x46DE: "Underneath Tunnels",   // HS_UNDTUNNEL15
    0x46E7: "Underneath Tunnels",   // HS_UNDTUNNEL16
    0x46F8: "Underneath Tunnels",   // HS_UNDTUNNEL17
    0x4702: "Underneath Tunnels",   // HS_UNDTUNNEL18
    0x470F: "Underneath Tunnels",   // HS_HDNUNDTUN02
    0x4719: "Underneath Tunnels",   // HS_UNDTUNNEL19
    0x472A: "Underneath Tunnels",   // HS_UNDTUNNEL20
    0x4738: "Underneath Tunnels",   // HS_UNDTUNNEL21
    0x4745: "Underneath Tunnels",   // HS_HDNUNDTUN03
    0x474E: "Underneath Tunnels",   // HS_HDNUNDTUN04
    0x475C: "Underneath Tunnels",   // HS_UNDTUNNEL22
    0x476D: "Underneath Tunnels",   // HS_HDNUNDTUN01
    0x477B: "Underneath Tunnels",   // HS_UNDTUNNEL23
    0x4788: "Underneath Tunnels",   // HS_UNDTUNNEL24
    0x4791: "Gruk's Mushroom Farm",   // HS_UNDMUSHFARM01
    0x479A: "Gruk's Mushroom Farm",   // HS_UNDMUSHFARM02
    0x47B4: "Gruk's Mushroom Farm",   // HS_UNDMUSHFARM03
    0x47CE: "Underneath Caverns",   // HS_UNDCAVERN01
    0x47DB: "Underneath Caverns",   // HS_UNDCAVERN02
    0x47F1: "Underneath Caverns",   // HS_UNDCAVERN03
    0x4813: "Underneath Caverns",   // HS_UNDCAVERN03_SECRET
    0x4825: "Underneath Caverns",   // HS_UNDCAVERN11
    0x482A: "Underneath Caverns",   // HS_UNDCAVERN04
    0x4837: "Underneath Caverns",   // HS_UNDCAVERN05
    0x4840: "Underneath Geyser",   // HS_UNDCAVERN06
    0x4855: "Prospector Garage",   // HS_UNDCAVERN07
    0x485E: "Prospector Garage",   // HS_UNDCAVERN08
    0x487C: "Underneath Geyser",   // HS_UNDGEYSER01
    0x4896: "Underneath Geyser",   // HS_UNDGEYSER02
    0x48D0: "Underneath Geyser",   // HS_UNDGEYSER03
    0x48DA: "Underneath Geyser",   // HS_UNDGEYSER04
    0x48E7: "Underneath Geyser",   // HS_UNDGEYSER05
    0x490D: "Underneath Geyser",   // HS_UNDGEYSER06
    0x4933: "Underneath Geyser",   // HS_UNDGEYSER07
    0x493D: "Underneath Geyser",   // HS_UNDGEYSER08
    0x4973: "Underneath Geyser",   // HS_UNDGEYSER09
    0x499D: "Core",   // HS_THRONE01
    0x49A6: "Core",   // HS_THRONE02
    0x49AF: "Core",   // HS_THRONE03
    0x49B8: "Core",   // HS_THRONE04
    0x49C1: "Core",   // HS_THRONE05
    0x49CF: "Core",   // HS_THRONE06
    0x49D8: "Core Entrance",   // HS_CREGATE01
    0x49EA: "Ashyn",   // HS_CLDLAVAPOOL01
    0x49F7: "Ashyn",   // HS_CLDLAVATOWN01
    0x4A30: "Ashyn",   // HS_CLDLAVATOWN01_PHASE01
    0x4A69: "Ashyn",   // HS_CLDLAVATOWN01_PHASE02
    0x4AA2: "Ashyn",   // HS_CLDLAVATOWN01_PHASE03
    0x4ADB: "Ashyn",   // HS_CLDLAVATOWN02
    0x4AEC: "Ashyn",   // HS_CLDLAVATOWN03
    0x4AF9: "Ashyn",   // HS_CLDLAVATOWN06
    0x4B02: "Ashyn",   // HS_CLDLAVATOWN07
    0x4B20: "Ashyn",   // HS_CLDLAVATOWN08
    0x4B3A: "Ashyn",   // HS_CLDLAVATOWN09
    0x4B3F: "Ashyn",   // HS_CLDLAVATOWN09A
    0x4B9E: "Ashyn",   // HS_CLDLAVATOWN10
    0x4BB8: "Ashyn",   // HS_CLDLAVATOWN11
    0x4BDE: "Ashyn",   // HS_CLDLAVATOWN12
    0x4C08: "Valkan's House",   // HS_CLDLAVATOWN13
    0x4C11: "Valkan's House",   // HS_CLDLAVATOWN14
    0x4C37: "East Lava Tubes",   // HS_CLDLAVATUBE01
    0x4C44: "East Lava Tubes",   // HS_CLDLAVATUBE02
    0x4C4D: "East Lava Tubes",   // HS_CLDLAVATUBE03
    0x4C5F: "East Lava Tubes",   // HS_CLDLAVATUBE04
    0x4C68: "East Lava Tubes",   // HS_CLDLAVATUBE05
    0x4C71: "East Lava Tubes",   // HS_CLDLAVATUBE06
    0x4C83: "East Lava Tubes",   // HS_CLDLAVATUBE07
    0x4C98: "East Lava Tubes",   // HS_CLDLAVATUBE08
    0x4CA1: "East Lava Tubes",   // HS_CLDLAVATUBE09
    0x4CB3: "East Lava Tubes",   // HS_CLDLAVATUBE10
    0x4CC9: "East Lava Tubes",   // HS_HDNLAVATUBE03
    0x4CEF: "East Lava Tubes",   // HS_CLDLAVATUBE11
    0x4CF8: "East Lava Tubes",   // HS_CLDLAVATUBE12
    0x4D05: "West Lava Tubes",   // HS_CLDLAVATUBE13
    0x4D0E: "West Lava Tubes",   // HS_CLDLAVATUBE14
    0x4D1F: "West Lava Tubes",   // HS_CLDLAVATUBE15
    0x4D28: "West Lava Tubes",   // HS_CLDLAVATUBE16
    0x4D31: "West Lava Tubes",   // HS_CLDLAVATUBE17
    0x4D3A: "West Lava Tubes",   // HS_CLDLAVATUBE18
    0x4D4B: "Lava Vents",   // HS_CLDLAVAVENT01
    0x4D5C: "Lava Vent Cavern",   // HS_CLDLAVAVENT01B
    0x4D61: "Lava Vents",   // HS_CLDVENTINT01
    0x4D6B: "Lava Vents",   // HS_CLDVENTINT02
    0x4D75: "Volcano",   // HS_CLDHYRENROOM
    0x4D7A: "Lava Vents",   // HS_CLDLAVAVENT02
    0x4D88: "Lava Vents",   // HS_CLDLAVAVENT03
    0x4D9E: "Lava Vents",   // HS_CLDLAVAVENT04
    0x4DB0: "Lava Vents",   // HS_CLDVENTINT03
    0x4DCE: "Lava Vents",   // HS_CLDLAVAVENT05
    0x4DD7: "Lava Vents",   // HS_CLDVENTINT04
    0x4DE1: "Lava Vents",   // HS_CLDLAVAVENT06
    0x4DEA: "Lava Vents",   // HS_CLDLAVAVENT07
    0x4DF3: "Lava Vents",   // HS_CLDLAVAVENT08
    0x4DFD: "Ferry",   // HS_FERRY01_AT_WEAVE
    0x4E02: "Ferry",   // HS_FERRY01_AT_CALD
    0x4E07: "Ferry",   // HS_FERRY02
    0x4E0C: "Cald Geyser",   // HS_CLDGEYSER01
    0x4E15: "Cald Geyser",   // HS_CLDGEYSER02
    0x4EB7: "Cald Geyser",   // HS_CLDGEYSER03
    0x4F41: "Cald Geyser",   // HS_CLDGEYSER04
    0x4F5B: "Cald Geyser",   // HS_CLDGEYSER05
    0x4F71: "Cald Geyser",   // HS_CLDGEYSER06
    0x4F72: "Gruk's Mushroom Farm",   // HS_HDNROOM01
    0x4F7B: "Naroom-Underneath Shortcut",   // HS_WARP07
    0x4F84: "Core Ringsmith",   // HS_HLDMAZE23
    0x4FA2: "Core Ringsmith's Playground",   // HS_HLDMAZE24
    0x4FAB: "Core Ringsmith's Playground",   // HS_HLDMAZE25
    0x4FB4: "Core Ringsmith's Playground",   // HS_HLDMAZE26
    0x4FB9: "Naroom Cave",   // HS_HDNROOM02
    0x4FC2: "Naroom-Underneath Shortcut",   // HS_WARP06
    0x4FCB: "Underneath Tunnels",   // HS_HDNROOM03
    0x4FDD: "Underneath Tunnels",   // HS_HDNROOM03B
    0x4FE6: "Underneath Tunnels",   // HS_HDNROOM03C
    0x4FEF: "Underneath Tunnels",   // HS_HDNROOM04
    0x5005: "Abandoned Fort",   // HS_FORT01
    0x5017: "Abandoned Fort",   // HS_FORT02
    0x5020: "Abandoned Fort",   // HS_FORT02B
    0x5032: "Abandoned Fort",   // HS_FORT03
    0x5040: "Arderial Fort",   // HS_HDNFORT04
    0x5049: "Arderial Fort",   // HS_HDNFORT04B
    0x5052: "Start Screen",   // HS_HDNLOAD01
    0x5063: "Start Screen",   // HS_HDNLOAD01B
    0x5071: "Start Screen",   // HS_HDNLOAD01C
    0x507A: "Tavel Gorge",   // HS_HMTCAVE01
    0x508B: "Tavel Gorge",   // HS_HMTCAVE01B
    0x5090: "Tavel Gorge Cave",   // HS_HMTCAVE02
    0x509D: "Tavel Gorge Cave",   // HS_HMTCAVE03
    0x50AA: "Tavel Gorge Cave",   // HS_HMTCAVE04
    0x50B3: "Gia's Farm",   // HS_WVEGIASHUT01
    0x50E9: "Gia's Farm",   // HS_WVEGIASHUT02
    0x50EE: "Gia's Farm",   // HS_WVEGIASHUT02_ABDUCTION
    0x5114: "Weave",   // HS_WVEPATHVALLEY01
    0x5121: "Weave",   // HS_WVEPATHVALLEY02
    0x5142: "Weave",   // HS_WVEPATHVALLEY02B
    0x516C: "Weave",   // HS_WVEPATHVALLEY03
    0x5179: "Naroom Cave",   // HS_WVESHORTCUT01
    0x5187: "Wheat Farm",   // HS_WVEPATHVALLEY04
    0x51A1: "Weave",   // HS_WVEPATHVALLEY08
    0x51AF: "Weave",   // HS_WVEPATHVALLEY05
    0x51C1: "Weave",   // HS_WVEPATHVALLEY06
    0x51EB: "Underneath Tunnels",   // HS_WVEPATHVALLEY07
    0x51F4: "Weave",   // HS_WVEPATHVALLEY09
    0x51F9: "Core Entrance",   // HS_WVECOREENTRANCE01
    0x5202: "Oscent Mar",   // HS_OROCITY01
    0x521F: "Oscent Mar",   // HS_OROCITY02
    0x5241: "Oscent Mar",   // HS_OROCITY03
    0x5246: "Oscent Mar",   // HS_OROCITY04
    0x52A0: "Orothe Tunnels",   // HS_OROTUNNEL01
    0x52AD: "Orothe Tunnels",   // HS_OROTUNNEL02
    0x52BE: "Orothe Tunnels",   // HS_OROTUNNEL03
    0x52CC: "Orothe Tunnels",   // HS_OROTUNNEL04
    0x52DA: "Orothe Tunnels",   // HS_OROTUNNEL05
    0x52EC: "Orothe Tunnels",   // HS_OROTUNNEL06
    0x52FA: "Orothe Tunnels",   // HS_OROTUNNEL07
    0x5307: "Orothe Tunnels",   // HS_OROTUNNEL08
    0x5319: "Orothe Tunnels",   // HS_OROTUNNEL09
    0x5326: "Orothe Tunnels",   // HS_OROTUNNEL09B
    0x5338: "Orothe Tunnels",   // HS_OROTUNNEL10
    0x534A: "Orothe Tunnels",   // HS_OROTUNNEL11
    0x5353: "Underwater Ruins",   // HS_ORORUINS01
    0x5369: "Underwater Ruins",   // HS_ORORUINS02
    0x5383: "Underwater Ruins",   // HS_ORORUINS03
    0x53A1: "Orothe Island",   // HS_OROISLANDS02
    0x53CB: "Orothe Island",   // HS_OROISLANDS04
    0x53D4: "Path to Orothe Geyser",   // HS_ORODEEP01
    0x53DD: "Orothe Geyser",   // HS_OROGEYSER01
    0x540B: "Orothe Geyser",   // HS_OROGEYSER02
    0x5414: "Orothe Geyser",   // HS_OROGEYSER03
    0x541D: "Orothe Geyser",   // HS_OROGEYSER04
    0x5426: "Orothe Geyser",   // HS_OROGEYSER05
    0x5433: "Orothe Geyser",   // HS_OROGEYSER06
    0x543C: "Orothe Geyser",   // HS_OROGEYSER07
    0x5445: "Orothe Geyser",   // HS_OROGEYSER08
    0x545B: "Orothe Geyser",   // HS_OROGEYSER09
    0x546D: "Orothe Geyser",   // HS_OROGEYSER10
    0x54C7: "Orothe Geyser",   // HS_OROGEYSER11
    0x54D5: "Orothe Geyser",   // HS_OROGEYSER12
    0x54DA: "Orothe Corals",   // HS_OROCORAL01
    0x54E8: "Orothe Corals",   // HS_OROCORAL02
    0x54FE: "Orothe Corals",   // HS_OROCORAL03
    0x5507: "Orothe Corals",   // HS_OROCORAL04
    0x5510: "Orothe Corals",   // HS_OROCORAL05
    0x5526: "Orothe Corals",   // HS_OROCORAL06
    0x552B: "Naroom Overworld",   // HS_OVERSURFACE01
    0x5590: "Hyren's Glade",   // HS_OVRSURFACE01B
    0x559A: "Underneath Overworld",   // HS_OVERSURFACE02
    0x55B7: "Cald Overworld",   // HS_OVERSURFACE03
    0x55D4: "Orothe Overworld",   // HS_OVERSURFACE04
    0x55F9: "Arderial Overworld",   // HS_OVERSURFACE05
    0x562A: "Arderial Throne Room",   // HS_ARDPALACE01
    0x5634: "Arderial Palace",   // HS_ARDCITY01
    0x5649: "Arderial Inn",   // HS_ARDCITY02
    0x565E: "Arderial Historian",   // HS_ARDCITY03
    0x5677: "Arderial Shop",   // HS_ARDCITY04
    0x568C: "Arderial Palace",   // HS_ARDGARDEN01
    0x569E: "Arderial Palace",   // HS_ARDGARDEN02
    0x56A7: "Arderial Palace",   // HS_ARDGARDEN03
    0x56B0: "Middle Clouds",   // HS_ARDGARDEN04
    0x56B5: "Arderial Inn",   // HS_ARDGARDEN05
    0x56C3: "Arderial Historian",   // HS_ARDGARDEN06
    0x56CC: "Arderial Historian",   // HS_ARDGARDEN07
    0x56DA: "Arderial Shop",   // HS_ARDGARDEN08
    0x56E8: "Arderial Historian",   // HS_ARDGARDEN09
    0x56ED: "Middle Clouds",   // HS_ARDCLOUDS01
    0x56F6: "Middle Clouds",   // HS_ARDCLOUDS02
    0x56FF: "Middle Clouds",   // HS_ARDCLOUDS03
    0x5711: "Middle Clouds",   // HS_ARDCLOUDS04
    0x571A: "Middle Clouds",   // HS_ARDCLOUDS05
    0x5723: "Middle Clouds",   // HS_ARDCLOUDS06
    0x5735: "North Clouds",   // HS_ARDCLOUDS07
    0x5742: "North Clouds",   // HS_ARDCLOUDS08
    0x574B: "North Clouds",   // HS_ARDCLOUDS09
    0x575C: "North Clouds",   // HS_ARDCLOUDS10
    0x576D: "North Clouds",   // HS_ARDCLOUDS11
    0x577A: "North Clouds",   // HS_ARDCLOUDS12
    0x5783: "North Clouds",   // HS_ARDCLOUDS13
    0x5794: "Palace Clouds",   // HS_ARDCLOUDS14
    0x579D: "South Clouds",   // HS_ARDCLOUDS15
    0x57A6: "South Clouds",   // HS_ARDCLOUDS16
    0x57AF: "Arderial Geyser",   // HS_ARDGEYSER01
    0x57C9: "Arderial Geyser",   // HS_ARDGEYSER02
    0x582B: "Arderial Geyser",   // HS_ARDGEYSER03
    0x584D: "Arderial Geyser",   // HS_ARDGEYSER04
    0x5867: "Arderial Geyser",   // HS_ARDGEYSER05
    0x588D: "Arderial Geyser",   // HS_ARDGEYSER06
    0x58A3: "Arderial Geyser",   // HS_ARDGEYSER07
    0x58AD: "Arderial Geyser",   // HS_ARDGEYSER08
    0x58B7: "Arderial Geyser",   // HS_ARDGEYSER09
    0x58C9: "Arderial Geyser",   // HS_ARDGEYSER10
    0x58DF: "Arderial Geyser",   // HS_ARDGEYSER11
    0x58E9: "Arderial Geyser",   // HS_ARDGEYSER12
    0x58F7: "Arderial Geyser",   // HS_ARDGEYSER13
    0x5915: "Arderial Geyser",   // HS_ARDGEYSER14
    0x5933: "Arderial Geyser",   // HS_ARDGEYSER15
    0x594D: "Arderial Geyser",   // HS_ARDGEYSER16
    0x595B: "Arderial Geyser",   // HS_ARDGEYSER17
    0x595C: "Arderial Geyser",   // HS_ARDGEYSER18
    0x597A: "Arderial Geyser",   // HS_ARDGEYSER19
    0x59A8: "Arderial Geyser",   // HS_ARDGEYSER20
    0x59B2: "Arderial Geyser",   // HS_ARDGEYSER21
    0x59C8: "Arderial Geyser",   // HS_ARDGEYSER22
    0x59C9: "Arderial Geyser",   // HS_ARDGEYSER23
    0x59E3: "Arderial Geyser",   // HS_ARDGEYSER24
    0x59F1: "Arderial Geyser",   // HS_ARDGEYSER25
    0x5A0B: "Arderial Geyser",   // HS_ARDGEYSER26
    0x5A1D: "Arderial Geyser",   // HS_ARDGEYSER27
    0x5A2B: "Arderial Geyser",   // HS_ARDGEYSER28
    0x5A30: "Shadowhold",   // HS_HLDMAZE01
    0x5A4A: "Shadowhold",   // HS_HLDMAZE03
    0x5A60: "Shadowhold",   // HS_HLDMAZE04
    0x5A82: "Shadowhold",   // HS_HLDMAZE05
    0x5A8B: "Shadowhold",   // HS_HLDMAZE06
    0x5AB9: "Shadowhold",   // HS_HLDMAZE07
    0x5AD7: "Shadowhold",   // HS_HLDMAZE08
    0x5AFD: "Shadowhold",   // HS_HLDMAZE09
    0x5B0B: "Shadowhold",   // HS_HLDMAZE10
    0x5B21: "Shadowhold",   // HS_HLDMAZE11
    0x5B53: "Shadowhold",   // HS_HLDMAZE12
    0x5B64: "Shadowhold",   // HS_HLDMAZE13
    0x5B6E: "Shadowhold",   // HS_HLDMAZE14
    0x5B88: "Shadowhold",   // HS_HLDMAZE15
    0x5B96: "Shadowhold",   // HS_HLDMAZE16
    0x5BD4: "Shadowhold",   // HS_HLDMAZE17
    0x5BE1: "Shadowhold",   // HS_HLDMAZE18
    0x5BEF: "Shadowhold",   // HS_HLDMAZE19
    0x5BFC: "Shadowhold",   // HS_HLDMAZE20
    0x5C12: "Shadowhold",   // HS_HLDMAZE21
    0x5C28: "Shadowhold",   // HS_HLDMAZE22
    0x5C36: "Shadowhold",   // HS_HLDCELL01
    0x5C6C: "Shadowhold",   // HS_HLDCELL02
    0x5C7E: "Shadowhold",   // HS_HLDCELL03
    0x5C87: "Shadowhold",   // HS_HLDCELL04
    0x5C95: "Shadowhold",   // HS_HLDCELL05
    0x5CAF: "Shadowhold",   // HS_HLDCELL06
    0x5CB8: "Shadowhold",   // HS_HLDEXTERIOR
}

// As stated above, we cannot reliably use SRAM with the current memory mapping and game design for achievements.
// However we can conditionally use it in Rich Presence when available.
function wBattery_ActiveSavefileBaseBank() => byte(0xC727)
function sram_valid() =>
    wBattery_ActiveSavefileBaseBank() == 0

// Tracks overall progress
function xGameCount() => word(0xA123)
GC_OPENING = 1
GC_NRM_INTRO = 2
GC_FIND_ORWIN = 3
GC_QUEST_FOR_GIA = 4
GC_NAROOM_GEYSER = 5
GC_GLOVES = 6
GC_UND_INTRO = 7
GC_UND_QUAKE = 8
GC_UND_GEYSER = 9
GC_UND_WASTED = 10
GC_CALD_INTRO = 11
GC_ARBOLL_HUNT = 12
GC_LAVA_BRIDGE = 13
GC_BOOTS_QUEST = 14
GC_CALD_GEYSER = 15
GC_TONY_KIDNAPPED = 16
GC_SHADOWHOLD_JAIL = 17
GC_BACK_IN_OROTHE = 18
GC_OROTHE_GEYSER = 19
GC_BEAT_OROTHE = 20
GC_FALSE_END = 21
GC_ARDERIAL = 22
GC_ARDERIAL_GEYSER = 23
GC_AGRAM_BATTLE = 24
GC_END_FUNERAL = 25
GC_END_PARTY = 26
gamecount_lookup = {
    0: "Booting up Magi-Nation for the first time",
    GC_OPENING: "Dunked in the Naroom river",
    GC_NRM_INTRO: "Running errands in Vash Naroom",
    GC_FIND_ORWIN: "Searching for Orwin",
    GC_QUEST_FOR_GIA: "Heading to see Gia",
    GC_NAROOM_GEYSER: "Facing the first shadow geyser",
    GC_GLOVES: "Destroyed the first shadow geyser",
    GC_UND_INTRO: "Exploring the Underneath",
    GC_UND_QUAKE: "Investigating another earthquake",
    GC_UND_GEYSER: "Facing on the second shadow geyser",
    GC_UND_WASTED: "Completing the second shadow geyser", // Changes at start of geyser boss battle
    GC_CALD_INTRO: "Leaving the Underneath",
    GC_ARBOLL_HUNT: "Hunting for that blasted Lava Arboll",
    GC_LAVA_BRIDGE: "Building a bridge",
    GC_BOOTS_QUEST: "Getting a nice pair of boots",
    GC_CALD_GEYSER: "Facing the third shadow geyser",
    GC_TONY_KIDNAPPED: "Having a hot party",
    GC_SHADOWHOLD_JAIL: "In a pickle",
    GC_BACK_IN_OROTHE: "Swimming with turtles",
    GC_OROTHE_GEYSER: "Facing the fourth shadow geyser",
    GC_BEAT_OROTHE: "Destroyed the fourth shadow geyser",
    GC_FALSE_END: "Heading home",
    GC_ARDERIAL: "Meeting the queen",
    GC_ARDERIAL_GEYSER: "Met the queen",
    GC_AGRAM_BATTLE: "Searching the Core",
    GC_END_FUNERAL: "Attending a funeral",
    GC_END_PARTY: "Life of the party",
}

// We can't directly track Tony's stats, but every time he enters a battle, his stats are loaded into WRAMX
// We can display Tony's stats for the supported cores (i.e. not mGBA)
// We need to make sure at least one battle has occurred to be able to read his stats,
// and they will only update every battle, not in-between

// Tony's stats apart from Energy never change, even on level up.
// So we if detect his stats, we know the WRAMX has been initialized
function wBattle_Creature_Hero_Stats() => dword(0x15152)
function battle_wram_valid() => (wBattle_Creature_Hero_Stats() == 0x19323232) // 50, 50, 50, 25 (Str, Skill, Speed, Defence)

function wBattle_Creature_Hero_Level() => byte(0x1514B)
function wBattle_Creature_Hero_MaxEnergy() => word_be(0x15150)

rich_presence_conditional_display(
    wHotspot_Table() == 0,
    "Splash Screen"
)
rich_presence_conditional_display(
    sram_valid() && battle_wram_valid(),
    "{0}. {1}. Level {2} ({3})",
    rich_presence_lookup("Gamecount", xGameCount(), gamecount_lookup, "???"),
    rich_presence_lookup("Location", wHotspot_Table(), hotspot_lookup, "???"),
    rich_presence_value("Tony Level", wBattle_Creature_Hero_Level(), "VALUE"),
    rich_presence_value("Tony MaxEnergy", wBattle_Creature_Hero_MaxEnergy(), "VALUE")
)
rich_presence_conditional_display(
    battle_wram_valid(),
    "{0}. Level {1} ({2})",
    rich_presence_lookup("Location", wHotspot_Table(), hotspot_lookup, "???"),
    rich_presence_value("Tony Level", wBattle_Creature_Hero_Level(), "VALUE"),
    rich_presence_value("Tony MaxEnergy", wBattle_Creature_Hero_MaxEnergy(), "VALUE")
)
rich_presence_conditional_display(
    sram_valid(),
    "{0}. {1}.",
    rich_presence_lookup("Gamecount", xGameCount(), gamecount_lookup, "???"),
    rich_presence_lookup("Location", wHotspot_Table(), hotspot_lookup, "???")
)
rich_presence_display(
    "{0}.",
    rich_presence_lookup("Location", wHotspot_Table(), hotspot_lookup, "???")
)

// TODO - remove alternate patch