import sys

pretty_names = [
    ('HS_NRMGLADE01', 'Naroom Grove'),
    ('HS_NRMGLADE02', 'Naroom Grove'),
    ('HS_NRMGLADE03', 'Vash Naroom'),
    ('HS_NRMGLADE04', 'Naroom Glade'),
    ('HS_NRMGLADE05', 'Naroom Glade'),
    ('HS_NRMGLADE06', 'Naroom Glade'),
    ('HS_NRMGLADE07', 'Naroom Glade'),
    ('HS_NRMGLADE08', 'Naroom Glade'),
    ('HS_NRMGLADE09', 'Naroom Geyser'),
    ('HS_NRMGLADE10', 'Naroom Cave'), # When geyser is defeated
    ('HS_NRMGLADE11', 'Naroom Forest'), # Boxxle to the forest
    ('HS_NRMGEYSER', 'Naroom Geyser'),
    ('HS_NRMFOREST06', 'Wence\'s House'),
    ('HS_NRMFOREST07', 'Wence\'s House'),
    ('HS_NRMFOREST', 'Naroom Forest'),
    ('HS_NRMLAKE04', 'Under the Seer\'s House'),
    ('HS_NRMLAKE05', 'Under the Seer\'s House'),
    ('HS_NRMLAKE06', 'Under the Seer\'s House'),
    ('HS_NRMLAKE', 'Seer\'s House'),
    ('HS_NRMRIVER03', 'Hacking! Developer\'s Secret Room'),
    ('HS_NRMRIVER', 'Naroom Grove'),
    ('HS_NRMVASH24', 'Aim for Animite'),
    ('HS_NRMVASH02_SCT', 'Avoid the Agovos'),
    ('HS_NRMVASH13', 'Training Grounds'),
    ('HS_NRMVASH', 'Vash Naroom'),
    ('HS_HDNROOM05', 'Avoid the Agovos'),
    ('HS_NRMTOWEAVE', 'Naroom Forest'),
    ('HS_UNDTOWN08', 'Brub House'),
    ('HS_UNDTOWN09', 'Scrub the Brub'),
    ('HS_UNDTOWN', 'Bogrom'),
    ('HS_UNDGEYSER', 'Underneath Geyser'),
    ('HS_UNDTUNNEL', 'Underneath Tunnels'),
    ('HS_HDNUNDTUN', 'Underneath Tunnels'),
    ('HS_UNDMUSHFARM', 'Gruk\'s Mushroom Farm'),
    ('HS_UNDCAVERN', 'Underneath Caverns'), # To Gruk's
    ('HS_THRONE', 'Core'),
    ('HS_CREGATE', 'Core Entrance'),
    ('HS_CLDLAVAPOOL', 'Ashyn'),
    ('HS_CLDLAVATOWN13', 'Valkan\'s House'),
    ('HS_CLDLAVATOWN14', 'Valkan\'s House'),
    ('HS_CLDLAVATOWN', 'Ashyn'),
    ('HS_CLDLAVATUBE13', 'West Lava Tubes'),
    ('HS_CLDLAVATUBE14', 'West Lava Tubes'),
    ('HS_CLDLAVATUBE15', 'West Lava Tubes'),
    ('HS_CLDLAVATUBE16', 'West Lava Tubes'),
    ('HS_CLDLAVATUBE17', 'West Lava Tubes'),
    ('HS_CLDLAVATUBE18', 'West Lava Tubes'),
    ('HS_CLDLAVATUBE', 'East Lava Tubes'), # 1-12
    ('HS_HDNLAVATUBE03', 'East Lava Tubes'), # Fireball
    ('HS_CLDLAVAVENT01B', 'Lava Vent Cavern'),
    ('HS_CLDLAVAVENT', 'Lava Vents'),
    ('HS_CLDVENTINT', 'Lava Vents'), # Blast urn rooms
    ('HS_CLDHYRENROOM', 'Volcano'),
    ('HS_FERRY', 'Ferry'),
    ('HS_CLDGEYSER', 'Cald Geyser'),
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
    ('HS_WVEPATHVALLEY04', 'Wheat Farm'),
    ('HS_WVEPATHVALLEY07', 'Underneath Tunnels'), # Tunnel entrance
    ('HS_WVEPATHVALLEY', 'Weave'),
    ('HS_WVECOREENTRANCE', 'Core Entrance'),
    ('HS_OROCITY', 'Oscent Mar'),
    ('HS_OROTUNNEL', 'Orothe Tunnels'), # Under the island
    ('HS_ORORUINS', 'Underwater Ruins'),
    ('HS_OROISLANDS', 'Orothe Island'),
    ('HS_ORODEEP', 'Path to Orothe Geyser'),
    ('HS_OROGEYSER', 'Orothe Geyser'),
    ('HS_OROCORAL', 'Orothe Corals'), # Dead end path where you get dumped from the Orothe Tunnels
    ('HS_OVERSURFACE01', 'Naroom Overworld'),
    ('HS_OVRSURFACE01B', 'Hyren\'s Glade'),
    ('HS_OVERSURFACE02', 'Underneath Overworld'),
    ('HS_OVERSURFACE03', 'Cald Overworld'),
    ('HS_OVERSURFACE04', 'Orothe Overworld'),
    ('HS_OVERSURFACE05', 'Arderial Overworld'),
    ('HS_ARDPALACE', 'Arderial Throne Room'),
    ('HS_ARDCITY01', 'Arderial Palace'),
    ('HS_ARDCITY02', 'Arderial Inn'),
    ('HS_ARDCITY03', 'Arderial Historian'),
    ('HS_ARDCITY04', 'Arderial Shop'),
    ('HS_ARDGARDEN01', 'Arderial Palace'),
    ('HS_ARDGARDEN02', 'Arderial Palace'),
    ('HS_ARDGARDEN03', 'Arderial Palace'),
    ('HS_ARDGARDEN04', 'Middle Clouds'), # Empty room
    ('HS_ARDGARDEN05', 'Arderial Inn'),
    ('HS_ARDGARDEN06', 'Arderial Historian'),
    ('HS_ARDGARDEN07', 'Arderial Historian'),
    ('HS_ARDGARDEN08', 'Arderial Shop'),
    ('HS_ARDGARDEN09', 'Arderial Historian'),
    ('HS_ARDCLOUDS01', 'Middle Clouds'),
    ('HS_ARDCLOUDS02', 'Middle Clouds'),
    ('HS_ARDCLOUDS03', 'Middle Clouds'),
    ('HS_ARDCLOUDS04', 'Middle Clouds'),
    ('HS_ARDCLOUDS05', 'Middle Clouds'),
    ('HS_ARDCLOUDS06', 'Middle Clouds'),
    ('HS_ARDCLOUDS07', 'North Clouds'),
    ('HS_ARDCLOUDS08', 'North Clouds'),
    ('HS_ARDCLOUDS09', 'North Clouds'),
    ('HS_ARDCLOUDS10', 'North Clouds'),
    ('HS_ARDCLOUDS11', 'North Clouds'),
    ('HS_ARDCLOUDS12', 'North Clouds'),
    ('HS_ARDCLOUDS13', 'North Clouds'),
    ('HS_ARDCLOUDS14', 'Palace Clouds'),
    ('HS_ARDCLOUDS15', 'South Clouds'),
    ('HS_ARDCLOUDS16', 'South Clouds'),
    ('HS_ARDGEYSER', 'Arderial Geyser'),
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
                map.append((address + 1, line))
                continue
            raise KeyError
            

    with open(file_out, 'w') as f:
        f.write('// Autogenerated from hotspot_parser.py\n')
        f.write('hotspot_lookup = {\n')
        f.write('    0x0000: "Splash Screen",\n')
        f.write('\n'.join([f'    0x{entry[0]:04X}: "{prettify_name(entry[1])}",   // {entry[1]}' for entry in map]))
        f.write('\n}')

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python hotspot_parser.py HS.s out.txt")
        sys.exit(1)
    
    file_in = sys.argv[1]
    file_out = sys.argv[2]
    hotspot_parser(file_in, file_out)