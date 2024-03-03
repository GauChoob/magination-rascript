import sys

pretty_names = [
    ('HS_NRMGLADE01', 'Naroom Grove'),
    ('HS_NRMGLADE02', 'Naroom Grove'),
    ('HS_NRMGLADE03', 'Vash Naroom Entrance'),
    ('HS_NRMGLADE09', 'Naroom Shadow Geyser Entrance'),
    ('HS_NRMGLADE10', 'Naroom Cave'), # When geyser is defeated
    ('HS_NRMGLADE11', 'Naroom Forest'), # Boxxle to the forest
    ('HS_NRMGLADE', 'Naroom Glade'),
    ('HS_NRMGEYSER', 'Naroom Shadow Geyser'),
    ('HS_NRMFOREST', 'Naroom Forest'),
    ('HS_NRMLAKE', 'Seer\'s House'),
    ('HS_NRMRIVER03', 'Developer\s Secret Room'),
    ('HS_NRMRIVER', 'Naroom Grove'),
    ('HS_NRMVASH24', 'Aim for Animite'),
    ('HS_NRMVASH02_SCT', 'Avoid the Agovos Lobby'),
    ('HS_NRMVASH', 'Vash Naroom'),
    ('HS_HDNROOM05', 'Avoid the Agovos'),
    ('HS_NRMTOWEAVE', 'Naroom Forest'),
    ('HS_UNDTOWN08', 'Brub House'),
    ('HS_UNDTOWN09', 'Scrub the Brub'),
    ('HS_UNDTOWN', 'Bogrom'),
    ('HS_UNDGEYSER', 'Underneath Shadow Geyser'),
    ('HS_UNDTUNNEL', 'Underneath Tunnels'),
    ('HS_HDNUNDTUN', 'Underneath Tunnels'),
    ('HS_UNDMUSHFARM', 'Gruk\'s Mushroom Farm'),
    ('HS_UNDCAVERN', 'Underneath Caverns'), # To Gruk's
    ('HS_THRONE', 'Arderial Palace'),
    ('HS_CREGATE', 'Core Entrance'),
    ('HS_CLDLAVAPOOL', 'Ashyn'),
    ('HS_CLDLAVATOWN', 'Ashyn'),
    ('HS_CLDLAVATUBE', 'Cald Lava Tubes'), # To the ferry
    ('HS_HDNLAVATUBE', 'Cald Lava Tubes'),
    ('HS_CLDLAVAVENT', 'Cald Lava Vents'), # Lava Arboll territory
    ('HS_CLDVENTINT', 'Cald Lava Vents'), # Underneath hyrens?
    ('HS_CLDHYRENROOM', 'Cald Volcano'),
    ('HS_FERRY', 'Ferry'),
    ('HS_CLDGEYSER', 'Cald Shadow Geyser'),
    ('HS_HDNROOM01', 'Gruk\'s Mushroom Farm'), # Gruk side
    ('HS_WARP07', 'Naroom-Underneath Shortcut'), # Gruk side
    ('HS_HLDMAZE23', 'Core Ringsmith'),
    ('HS_HLDMAZE24', 'Core Ringsmith\'s Playground'),
    ('HS_HLDMAZE25', 'Core Ringsmith\'s Playground'),
    ('HS_HLDMAZE26', 'Core Ringsmith\'s Playground'),
    ('HS_HLDMAZE', 'Shadowhold'),
    ('HS_HLDCELL', 'Shadowhold'),
    ('HS_HLDEXTERIOR', 'Shadowhold'),
    ('HS_HDNROOM02', 'Naroom Cave'), # Naroom side
    ('HS_WARP06', 'Naroom-Underneath Shortcut'), # Naroom side
    ('HS_HDNROOM03', 'Underneath Tunnels'), # Naroom Hyren path
    ('HS_HDNROOM04', 'Underneath Tunnels'), # Underneath Tunnel shortcut (Agadon's boots)
    ('HS_HDNFORT', 'Arderial Fort'), # Arderial-Naroom warp
    ('HS_FORT', 'Abandoned Fort'), # Underneath, Fort1-3
    ('HS_HDNLOAD', 'Start Screen'), # Headed towards Music player
    ('HS_HMTCAVE01', 'Tavel Gorge'),
    ('HS_HMTCAVE', 'Tavel Gorge Cave'), # 2-4
    ('HS_WVEGIASHUT', 'Gia\'s Farm'),
    ('HS_WVESHORTCUT', 'Naroom Cave'),
    ('HS_WVEPATHVALLEY', 'Weave'),
    ('HS_WVECOREENTRANCE', 'Core Entrance'),
    ('HS_OROCITY', 'Oscent Mar'),
    ('HS_OROTUNNEL', 'Orothe Tunnels'), # Under the island
    ('HS_ORORUINS', 'Underwater Ruins'),
    ('HS_OROISLANDS', 'Orothe Island'),
    ('HS_ORODEEP', 'Path to the Orothe Shadow Geyser'),
    ('HS_OROGEYSER', 'Orothe Shadow Geyser'),
    ('HS_OROCORAL', 'Orothe Corals'), # Dead end path where you get dumped from the Orothe Tunnels
    ('HS_OVERSURFACE01', 'Naroom Overworld'),
    ('HS_OVRSURFACE01B', 'Hyren\'s Glade'),
    ('HS_OVERSURFACE02', 'Underneath Overworld'),
    ('HS_OVERSURFACE03', 'Cald Overworld'),
    ('HS_OVERSURFACE04', 'Orothe Overworld'),
    ('HS_OVERSURFACE05', 'Arderial Overworld'),
    ('HS_ARDPALACE', 'Arderial Throne Room'),
    ('HS_ARDCITY', 'Arderial Palace'),
    ('HS_ARDGARDEN04', 'Arderial Clouds'), # Shadowhold rescued guys
    ('HS_ARDGARDEN', 'Arderial Hamlet'), # Multiple locations
    ('HS_ARDCLOUDS', 'Arderial Clouds'), # All the routes put together
    ('HS_ARDGEYSER', 'Arderial Shadow Geyser'),
]

def prettify_name(name):
    for option in pretty_names:
        if name.startswith(option[0]):
            return option[1]
    print(name)
    raise KeyError()

def hotspot_parser(file_in, file_out):
    address = 0x4000
    map = []

    with open(file_in, 'r') as f:
        for line in f:
            line = line.strip()

            if len(line) == 0:
                continue
            if line[0] == ';':
                continue
            header = line[0:2]
            if header == 'DB':
                address += 1
                continue
            if header == 'DW':
                address += 2
                continue
            if header == 'GL': # GLOBAL
                continue
            if header == 'EN': # END
                continue
            if header == 'TR':
                continue
            if header == 'HS':
                map.append((address, line))
                continue
            raise KeyError
            

    with open(file_out, 'w') as f:
        f.write('hotspot_reference = {\n')
        f.write('    0x0000: "Splash Screen",\n')
        f.write(',\n'.join([f'    0x{entry[0]:04X}: "{prettify_name(entry[1])} ({entry[1]})"' for entry in map]))
        f.write('\n}')

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python hotspot_parser.py HS.s out.txt")
        sys.exit(1)
    
    file_in = sys.argv[1]
    file_out = sys.argv[2]
    hotspot_parser(file_in, file_out)