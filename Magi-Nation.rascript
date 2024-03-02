// Magi-Nation (GBC)
// #ID = 4731
// md5: 1624f857098ca278b15629914f48352b

// Mapping reference: https://github.com/RetroAchievements/rcheevos/blob/cc854ad75b6533e73cff5eb7a92429c5750c01a3/src/rcheevos/consoleinfo.c#L422
// Unfortunately, only the first SRAM is mapped, and since the save file swaps between bank 0 and 2
// we can't reliably read SRAM at the moment.
// WRAM0 and 1 are mapped.
// Gambatte, GearBoy, VGA-M, SameBoy and GBHawk all support WRAM2-7 at 0x10000-0x16000
// However, mGBA does not, meaning this memory location is core-dependant
// Therefore the only useable memory for achievements is WRAM0, along with WRAM1 (only has MusyX data)
// This means that magi and creature stats and count, chests, spells, relics, glyph status, hero abilities are all locked out

// Reference source code: https://github.com/GauChoob/magination

//////////////////////
// Helper Functions //
//////////////////////

// Only valid for ROM banks >= 1
function bank_address(address) => byte(address)*0x4000 - 0x4000 + word(address + 1)

function changes_from(address, value) => (prev(address) == value) && (address != value)

//////////
// WRAM //
//////////

// The game has 4 different bytecode scripts running simultaneously, plus each Actor has 1-2 scripts, up to a maximum of 24 simultaneous threads
// TODO - wrap these in bank_address
function wScript_Master() => bank_address(0xC706)
function wScript_Scroll() => bank_address(0xC70D)
function wScript_System() => bank_address(0xC714)
function wScript_Text() => bank_address(0xC71B)

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
    array_push(wActorScriptA, bank_address(wActor_00 + wActor_Size*i + wActor_Offset_ScriptA))
    array_push(wActorScriptB, bank_address(wActor_00 + wActor_Size*i + wActor_Offset_ScriptB))
}

wActorTony = 0xC189
function wActorTonyState() => word(wActorTony + wActor_Offset_State)
function wActorTonyX() => byte(wActorTony + wActor_Offset_X)
function wActorTonyY() => byte(wActorTony + wActor_Offset_Y)
function wActorTonyScriptA() => bank_address(wActorTony + wActor_Offset_ScriptA)
function wActorTonyScriptB() => bank_address(wActorTony + wActor_Offset_ScriptB)


// String buffer for text input
wText_StringBuffer = 0xC949
Battle_Source = wText_StringBuffer + 0 // Battle action source and targets
Battle_Target = wText_StringBuffer + 11
Treasure_Name = wText_StringBuffer + 1 // Starts at 0, but skip the (optional) item icon for simplicity

//TODO unused
// Buttons pressed (Held, PushDown, PushUp)
wCnt1 = 0xC931
wCntDown = 0xC932
wCntUp = 0xC933
Button_A = 0
Button_B = 1
Button_Select = 2
Button_Start = 3
Button_Right = 4
Button_Left = 5
Button_Up = 6
Button_Down = 7

// Sound is initialized right after WRAM is wiped on reset
function wSound_SoundInit() => byte(0xC91D)
Sound_Init_MagicNumber = 0x55
// Requested SFX
function wSound_Control_SFX0() => byte(0xC921)
SFXID_CriticalAttack = 14



////////////////////////////////
//  Bytecode Script Addresses //
////////////////////////////////

// Unique actions //

// TODO Unused
function i2_logo_displayed() =>
    wScript_Master() == 0x0AB260 // hdnload01.mgi Line 19, Delay(90)

function great_furok() =>
    wScript_Text() == 0x053A0A // nrmvash11_txt.mgi Line 281, TextClose()

function leaf_cut() =>
    wScript_Text() == 0x0AC508 // nrmvash12_txt.mgi Line 109, TextClose()
function blurry_scroll() =>
    wScript_Text() == 0x066A01 // ororuins02_dr.mgi Line 22, TextClose()

function maelstrom() =>
    wScript_Text() == 0x06B4D5 // cldlavatown14_txt.mgi Line 86, TextClose()

function energy_band() =>
    wScript_Text() == 0x052835 // nrmglade09A_txt.mgi Line 187, TextClose()
function crystal_gloves() =>
    wScript_Text() == 0x0746FC // wvegiashut01_txt.mgi Line 102, TextClose()
function agadons_boots() =>
    wScript_System() == 0x067B62 // orotunnel10_dr.mgi Line 29 TextClose()
function orothean_belt() =>
    wScript_Text() == 0x070E4C // hldcell06.mgi Line 422 TextClose()
   
function geyser1() =>
    wScript_Master() == 0x06A7F3 // nrmgeyser11.mgi Line 106, PalFade(0,15,32,0)
function geyser2() =>
    wScript_Master() == 0x04ED51 // undgeyser09.mgi Line 136, PalFade(0,15,32,0)
function geyser3() =>
    wScript_Master() == 0x07FB09 // cldgeyser05.mgi Line 93, PalFade(0,15,32,0)

function poop_gag() =>
    wScript_System() == 0x0742C4 // wvegiashut01_dr.mgi Line 38, TextClose()
function soap_gag() =>
    wScript_Text() == 0x074FE5 // wvegiashut01.mgi Line 463, TextClose()
function haggle() =>
    wScript_Text() == 0x0A97CD // ferry01_txt.mgi Line 241, TextIcon(ICON_TONY)

function morag_underneath_start() =>
    wScript_Text() == 0x088DAE // undtown01_txt.mgi Line 380, TextClose()
function morag_underneath_end() =>
    wScript_Text() == 0x088DB2 // undtown01_txt.mgi Line 386, TextIcon(ICON_MORAG)


// Repeatable actions

// Battle
function _tony_summon() =>
    wScript_Text() == 0x130AF4 // battle_txt.mgi Line 954, TextClose()
function _magi_summon() =>
    wScript_Text() == 0x130B09 // battle_txt.mgi Line 964, TextClose()
function _wild_appear() =>
    wScript_Text() == 0x130B19 // battle_txt.mgi Line 974, TextClose()
function tony_wins() =>
    wScript_Text() == 0x130B69 // battle_txt.mgi Line 1016, TextClose()

// Chests
function _get_treasure() =>
    wScript_System() == 0x08805A // system.mgi Line 41, TextClose()

// Minigames
function minigame_underneath_points() =>
    wScript_Text() == 0x0738E8 // undtown08.mgi Line 74, TextClose()
function minigame_cald_points() =>
    wScript_Text() == 0x073488 // undtown08_sct.mgi Line 68, TextClose()
function minigame_brub() =>
    wScript_Master() == 0x073A21 // undtown09.mgi Line 31, Sync(2,0)
function minigame_archery() =>
    wScript_Master() == 0x09A710 // nrmvash24.mgi Line 49, PalFade(0,15,32,0)

function archery_target_animite() =>
    wScript_Scroll() == 0x9A7EF // nrmvash24.mgi Line 117, ScrollMap(2,2,0), (Frame-perfect)
function archery_target_slow() =>
    changes_from(wScript_Scroll(), 0x9A877) // nrmvash24.mgi Line 161, Delay(10) (end, Frame-perfect)
function archery_target_medium() =>
    changes_from(wScript_Scroll(), 0x9A8B5) // nrmvash24.mgi Line 176, Delay(10) (end, Frame-perfect)
function archery_target_fast() =>
    changes_from(wScript_Scroll(), 0x9A8F3) // nrmvash24.mgi Line 191, Delay(10) (end, Frame-perfect)

function agovo_start() =>
    wScript_Master() == 0x05A7A3 // nrmvash02.mgi Line 379, TextClose()
function agovo_win() =>
    wScript_Master() == 0x05A393 // nrmvash02.mgi Line 77, TextWrite("You win!")
function agovo_lose() =>
    wScript_Master() == 0x05A381 // nrmvash02.mgi Line 67, TextWrite("You lose!")

// Misc

function mushroom_gag() =>
    wScript_Text() == 0x0727E3 // undtown06.mgi Line 103, End()
function close_training_door() =>
    wScript_System() == 0x04C159 // nrmvash13_dr.mgi Line 241, TextClose()

// Actor Frames (Bank 1 ROM)

AI_Anim = 0x4A6B
AI_Hero_Main = 0x5D81

// Actor Graphics
Brub_Squished_Anim = 0x0472C6 // objects_anim.mgi Line 383, Frame(32,0,0,?Brub_Splat)
RedBrub_Squished_Anim = 0x0047327 // objects_anim.mgi Line 422, Frame(32,0,0,?RedBrub_Splat)

/////////////////
// Actor State //
/////////////////

function tony_frozen() =>
    wActorTonyState() == AI_Anim

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

// WRAM has been initialized
function game_init() => wSound_SoundInit() == Sound_Init_MagicNumber

function get_treasure(name) => _get_treasure() && treasure_name(name)

//TODO unused
function press(button) =>
    bit(button, wCntDown) == 1
function menu() =>
    press(Button_Start)

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
achievement(
    title = "Hero of the Cald", points = 5,
    description = "Complete the third Shadow Geyser",
    id = 0, badge = "000000",
    trigger = game_init() && geyser3()
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
achievement(
    title = "Fancy Footwear", points = 2,
    description = "Obtain Agadon's Boots.",
    id = 0, badge = "000000",
    trigger = game_init() && agadons_boots()
)
achievement(
    title = "Under the Sea", points = 2,
    description = "Obtain the Orothean Belt.",
    id = 0, badge = "000000",
    trigger = game_init() && orothean_belt()
)

// MiniGames //
achievement(
    title = "Brub Scrub", points = 10,
    description = "Score at least 50 points in Scrub the Brub.",
    id = 0, badge = "000000",
    trigger = game_init() && brub_start() && brub_end() && (number() >= 50) // use number() instead of brub_count() since we only need to check the total score at the end
)
achievement(
    title = "Brub Elite", points = 25,
    description = "Score at least 60 points in Scrub the Brub.",
    id = 0, badge = "000000",
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
    id = 0
)

achievement(
    title = "Aim for Tickets", points = 10,
    description = "Score at least 50 points in Aim for Animite",
    id = 0, badge = "000000",
    trigger = game_init() && archery_start() && archery_end() && (number() >= 50) // use number() instead of archery_count() since we only need to check the total score at the end
)
achievement(
    title = "Bullseye", points = 25,
    description = "Score at least 60 points in Aim for Animite",
    id = 0, badge = "000000",
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
    id = 0
)

achievement(
    title = "Speedy Tony", points = 10,
    description = "Beat Avoid the Agovos in under 7.7 seconds.", // 7.7*60 = 462
    id = 0, badge = "000000",
    trigger = game_init() && disable_when(repeated(462, !tony_frozen()), until=agovo_start()) && agovo_win()
)
achievement(
    title = "Flash Tony", points = 25,
    description = "Beat Avoid the Agovos in under 7.4 seconds.", // 7.4*60 = 444
    id = 0, badge = "000000",
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
    id = 0
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
    title = "After the Flame, Only Ashes Remain[m]", points = 2,
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
    title = "Skeleton Key[m]", points = 5,
    description = "Find the Channeled Gem using Ashgar's Key.",
    id = 0, badge = "000000",
    trigger = game_init() && get_treasure("ChanneledGem")
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
achievement(
    title = "So That's Where Soap Comes From[m]", points = 1,
    description = "Tell Eidon about Oflardt's stories.",
    id = 0, badge = "000000",
    trigger = game_init() && soap_gag()
)
achievement(
    title = "Bargainer[m]", points = 3,
    description = "Haggle the ferryman down to his lowest price.",
    id = 0, badge = "000000",
    trigger = game_init() && haggle()
)
achievement(
    title = "Gentleman Thief", points = 5,
    description = "Close the training equipment door after opening it.",
    id = 0, badge = "000000",
    trigger = game_init() && close_training_door()
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

// Beast of the Deep - Obtain Megathan.
// Beast of the Sky - Obtain Orothan F.
// Guardian of the Region - Obtain any Hyren.

// Highway to Heaven - Queen
// Hero of Naroom - Complete the first Shadow Geyser.
// Hero of the Underneath - Complete the second Shadow Geyser.
// Hero of Cald - Complete the third Shadow Geyser.
// Hero of Orothe - Complete the fourth Shadow Geyser.
// Hero of Arderial - Queen
// Winners Never Lose - Defeat Agram.
// Talk to every cat photo
// Craft first Hyren