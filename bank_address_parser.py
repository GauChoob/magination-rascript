import sys

def bank_address(raw_address):
    return 0x000100*(raw_address % 0x4000 + 0x4000) + 0x000001*(raw_address // 0x4000)

def process_file(file_in, file_out):
    with open(file_in, 'r') as f:
        with open(file_out, 'w') as g:
            for line in f: # bank_address(0xXXXXXX)
                line = line.strip()
                raw = int(line[15:21], 16)
                pointer = bank_address(raw)
                g.write(f"0x{pointer:06X} = {line} // \n")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python hotspot_parser.py bank_address_raw.txt bank_address_pointers.txt")
        sys.exit(1)
    
    file_in = sys.argv[1]
    file_out = sys.argv[2]
    process_file(file_in, file_out)