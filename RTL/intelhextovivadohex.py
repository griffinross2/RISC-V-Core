def convert_intel_hex_to_vivado_hex(file_path):
    memsize = 16384
    hex_strings = []
    for i in range(memsize):
        hex_strings.append('00000000')

    with open(file_path, 'r') as file:
        for line in file:
            if line.startswith(':'):
                hex_data = line[1:].strip()

                record_type = int(hex_data[6:8], 16)
                if record_type != 0:
                    # Only process data records
                    continue
                
                address = int(hex_data[2:6], 16)
                hex_string = hex_data[8:16]
                hex_strings[address] = hex_string
    return '\n'.join(hex_strings)

if __name__ == "__main__":
    out = convert_intel_hex_to_vivado_hex('raminit.hex')
    with open('raminit.mem', 'w') as f:
        f.write(out)
    