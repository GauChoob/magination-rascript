// Magi-Nation (GBC)
// #ID = 4731
// md5: 1624f857098ca278b15629914f48352b

// Mapping reference: https://github.com/RetroAchievements/rcheevos/blob/cc854ad75b6533e73cff5eb7a92429c5750c01a3/src/rcheevos/consoleinfo.c#L422
// Unfortunately, only SRAM0 is mapped, and since the save file swaps SRAM0-1 and SRAM2-3, we can't reliably read SRAM at the moment as the data is stale half of the time
// WRAM0 and 1 are mapped.
// Gambatte, GearBoy, VGA-M, SameBoy and GBHawk all support WRAM2-7 at 0x10000-0x16000
// However, mGBA does not, meaning this memory location is core-dependant
// Therefore the only useable memory for achievements is WRAM0, along with WRAM1 (which contains nothing but MusyX internal vars)
// This means that magi and creature stats, rings, infused animite, animite, chests, inventory, spells, relics, glyph status, hero abilities cannot be directly checked
// Even with access to WRAM2-7, we don't really gain much. We can read the scene map tiles and also read the battle state

// So basically we are mostly left with a few pointers to data tables and pointers to bytecode scripts
// For the majority of the achievements, we read the pointer address and don't read the actual text contents
// with the exception of item names in treasure chests (located in SRAM) and Ormagon (WRAM7), because we don't have any reliable alternative way of reading them
// without creating a patch, but in that case we are dropping support for the large majority of players who would play without a patch

// If ever there would be a translation patch (there definitely never will be due to the game's popularity), it is fairly trivial to check for an alternative name if need be...

// The achievements were developed primarily on Gambatte, but GearBoy, VGA-M, mGBA and SameBoy were all also briefly tested,
// and the achievements are expected to work on all 6 cores mentioned above.

//////////////////////
// Helper Functions //
//////////////////////

// Converts a ROM address from raw location to a bank_address. Only valid for ROM banks >= 1
// e.g. 0x047327 -> ROMX[0x11] 0x7327 -> 0x732711
function bank_address(raw_address) =>
    0x000100*(raw_address % 0x4000 + 0x4000) + // Address
    0x000001*(raw_address / 0x4000) // Bank

// Converts a number to 8-bit-width bcd
// e.g. 149 -> 0x010409
function bcd_8(number) =>
    0x010000*(number/100) +
    0x000100*((number % 100)/10) +
    0x000001*(number % 10)

function changes_from(address, value) => (prev(address) == value) && (address != value)

function changes(address) => (prev(address) != address)


///////////////////
// Lookup Tables //
///////////////////
CreatureID_Null = 0xFF
CreatureID_Abaquist = 0x00
CreatureID_Agovo = 0x01
CreatureID_Alaban = 0x02
CreatureID_Arbolit = 0x03
CreatureID_Arboll = 0x04
CreatureID_Ayebaw = 0x05
CreatureID_Bhatar = 0x06
CreatureID_Bisiwog = 0x07
CreatureID_BlackAgovo = 0x08
CreatureID_Bolt_Hyren = 0x09
CreatureID_Borgor = 0x0A
CreatureID_Brub = 0x0B
CreatureID_Bwill = 0x0C
CreatureID_Cave_Hyren = 0x0D
CreatureID_CaveRudwot = 0x0E
CreatureID_Chaos_Jile = 0x0F
CreatureID_CoralHyren = 0x10
CreatureID_Core_Grag = 0x11
CreatureID_Core_Hyren = 0x12
CreatureID_DarkAyebaw = 0x13
CreatureID_DarkVellup = 0x14
CreatureID_Deep_Hyren = 0x15
CreatureID_Diobor = 0x16
CreatureID_Drakan = 0x17
CreatureID_DryteFiend = 0x18
CreatureID_Eebit = 0x19
CreatureID_Epik = 0x1A
CreatureID_FlameHyren = 0x1B
CreatureID_Furok = 0x1C
CreatureID_GhostBwisp = 0x1D
CreatureID_GiantKorit = 0x1E
CreatureID_Graw = 0x1F
CreatureID_Grax = 0x20
CreatureID_Gum_Gum = 0x21
CreatureID_Hook_Wing = 0x22
CreatureID_Jingjack = 0x23
CreatureID_Karak = 0x24
CreatureID_Kazor = 0x25
CreatureID_Kelthet = 0x26
CreatureID_Kletch = 0x27
CreatureID_Koil = 0x28
CreatureID_Lava_Aq = 0x29
CreatureID_LavaArboll = 0x2A
CreatureID_LavaBalmnt = 0x2B
CreatureID_Leaf_Chogo = 0x2C
CreatureID_Leaf_Hyren = 0x2D
CreatureID_MagmaHyren = 0x2E
CreatureID_Megathan = 0x2F
CreatureID_Mush_Hyren = 0x30
CreatureID_Orathan_F = 0x31
CreatureID_Orish = 0x32
CreatureID_Ormagon = 0x33
CreatureID_Orpus = 0x34
CreatureID_Paralit = 0x35
CreatureID_Parmalag = 0x36
CreatureID_Platheus = 0x37
CreatureID_Plith = 0x38
CreatureID_Porkuslime = 0x39
CreatureID_Quor = 0x3A
CreatureID_Rabbage = 0x3B
CreatureID_Raxis = 0x3C
CreatureID_Rudwot = 0x3D
CreatureID_Sabreback = 0x3E
CreatureID_Sarbil = 0x3F
CreatureID_Sea_Jile = 0x40
CreatureID_ShadwKarak = 0x41
CreatureID_ShadwVinoc = 0x42
CreatureID_Sharbloot = 0x43
CreatureID_Shryque = 0x44
CreatureID_Sphor = 0x45
CreatureID_Spindle = 0x46
CreatureID_ThundrHyrn = 0x47
CreatureID_TimberHyrn = 0x48
CreatureID_Treebit = 0x49
CreatureID_Tusk_Bwisp = 0x4A
CreatureID_Twee = 0x4B
CreatureID_Vashp = 0x4C
CreatureID_Vellup = 0x4D
CreatureID_Vile_Yogu = 0x4E
CreatureID_Vinoc = 0x4F
CreatureID_Vulbor = 0x50
CreatureID_Wasperine = 0x51
CreatureID_Weebat = 0x52
CreatureID_Weebo = 0x53
CreatureID_Xyx = 0x54
CreatureID_Yvohcna = 0x55

// Creatures that are not obtainable in the base game
// 77/86 creatures are therefore obtainable
Unobtainable_Creatures = [
    CreatureID_Alaban,  // Requires Infused Platheus
    CreatureID_Bolt_Hyren,
    CreatureID_Borgor,  // Requires Infused Sphor
    CreatureID_Core_Hyren,  // Requires Infused ThundrHyrn
    CreatureID_Platheus,
    CreatureID_Sphor,
    CreatureID_ThundrHyrn,
    CreatureID_Xyx,
    CreatureID_Yvohcna,  // Requires Infused Platheus
    0
]

Obtainable_Creatures = []
j = 0
for i in range(CreatureID_Abaquist, CreatureID_Yvohcna) {
    if(i != Unobtainable_Creatures[j]) {
        array_push(Obtainable_Creatures, i)
    } else {
        j = j + 1
    }
}

xInventory_Relics = 0xA019
Relic_NULL = 0x00
Relic_ARCHAICLEAF = 0x01
Relic_ARMORORB = 0x02
Relic_BAGOFBONES = 0x03
Relic_BARKTHIMBLE = 0x04
Relic_CHANNELEDGEM = 0x05
Relic_CORFPEARL = 0x06
Relic_CRIMSONVOID = 0x07
Relic_EARTHSAURA = 0x08
Relic_ENDBRINGER = 0x09
Relic_ENERGYGEM = 0x0A
Relic_FLAMEAURA = 0x0B
Relic_FLAMEESSENCE = 0x0C
Relic_GEMOFNAROOM = 0x0D
Relic_GOLDENCLOVER = 0x0E
Relic_GRAILOFLIFE = 0x0F
Relic_HYRENSCLAW = 0x10
Relic_LEAFESSENCE = 0x11
Relic_LUCENTBELT = 0x12
Relic_MAELSTROM = 0x13
Relic_OMBORSAMULET = 0x14
Relic_PHANTOMWIND = 0x15
Relic_PINCHOFLIFE = 0x16
Relic_RABBAGEFOOT = 0x17
Relic_RAGESTONE = 0x18
Relic_SHADOWVEIL = 0x19
Relic_SHIELDORB = 0x1A
Relic_SKYESSENCE = 0x1B
Relic_SPICEOFLIFE = 0x1C
Relic_STONEESSENCE = 0x1D
Relic_STONEOFDOOM = 0x1E
Relic_STONEOFLIFE = 0x1F
Relic_SWORDOFWIND = 0x20
Relic_TIDEESSENCE = 0x21
Relic_TITANRING = 0x22
Relic_WATERORB = 0x23
Relic_WISHBONE = 0x24

// Relics that are not obtainable in the base game
// 32/36 relics are obtainable
Unobtainable_Relics = [
    Relic_FLAMEAURA, // Removed treasure from Cald Geyser
    Relic_LUCENTBELT,
    Relic_STONEOFLIFE,
    Relic_TIDEESSENCE,
    0
]

Obtainable_Relics = []
j = 0
for i in range(Relic_ARCHAICLEAF, Relic_WISHBONE) {
    if(i != Unobtainable_Relics[j]) {
        array_push(Obtainable_Relics, i)
    } else {
        j = j + 1
    }
}


//////////
// WRAM //
//////////

// The game has 4 different bytecode scripts running simultaneously, pointed to by these 4 variables,
// plus each Actor (49 of them) (up to 10 simultaneously) has 1-2 scripts,
// for a total of 98 different threads, (maximum of 24 simultaneous threads)
// The large majority of achievements simply track the bytecode script pointers running in the intended thread,
// as we know with 100% reliability when these will trigger
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
Battle_Source = wText_StringBuffer + 0 // Battle action source and targets
Battle_Target = wText_StringBuffer + 11
Treasure_Name = wText_StringBuffer + 1 // Starts at 0, but skip the first char which often isn't ASCII, for simplicity
// Number buffer for text input
function wX1() => tbyte(0xC92D) // 8-bit-wide BCD-encoded number (0-999)
function number_buffer() => wX1()

// Sound is initialized right after WRAM is wiped on reset
function wSound_SoundInit() => byte(0xC91D)
Sound_Init_MagicNumber = 0x55
// Requested SFX
function wSound_Control_SFX0() => byte(0xC921)
SFXID_CriticalAttack = 14

// The CreatureID is set when a ring is made
function wScript_RingMadeID() => byte(0xC726)

// Pointers to the 5 visible entries in the MainMenu or Battle
// For Items, Spells, Relics only
wMenu_MainMenu_Entry_EntriesPointers = 0xCC78

// Array of 7*[CreatureID, CreatureLevel].
// Initialized to 0 on game boot
// Unused entries set to CreatureID_Null upon first RingBank load
wMenu_RingBank_VisibleRings = 0xCD59
// Number of visible rings - only needed for CreatureID_Abaquist = 0
function wMenu_RingBank_VisibleRingCount() => byte(0xCD67)


////////////////////////////////
//  Bytecode Script Addresses //
////////////////////////////////

// All of these bytecode script addresses are only pointed to for up to a few frames at most, making them transient, event-based addresses

// Unique Actions //
////////////////////


// Spells
// Triggers on textbox close after the spell is obtained
function leaf_cut() =>
    wScript_Text() == bank_address(0x0AC508) // nrmvash12_txt.mgi Line 109, TextClose()
function blurry_scroll() =>
    wScript_System() == bank_address(0x066A01) // ororuins02_dr.mgi Line 22, TextClose()

// Relics
// Triggers on textbox close after the relic is obtained
function maelstrom() =>
    wScript_Text() == bank_address(0x06B4D5) // cldlavatown14_txt.mgi Line 86, TextClose()

// Hero Abilities
// Triggers on textbox close after the ability is obtained
function translation_bracelet() =>
    wScript_Text() == bank_address(0x0A82EE) // nrmriver01_txt.mgi Line 139, TextClose()
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
// Triggers on scene fadeout right before permanently leaving the geyser
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
function zet_end() =>
    wScript_Text() == bank_address(0x09AD56) // cregate01_txt.mgi Line 66, TextClose() - Triggers on textbox close right after Zet's last dialogue
function agram_end() =>
    wScript_Text() == bank_address(0x0568AC) // throne01_txt.mgi Line 66, TextIcon(ICON_AGRAM) - Triggers on textbox open right after battle ends

// Gags
function poop_gag() =>
    wScript_System() == bank_address(0x0742C4) // wvegiashut01_dr.mgi Line 38, TextClose() - Triggers on textbox close at the end of the dialogue
function soap_gag() =>
    wScript_Text() == bank_address(0x074FE5) // wvegiashut01.mgi Line 463, TextClose() - Triggers on textbox close at the end of the dialogue
function haggle() =>
    // Triggers mid-dialogue when Tony gets to choose whether to accept 50 animite or not
    // Unfortunately there's no valid pointer address after Tony selects to accept 50 animite, as the next frame
    // the script has already exited to a wider scope
    wScript_Text() == bank_address(0x0A97CD) // ferry01_txt.mgi Line 241, TextIcon(ICON_TONY)

// Prisoner Reward
// When the rescued prisoner gives you an item. See also Prisoner Thanks
HldPrisoner_Reward = [
    bank_address(0x08B02F), //1 nrmvash17.mgi Line 15, TextClose()
    bank_address(0x07AC93), //2 cldlavatown10_txt.mgi Line 17, TextClose()
    bank_address(0x04F699), //3 wvepathvalley04_txt.mgi Line 23, TextClose()
    bank_address(0x088363), //4 undtown01_txt.mgi Line 28, TextClose()
    bank_address(0x0544EC), //5 undcave03_sct.mgi Line 53, TextClose()
    bank_address(0x05D636), //6 cldlavavent04_sct.mgi Line 56, TextClose()
    bank_address(0x0AA7A6) //7 ferry02.mgi Line 469, TextClose()
    // 8 only accessible by hacking ardgarden04.mgi
]

// Misc
function i2_logo() =>
    wScript_Master() == bank_address(0x0AB25C) // hdnload01.mgi Line 18, PalFade(0,7,32,2) - Triggers as the i2 logo fades in
function great_furok() =>
    wScript_Text() == bank_address(0x053A0A) // nrmvash11_txt.mgi Line 281, TextClose() - Triggers on textbox close after Tony gets a Great Furok
function cure_orwin() =>
    wScript_Text() == bank_address(0x08E2BA) // nrmvash15_sicko.mgi Line 521, TextIcon(ICON_ORWIN) - Triggers on textbox open right after Orwin jumps out of bed
function funeral() =>
    wScript_Text() == bank_address(0x051944) // nrmglade03.mgi Line 626, TextClose() - Triggers on textbox close after Gia explains the funeral, right before heading to the glade
function party() =>
    wScript_Master() == bank_address(0x0519E3) // nrmvash03.mgi Line 664, PalFade(0,15,32,0) - Triggers upon scene load into Vash Naroom after Tony leaves the Core
function evu_secret() =>
    wScript_Text() == bank_address(0x05A2DD) // nrmvash02_party.mgi Line 639, TextClose() - Triggers on textbox close right before Evu teleports
function new_game_plus() =>
    wScript_Text() == bank_address(0x0AAF63) // hdnload01_sct.mgi Line 63, TextClose() - Triggers on textbox close after talking to the secret hooded figure


// Repeatable Actions //
////////////////////////

// Battle
// Battle engine events
function _tony_summon() =>
    wScript_Text() == bank_address(0x130AF4) // battle_txt.mgi Line 954, TextClose()
function _magi_summon() =>
    wScript_Text() == bank_address(0x130B09) // battle_txt.mgi Line 964, TextClose()
function _wild_appear() =>
    wScript_Text() == bank_address(0x130B19) // battle_txt.mgi Line 974, TextClose()
function tony_wins() =>
    wScript_Text() == bank_address(0x130B69) // battle_txt.mgi Line 1016, TextClose()
function tony_escapes() =>
    wScript_Text() == bank_address(0x130A28) // battle_txt.mgi Line 882, TextClose()
function terminates() =>
    wScript_Text() == bank_address(0x13046C) // battle_txt.mgi Line 405, TextClose()
function hiccups_cured() =>
    wScript_Text() == bank_address(0x130447) // battle_txt.mgi Line 334, TextClose()
function plague_cured() =>
    wScript_Text() == bank_address(0x130841) // battle_txt.mgi Line 707, TextClose()
NumberBounce_Anim = bank_address(0x10707F) // spellFX_anim.mgi Line 184, Frame(64,0,0,?BOUNCE15) - Bouncy numbers when damage is dealt

// Code before booting the player back to the starting room. Excludes scripted losing to Morag, Salafy
function battle_lost() =>
    wScript_Master() == bank_address(0x0880D6) // system.mgi Line 99, Delay(96)

function salafy_level4_start() =>
    wScript_System() == bank_address(0x0589DD) // vash_bat.mgi Line 23, TextIcon(ICON_SALAFY) - triggers on first textbox open during Salafy's level 4 battle
function salafy_win() =>
    wScript_Text() == bank_address(0x04D58F) // nrmvash13.mgi Line 139, TextIcon(ICON_SALAFY) - triggers on first textbox open after defeating Salafy (any level), or afte running from Salafy

// Chests
function _get_treasure() =>
    wScript_System() == bank_address(0x08805A) // system.mgi Line 41, TextClose() - System event

// Minigames
function minigame_underneath_points() =>
    wScript_Text() == bank_address(0x0738E8) // undtown08.mgi Line 74, TextClose() - triggers on textbox close after receiving score result
function minigame_cald_points() =>
    wScript_Text() == bank_address(0x073488) // undtown08_sct.mgi Line 68, TextClose() - triggers on textbox close after receiving score result
function minigame_brub() =>
    wScript_Master() == bank_address(0x073A21) // undtown09.mgi Line 31, Sync(2,0) - triggers when brub scene is loaded
function minigame_archery() =>
    wScript_Master() == bank_address(0x09A710) // nrmvash24.mgi Line 49, PalFade(0,15,32,0) - triggers when archery scene is loaded

function archery_target_animite() =>
    wScript_Scroll() == bank_address(0x09A7EF) // nrmvash24.mgi Line 117, ScrollMap(2,2,0), (Frame-perfect) - triggers when screen starts to shake after animite is hit
function archery_target_slow() =>
    changes_from(wScript_Scroll(), bank_address(0x09A877)) // nrmvash24.mgi Line 161, Delay(10) (end, Frame-perfect) - triggers when target resets from destroyed state. Also works with bug where actor stays in permanent destroyed state
function archery_target_medium() =>
    changes_from(wScript_Scroll(), bank_address(0x09A8B5)) // nrmvash24.mgi Line 176, Delay(10) (end, Frame-perfect) - triggers when target resets from destroyed state. Also works with bug where actor stays in permanent destroyed state
function archery_target_fast() =>
    changes_from(wScript_Scroll(), bank_address(0x09A8F3)) // nrmvash24.mgi Line 191, Delay(10) (end, Frame-perfect) - triggers when target resets from destroyed state. Also works with bug where actor stays in permanent destroyed state

function agovo_start() =>
    wScript_Master() == bank_address(0x05A7A3) // nrmvash02.mgi Line 368, TextClose() - triggers on textbox close right when Tony's state becomes AI_Hero and gains control of his character in the Agovo room
function agovo_win() =>
    wScript_Master() == bank_address(0x05A393) // nrmvash02.mgi Line 77, TextWrite("You win!") - triggers on textbox close at the end of the Agovo room
function agovo_lose() =>
    wScript_Master() == bank_address(0x05A381) // nrmvash02.mgi Line 67, TextWrite("You lose!") - triggers on textbox close at the end of the Agovo room

// Forging Dream Creatures
// Triggers on textbox open after ring crafting animation
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
    wScript_Text() == bank_address(0x0727E3) // undtown06.mgi Line 103, TextClose() - triggers on textbox close after Tony thanks Motash
function close_training_door() =>
    wScript_System() == bank_address(0x04C159) // nrmvash13_dr.mgi Line 93, TextClose() - triggers on textbox close after Click! when closing door
function large_screwdriver() =>
    wScript_System() == bank_address(0x06DFF0) // hldmaze08_dr.mgi Line 67, TextClose() - triggers on textbox close after examination of screwdriver
function greet_coresmith() =>
    wScript_Text() == bank_address(0x0963C9) // hdnroom01.mgi Line 110, TextIcon(ICON_CLOAK) - triggers on textbox open when dialogue with coresmith starts

// Graphics Scripts
Brub_Squished_Anim = bank_address(0x0472C6) // objects_anim.mgi Line 383, Frame(32,0,0,?Brub_Splat)
RedBrub_Squished_Anim = bank_address(0x047327) // objects_anim.mgi Line 422, Frame(32,0,0,?RedBrub_Splat)

// Prisoner Thanks
// Prisoner thanking the player once reward has already been received. See also Prisoner Reward
HldPrisoner_Thanks = [
    bank_address(0x08B055), //1 nrmvash17.mgi Line 24, TextClose()
    bank_address(0x07ACB9), //2 cldlavatown10_txt.mgi Line 26, TextClose()
    bank_address(0x04F6BF), //3 wvepathvalley04_txt.mgi Line 32, TextClose()
    bank_address(0x088395), //4 undtown01_txt.mgi Line 38, TextClose()
    bank_address(0x054510), //5 undcave03_sct.mgi Line 60, TextClose()
    bank_address(0x05D65A), //6 cldlavavent04_sct.mgi Line 64, TextClose()
    bank_address(0x0AA7CA) //7 ferry02.mgi Line 476, TextClose()
    // 8 only accessible by hacking ardgarden04.mgi
]

///////////////////
// String Buffer //
///////////////////

function battle_source(source) => ascii_string_equals(Battle_Source, source) // Battle info is stored in WRAM7, so we can't access the ID directly on all Cores
function battle_target(target) => ascii_string_equals(Battle_Target, target)
function treasure_name(name) => ascii_string_equals(Treasure_Name, name) // The item received ID is written and then erased from WRAM before the end of a single frame, so we can't access the ID directly


////////////
// Battle //
////////////

function tony_summon(creature) => _tony_summon() && battle_target(creature)
function magi_summon(magi, creature) => _magi_summon() && battle_source(magi) && battle_target(creature)
function wild_appear(creature) => _wild_appear() && battle_target(creature)

// If any of the 4 enemy dream creatures, or enemy magi, gets a damage pop-up of 100 or more
function enemy_number_popup() =>
    any_of(range(5, 9), actorid => wActorScriptA[actorid] == NumberBounce_Anim) //id 4-8 = enemy dream creatures, id 9 = enemy magi


//////////
// Menu //
//////////

// I wish there was a less janky way of verifying all this, unfortunately without direct access to SRAM we are stuck with this dumb verification method
// We also don't have protection against someone stealing a completed savefile, but again, nothing we can do about it without SRAM access


// Check if Equip menu has ever been loaded.
function equip_uninitialized() =>
    wMenu_RingBank_VisibleRingCount() == 0
// In the rare case that we can't rely on saved WRAM values because the game has been rebooted but WRAM has not been initialized,
// wait to detect any change to RingBank, meaning we know that the information has been updated.
// Very slightly janky as you might have to page back and forth once, but invalid WRAM should be an extremely rare situation (probably only caused by intentional attempts to cheat the achievement)
function equip_updated() =>
    changes(dword(wMenu_RingBank_VisibleRings)) //|| changes(dword(wMenu_RingBank_VisibleRings + 4)) || changes(dword(wMenu_RingBank_VisibleRings + 8)) || changes(word(wMenu_RingBank_VisibleRings + 12))
function equip_wram_revalidate() =>
    never(always_true() && once(game_reset()) && equip_updated()) && never(always_true() && once(battle_reset()) && equip_updated()) // always_true() to force a different order of the params or else it doesn't work properly
// Janky check to see if each creature is in any of the 7 positions in the menu
function own_creature(id) =>
    once(any_of(range(0, 6), i => byte(wMenu_RingBank_VisibleRings + 2*i) == id))
function own_creatures() =>
    measured(tally_of(Obtainable_Creatures, 77, id => own_creature(id)))

// Check if wMenu_MainMenu_Entry_EntriesPointers menu has ever been loaded.
function relic_uninitialized() =>
    dword(wMenu_MainMenu_Entry_EntriesPointers) == 0
// In the rare case that we can't rely on saved WRAM values because the game has been rebooted but WRAM has not been initialized,
// wait to detect any change to wMenu_MainMenu_Entry_EntriesPointers, meaning we know that the information has been updated.
// Very slightly janky as you might have to page back and forth once, but invalid WRAM should be an extremely rare situation (probably only caused by intentional attempts to cheat the achievement)
// We use wMenu_MainMenu_Entry_EntriesPointers + 1 because the previous var has an overflow bug that sometimes overwrites the very first byte in wMenu_MainMenu_Entry_EntriesPointers, and we don't want to detect this change
function relic_updated() =>
    changes(dword(wMenu_MainMenu_Entry_EntriesPointers + 1)) //|| changes(dword(wMenu_MainMenu_Entry_EntriesPointers + 5)) || changes(byte(wMenu_MainMenu_Entry_EntriesPointers + 9))
function relic_wram_revalidate() =>
    never(always_true() && once(game_reset()) && relic_updated()) && never(always_true() && once(battle_reset()) && relic_updated()) // always_true() to force a different order of the params or else it doesn't work properly
// Janky check to see if each relic is in any of the 5 positions in the menu
// Unfortunately, we cannot access/read the 2 equipped relics without reading. (Technically we can read the 2nd relic by string only, but that's too janky)
function own_relic(id) =>
    once(any_of(range(0, 4), i => word(wMenu_MainMenu_Entry_EntriesPointers + 2*i) == (xInventory_Relics + id)))
function own_relics() =>
    measured(tally_of(Obtainable_Relics, 32, id => own_relic(id)))

// Forging a dream creature - easy and straightforward
forge_location = {
    "Naroom": forge_naroom(),
    "Underneath": forge_underneath(),
    "Cald": forge_cald(),
    "Orothe": (forge_orothe_city() || forge_orothe_island()),
    "Arderial": forge_arderial(),
    "Core": forge_core()
}
function forge(location, creature) =>
    forge_location[location] && (wScript_RingMadeID() == creature)

///////////////
// MiniGames //
///////////////

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


//////////
// Misc //
//////////

// Asserts that WRAM has been initialized.
// (GBC boot ROM seems to only modify WRAM2 and HRAM, so we shouldn't expect the boot ROM to trigger any achievements prior to initialization (nor on hard reset))
function game_init() =>
    wSound_SoundInit() == Sound_Init_MagicNumber

// Used to reset if i2 logo is displayed, as you can do a soft reset by pressing Select-Start-A-B, by formatting game pak, or by watching the credits
// which could in rare cases be used to cheat on leaderboards or for specific achievements
function game_reset() =>
    i2_logo()

// The last way to reset is by losing a battle and warping back to the loading room (skips the i2 logo)
function battle_reset() =>
    battle_lost()

// Treasure chest item
function get_treasure(name) => _get_treasure() && treasure_name(name)

// Shadowhold prisoners
function prisoner(id) =>
    once((wScript_Text() == HldPrisoner_Reward[id]) || (wScript_Text() == HldPrisoner_Thanks[id]))
function prisoners() =>
    measured(tally_of(range(0,6), 7, id => prisoner(id)))


//////////////////
// Achievements //
//////////////////

// The achievement covers pretty much all possible progression and all secrets, except for:
// All blast urn rooms (requires SRAM ideally, or else the setup is too janky, but we already require 1 room for Jailbreak so I don't think this achievement is necessarily a great idea)
// Opening all chests in all locations (requires SRAM so not currently doable)
// Refusing to fight Agadon (bad ending)
// Taking the easy vs hard way with Warrada (doesn't really make much a difference)
// Saving Eryn and Karyn vs letting them die (doesn't make a big difference, and you need to save them to get atwice ll relics)
// Note that the Arderial and Core hyrens are unobtainable in the game and so there are no achievements for them


// Geysers //
/////////////
achievement(
    title = "Hero of Naroom", points = 5,
    description = "Complete the first Shadow Geyser",
    id = 404343, badge = "459092",
    trigger = game_init() && geyser1()
)
achievement(
    title = "Hero of the Underneath", points = 5,
    description = "Complete the second Shadow Geyser",
    id = 404344, badge = "459100",
    trigger = game_init() && geyser2()
)
achievement(
    title = "Hero of the Cald", points = 5,
    description = "Complete the third Shadow Geyser",
    id = 404345, badge = "459111",
    trigger = game_init() && geyser3()
)
achievement(
    title = "Hero of Orothe", points = 10,
    description = "Complete the fourth Shadow Geyser",
    id = 404346, badge = "459118",
    trigger = game_init() && (geyser4_fight() || geyser4_nofight())
)
achievement(
    title = "Hero of Arderial", points = 10,
    description = "Defeat Morag",  // Avoid spoilers
    id = 404347, badge = "459124",
    trigger = game_init() && geyser5()
)
achievement(
    title = "Hero of Magi-Nation", points = 25,
    description = "Defeat Agram",
    id = 404348, badge = "459126",
    trigger = game_init() && agram_end()
)

// Hero Abilities //
////////////////////
achievement(
    title = "Welcome to the Jungle", points = 1,
    description = "Obtain the Translation Bracelet",
    id = 411979, badge = "466856",
    trigger = game_init() && translation_bracelet()
)
achievement(
    title = "You're the Best Around", points = 1,
    description = "Obtain the Energy Band",
    id = 404349, badge = "459089",
    trigger = game_init() && energy_band()
)
achievement(
    title = "But Where Do My Pinkies Go?", points = 1,
    description = "Obtain the Crystal Gloves",
    id = 404350, badge = "459095",
    trigger = game_init() && crystal_gloves()
)
achievement(
    title = "Fancy Footwear", points = 2,
    description = "Obtain Agadon's Boots",
    id = 404351, badge = "459105",
    trigger = game_init() && agadons_boots()
)
achievement(
    title = "Under the Sea", points = 2,
    description = "Obtain the Orothean Belt",
    id = 404352, badge = "459113",
    trigger = game_init() && orothean_belt()
)
achievement(
    title = "Highway to Heaven", points = 3,
    description = "Meet the Queen",  // Avoid spoilers
    id = 404353, badge = "459120",
    trigger = game_init() && eye_of_the_storm()
)

// MiniGames //
///////////////
achievement(
    title = "Brub Scrub", points = 5,
    description = "Score at least 50 points in Scrub the Brub",
    id = 404354, badge = "459096",
    trigger = never(!game_init()) && brub_start() && brub_end() && (number_buffer() >= bcd_8(50)) // use number_buffer() instead of brub_count() since we only need to check the total score at the end
)
achievement(
    title = "Brub Elite", points = 10,
    description = "Score at least 60 points in Scrub the Brub",
    id = 404355, badge = "459097",
    trigger = never(!game_init()) && brub_start() && brub_end() && (number_buffer() >= bcd_8(60)) // use number_buffer() instead of brub_count() since we only need to check the total score at the end
)
leaderboard(
    title = "Scrub the Brub",
    description = "Highest points in Scrub the Brub",
    start = game_init() && minigame_brub(), // We don't need to use once() so we don't need to use brub_start()
    cancel = game_reset(),
    submit = __ornext(brub_end()),
    value = brub_count(), // use brub_count() instead of number_buffer() so we can keep track of score during the minigame
    format = "VALUE",
    lower_is_better = false,
    id = 90347
)

achievement(
    title = "Aim for Tickets", points = 5,
    description = "Score at least 50 points in Aim for Animite",
    id = 404356, badge = "459102",
    trigger = never(!game_init()) && archery_start() && archery_end() && (number_buffer() >= bcd_8(50)) // use number_buffer() instead of archery_count() since we only need to check the total score at the end
)
achievement(
    title = "Bullseye", points = 10,
    description = "Score at least 60 points in Aim for Animite",
    id = 404357, badge = "459103",
    trigger = never(!game_init()) && archery_start() && archery_end() && (number_buffer() >= bcd_8(60)) // use number_buffer() instead of archery_count() since we only need to check the total score at the end
)
leaderboard(
    title = "Aim for Animite",
    description = "Highest points in Aim for Animite",
    start = game_init() && minigame_archery(), // We don't need to use once() so we don't need to use archery_start()
    cancel = game_reset(),
    submit = archery_end(),
    value = archery_count(), // use archery_count() instead of number_buffer() so we can keep track of score during the minigame
    format = "VALUE",
    lower_is_better = false,
    id = 90348
)

achievement(
    title = "Speedy Tony", points = 5,
    description = "Beat Avoid the Agovos in under 7.7 seconds", // 7.7*60-1 = 461. Subtract 1 to correspond frame-perfectly with the leaderboard (empirically tested)
    id = 404358, badge = "459093",
    trigger = never(!game_init()) && disable_when(repeated(461, always_true()), until=agovo_start()) && agovo_win()
)
achievement(
    title = "Flash Tony", points = 10,
    description = "Beat Avoid the Agovos in under 7.4 seconds", // 7.4*60-1 = 443. Subtract 1 to correspond frame-perfectly with the leaderboard (empirically tested)
    id = 404359, badge = "459094",
    trigger = never(!game_init()) && disable_when(repeated(443, always_true()), until=agovo_start()) && agovo_win()
)
leaderboard(
    title = "Avoid the Agovos",
    description = "Fastest time in Avoid the Agovos",
    start = game_init() && agovo_start(),
    cancel = __ornext(agovo_lose() || game_reset()),
    submit = agovo_win(),
    value = always_true(),
    format = "FRAMES",
    lower_is_better = true,
    id = 90349
)

// Spells //
////////////
achievement(
    title = "Throw Leaves at Enemies", points = 1,
    description = "Obtain Leaf Cut in Naroom",
    id = 404360, badge = "459088",
    trigger = game_init() && leaf_cut()
)
achievement(
    title = "Throw Healing at Friends", points = 1,
    description = "Obtain Grow in Naroom",
    id = 404361, badge = "459090",
    trigger = game_init() && get_treasure("Grow        ")
)
achievement(
    title = "Rock and Roll", points = 3,
    description = "Obtain Cave In in the second Shadow Geyser",
    id = 404362, badge = "459099",
    trigger = game_init() && get_treasure("Cave In     ")
)
achievement(
    title = "Ready to Rumble", points = 3,
    description = "Obtain Thunderquake in the second Shadow Geyser",
    id = 404363, badge = "459098",
    trigger = game_init() && get_treasure("Thunderquake")
)
achievement(
    title = "Have Some Flame", points = 5,
    description = "Obtain Fireball in the Cald",
    id = 404364, badge = "459104",
    trigger = game_init() && get_treasure("Fireball    ")
)
achievement(
    title = "After the Flame, Only Ashes Remain", points = 2,
    description = "Obtain Flame Geyser in the third Shadow Geyser",
    id = 404365, badge = "459110",
    trigger = game_init() && get_treasure("Flame Geyser")
)
achievement(
    title = "Abracadableeeerrrgh!", points = 1,
    description = "Obtain Entangle in Orothe",
    id = 404366, badge = "459116",
    trigger = game_init() && get_treasure("Entangle    ")
)
achievement(
    title = "Not What You Expect", points = 1,
    description = "Obtain the Blurry Scroll in Orothe",
    id = 404367, badge = "459115",
    trigger = game_init() && blurry_scroll()
)
achievement(
    title = "Bend Water to Your Will", points = 3,
    description = "Obtain Tidal Wave in the fourth Shadow Geyser",
    id = 404368, badge = "459117",
    trigger = game_init() && get_treasure("Tidal Wave  ")
)
achievement(
    title = "Zaptacular", points = 3,
    description = "Obtain Lightning before facing Morag", // Avoid spoilers
    id = 404369, badge = "459122",
    trigger = game_init() && get_treasure("Lightning   ")
)
achievement(
    title = "Winds of Protection", points = 3,
    description = "Obtain Updraft before facing Morag", // Avoid spoilers
    id = 404370, badge = "459123",
    trigger = game_init() && get_treasure("Updraft     ")
)

// Completionist //
///////////////////
achievement(
    title = "Great Furok", points = 5,
    description = "Obtain a Great Furok by almost escaping the Tavel Gorge caves",
    id = 404371, badge = "459087",
    trigger = game_init() && great_furok()
)
achievement(
    title = "Solo Operative", points = 10,
    description = "Obtain Maelstrom by defeating all the ShadowMagi without any help",
    id = 404372, badge = "459101",
    trigger = game_init() && maelstrom()
)
achievement(
    title = "Skeleton Key", points = 5,
    description = "Find the Channeled Gem using Ashgar's Key",
    id = 404373, badge = "459107",
    trigger = game_init() && get_treasure("ChanneledGem")
)
achievement(
    title = "Second Largest Screwdriver", points = 25,
    description = "Examine the large screwdriver near some Jingjacks", // Avoid spoilers
    id = 404374, badge = "459112",
    trigger = game_init() && large_screwdriver()
)
achievement(
    title = "Savior", points = 25,
    description = "Cure Orwin",
    id = 404375, badge = "459114",
    trigger = game_init() && cure_orwin()
)
achievement(
    title = "Jailbreak", points = 25,
    description = "Rescue all 7 prisoners, find them throughout the world, and then, without resetting, talk to each of them",
    id = 406696, badge = "460199",
    trigger = game_init() && prisoners() // We don't care about protecting against game reset
)
achievement(
    title = "Funeral", points = 5,
    description = "After defeating Agram, attend a funeral instead of going home",
    id = 405828, badge = "459150",
    trigger = game_init() && funeral()
)
achievement(
    title = "Spoiled Kyros", points = 10,
    description = "After defeating Agram, attend a party instead of going home",
    id = 404376, badge = "459127",
    trigger = game_init() && party()
)
achievement(
    title = "Simpsons Homage", points = 10,
    description = "Do everything at the Naroom party before leaving",
    id = 404377, badge = "459128",
    trigger = game_init() && evu_secret()
)
achievement(
    title = "The Third Door", points = 5,
    description = "Unlock New Game Plus",
    id = 404378, badge = "459129",
    trigger = game_init() && new_game_plus()
)
achievement(
    title = "Dark Side", points = 25,
    description = "Visit the Core Ringsmith",
    id = 404379, badge = "459130",
    trigger = game_init() && greet_coresmith()
)
achievement(
    title = "Gotta Catch 'Em All", points = 50,
    description = "Forge all 77 forgeable dream creatures, and browse through all of them in the Equip Menu",
    id = 408602, badge = "463338",
    trigger = never(equip_uninitialized()) && equip_wram_revalidate() && own_creatures() // No need for game_init() since it is covered within equip_uninitialized(). Reset to prevent animite scumming to craft 2 different creatures
)
achievement(
    title = "Archaeologist", points = 50,
    description = "Obtain all 32 obtainable relics, and browse through all of them, unequipped, in the Start Menu",
    id = 408603, badge = "463339",
    trigger = never(relic_uninitialized()) && relic_wram_revalidate() && own_relics()  // No need for game_init() since it is covered within relic_uninitialized(). Reset to prevent scumming Spice & Pinch of Life
)

// Dream Creatures //
/////////////////////
achievement(
    title = "Leaves that Cut", points = 5,
    description = "Forge Leaf Hyren",
    id = 404380, badge = "459132",
    trigger = game_init() && forge("Naroom", CreatureID_Leaf_Hyren)
)
achievement(
    title = "Tree Power", points = 5,
    description = "Forge Timber Hyren",
    id = 404394, badge = "459133",
    trigger = game_init() && forge("Naroom", CreatureID_TimberHyrn)
)
achievement(
    title = "Pummel Party", points = 5,
    description = "Forge Mush Hyren",
    id = 404381, badge = "459134",
    trigger = game_init() && forge("Underneath", CreatureID_Mush_Hyren)
)
achievement(
    title = "Bury Your Foes", points = 5,
    description = "Forge Cave Hyren",
    id = 404382, badge = "459135",
    trigger = game_init() && forge("Underneath", CreatureID_Cave_Hyren)
)
achievement(
    title = "Flightless Wings", points = 5,
    description = "Forge Magma Hyren",
    id = 404383, badge = "459136",
    trigger = game_init() && forge("Cald", CreatureID_MagmaHyren)
)
achievement(
    title = "Purifying Flame", points = 5,
    description = "Forge Flame Hyren",
    id = 404384, badge = "459137",
    trigger = game_init() && forge("Cald", CreatureID_FlameHyren)
)
achievement(
    title = "Sitting Pretty", points = 5,
    description = "Forge Coral Hyren",
    id = 404385, badge = "459138",
    trigger = game_init() && forge("Orothe", CreatureID_CoralHyren)
)
achievement(
    title = "Ruler of the Depths", points = 5,
    description = "Forge Deep Hyren",
    id = 404395, badge = "459139",
    trigger = game_init() && forge("Orothe", CreatureID_Deep_Hyren)
)
achievement(
    title = "Beast of the Sea", points = 5,
    description = "Forge Megathan",
    id = 404386, badge = "459140",
    trigger = game_init() && forge("Orothe", CreatureID_Megathan)
)
achievement(
    title = "Wind Fish", points = 5,
    description = "Forge Orathan F",
    id = 404387, badge = "459141",
    trigger = game_init() && forge("Arderial", CreatureID_Orathan_F)
)
achievement(
    title = "Now THAT is a BIG Mushroom", points = 25,
    description = "Encounter Ormagon",
    id = 404388, badge = "459125",
    trigger = game_init() && wild_appear("Ormagon   ")
)

// Fun //
/////////
achievement(
    title = "Outhouse", points = 1,
    description = "Look inside Gia's 'storage shed'",
    id = 404396, badge = "459091",
    trigger = game_init() && poop_gag()
)
achievement(
    title = "Acquired Taste", points = 3,
    description = "Eat 20 mushrooms",
    id = 404389, badge = "458598",
    trigger = game_init() && mushroom_gag()
)
achievement(
    title = "So That's Where Soap Comes From", points = 1,
    description = "Tell Eidon about Oflardt's stories",
    id = 404390, badge = "459106",
    trigger = game_init() && soap_gag()
)
achievement(
    title = "Bargainer", points = 3,
    description = "Haggle the ferryman down to his lowest price",
    id = 404391, badge = "459108",
    trigger = game_init() && haggle()
)
achievement(
    title = "Gentleman Thief", points = 5,
    description = "Close the training equipment door after opening it",
    id = 404397, badge = "459109",
    trigger = game_init() && close_training_door()
)


// Battles //
/////////////
achievement(
    title = "Two Stooges", points = 10,
    description = "Defeat Korg and Zet", // Avoid spoilers
    id = 404393, badge = "459119",
    trigger = game_init() && zet_end()
)
achievement(
    title = "Weebest", points = 25,
    description = "Defeat Salafy in her strongest form",
    id = 404398, badge = "459121",
    trigger = never(!game_init()) && never(game_reset()) && never(battle_reset()) && never(tony_escapes()) && once(salafy_level4_start()) && salafy_win() // Tony escaping counts as a win, so we need to explicitly guard against this
)

// Battle Moves //
//////////////////
achievement(
    title = "Drink Water", points = 5,
    description = "Cure Hiccups by using a Water attack on an afflicted Dream Creature",
    id = 422151, badge = "476817",
    trigger = game_init() && hiccups_cured()
)
achievement(
    title = "Fever Dream", points = 5,
    description = "Cure Plague by using a Fire attack on an afflicted Dream Creature",
    id = 422152, badge = "476818",
    trigger = game_init() && plague_cured()
)
achievement(
    title = "One-Hit KO", points = 1,
    description = "Witness a terminating attack",
    id = 422153, badge = "476819",
    trigger = game_init() && terminates()
)
achievement(
    title = "Mauled to Death", points = 5,
    description = "Deal 100 or more damage in one attack",
    id = 422154, badge = "476820",
    trigger = game_init() && (number_buffer() >= bcd_8(100)) && enemy_number_popup()
)

///////////////////
// Rich Presence //
///////////////////

// The scene/menu/battle status isn't directly kept track in any variable, it is instead based on the script frame and PC,
// but we can reasonably guess the loaded scene using the loaded hotspot pointers
// One scene can have multiple different hotspot tables depending on how you get to the specific scene and the game progress
// Cutscenes and some special scripted scenes don't load any hotspots, but they should be short-lasted and minimal
// Hotspot tables are located in bank 0x21
function wHotspot_Table() => word(0xC6DF)
// Autogenerated from hotspot_parser.py
hotspot_lookup = {
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
    0x5005: "Abandoned Tower",   // HS_FORT01
    0x5017: "Abandoned Tower",   // HS_FORT02
    0x5020: "Abandoned Tower",   // HS_FORT02B
    0x5032: "Abandoned Tower",   // HS_FORT03
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
    GC_NAROOM_GEYSER: "Facing the first Shadow Geyser",
    GC_GLOVES: "Destroyed the first Shadow Geyser",
    GC_UND_INTRO: "Exploring the Underneath",
    GC_UND_QUAKE: "Investigating another earthquake",
    GC_UND_GEYSER: "Facing the second Shadow Geyser",
    GC_UND_WASTED: "Destroying the second Shadow Geyser", // Changes at start of geyser boss battle
    GC_CALD_INTRO: "Leaving the Underneath",
    GC_ARBOLL_HUNT: "Hunting for that blasted Lava Arboll",
    GC_LAVA_BRIDGE: "Building a bridge",
    GC_BOOTS_QUEST: "Getting a nice pair of boots",
    GC_CALD_GEYSER: "Facing the third Shadow Geyser",
    GC_TONY_KIDNAPPED: "Having a party",
    GC_SHADOWHOLD_JAIL: "In a pickle",
    GC_BACK_IN_OROTHE: "Swimming with turtles",
    GC_OROTHE_GEYSER: "Facing the fourth Shadow Geyser",
    GC_BEAT_OROTHE: "Destroyed the fourth Shadow Geyser",
    GC_FALSE_END: "Heading home",
    GC_ARDERIAL: "Meeting the queen",
    GC_ARDERIAL_GEYSER: "Met the queen",
    GC_AGRAM_BATTLE: "Facing the Core",
    GC_END_FUNERAL: "Attending a funeral",
    GC_END_PARTY: "Life of the party",
}

// We can't directly track Tony's stats since they are saved in SRAM1 & SRAM3, which are never exposed,
// but every time he enters a battle, his stats are loaded into WRAM7
// We can display Tony's stats for the supported cores (i.e. not mGBA)
// We need to make sure at least one battle has occurred to be able to read his stats,
// and they will unfortunately only update every battle, not in-between

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
    "Progression: {0}. Location: {1}. Level {2} ({3})",
    rich_presence_lookup("Gamecount", xGameCount(), gamecount_lookup, "???"),
    rich_presence_lookup("Location", wHotspot_Table(), hotspot_lookup, "???"),
    rich_presence_value("Tony Level", wBattle_Creature_Hero_Level(), "VALUE"),
    rich_presence_value("Tony MaxEnergy", wBattle_Creature_Hero_MaxEnergy(), "VALUE")
)
rich_presence_conditional_display(
    battle_wram_valid(),
    "Location: {0}. Level {1} ({2})",
    rich_presence_lookup("Location", wHotspot_Table(), hotspot_lookup, "???"),
    rich_presence_value("Tony Level", wBattle_Creature_Hero_Level(), "VALUE"),
    rich_presence_value("Tony MaxEnergy", wBattle_Creature_Hero_MaxEnergy(), "VALUE")
)
rich_presence_conditional_display(
    sram_valid(),
    "Progression: {0}. Location: {1}.",
    rich_presence_lookup("Gamecount", xGameCount(), gamecount_lookup, "???"),
    rich_presence_lookup("Location", wHotspot_Table(), hotspot_lookup, "???")
)
rich_presence_display(
    "Location: {0}.",
    rich_presence_lookup("Location", wHotspot_Table(), hotspot_lookup, "???")
)