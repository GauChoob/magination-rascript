import sys

def bank_address(raw_address):
    return 0x000100*(raw_address % 0x4000 + 0x4000) + 0x000001*(raw_address // 0x4000)

def process_file(file_in, file_out):
    with open(file_in, 'r') as f:
        lines = f.readlines()
        with open(file_out, 'w') as g:
            lines.sort(key = lambda line: int(line[2:8], 16))
            g.write('\n'.join([line.strip() for line in lines]))

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python sort_hex.py bank_address_pointers.txt bank_address_sorted.txt")
        sys.exit(1)
    
    file_in = sys.argv[1]
    file_out = sys.argv[2]
    process_file(file_in, file_out)